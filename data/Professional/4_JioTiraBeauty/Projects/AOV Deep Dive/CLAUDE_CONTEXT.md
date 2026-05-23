# AOV Deep Dive V2 — Claude Context File
**Drop this file in any folder and Claude will have full project context.**
**Author:** Shubham | **Last Updated:** May 2026

---

## 1. What This Project Is

A deep-dive analysis of customer purchase behaviour on **Tira** (Reliance's premium beauty retail platform).
The central business question: *"Are we building customers or buying orders?"*

- **Data:** `tira-prod.derived_table.TransactionalData`
- **Period:** Jan 2024 – Mar 2026
- **Scale:** 2.9M users | 22.4M transactions
- **Cross-platform:** Tira + AJIO + JioMart linked via UCP (Unified Customer Profile)

---

## 2. File Structure

```
AOV Deep Dive V2/
├── CLAUDE_CONTEXT.md                  ← this file
├── documentation/
│   ├── AOV_V2_Framework.md            ← full analytical framework, SQL architecture, scoring models
│   └── AOV_V2_Insights.md             ← 9 findings with numbers, CRM activation playbooks
├── scripts/
│   └── AOV_Analysis_V2.ipynb          ← Python notebook (BigQuery → pandas), setup cell only
└── output/
    ├── AOV_V2_Queries.sql             ← all BigQuery SQL queries, one per finding
    ├── AOV_Analysis_V2.xlsx           ← raw analysis output
    └── AOV_Story_Data.xlsx            ← presentation-ready Excel (6 sheets, light theme)
```

---

## 3. Data Schema (TransactionalData)

Key columns used across all queries:
- `user_id` — unique user identifier
- `order_id` — unique order identifier
- `order_date` — date of order
- `brand_name` — brand of line item
- `SKU_id` — product SKU
- `amount_paid_per_quantity` — price per unit (used for ASP)
- `no_of_items_purchased` — quantity
- `event_type` — promotion context (BAU, P0 Sale, P1 sale, VIP Day - TTO, 1 day sale, etc.)

**Revenue formula:** `amount_paid_per_quantity * no_of_items_purchased`

**Event type cleaning (always apply):**
```
P0 sale, P0 sale Extension  →  P0 Sale
Pre buzz, Pre Buzz, Prebuzz / P0 early start  →  PreBuzz
All others: unchanged
```

---

## 4. Core Metric Definitions

| Metric | Formula |
|---|---|
| AOV | SUM(revenue) / COUNT(orders) |
| ASP | SUM(revenue) / SUM(items) — price per unit |
| Basket Size | SUM(items) / COUNT(orders) |
| Retention to Nth order | Users with Nth order / Users with 1st order |
| 30-day retention | Users whose 2nd order was within 30 days of 1st order / Users with 1st order |
| LTV | SUM(revenue) per user (historical) |
| Premiumization | ASP in recent 3 orders vs first 3 orders (for users with 6+ orders) |

---

## 5. SQL Base CTE Pattern (used in all queries)

```sql
WITH base AS (
  SELECT *,
    amount_paid_per_quantity * no_of_items_purchased AS revenue,
    CASE
      WHEN event_type IN ('P0 Sale','P0 sale','P0 sale Extension') THEN 'P0 Sale'
      WHEN event_type IN ('Pre buzz','Pre Buzz','Prebuzz / P0 early start') THEN 'PreBuzz'
      ELSE event_type
    END AS event_type_clean
  FROM `tira-prod.derived_table.TransactionalData`
  WHERE order_date BETWEEN '2024-01-01' AND '2026-03-31'
),
orders AS (
  SELECT user_id, order_id, order_date,
    MAX(event_type_clean) AS event_type,
    SUM(revenue) AS order_value,
    SUM(no_of_items_purchased) AS total_items,
    COUNT(DISTINCT brand_name) AS brand_count,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2) AS asp
  FROM base GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (SELECT * FROM order_seq WHERE order_rank = 1),
second_order_30d AS (
  SELECT o2.user_id FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1 USING (user_id)
  WHERE o2.order_rank = 2 AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
)
```

---

## 6. The 9 Findings (with headline numbers)

### Finding 1 — AOV Maturity Curve
AOV grows **+59%** over a user's lifecycle: ₹1,667 (order 1) → ₹2,650 (orders 26–30).
ASP also grows: ₹928 → ₹1,246. Brand count peaks at orders 7–10 (2.07) then narrows.
**Formula for 59%:** (2,650 - 1,667) / 1,667 × 100

### Finding 2 — The ₹1,000 Threshold
Biggest retention jump on the platform happens at ₹1,000 first order:

| First Order AOV | Users | Ret to 2nd | Ret to 5th |
|---|---|---|---|
| <₹500 | 1,98,050 | 27.2% | 4.8% |
| ₹500–999 | 8,69,047 | 34.4% | 7.6% |
| **₹1,000–1,999** | **11,07,510** | **43.7%** | **12.2%** |
| ₹2,000–2,999 | 4,04,678 | 49.6% | 16.1% |
| ₹3,000–4,999 | 2,33,620 | 52.0% | 17.2% |
| ₹5,000+ | 88,788 | 50.6% | 15.9% |

Sweet spot for retention: ₹3,000–4,999 (52%). Ultra-luxury (₹5,000+) slightly lower — gifting/occasion buyers.

### Finding 3 — Event Type: VIP Day vs 1-Day Sale
| Event | Users | Ret to 2nd | Avg First AOV |
|---|---|---|---|
| VIP Day - TTO | 5,003 | **60.2%** | ₹1,760 |
| Match Day | 18,372 | 54.3% | ₹1,498 |
| Cat day | 1,26,083 | 50.7% | ₹1,542 |
| P0 Sale | 6,75,066 | 42.0% | ₹1,703 |
| BAU | 8,08,507 | 40.5% | ₹1,666 |
| **1 day sale** | **48,532** | **32.8%** | **₹1,839** |

1-Day Sale paradox: highest first-order AOV (₹1,839 avg), worst retention (32.8%).
VIP Day: best retention (60.2%), serves only 5,003 users — less than 0.2% of acquisition.

### Finding 4 — Sale Dependency Split
| Buyer Type | Users | % | Avg Orders |
|---|---|---|---|
| Sale Only | 16,77,396 | **57.8%** | 1.5 |
| BAU Only | 5,47,424 | 18.9% | 1.2 |
| Both BAU & Sale | 6,76,873 | **23.3%** | **5.8** |

"Both" buyers order 4× more than sale-only. The 23.3% who engage both ways are the platform's health core.

### Finding 5 — Brand Retention
Top retaining brands (high volume): COSRX (116K users, 54.3%), SKIN1004 (101K users, 55.1%)
Top retaining brands (niche): Aminu (70.6%), Thank You Farmer (68.1%), First Aid Beauty (66.7%), Shiseido (64.9%)
Worst retaining: Bombay Shaving Company (15.4%), AGARO (16.0%), KRYOLAN (16.6%), Beardo (19.0%)
By tier: Premium (₹2,000–3,999) = 48.8% retention. Luxury = 45.3%. Premium outperforms luxury.

### Finding 6 — Basket Size Retention
| First Order Items | Users | Ret to 2nd | Avg AOV |
|---|---|---|---|
| 1 item | 12,56,839 | 37.0% | ₹1,333 |
| 2–3 items | 10,89,020 | 44.2% | ₹1,598 |
| 4–5 items | 3,61,537 | 46.0% | ₹2,174 |
| 6+ items | 1,94,297 | 47.1% | ₹3,276 |

Biggest jump: 1 item → 2 items (+7 pts). Single-item buyers are targeted searchers, not platform explorers.

### Finding 7 — Premiumization (6+ order users only)
| Status | Users | % | ASP Change |
|---|---|---|---|
| Premiumizing | 74,295 | 30% | ₹738 → ₹1,498 (+111%) |
| Stable | 66,718 | 27% | ₹906 → ₹974 (+8%) |
| **Downgrading** | **1,06,495** | **43%** | **₹1,401 → ₹769 (-38.5%)** |

43% of loyal users (6+ orders) are spending less per item over time. The platform's most alarming finding.
Thresholds: Premiumizing = ASP growth >30% | Downgrading = ASP decline >10%

### Finding 8 — Cohort Quality Trend
| Cohort | New Users | Avg First AOV | Ret to 2nd |
|---|---|---|---|
| Jan 2024 | 1,01,276 | ₹1,633 | **62.6%** |
| Jul 2024 | 1,20,658 | ₹1,544 | 49.8% |
| Jan 2025 | 1,49,886 | ₹1,595 | 44.0% |
| Jul 2025 | 1,36,082 | ₹1,766 | 37.2% |
| Jan 2026 | 1,55,271 | ₹1,764 | 25.5% |
| Mar 2026 | 98,460 | ₹1,817 | 12.8% |

Jan 2024 = benchmark cohort (62.6%). Recent cohorts look weak but partly a data timing artifact —
they haven't had enough time to repeat. However, 2024 cohort decline (62.6% → 49.8%) is structural.
First-order AOV is rising but retention is falling — quality signal weakening despite higher spend.

### Finding 9 — Return Window
| Days to 2nd Order | Users | Ret to 3rd |
|---|---|---|
| 0–7 days | 2,92,347 | 59.5% |
| 8–14 days | 79,592 | 61.0% |
| **15–30 days** | **1,20,509** | **63.8%** ← peak |
| 31–60 days | 1,48,354 | 63.4% |
| 91–180 days | 1,90,033 | 58.2% |
| **180+ days** | **2,64,649** | **46.4%** ← cliff |

Sweet spot: return within 15–60 days = 63–64% chance of a 3rd order.
Day 15 push is the highest-leverage CRM trigger on the platform.
180+ day gap = 17-point drop in 3rd order retention.

---

## 7. Retention Column Clarification (important)

Two types of retention exist in the queries:

| Column | Meaning |
|---|---|
| `ret_to_Nth_pct` | User placed Nth order at ANY point in the dataset window (lifetime, no time cap) |
| `ret_to_2nd_30d_pct` | User placed 2nd order within **30 days** of their first order |

30-day retention will always be lower. The gap between them shows how many users come back slowly vs quickly.
All findings with retention columns have both versions as of the current query file.

---

## 8. Presentation Story (4 slides)

| Slide | Title | Core Message |
|---|---|---|
| 1 | The Proof | "Tira is building loyal customers. The data proves it." — AOV +59%, retention curve is real |
| 2 | The Tension | "But only for 23% of the platform." — 57.8% sale-only, 43% downgrading |
| 3 | The Diagnosis | "Here is where we are not reaching customers effectively." — event type, brand, basket, return window |
| 4 | Recommendations | "Here is what we do about it." — 7 CRM audiences, 6 strategic moves |

Opening headline: **"Are we building customers or buying orders?"**

---

## 9. Excel Output (AOV_Story_Data.xlsx)

6 sheets:
1. **1-The Proof** — AOV maturity curve, lifecycle numbers
2. **2-The Tension** — sale dependency split, premiumization breakdown
3. **3-Acquisition** — event type retention, first-order AOV band table
4. **4-First 30 Days** — basket size, return window, Day 15 trigger
5. **5-Loyal Base** — brand retention, cohort table, downgrader numbers
6. **6-Recommendations** — 7 CRM audiences with sizes and messaging

Theme: Light (white background). Gold = positive/opportunity. Red/blush = risk. Green = growth.

---

## 10. CRM Activation Stack

```
BigQuery (tira-prod) → UCP (identity stitching) → Segment → MoEngage
```

7 priority audiences:
1. Sub-₹500 first buyers, Day 0–14 (~15K/month) — CRITICAL
2. Day 15 no-repeat push (~80K/month) — CRITICAL
3. Active Premiumizers (74K users) — HIGH
4. Downgraders — ASP intervention (106K users) — HIGH
5. 1-Day Sale first buyers, no repeat (~12K) — HIGH
6. AJIO premium users new to Tira (TBD via UCP) — MEDIUM
7. Sale-only users with BAU browse signal (ongoing) — MEDIUM

---

## 11. Strategic Recommendations Summary

1. **Protect the ₹1,000 threshold** — bundle prompts, guided discovery before checkout
2. **Scale VIP Day, reduce 1-day flash sales** — 5–10x VIP Day reach; flash sales destroy LTV
3. **Intervene on downgraders** — 43% of loyal base drifting cheaper; premium re-introduction campaign
4. **Make Korean skincare a franchise** — COSRX + SKIN1004 are the best volume-loyalty engines on platform
5. **Build AJIO → Tira premium bridge** — lowest CAC premium acquisition channel available
6. **Shift CRM KPI to 15–30 day return rate** — better predictor of long-term retention than 2nd-order rate

---

## 12. User / Session Preferences

- Short, data-forward slides (3–4 max)
- McKinsey/BCG consulting tone — not blame-forward, data-forward
- Light theme for Excel outputs
- Mirrored slide formats (same layout, contrasting data)
- Short punchy headings
- No emojis
- Concise responses preferred

---

*AOV Deep Dive V2 | Context file for Claude | May 2026*
