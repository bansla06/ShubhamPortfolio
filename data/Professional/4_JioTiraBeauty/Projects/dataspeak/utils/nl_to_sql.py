import subprocess
import os
import json
import re
import pandas as pd
from utils.bq_client import FULL_TABLE_ID

FEEDBACK_CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "feedback_training.csv")


# ── Source routing prompt ──────────────────────────────────────────────────────

DETECT_SOURCE_PROMPT = """Classify which data source should answer this question. Choose from: "amplitude", "ga4", or "bigquery".

RULE 1 — CLICKSTREAM / BEHAVIORAL → Amplitude
Use Amplitude for: sessions, active users, DAU/WAU/MAU, app opens, installs, event counts, funnels, user actions, button clicks, screen views, feature usage, user journeys, retention, engagement, in-app behavior.

RULE 2 — TRANSACTIONAL → BigQuery
Use BigQuery for: orders, revenue, GMV, AOV, cancellations, returns, refunds, brands, products, delivery, payment, coupons, order lifecycle.

RULE 3 — MARKETING / TRAFFIC ATTRIBUTION → GA4
Use GA4 for: web/app traffic sources, UTM campaigns, acquisition channels, referral sources, landing pages, bounce rate, marketing attribution.

Reply with exactly one word: "amplitude", "ga4", or "bigquery"

Question: {question}"""


# ── GA4 prompt template ────────────────────────────────────────────────────────

GA4_SCHEMA = """
AVAILABLE GA4 DIMENSIONS (use exact names):
date, dateHour, week, month, year,
sessionSource, sessionMedium, sessionCampaign, sessionDefaultChannelGroup,
firstUserSource, firstUserMedium, firstUserCampaign, firstUserDefaultChannelGroup,
deviceCategory, operatingSystem, browser, platform, mobileDeviceBranding,
country, region, city,
pagePath, pageTitle, landingPage, exitPage,
eventName, newVsReturning, userAgeBracket, userGender,
itemName, itemBrand, itemCategory, itemListName

AVAILABLE GA4 METRICS (use exact names):
sessions, totalUsers, newUsers, activeUsers, returningUsers,
screenPageViews, screenPageViewsPerSession,
eventCount, eventsPerSession,
engagementRate, bounceRate, averageSessionDuration, sessionsPerUser,
conversions, totalRevenue, dauPerMau, dauPerWau, wauPerMau

DATE RANGE FORMATS:
- Relative: "today", "yesterday", "NdaysAgo" (e.g. "7daysAgo", "30daysAgo")
- Absolute: "YYYY-MM-DD"
"""

GA4_QUERY_PROMPT_TEMPLATE = """You are a Google Analytics 4 expert. Convert the user's question into a GA4 report query.

{ga4_schema}

Rules:
- Choose only dimensions and metrics relevant to the question
- Keep dimensions to 3 or fewer unless specifically needed
- Default date range is last 30 days if not specified
- Return ONLY a valid JSON object with keys: dimensions (list), metrics (list), start_date (string), end_date (string)
- No explanation, no markdown, just the JSON

Question: {question}"""


# ── Amplitude prompt template ──────────────────────────────────────────────────

AMPLITUDE_QUERY_PROMPT_TEMPLATE = """You are an Amplitude analytics expert. Convert the user's question into an Amplitude API query.

QUERY TYPES:
1. "segmentation" — for questions about a single event trend, counts, or uniques over time
2. "funnel" — for questions about conversion between multiple sequential steps/events

METRICS (segmentation only):
- "uniques" — unique users (default)
- "totals" — total event occurrences
- "pct_dau" — % of daily active users

INTERVALS (segmentation only): 1=daily (default), 7=weekly, 30=monthly
DATE FORMATS: "YYYY-MM-DD"

Rules:
- Default date range is last 30 days if not specified
- For funnel queries, list events in the order described
- group_by is optional — null if not needed
- Return ONLY a valid JSON object, no explanation, no markdown

For SEGMENTATION return:
{{"query_type": "segmentation", "event_type": "<event>", "start_date": "YYYY-MM-DD", "end_date": "YYYY-MM-DD", "metric": "uniques", "interval": 1, "group_by": null}}

For FUNNEL return:
{{"query_type": "funnel", "events": ["<event1>", "<event2>", "..."], "start_date": "YYYY-MM-DD", "end_date": "YYYY-MM-DD"}}

Question: {question}"""


