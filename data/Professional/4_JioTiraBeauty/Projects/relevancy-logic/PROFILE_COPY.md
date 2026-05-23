# Relevancy Logic — Profile & Resume Copy

---

## Resume (1–2 liner)

> Engineered a **product relevancy and ranking system** for a large-scale e-commerce catalog, scoring 55,000+ SKUs across 10 behavioral and commercial signals — with configurable weights, brand boosting, and anti-clustering logic — deployed as a Streamlit pipeline reducing manual ranking effort to a single run.

---

## LinkedIn / Naukri — Project Section

**Relevancy Logic | Personal Project | Python, BigQuery, Streamlit, Pandas**

**Problem:**
In a large beauty e-commerce catalog, product ordering on category and search pages was either manually curated or driven by a single metric like revenue — leading to stale products surfacing at the top, poor inventory utilization, and missed opportunities for high-converting new launches.

**Solution:**
Built an end-to-end product ranking pipeline that scores every SKU across 10 signals — recency, inventory health, revenue efficiency, views, sales velocity, and per-view conversion rates. The system runs on BigQuery-sourced data, normalizes every signal within its category × price bracket peer group, and produces three ready-to-upload output files: final ranking, SEO ranking, and social nudge tags.

Key highlights:
- Weighted scoring engine with two parallel rank tracks (inventory/age track vs. behavioral track) — each product takes the higher of the two scores
- Cube-root normalization per category × price bracket ensures fair comparison across high and low volume segments
- Post-processing layer handles COMBO item penalties, per-item boost/penalty overrides via CSV, brand boosting from a live Google Sheet, anti-clustering to prevent brand monopoly in ranked lists, and Free-L1 exclusion
- Social nudge tagging automatically flags top-selling products (500+/1000+ units in last 30 days) for display badges
- Streamlit UI with live weight sliders — business teams can tune signal weights and re-run ranking without touching code
- All table names and schema abstracted behind environment variables — zero sensitive data in the codebase

---

## Naukri — Project Description (shorter format)

**Relevancy Logic** — Product ranking pipeline for e-commerce catalog

Built a data-driven product relevancy engine that ranks 55,000+ SKUs using 10 behavioral and commercial signals: product aging, inventory, revenue, views, sales, RPV, and SPV. Signals are cube-root normalized within category × price bracket peer groups and combined via two weighted rank tracks — the higher score wins. Post-processing applies COMBO penalties, per-item overrides, brand boosting (from Google Sheets), and anti-clustering rules. Outputs three files: final ranking, SEO file, and social nudge tags. Wrapped in a Streamlit app with interactive weight sliders for business-side experimentation.

**Tech:** Python, Pandas, NumPy, Google BigQuery, Streamlit, Google Sheets API
