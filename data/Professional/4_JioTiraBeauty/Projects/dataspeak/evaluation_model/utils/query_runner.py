import json
import re
import subprocess
import uuid
from datetime import datetime, timezone

import pandas as pd

from evaluation_model.utils.bq_client import run_query, insert_row, ensure_table_exists


def _call_claude(prompt: str) -> str:
    result = subprocess.run(
        ["claude", "--print", "--model", "claude-sonnet-4-6"],
        input=prompt, capture_output=True, text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr.strip())
    return result.stdout.strip()


def _strip_markdown(text: str) -> str:
    text = re.sub(r"^```[a-zA-Z]*\n?", "", text.strip())
    text = re.sub(r"\n?```$", "", text.strip())
    return text.strip()


def extract_comments_from_sql(sql: str) -> str:
    lines = []
    for block in re.findall(r"/\*(.*?)\*/", sql, re.DOTALL):
        cleaned = " ".join(block.strip().splitlines()).strip()
        if cleaned:
            lines.append(cleaned)
    for line in sql.splitlines():
        line = line.strip()
        if line.startswith("--"):
            comment = line.lstrip("-").strip()
            if comment:
                lines.append(comment)
    return " | ".join(lines) if lines else ""


def correct_grammar(raw_text: str) -> str:
    if not raw_text.strip():
        return raw_text
    prompt = (
        "Correct the grammar and rewrite the following text clearly and professionally. "
        "Keep the meaning exactly the same. Return only the corrected text, nothing else.\n\n"
        f"{raw_text}"
    )
    result = _call_claude(prompt)
    return result if result else raw_text


def suggest_description(sql: str, existing_descriptions: list = None) -> str:
    examples_block = ""
    if existing_descriptions:
        examples = "\n".join(f"- {d}" for d in existing_descriptions[:8] if d and d.strip())
        if examples:
            examples_block = f"\n\nExisting descriptions for style reference:\n{examples}"
    comment_text = extract_comments_from_sql(sql)
    prompt = (
        "Read this BigQuery SQL query and write a clear, concise business description of what it does.\n"
        "Focus on: what business metrics it calculates, what filters are applied, and what the output represents.\n"
        "Write 1-2 sentences in plain business English. Do not mention SQL syntax or raw column names.\n"
        "Return only the description, nothing else.\n\n"
        f"SQL:\n{sql}{examples_block}"
    )
    if comment_text:
        prompt += f"\n\nHints from SQL comments: {comment_text}"
    result = _call_claude(prompt)
    return result if result else comment_text


def generate_short_description(sql: str) -> str:
    prompt = (
        "Read this BigQuery SQL and write a very short title (4-6 words max) that names the metric(s) it calculates.\n"
        "Return only the title, nothing else.\n\n"
        f"SQL:\n{sql}"
    )
    return _call_claude(prompt) or ""


def extract_metrics(sql: str) -> str:
    prompt = (
        "Read this BigQuery SQL query carefully and identify every business metric it calculates.\n"
        "Use short, clear business names. Return ONLY a comma-separated list, nothing else.\n\n"
        f"SQL:\n{sql}"
    )
    return _call_claude(prompt) or "Unknown"


def execute_query(sql: str) -> tuple:
    rows_iter = run_query(sql)
    df = rows_iter.to_dataframe()
    result_json = df.to_json(orient="records", date_format="iso", default_handler=str)
    return df, result_json, len(df)


def prepare_result(sql: str, raw_description: str) -> dict:
    ensure_table_exists()

    rows_iter = run_query(sql)
    df = rows_iter.to_dataframe()

    comment_text = extract_comments_from_sql(sql)
    manual = raw_description.strip()
    description_source = f"{manual} | {comment_text}" if manual and comment_text else (manual or comment_text)

    query_description = correct_grammar(description_source) if description_source else ""
    metric_names      = extract_metrics(sql)
    result_json       = df.to_json(orient="records", date_format="iso", default_handler=str)

    return {
        "id":                str(uuid.uuid4()),
        "timestamp":         datetime.now(timezone.utc).isoformat(),
        "query":             sql,
        "query_description": query_description,
        "raw_description":   description_source,
        "dataset_name":      "configured-dataset",
        "metric_names":      metric_names,
        "query_result":      result_json,
        "row_count":         len(df),
        "df":                df,
    }


def store_result(prepared: dict) -> str:
    bq_row = {k: v for k, v in prepared.items() if k != "df"}
    insert_row(bq_row)
    return prepared["id"]