# ── SQL generation prompt ──────────────────────────────────────────────────────

SQL_PROMPT_TEMPLATE = """You are a BigQuery SQL expert. Convert the user's plain English question into a valid BigQuery SQL query.

Primary table: {table}

Rules:
- Return ONLY the SQL query, no explanation, no markdown code blocks
- Use standard BigQuery SQL syntax
- Limit results to 1000 rows unless the user asks for aggregations
- Use backticks for table names

Data Dictionary:
{data_dictionary}

{feedback_context}

Question: {question}"""

SUMMARY_PROMPT_TEMPLATE = """The user asked: '{question}'

Query used:
{sql}

Data preview (first 5 rows):
{df_preview}

Write a short 2-3 sentence plain English summary of what the data shows.
Rules:
- Plain text only. No markdown, no bullet points, no bold, no italics.
- Just clean prose sentences."""


# ── Reasoning & synthesis prompts (multi-source analysis) ─────────────────────

REASONING_PROMPT_TEMPLATE = """You are a senior data analytics expert. A business problem has been described. Your job is to build an investigation plan across all available data sources.

Available data sources:
1. "amplitude" — in-app user behavior: events, funnels, sessions, DAU/WAU/MAU, user journeys, feature usage, retention
2. "ga4" — web/app traffic: acquisition channels, UTM campaigns, landing pages, device breakdown, bounce rate
3. "bigquery" — transactional data: orders, revenue, AOV, cancellations, returns, payment methods, brands, products

Business problem: {question}

Reason through which data sources are relevant and what specific angle each one covers. Then return a list of 3 to 5 targeted sub-questions — one per data source query — that together would give a complete picture.

Rules:
- Each sub-question must be self-contained and answerable by that single source
- Cover different angles — avoid redundancy
- Return ONLY a valid JSON array, no explanation, no markdown

Format:
[
  {{"source": "amplitude", "question": "..."}},
  {{"source": "bigquery",  "question": "..."}},
  {{"source": "ga4",       "question": "..."}}
]"""

SYNTHESIS_PROMPT_TEMPLATE = """You are a senior data analyst. A business problem was investigated across multiple data sources and the findings are below.

Business problem: {question}

Findings:
{findings_text}

Synthesize these findings into a clear, connected analysis:
- What patterns emerge across the data sources?
- What is the most likely root cause or key driver?
- What is the single most important thing to act on?

Write 4-6 plain English sentences. No markdown, no bullet points, no bold, no headers. Just clear analytical prose."""


# ── Claude CLI call ────────────────────────────────────────────────────────────

