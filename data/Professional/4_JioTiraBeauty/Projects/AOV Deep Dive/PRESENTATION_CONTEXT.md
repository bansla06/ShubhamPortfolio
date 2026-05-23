# AOV Deep Dive V2 — Presentation Context for Claude Code
# Drop this file alongside chart_data.json to build the full presentation.
# Author: Shubham | Data refreshed: May 2026
# All numbers are live from BigQuery (tira-prod.derived_table.TransactionalData, Jan 2024 – Mar 2026)

---

## STORY ARC (4 slides)

Slide 1 — THE GROWTH      : Tira is scaling. The numbers are moving in the right direction.
Slide 2 — THE TENSION     : But the growth is hiding a quality problem.
Slide 3 — THE INSIGHTS    : Here is what loyalty actually looks like when it works — and where it breaks.
Slide 4 — RECOMMENDATIONS : Six moves to shift from buying orders to building customers.

Opening headline: "Are we building customers or buying orders?"

---

## PLATFORM BASELINE (hero callout numbers)

| Metric            | Value         |
|-------------------|---------------|
| Total Users       | 2,901,693     |
| Total Orders      | 7,113,922     |
| Total Revenue     | ₹1,348 Cr     |
| Avg AOV           | ₹1,895        |
| Avg ASP           | ₹986          |
| Repeat User Rate  | 41.5%         |
| Period            | Jan 2024 – Mar 2026 |

---

## SLIDE 1 — THE GROWTH

### Headline
"Tira has grown 3x in orders and nearly 4x in revenue in 9 quarters."

### Narrative
Start with the good news. The platform is scaling. Orders grew from 399K in Q1 2024 to 1.19M in Q1 2026 — a 3x increase. Revenue grew from ₹69 Cr to ₹240 Cr per quarter. New users are coming in consistently. Repeat users as a share of total are rising — from 22.9% in Q1 2024 to 62.9% in Q1 2026. AOV has moved up from ₹1,721 to ₹2,016. On paper, every line is pointing up.

### Key callouts for this slide
- Orders: 399K (Q1 2024) → 1,192K (Q1 2026) — +199%
- Revenue: ₹69 Cr → ₹240 Cr per quarter — +250%
- Repeat users: 22.9% → 62.9% of quarterly active users
- AOV: ₹1,721 → ₹2,016 — +17%
- New users per quarter: stable ~300–360K/quarter (platform is consistently acquiring)

### Charts for Slide 1

CHART 1 (hero, full width):
TYPE: Grouped bar + line combo
  - Bars: new_users (blue/light) + repeat_users (gold) stacked or grouped
  - Line: revenue_crore (right axis)
  - X: quarter (Q1 2024 → Q1 2026)
CHART NAME: "Tira Growth: Users and Revenue by Quarter"
DATA KEY: qoq_growth

CHART 2 (supporting, half width):
TYPE: Line chart
  - Y: avg_aov
  - X: quarter
CHART NAME: "Average Order Value by Quarter"
DATA KEY: qoq_growth

CHART 3 (supporting, half width):
TYPE: Line chart
  - Y: repeat_pct
  - X: quarter
CHART NAME: "Repeat Users as % of Quarterly Active"
DATA KEY: qoq_growth

---

## SLIDE 2 — THE TENSION

### Headline
"But the growth is concentrated in a narrow slice of customers. For the majority, Tira is a one-time visit."

### Narrative
The QoQ numbers look healthy. Now look at the same base of 2.9M users through a different lens.

58.5% of users — 1.7M people — placed exactly one order and never came back.
57.8% — 1.68M people — only ever bought during a sale. They have never engaged at full price.
36.8% of first-time buyers spent less than ₹1,000 on their first order (sub-₹500: 6.8%, ₹500–999: 30%).
31.8% of all users have an average ASP below ₹500 — they are buying budget-tier products consistently.
33.6% have an average order value below ₹1,000 across all their orders.

