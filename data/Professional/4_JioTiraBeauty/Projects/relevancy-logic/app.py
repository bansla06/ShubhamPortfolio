import pandas as pd
import streamlit as st

from config.settings import settings
from config.weights import Weights
from utils.post_processing import (
    apply_anti_clustering,
    apply_brand_boost,
    apply_combo_penalty,
    apply_item_overrides,
    finalize_ranking,
    load_brand_boost_from_sheet,
    remove_free_l1,
)
from utils.scoring import apply_social_nudge, compute_scores

st.set_page_config(page_title="Relevancy Logic", page_icon="📊", layout="wide")

# ── Sidebar: Weight Configuration ──────────────────────────────────────────────
st.sidebar.title("Scoring Weights")
st.sidebar.caption("Adjust each signal's contribution to the final rank.")

weights = Weights(
    aging=st.sidebar.slider("Product Aging", 0.0, 2.0, 0.66, step=0.01),
    inventory=st.sidebar.slider("Inventory", 0.0, 2.0, 1.00, step=0.01),
    last_15_days_revenue_inv_track=st.sidebar.slider(
        "Revenue 15D — Inv Track", 0.0, 3.0, 0.75, step=0.01
    ),
    last_15_days_revenue_main_track=st.sidebar.slider(
        "Revenue 15D — Main Track", 0.0, 3.0, 1.50, step=0.01
    ),
    older_revenue=st.sidebar.slider("Revenue 15–75D Ago", 0.0, 2.0, 0.00, step=0.01),
    last_15_days_views=st.sidebar.slider("Views 15D", 0.0, 2.0, 0.00, step=0.01),
    older_views=st.sidebar.slider("Views 15–75D Ago", 0.0, 2.0, 0.00, step=0.01),
    last_15_days_sales=st.sidebar.slider("Sales 15D", 0.0, 2.0, 0.25, step=0.01),
    older_sales=st.sidebar.slider("Sales 15–75D Ago", 0.0, 2.0, 0.25, step=0.01),
    rpv=st.sidebar.slider("RPV (Revenue Per View)", 0.0, 2.0, 0.60, step=0.01),
    spv=st.sidebar.slider("SPV (Sales Per View)", 0.0, 2.0, 0.40, step=0.01),
)

st.sidebar.divider()

# ── Sidebar: Post-Processing ────────────────────────────────────────────────────
st.sidebar.subheader("Post-Processing")

combo_price_threshold = st.sidebar.number_input(
    "COMBO penalty — max price (₹)", value=500, step=50
)
combo_penalty_pct = st.sidebar.slider("COMBO penalty %", 0.0, 1.0, 0.40, step=0.05)

st.sidebar.divider()
st.sidebar.subheader("Brand Boosting")

boost_source = st.sidebar.radio("Load brands from", ["Manual input", "Google Sheet"])
if boost_source == "Manual input":
    raw_input = st.sidebar.text_area("Brand names (one per line)")
    brands_to_boost = [b.strip() for b in raw_input.strip().splitlines() if b.strip()]
else:
    sheet_url = st.sidebar.text_input("Google Sheet URL", value=settings.brand_boost_sheet_url)
    brands_to_boost = []
    if sheet_url:
        try:
            brands_to_boost = load_brand_boost_from_sheet(sheet_url)
            st.sidebar.success(f"{len(brands_to_boost)} brand(s): {', '.join(brands_to_boost)}")
        except Exception as exc:
            st.sidebar.error(f"Could not load sheet: {exc}")

boost_pct = st.sidebar.slider("Boost percentage", 0.0, 1.0, 0.60, step=0.05)

# ── Session State ───────────────────────────────────────────────────────────────
for key, default in [("raw_df", None), ("result_df", None), ("error", None)]:
    if key not in st.session_state:
        st.session_state[key] = default

# ── Main ────────────────────────────────────────────────────────────────────────
st.title("Relevancy Logic")
st.caption("Product ranking pipeline — configure weights, run scoring, export results.")

tab_upload, tab_bq = st.tabs(["Upload CSV", "Pull from BigQuery"])

