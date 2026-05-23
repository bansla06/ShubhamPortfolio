# DataSpeak — Profile & Resume Copy

---

## Resume (1–2 liner)

> Built **DataSpeak**, an AI-powered natural language to SQL tool using Claude LLM and Google BigQuery, enabling non-technical business users to query live data through plain English — with a self-improving feedback loop that gets smarter with every correction.

---

## LinkedIn / Naukri — Project Section

**DataSpeak | Personal Project | Python, Claude LLM, BigQuery, Streamlit**

**Problem:**
Business teams lose hours every week waiting on data analysts to pull numbers. Every question becomes a ticket, decisions stall, and the bottleneck isn't the data — it's access to it.

**Solution:**
DataSpeak lets anyone type a question in plain English and get a live data answer instantly — no SQL knowledge required. Under the hood, Claude LLM translates the question into an accurate SQL query, runs it against a live data warehouse, and returns both the data and a plain English summary of what it means.

Key highlights:
- NL-to-SQL pipeline powered by Claude (Anthropic) with zero API key overhead using OAuth-based CLI auth
- Self-improving feedback loop — user corrections are automatically injected into future prompts, making the system more accurate over time without any model fine-tuning
- Built a separate evaluation module that maintains a ground-truth cache of verified queries in BigQuery, enabling measurable accuracy tracking
- Integrated connectors for Google Analytics 4 and Amplitude alongside the core data warehouse

---

## Naukri — Project Description (shorter format)

**DataSpeak** — AI-powered plain English to SQL interface

Built a production-ready tool that converts natural language questions into SQL queries using Claude LLM, executes them on Google BigQuery, and returns results with a plain English summary. Designed for non-technical business users. Features a self-improving feedback mechanism — corrections made by users are stored and automatically fed back into the model's context on future queries. Includes a standalone evaluation module for tracking SQL generation accuracy against a curated ground-truth cache.

**Tech:** Python, Streamlit, Claude LLM (Anthropic), Google BigQuery, React, GA4, Amplitude
