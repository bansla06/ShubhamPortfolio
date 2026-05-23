# Relevancy Logic

**Product ranking pipeline for e-commerce catalogs.**

Scores and ranks products based on behavioral signals — views, sales, revenue, inventory age, and efficiency metrics — with configurable weights and post-processing rules.

---

## How It Works

```
Raw Data (CSV upload or BigQuery pull)
             │
             ▼
     Feature Engineering
     (normalize signals per category × price bracket)
             │
             ▼
     Weighted Scoring
     (10 configurable signals → two rank tracks → final score)
             │
             ▼
     Post-Processing
     (combo penalty, item overrides, brand boosting, anti-clustering)
             │
             ▼
     3 Output Files
     Final Ranking  |  SEO File  |  Social Nudge File
```

---

## Scoring Signals

| Signal | Default Weight |
|---|---|
| Product Aging (newer = better) | 0.66 |
| Inventory | 1.00 |
| Revenue — Last 15 Days (Inv Track) | 0.75 |
| Revenue — Last 15 Days (Main Track) | 1.50 |
| Revenue — 15–75 Days Ago | 0.00 |
| Views — Last 15 Days | 0.00 |
| Views — 15–75 Days Ago | 0.00 |
| Sales — Last 15 Days | 0.25 |
| Sales — 15–75 Days Ago | 0.25 |
| RPV (Revenue Per View) | 0.60 |
| SPV (Sales Per View) | 0.40 |

Two rank tracks run in parallel and the higher score wins:
- **Inventory/Age Track** — aging + inventory + recent revenue
- **Main Track** — all behavioral signals combined

---

## Post-Processing Rules

1. **Combo Penalty** — COMBO items priced ≤ threshold get a rank penalty
2. **Item Overrides** — specific item codes can be boosted or penalized via CSV
3. **Brand Boosting** — selected brands get a priority boost (from manual input or Google Sheet)
4. **Anti-Clustering** — prevents the same brand from appearing consecutively
5. **L1 Removal** — items tagged as Free-L1 are excluded
6. **Social Nudge** — tags top sellers (500+/1000+ units in last 30 days)

---

## Architecture

```
relevancy-logic/
├── app.py                    # Streamlit app — thin orchestrator
├── requirements.txt
├── .env.example
│
├── config/
│   ├── settings.py           # Table names + credentials from env vars
│   └── weights.py            # Default scoring weights
│
├── utils/
│   ├── bq_client.py          # BigQuery connection + SQL template runner
│   ├── scoring.py            # Feature engineering + weighted scoring
│   └── post_processing.py    # Combo penalty, brand boost, anti-clustering
│
├── sql/
│   ├── part1_views_sales.sql # Computes view + sales metrics (store result as BQ table)
│   └── part2_final_dataset.sql # Joins metrics with item metadata + category averages
│
└── data/
    └── item_overrides_sample.csv  # Sample override file (boost/penalty per item)
```

---

## Setup

```bash
# Clone the repo
git clone https://github.com/yourusername/relevancy-logic.git
cd relevancy-logic

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Fill in your BigQuery project, dataset, and table names in .env

# Run the app
streamlit run app.py
```

---

## Data Flow

### Option A — Upload CSV
Export your raw data from BigQuery using the SQL in `sql/part2_final_dataset.sql` and upload the resulting CSV directly in the app.

### Option B — Pull from BigQuery
Configure all `BQ_*` variables in `.env` and use the "Pull from BigQuery" tab to fetch data automatically.

### SQL Execution Order
1. Run `sql/part1_views_sales.sql` and store results as a BigQuery table (set `BQ_TABLE_POPULARITY_CACHE` to that table name)
2. `sql/part2_final_dataset.sql` references that cache to produce the final raw dataset

---

## Item Overrides

Upload a CSV with these columns to apply per-item adjustments:

| column | values |
|---|---|
| `item_code` | product item code |
| `override_type` | `boost` or `penalty` |
| `adjustment_pct` | decimal (e.g. `0.40` = 40%) |

See `data/item_overrides_sample.csv` for format.

---

## Environment Variables

| Variable | Description |
|---|---|
| `BQ_PROJECT_ID` | GCP project ID |
| `BQ_CREDENTIALS_PATH` | Path to service account JSON |
| `BQ_DATASET_AGG` | Aggregation dataset name |
| `BQ_DATASET_DWH` | Data warehouse dataset name |
| `BQ_DATASET_DERIVED` | Derived tables dataset name |
| `BQ_TABLE_ORDERS` | Orders state table name |
| `BQ_TABLE_EVENTS` | View-item events table name |
| `BQ_TABLE_ITEM` | Item master table name |
| `BQ_TABLE_BRAND` | Brand table name |
| `BQ_TABLE_CATEGORY` | Category table name |
| `BQ_TABLE_ARTICLE` | Article/inventory table name |
| `BQ_TABLE_POPULARITY_CACHE` | Part 1 output cache table name |
| `BRAND_BOOST_SHEET_URL` | Google Sheet URL for brand boost list |

Never commit `.env` to version control.

---

## Author

Shubham Bansla