with tab_upload:
    uploaded_file = st.file_uploader("Upload raw data CSV", type="csv")
    if uploaded_file:
        st.session_state.raw_df = pd.read_csv(uploaded_file, low_memory=False).fillna(0)
        st.success(f"Loaded {len(st.session_state.raw_df):,} rows.")

with tab_bq:
    st.info("Requires BigQuery credentials configured in `.env`.")
    if st.button("Pull from BigQuery"):
        with st.spinner("Querying BigQuery..."):
            try:
                from utils.bq_client import fetch_raw_data
                st.session_state.raw_df = fetch_raw_data()
                st.success(f"Loaded {len(st.session_state.raw_df):,} rows from BigQuery.")
            except Exception as exc:
                st.error(f"BigQuery error: {exc}")

# ── Item Overrides ──────────────────────────────────────────────────────────────
overrides_file = st.file_uploader(
    "Item overrides CSV (optional)",
    type="csv",
    help="Columns: item_code, override_type (boost/penalty), adjustment_pct",
)
overrides_df = (
    pd.read_csv(overrides_file)
    if overrides_file
    else pd.DataFrame(columns=["item_code", "override_type", "adjustment_pct"])
)

# ── Run Pipeline ────────────────────────────────────────────────────────────────
if st.session_state.raw_df is not None:
    if st.button("Run Scoring Pipeline", type="primary"):
        with st.spinner("Scoring products..."):
            try:
                df = st.session_state.raw_df.copy()
                df = apply_social_nudge(df)
                df = compute_scores(df, weights)
                df = apply_combo_penalty(df, combo_price_threshold, combo_penalty_pct)
                if not overrides_df.empty:
                    df = apply_item_overrides(df, overrides_df)
                if brands_to_boost:
                    df = apply_brand_boost(df, brands_to_boost, boost_pct)
                df = remove_free_l1(df)
                df = apply_anti_clustering(df)
                df = finalize_ranking(df)
                st.session_state.result_df = df
                st.session_state.error = None
            except Exception as exc:
                st.session_state.error = str(exc)

if st.session_state.error:
    st.error(st.session_state.error)

# ── Results ─────────────────────────────────────────────────────────────────────
if st.session_state.result_df is not None:
    df = st.session_state.result_df

    st.subheader("Ranked Products")
    st.markdown(
        f"<p style='color:#555; font-size:0.88rem'>{len(df):,} products ranked</p>",
        unsafe_allow_html=True,
    )

    display_cols = [c for c in
        ["item_id", "item_code", "brandname", "categoryl1", "product_priority", "social_nudge"]
        if c in df.columns
    ]
    st.dataframe(df[display_cols].sort_values("product_priority"), use_container_width=True)

    with st.expander("Full scoring breakdown"):
        st.dataframe(df, use_container_width=True)

    # ── Export ──────────────────────────────────────────────────────────────────
    st.subheader("Export")
    col1, col2, col3 = st.columns(3)

    ranking_cols = [c for c in
        ["item_id", "item_code", "brandname", "categoryl1", "product_priority", "social_nudge"]
        if c in df.columns
    ]
    df_ranking = df[ranking_cols].rename(columns={
        "item_code": "Item Code",
        "brandname": "Brand",
        "categoryl1": "L1",
        "product_priority": "Product Priority",
    })

    seo_cols = [c for c in
        ["item_id", "item_code", "brandname", "categoryl1", "categoryl2", "categoryl3", "product_priority"]
        if c in df.columns
    ]

    nudge_cols = [c for c in
        ["item_code", "brandname", "categoryl1", "social_nudge"]
        if c in df.columns
    ]
    df_nudge = df[df["social_nudge"].astype(str).str.strip() != ""]

    with col1:
        st.download_button(
            "Download Final Ranking",
            df_ranking.to_csv(index=False),
            "final_ranking.csv",
            "text/csv",
        )
    with col2:
        st.download_button(
            "Download SEO File",
            df[seo_cols].to_csv(index=False),
            "seo.csv",
            "text/csv",
        )
    with col3:
        st.download_button(
            "Download Nudge File",
            df_nudge[nudge_cols].to_csv(index=False),
            "nudge.csv",
            "text/csv",
        )