This is the tension: Tira is growing in volume, but the majority of that volume is not converting into customers. It is converting into one-time transactions — often during promotions, often at low price points.

### Key callouts for this slide (big number cards)

CARD 1: 58.5% — users who placed only one order (1,697,231 users)
CARD 2: 57.8% — users who only ever bought during a sale (never BAU)
CARD 3: 36.8% — first-time buyers who spent less than ₹1,000
CARD 4: 31.8% — users with avg ASP below ₹500
CARD 5: 43% — of loyal users (6+ orders) are spending LESS per item over time (downgrading ASP)

### Charts for Slide 2

CHART 1 (left panel):
TYPE: Donut chart
  - Segments: One-time buyers 58.5%, Repeat buyers 41.5%
CHART NAME: "One-Time vs Repeat Buyers"
COLOR: One-time = red/blush, Repeat = gold

CHART 2 (center panel):
TYPE: Donut or horizontal bar
  - Sale Only: 57.8%, Both BAU & Sale: 23.3%, BAU Only: 18.9%
CHART NAME: "57.8% of Users Never Bought Outside a Sale"
DATA KEY: finding_4_sale_dependency
COLOR: Sale Only = red/blush, Both = gold, BAU Only = grey

CHART 3 (right panel):
TYPE: Bar chart — first-order AOV distribution
  - X: aov_band, Y: pct_of_users
  - Highlight everything below ₹1,000 (bars 1 and 2) in red
CHART NAME: "First-Order AOV Distribution — 36.8% Started Below ₹1,000"
DATA KEY: first_order_aov_distribution
ANNOTATION: "36.8% of new users started below ₹1,000" (sum of bands 1+2)

CHART 4 (full width, bottom):
TYPE: Diverging bar or donut — Premiumization status
  - Downgrading 43%, Premiumizing 30%, Stable 27%
  - Show ASP trajectories: Downgrading ₹1,401 → ₹769, Premiumizing ₹737 → ₹1,498
CHART NAME: "43% of Loyal Users Are Spending Less Per Item Over Time"
DATA KEY: finding_7_premiumization
COLOR: Downgrading = red, Premiumizing = gold, Stable = grey

---

## SLIDE 3 — THE INSIGHTS

### Headline
"When customers do come back, they spend more. The problem is getting them back."

### Narrative
Here is what the data shows about customers who do cross the loyalty threshold.
The lifecycle value is provably real. The interventions are knowable. The window is narrow.

### Panel A — The Lifecycle Works (Finding 1)
Customers who stay on the platform increase their AOV by 59% over their first 30 orders.
ASP grows from ₹928 to ₹1,247. They buy more expensive products over time.
They explore brands broadly in orders 7–10 (2.07 brands/order), then settle into a repertoire.
The lifecycle is real — but only 10,876 users have reached order 26–30.

TYPE: Line chart (dual axis)
  - Primary Y: avg_aov, Secondary Y: avg_asp, X: order_rank_bucket
CHART NAME: "AOV & ASP Grow +59% Over the Customer Lifecycle"
DATA KEY: finding_1_aov_maturity
ANNOTATION: Mark order 1 (₹1,667) and order 26-30 (₹2,651). Show +59% label.

### Panel B — The ₹1,000 First-Order Threshold (Finding 2)
The single biggest retention lever is first-order value.
Getting a user to ₹1,000+ on their first order lifts retention by +9.2 pts vs ₹500–999.
The sweet spot is ₹3,000–4,999 (51.9% retention to 2nd order).
₹5,000+ drops slightly — these are gifting/occasion buyers with lower repeat intent.

TYPE: Bar chart
  - X: first_order_aov_band, Y: ret_to_2nd_pct
  - Highlight ₹1,000–1,999 bar as the inflection point
CHART NAME: "Retention by First-Order Value — ₹1,000 is the Inflection Point"
DATA KEY: finding_2_aov_retention
ANNOTATION: "+9.2 pts jump at the ₹1,000 threshold"