def _call_claude(prompt: str) -> str:
    result = subprocess.run(
        ["claude", "--print", "--model", "claude-sonnet-4-6"],
        input=prompt,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    return result.stdout.strip()


def _strip_markdown(text: str) -> str:
    text = re.sub(r"^```[a-zA-Z]*\n?", "", text.strip())
    text = re.sub(r"\n?```$", "", text.strip())
    return text.strip()


# ── Feedback loop ──────────────────────────────────────────────────────────────

def load_feedback_context() -> str:
    if not os.path.exists(FEEDBACK_CSV_PATH):
        return ""
    df = pd.read_csv(FEEDBACK_CSV_PATH)
    if df.empty:
        return ""
    lines = ["Past corrections (learn from these mistakes):"]
    for i, row in enumerate(df.tail(10).itertuples(), 1):
        lines.append(f"\nCorrection {i}:")
        lines.append(f"  Question: {row.user_question}")
        if pd.notna(row.what_was_wrong) and str(row.what_was_wrong).strip():
            lines.append(f"  What was wrong: {row.what_was_wrong}")
        if pd.notna(row.correct_sql) and str(row.correct_sql).strip():
            lines.append(f"  Correct SQL: {row.correct_sql}")
    return "\n".join(lines)


def save_feedback(user_question: str, wrong_sql: str, what_was_wrong: str = "",
                  correct_sql: str = "", correct_answer: str = "") -> None:
    from datetime import datetime
    row = {
        "timestamp":      datetime.now().isoformat(),
        "user_question":  user_question,
        "what_was_wrong": what_was_wrong,
        "wrong_sql":      wrong_sql,
        "correct_answer": correct_answer,
        "correct_sql":    correct_sql,
    }
    if os.path.exists(FEEDBACK_CSV_PATH):
        df = pd.read_csv(FEEDBACK_CSV_PATH)
    else:
        df = pd.DataFrame(columns=list(row.keys()))
    df = pd.concat([df, pd.DataFrame([row])], ignore_index=True)
    df.to_csv(FEEDBACK_CSV_PATH, index=False)


# ── Core pipeline functions ────────────────────────────────────────────────────

def generate_sql(question: str, data_dictionary: str) -> str:
    feedback_context = load_feedback_context()
    prompt = SQL_PROMPT_TEMPLATE.format(
        table=FULL_TABLE_ID,
        data_dictionary=data_dictionary,
        feedback_context=feedback_context,
        question=question,
    )
    return _strip_markdown(_call_claude(prompt))


def summarize_results(question: str, sql: str, df_preview: str) -> str:
    prompt = SUMMARY_PROMPT_TEMPLATE.format(
        question=question, sql=sql, df_preview=df_preview
    )
    result = _call_claude(prompt)
    result = re.sub(r'~~(.+?)~~', r'\1', result)
    result = re.sub(r'\*\*(.+?)\*\*', r'\1', result)
    result = re.sub(r'\*(.+?)\*', r'\1', result)
    return result


def detect_data_source(question: str) -> str:
    prompt = DETECT_SOURCE_PROMPT.format(question=question)
    result = _call_claude(prompt).strip().lower()
    if "amplitude" in result:
        return "amplitude"
    if "ga4" in result:
        return "ga4"
    return "bigquery"


def generate_ga4_query(question: str) -> dict:
    prompt = GA4_QUERY_PROMPT_TEMPLATE.format(ga4_schema=GA4_SCHEMA, question=question)
    return json.loads(_strip_markdown(_call_claude(prompt)))


def generate_amplitude_query(question: str) -> dict:
    prompt = AMPLITUDE_QUERY_PROMPT_TEMPLATE.format(question=question)
    return json.loads(_strip_markdown(_call_claude(prompt)))


def reason_about_question(question: str) -> list:
    prompt = REASONING_PROMPT_TEMPLATE.format(question=question)
    return json.loads(_strip_markdown(_call_claude(prompt)))


def synthesize_findings(question: str, findings: list) -> str:
    lines = []
    for f in findings:
        lines.append(f"[{f['source'].upper()}] Sub-question: {f['question']}")
        if f.get("error"):
            lines.append(f"Result: Could not retrieve data — {f['error']}")
        else:
            lines.append(f"Data:\n{f.get('data_preview') or f.get('summary') or 'No data.'}")
        lines.append("")
    prompt = SYNTHESIS_PROMPT_TEMPLATE.format(
        question=question, findings_text="\n".join(lines)
    )
    return _call_claude(prompt)


def correct_grammar(text: str) -> str:
    if not text.strip():
        return text
    prompt = (
        "Correct the grammar, spelling, and phrasing of the following text. "
        "Keep the meaning exactly the same. Return only the corrected text, nothing else.\n\n"
        f"{text.strip()}"
    )
    return _call_claude(prompt)
