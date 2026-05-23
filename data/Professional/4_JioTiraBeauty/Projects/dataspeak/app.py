import streamlit as st
import os
from utils.bq_client import run_query, FULL_TABLE_ID
from utils.nl_to_sql import (
    generate_sql, summarize_results, save_feedback,
    detect_data_source, generate_ga4_query, generate_amplitude_query,
)

st.set_page_config(page_title="DataSpeak", page_icon="🗣", layout="wide")

# ── Load data dictionary once ──────────────────────────────────────────────────
@st.cache_data
def load_data_dictionary():
    path = os.path.join(os.path.dirname(__file__), "data", "data_dictionary.txt")
    if os.path.exists(path):
        with open(path) as f:
            return f.read()
    return ""

data_dictionary = load_data_dictionary()

# ── Session state ──────────────────────────────────────────────────────────────
for key, default in [
    ("result", None), ("last_question", ""), ("error", None),
    ("feedback_submitted", False), ("show_feedback_form", False),
]:
    if key not in st.session_state:
        st.session_state[key] = default

# ── Search bar ─────────────────────────────────────────────────────────────────
st.title("🗣 DataSpeak")
st.caption("Ask your data a question in plain English.")
question = st.text_input("Ask a question", placeholder="e.g. How many orders were placed today?")

# ── Clear state when question is deleted ───────────────────────────────────────
if not question:
    st.session_state.result        = None
    st.session_state.last_question = ""
    st.session_state.error         = None

# ── Run pipeline on new question ───────────────────────────────────────────────
elif question != st.session_state.last_question:
    st.session_state.last_question      = question
    st.session_state.result             = None
    st.session_state.error              = None
    st.session_state.feedback_submitted = False
    st.session_state.show_feedback_form = False

    with st.spinner("Understanding your question..."):
        try:
            data_source = detect_data_source(question)
        except Exception:
            data_source = "bigquery"

    # ── Amplitude branch ───────────────────────────────────────────────────────
    if data_source == "amplitude":
        with st.spinner("Building Amplitude query..."):
            try:
                amp_params = generate_amplitude_query(question)
            except Exception as e:
                st.session_state.error = f"Amplitude query generation failed: {e}"
                amp_params = None

        if amp_params:
            from connectors.amplitude.amplitude_client import run_amplitude_query
            with st.spinner("Fetching data from Amplitude..."):
                try:
                    df = run_amplitude_query(amp_params)
                except Exception as e:
                    st.session_state.error = f"Amplitude error: {e}"
                    df = None

            if df is not None and not df.empty:
                amp_desc = f"Event: {amp_params.get('event_type', '')} | Date: {amp_params['start_date']} → {amp_params['end_date']}"
                with st.spinner("Summarizing results..."):
                    try:
                        summary = summarize_results(question, amp_desc, df.head(5).to_string())
                    except Exception:
                        summary = ""
                st.session_state.result = {
                    "question": question, "sql": amp_desc, "df": df,
                    "summary": summary, "data_source": "amplitude", "amp_params": amp_params,
                }
            elif df is not None and df.empty:
                st.session_state.error = "The Amplitude query returned no results."

    # ── GA4 branch ─────────────────────────────────────────────────────────────
    elif data_source == "ga4":
        with st.spinner("Building GA4 query..."):
            try:
                ga4_params = generate_ga4_query(question)
            except Exception as e:
                st.session_state.error = f"GA4 query generation failed: {e}"
                ga4_params = None

        if ga4_params:
            from connectors.ga4.ga_client import run_ga_report
            with st.spinner("Fetching data from Google Analytics..."):
                try:
                    df = run_ga_report(**ga4_params)
                except Exception as e:
                    st.session_state.error = f"GA4 error: {e}"
                    df = None

            if df is not None and not df.empty:
                ga4_desc = (
                    f"Dimensions: {', '.join(ga4_params['dimensions'])} | "
                    f"Metrics: {', '.join(ga4_params['metrics'])} | "
                    f"Date: {ga4_params['start_date']} → {ga4_params['end_date']}"
                )
                with st.spinner("Summarizing results..."):
                    try:
                        summary = summarize_results(question, ga4_desc, df.head(5).to_string())
                    except Exception:
                        summary = ""
                st.session_state.result = {
                    "question": question, "sql": ga4_desc, "df": df,
                    "summary": summary, "data_source": "ga4", "ga4_params": ga4_params,
                }
            elif df is not None and df.empty:
                st.session_state.error = "The GA4 query returned no results."

    # ── BigQuery branch ────────────────────────────────────────────────────────
    else:
        with st.spinner("Generating SQL..."):
            try:
                sql = generate_sql(question, data_dictionary)
            except Exception as e:
                st.session_state.error = f"SQL generation failed: {e}"
                sql = None

        if sql:
            with st.spinner("Running query..."):
                try:
                    df = run_query(sql).to_dataframe()
                except Exception as e:
                    st.session_state.error = f"Query error: {e}"
                    df = None

            if df is not None and not df.empty:
                with st.spinner("Summarizing results..."):
                    try:
                        summary = summarize_results(question, sql, df.head(5).to_string())
                    except Exception:
                        summary = ""
                st.session_state.result = {
                    "question": question, "sql": sql, "df": df,
                    "summary": summary, "data_source": "bigquery",
                }
            elif df is not None and df.empty:
                st.session_state.error = "The query returned no results."

# ── Display error ──────────────────────────────────────────────────────────────
if st.session_state.error:
    st.error(st.session_state.error)

# ── Display results ────────────────────────────────────────────────────────────
if st.session_state.result:
    r = st.session_state.result

    if r["summary"]:
        st.info(r["summary"])

    st.markdown(f"<p style='color:#555; font-size:0.88rem'>{len(r['df']):,} rows returned</p>", unsafe_allow_html=True)
    st.dataframe(r["df"], use_container_width=True)

    source = r.get("data_source", "bigquery")
    if source == "amplitude":
        with st.expander("View Amplitude query parameters"):
            st.json(r.get("amp_params", {}))
    elif source == "ga4":
        with st.expander("View GA4 query parameters"):
            st.json(r.get("ga4_params", {}))
    else:
        with st.expander("View generated SQL"):
            st.code(r["sql"], language="sql")

    # ── Feedback ───────────────────────────────────────────────────────────────
    if st.session_state.feedback_submitted:
        st.success("Feedback saved — the model will learn from this.")
    else:
        c1, c2, _ = st.columns([1, 1, 4])
        with c1:
            if st.button("👍  Correct"):
                st.session_state.feedback_submitted = True
                st.rerun()
        with c2:
            if st.button("👎  Wrong"):
                st.session_state.show_feedback_form = True

    if st.session_state.show_feedback_form and not st.session_state.feedback_submitted:
        with st.form("feedback_form"):
            what_was_wrong = st.text_area("What was wrong?", height=80)
            correct_sql    = st.text_area("Correct SQL (optional)", height=150)
            if st.form_submit_button("Submit Feedback", type="primary"):
                save_feedback(
                    user_question=r["question"],
                    wrong_sql=r["sql"],
                    what_was_wrong=what_was_wrong,
                    correct_sql=correct_sql,
                )
                st.session_state.feedback_submitted = True
                st.session_state.show_feedback_form = False
                st.rerun()