### Panel C — Event Type Determines Loyalty (Finding 3)
Not all acquisition is equal. The event a user first buys on shapes their loyalty.
VIP Day: 60.2% ret — highest intent, lowest reach (5,003 users, 0.17% of base)
1-Day Sale: 32.8% ret — highest AOV (₹1,841), worst loyalty. Promotionally triggered, not platform-loyal.
P0 Sale: 42.0% ret, 675K users — platform's biggest acquisition channel.
BAU: 40.5% ret, 808K users.

TYPE: Scatter plot
  - X: avg_first_aov, Y: ret_to_2nd_pct, bubble size: new_users
CHART NAME: "Event Type: High Spend ≠ High Loyalty"
DATA KEY: finding_3a_event_retention
ANNOTATION: Flag "1 day sale" (top-right, high AOV + low ret) and "VIP Day - TTO" (high ret, tiny bubble)

### Panel D — The Return Window (Finding 9)
The window to capture a customer's 3rd order is narrowest and most productive at Day 15–30.
Peak: users who return in 15–30 days have a 63.8% chance of a 3rd order.
Cliff: users who take 180+ days have only a 46.4% chance — a 17-point drop.
264,649 users are in the 180+ day cliff right now. They are recoverable but degrading.

TYPE: Line chart
  - X: days_to_2nd_bucket, Y: ret_to_3rd_pct
CHART NAME: "The Return Window: Day 15–30 is Peak. 180+ Days is a Cliff."
DATA KEY: finding_9_return_window
ANNOTATION: Peak marker at 15-30 days (63.8%). Cliff marker at 180+ (46.4%, -17 pts).

### Panel E — Cohort Quality Is Declining (Finding 8)
Jan 2024 cohort: 62.6% returned for a 2nd order.
Jan 2025 cohort: 44.0%.
2025 cohorts: ~35–38%.
First-order AOV is rising (₹1,632 → ₹1,817) — users are spending more on visit 1.
Retention is falling — fewer of them come back.
The platform is acquiring higher-spending users with lower platform intent.

TYPE: Dual-axis line
  - Left Y: ret_to_2nd_pct (line, falling), Right Y: avg_first_aov (line, rising), X: cohort_month
CHART NAME: "Rising First-Order Spend. Falling Retention. Cohort Quality Is Declining."
DATA KEY: finding_8_cohort_quality
NOTE: Shade 2026 cohorts differently — data timing artifact (insufficient time to repeat)

### Supporting: Brand Retention (Finding 5)
Top loyalty brands: Aminu (70.5%), Thank You Farmer (67.9%), First Aid Beauty (66.7%), Shiseido (64.9%)
Korean skincare cluster (Klairs, ONE THING, Mixsoon, Thank You Farmer): 57–68% retention — best volume-loyalty engine
Worst: Bombay Shaving Company (15.3%), AGARO (16.0%), Beardo (19.0%) — men's grooming brands, category misfit

TYPE: Horizontal bar, sorted by ret_to_2nd_pct
  - Top 15 in gold, bottom 10 in red
CHART NAME: "Brand Retention Map"
DATA KEY: finding_5_brand_retention_top + finding_5_brand_retention_bottom

### Supporting: Basket Size (Finding 6)
1 item → 2 items: +7.2 pts retention (37.0% → 44.2%). The biggest single jump.
43% of all new users bought just 1 item. They came for a specific SKU, not the platform.

TYPE: Bar chart
  - X: basket_size, Y: ret_to_2nd_pct
CHART NAME: "Basket Size at First Order Drives Retention"
DATA KEY: finding_6_basket_retention
ANNOTATION: "+7.2 pts from 1 item to 2 items"

---

## SLIDE 4 — RECOMMENDATIONS

### Headline
"Six moves. All focused on converting volume into value."

### Strategic Recommendations

