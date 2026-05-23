# DataSpeak

**Ask your data a question. Get an answer. No SQL needed.**

DataSpeak is an AI-powered natural language interface that lets anyone — analyst, manager, or executive — query a live data warehouse by simply typing a plain English question.

---

## The Problem

Business teams constantly depend on data analysts to pull numbers. Every question becomes a ticket. Every ticket adds delay. Decisions slow down, not because the data isn't there — but because accessing it requires SQL expertise most people don't have.

## The Solution

DataSpeak removes that bottleneck. Type a question. Get live data and a plain English summary — instantly.

---

## How It Works

```
User types a plain English question
             │
             ▼
     Natural Language Processing
     (Claude LLM via CLI — no API key needed)
             │
             ▼
         SQL Generated
             │
             ▼
     Query runs on BigQuery
             │
             ▼
     Results summarized by Claude
             │
             ▼
  Summary + Data Table shown in UI
             │
             ▼
   Optional Feedback (thumbs up/down)
             │
             └── Stored → Injected into future prompts
                          (self-improving feedback loop)
```

---

## Features

- **Plain English to SQL** — Claude LLM translates natural language into accurate SQL queries
- **Live data** — queries run directly against BigQuery; results are always fresh
- **Plain English summary** — Claude explains what the data says in 2–3 sentences
- **Self-improving feedback loop** — users can flag bad results; corrections are automatically fed back into future query generation
- **Evaluation module** — separate tool to build a ground-truth cache of known-correct queries, enabling measurable accuracy tracking over time
- **No API key required** — uses Claude Code OAuth authentication

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend UI | Streamlit + custom React component |
| LLM | Claude (Anthropic) via CLI subprocess |
| Data Warehouse | Google BigQuery |
| Analytics Connectors | Google Analytics 4, Amplitude |
| Language | Python 3.10 |

---

## Architecture

```
dataspeak/
├── app.py                    # Main Streamlit app — thin orchestrator
├── requirements.txt
│
├── utils/
│   ├── nl_to_sql.py          # NL → SQL generation + result summarization (Claude)
│   ├── bq_client.py          # BigQuery connection + query execution
│   └── __init__.py
│
├── frontend/
│   └── src/
│       └── components/
│           ├── DataTable.jsx  # Results table component
│           └── SqlBlock.jsx   # SQL display component
│
├── connectors/
│   ├── ga4/                  # Google Analytics 4 connector
│   └── amplitude/            # Amplitude connector
│
├── evaluation_model/         # Standalone accuracy evaluation tool (port 8502)
│   ├── eval_app.py
│   └── utils/
│       ├── bq_client.py      # BQ CRUD for evaluation cache
│       └── query_runner.py   # prepare_result() + store_result()
│
└── data/
    ├── training_data/        # Curated NL→SQL examples for prompt injection
    └── feedback_training.csv # User corrections (auto-created at runtime)
```

---

## Key Design Decisions

**1. Claude CLI as subprocess**
Instead of calling the Anthropic API directly, DataSpeak uses the `claude` CLI as a subprocess. This means no API key management — it runs on the developer's existing Claude Code OAuth session.

**2. Feedback loop via CSV injection**
Every time a user marks a result as wrong and provides a correction, it's saved to a CSV. The last 10 corrections are automatically injected into the system prompt on every future query — giving the model memory of past mistakes without any fine-tuning.

**3. Data dictionary in every prompt**
A structured data dictionary (field names, types, descriptions, and business rules) is loaded once at startup and injected into every SQL generation prompt. This grounds Claude's SQL in the actual shape of the data.

**4. Evaluation model as a separate process**
The evaluation module runs on a separate port and has no shared code with the main app. It maintains a ground-truth cache of verified SQL queries and results in BigQuery — enabling future automated accuracy scoring.

---

## Evaluation Model

The evaluation module is a standalone Streamlit app (port 8502) that lets you build a library of known-correct queries.

**3-step flow:**
1. **Run** — execute the SQL and preview results
2. **Preview** — inspect every field that will be stored (query, description, result, metadata)
3. **Store** — commit the verified record to the evaluation cache in BigQuery

This cache becomes the ground truth for measuring how accurately DataSpeak's NL-to-SQL pipeline performs over time.

---

## Setup

```bash
# Clone the repo
git clone https://github.com/yourusername/dataspeak.git
cd dataspeak

# Install dependencies
pip install -r requirements.txt

# Add your BigQuery credentials (service account JSON) — see .env.example
# Add your data dictionary to data/

# Run the main app
streamlit run app.py

# Run the evaluation module (optional, separate terminal)
python3 -m streamlit run evaluation_model/eval_app.py --server.port 8502
```

---

## Environment Variables

Copy `.env.example` to `.env` and fill in your values. Never commit `.env` to version control.

```
BQ_CREDENTIALS_PATH=path/to/your/service_account.json
BQ_PROJECT_ID=your-gcp-project
BQ_DATASET=your-dataset
```

---

## Status

- [x] NL to SQL via Claude LLM
- [x] Live BigQuery query execution
- [x] Plain English result summarization
- [x] User feedback collection
- [x] Self-improving feedback loop (last 10 corrections injected into prompts)
- [x] Evaluation model with ground-truth cache
- [ ] Query timeout handling
- [ ] Ambiguous question detection (ask clarifying question)
- [ ] Date range UI controls
- [ ] Automated accuracy scoring against evaluation cache

---

## Author

Shubham Bansla