1. PROTECT THE ₹1,000 FIRST-ORDER THRESHOLD
   Problem: 36.8% of new users started below ₹1,000. Retention is 27–34% in that range.
   Action: Bundle prompts, guided discovery, cross-sell nudges at checkout for sub-₹1,000 carts.
   Target: ₹500–999 band (869K users). Shifting 50% above ₹1,000 = ~4.5 pts platform retention lift.
   KPI: % of first orders above ₹1,000.

2. SCALE VIP DAY. RETIRE 1-DAY FLASH SALES.
   Problem: 1-Day Sale = highest AOV acquisition (₹1,841) + worst retention (32.8%). Destroys LTV.
   Action: 5–10x VIP Day reach (5K → 25–50K users per event). Reframe flash sales as loyalty-only.
   KPI: VIP Day users as % of new acquisition.

3. DAY 15 CRM TRIGGER — THE HIGHEST-LEVERAGE ACTION ON THE PLATFORM
   Problem: Peak return window is 15–30 days. 264K users are past 180 days and fading.
   Action: Shift CRM KPI from "2nd order rate" to "2nd order within 30 days rate."
            Personalized Day 15 push based on first-order brand and category.
   KPI: % of new users who place 2nd order within 30 days.

4. INTERVENE ON THE 43% WHO ARE DOWNGRADING
   Problem: 107K loyal users (6+ orders) have dropped ASP by -38.5% (₹1,401 → ₹769).
   Action: Premium re-introduction via editorial content, curated edits, sampling. Not discounts.
   KPI: ASP trajectory among 6+ order users.

5. FIX THE MEN'S GROOMING ACQUISITION DRAIN
   Problem: Beardo (19% ret, 28.7K users), Bombay Shaving (15.3%), AGARO (16%) — ~41K/year who don't return.
   Action: Deprioritize acquisition on these brands. Or build a dedicated men's premium pathway.
   KPI: Retention rate for men's grooming first-buyers.

6. BUILD KOREAN SKINCARE AS A PLATFORM FRANCHISE
   Problem: The best loyalty engine on the platform is underutilised and not marketed as a franchise.
   Action: Korean Beauty editorial hub, bundles, CRM journey. Klairs, Thank You Farmer, Mixsoon, ONE THING.
   KPI: Korean skincare share of new user acquisition.

### CRM Activation Stack
BigQuery (tira-prod) → UCP (identity stitching) → Segment → MoEngage

| Priority | Audience                              | Size           | Action                          |
|----------|---------------------------------------|----------------|---------------------------------|
| CRITICAL | Sub-₹500 first buyers, Day 0–14       | ~15K/month     | AOV lift nudge before 2nd order |
| CRITICAL | Day 15 no-repeat users                | ~80K/month     | Personalized re-engagement      |
| HIGH     | Active Premiumizers                   | 74,293 users   | Affirm + upsell                 |
| HIGH     | Downgraders (ASP -10%+)               | 106,544 users  | Premium re-introduction         |
| HIGH     | 1-Day Sale first buyers, no repeat    | ~12K/month     | Intent qualification            |
| MEDIUM   | AJIO premium → Tira new               | TBD via UCP    | Cross-platform bridge           |
| MEDIUM   | Sale-only with BAU browse signal      | Ongoing        | BAU conversion nudge            |

---

## DESIGN SYSTEM

Theme: Light (white background)
Font hierarchy: Bold headline → Regular sub-head → Light body
Color palette:
  - Gold (#C9A84C)    = positive / opportunity / highlight / growth
  - Red/Blush (#D94F4F) = risk / warning / bad metric
  - Green (#4CAF50)   = improvement / recommendation
  - Grey (#9E9E9E)    = neutral / supporting
  - Dark (#1A1A1A)    = headline text

Chart style: Clean, minimal gridlines, no chart borders, data labels on key points only
Numbers: Indian format (₹1,667 | 2.9M | 57.8%)
Slide layout: Max 1 headline chart + supporting stats per panel. Never crowd.
Big number cards: Use for tension slide — large font % or number, short descriptor below.
