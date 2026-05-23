-- ============================================================
-- AOV Deep Dive V2 — Analysis Queries
-- Source: tira-prod.derived_table.TransactionalData
-- Period: 2024-01-01 to 2026-03-31
-- Author: Shubham | May 2026
-- ============================================================
-- HOW TO USE:
--   Each finding is a standalone query.
--   Copy the full block (WITH ... SELECT ...) into BigQuery and run.
--
-- RETENTION COLUMNS:
--   ret_to_Nth_pct      = user placed Nth order at ANY point (lifetime)
--   ret_to_2nd_30d_pct  = user placed 2nd order within 30 days of first order
-- ============================================================


-- ============================================================
-- FINDING 1: AOV / ASP / Basket Size by Order Rank
-- (No retention column — this is a spend maturity curve)
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    SUM(no_of_items_purchased)                                             AS total_items,
    COUNT(DISTINCT brand_name)                                             AS brand_count,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
)
SELECT
  CASE
    WHEN order_rank <= 10 THEN CAST(order_rank AS STRING)
    WHEN order_rank <= 15 THEN '11-15'
    WHEN order_rank <= 20 THEN '16-20'
    WHEN order_rank <= 25 THEN '21-25'
    WHEN order_rank <= 30 THEN '26-30'
    ELSE                       '30+'
  END                                   AS order_rank_bucket,
  ROUND(AVG(order_value), 0)            AS avg_aov,
  ROUND(AVG(asp), 0)                    AS avg_asp,
  ROUND(AVG(brand_count), 2)            AS avg_brands_per_order,
  ROUND(AVG(total_items), 2)            AS avg_items_per_order,
  COUNT(DISTINCT user_id)               AS user_count,
  COUNT(order_id)                       AS order_count
FROM order_seq
GROUP BY 1
ORDER BY
  CASE order_rank_bucket
    WHEN '1'  THEN 1  WHEN '2'  THEN 2  WHEN '3'  THEN 3  WHEN '4'  THEN 4
    WHEN '5'  THEN 5  WHEN '6'  THEN 6  WHEN '7'  THEN 7  WHEN '8'  THEN 8
    WHEN '9'  THEN 9  WHEN '10' THEN 10 WHEN '11-15' THEN 11
    WHEN '16-20' THEN 12 WHEN '21-25' THEN 13 WHEN '26-30' THEN 14
    ELSE 15
  END;


-- ============================================================
-- FINDING 2: Retention Funnel by First-Order AOV Band
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    SUM(no_of_items_purchased)                                             AS total_items,
    COUNT(DISTINCT brand_name)                                             AS brand_count,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (
  SELECT *,
    CASE
      WHEN order_value < 500  THEN '1. <500'
      WHEN order_value < 1000 THEN '2. 500-999'
      WHEN order_value < 2000 THEN '3. 1000-1999'
      WHEN order_value < 3000 THEN '4. 2000-2999'
      WHEN order_value < 5000 THEN '5. 3000-4999'
      ELSE                         '6. 5000+'
    END AS aov_bucket
  FROM order_seq
  WHERE order_rank = 1
),
-- 30-day retention: 2nd order placed within 30 days of first order
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
)
SELECT
  fo.aov_bucket                                                                   AS first_order_aov_band,
  COUNT(DISTINCT fo.user_id)                                                      AS new_users,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id    IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1)  AS ret_to_2nd_pct,
  ROUND(COUNTIF(s3.user_id    IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1)  AS ret_to_3rd_pct,
  ROUND(COUNTIF(s5.user_id    IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1)  AS ret_to_5th_pct,
  ROUND(COUNTIF(s10.user_id   IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1)  AS ret_to_10th_pct
FROM first_order fo
LEFT JOIN second_order_30d                                            s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2)  s2  USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 3)  s3  USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5)  s5  USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 10) s10 USING (user_id)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- FINDING 2b: Retention by First-Order ASP Tier
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    SUM(no_of_items_purchased)                                             AS total_items,
    COUNT(DISTINCT brand_name)                                             AS brand_count,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (
  SELECT *,
    CASE
      WHEN asp < 500  THEN '1. Budget (<500)'
      WHEN asp < 1000 THEN '2. Low (500-999)'
      WHEN asp < 2000 THEN '3. Mid (1000-1999)'
      WHEN asp < 4000 THEN '4. Premium (2000-3999)'
      ELSE                 '5. Luxury (4000+)'
    END AS asp_tier
  FROM order_seq
  WHERE order_rank = 1
),
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
)
SELECT
  fo.asp_tier                                                                       AS first_order_asp_tier,
  COUNT(DISTINCT fo.user_id)                                                        AS new_users,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_pct,
  ROUND(COUNTIF(s5.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_5th_pct
FROM first_order fo
LEFT JOIN second_order_30d                                           s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2) s2 USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5) s5 USING (user_id)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- FINDING 3a: Retention by First-Order Event Type
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    SUM(no_of_items_purchased)                                             AS total_items,
    COUNT(DISTINCT brand_name)                                             AS brand_count,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (
  SELECT * FROM order_seq WHERE order_rank = 1
),
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
)
SELECT
  fo.event_type                                                                     AS first_order_event,
  COUNT(DISTINCT fo.user_id)                                                        AS new_users,
  ROUND(AVG(fo.order_value), 0)                                                     AS avg_first_aov,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_pct,
  ROUND(COUNTIF(s3.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_3rd_pct,
  ROUND(COUNTIF(s5.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_5th_pct
FROM first_order fo
LEFT JOIN second_order_30d                                           s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2) s2 USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 3) s3 USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5) s5 USING (user_id)
GROUP BY 1
ORDER BY ret_to_2nd_pct DESC;


-- ============================================================
-- FINDING 3b: AOV / ASP / Revenue by Event Type (all orders)
-- (No retention column — spend metrics only)
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
)
SELECT
  event_type,
  COUNT(DISTINCT order_id)                AS total_orders,
  ROUND(AVG(order_value), 0)              AS avg_aov,
  ROUND(AVG(asp), 0)                      AS avg_asp,
  ROUND(SUM(order_value) / 1e7, 1)       AS revenue_crore
FROM orders
GROUP BY 1
ORDER BY avg_aov DESC;


-- ============================================================
-- FINDING 4: Sale Dependency Split (BAU Only / Sale Only / Both)
-- (No per-user retention column here — order frequency is the metric)
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean) AS event_type,
    SUM(revenue)          AS order_value
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
user_event_flags AS (
  SELECT
    user_id,
    LOGICAL_OR(event_type = 'BAU')  AS has_bau,
    LOGICAL_OR(event_type != 'BAU') AS has_sale,
    COUNT(DISTINCT order_id)         AS total_orders,
    COUNTIF(event_type = 'BAU')      AS bau_orders,
    COUNTIF(event_type != 'BAU')     AS sale_orders
  FROM order_seq
  GROUP BY user_id
)
SELECT
  CASE
    WHEN has_bau AND has_sale THEN 'Both BAU & Sale'
    WHEN has_bau              THEN 'BAU Only'
    ELSE                           'Sale Only'
  END                                                                   AS buyer_type,
  COUNT(user_id)                                                        AS users,
  ROUND(COUNT(user_id) / SUM(COUNT(user_id)) OVER () * 100, 1)         AS pct_of_users,
  ROUND(AVG(total_orders), 1)                                           AS avg_total_orders,
  ROUND(AVG(bau_orders), 1)                                             AS avg_bau_orders,
  ROUND(AVG(sale_orders), 1)                                            AS avg_sale_orders
FROM user_event_flags
GROUP BY 1
ORDER BY users DESC;


-- ============================================================
-- FINDING 5: Brand Retention Map (min 500 new users per brand)
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    SUM(no_of_items_purchased)                                             AS total_items,
    COUNT(DISTINCT brand_name)                                             AS brand_count,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (
  SELECT * FROM order_seq WHERE order_rank = 1
),
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
),
-- Primary brand on first order = brand with highest spend in that order
brand_first_order AS (
  SELECT b.user_id, b.brand_name
  FROM (
    SELECT
      t.user_id,
      t.brand_name,
      SUM(t.amount_paid_per_quantity * t.no_of_items_purchased) AS brand_spend,
      ROW_NUMBER() OVER (
        PARTITION BY t.user_id
        ORDER BY SUM(t.amount_paid_per_quantity * t.no_of_items_purchased) DESC
      ) AS rn
    FROM `tira-prod.derived_table.TransactionalData` t
    JOIN (SELECT user_id, order_id FROM order_seq WHERE order_rank = 1) fo
      USING (user_id, order_id)
    WHERE t.order_date BETWEEN '2024-01-01' AND '2026-03-31'
    GROUP BY t.user_id, t.brand_name
  ) b
  WHERE rn = 1
)
SELECT
  bfo.brand_name,
  COUNT(DISTINCT bfo.user_id)                                                       AS new_users,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT bfo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id     IS NOT NULL) / COUNT(DISTINCT bfo.user_id) * 100, 1) AS ret_to_2nd_pct,
  ROUND(COUNTIF(s5.user_id     IS NOT NULL) / COUNT(DISTINCT bfo.user_id) * 100, 1) AS ret_to_5th_pct,
  ROUND(AVG(fo.asp), 0)                                                              AS avg_first_asp
FROM brand_first_order bfo
JOIN first_order fo USING (user_id)
LEFT JOIN second_order_30d                                           s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2) s2 USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5) s5 USING (user_id)
GROUP BY 1
HAVING COUNT(DISTINCT bfo.user_id) >= 500
ORDER BY ret_to_2nd_pct DESC;


-- ============================================================
-- FINDING 5b: Retention by Brand Price Tier
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
),
brand_tier AS (
  SELECT
    brand_name,
    CASE
      WHEN AVG(amount_paid_per_quantity) < 500  THEN '1. Budget (<500)'
      WHEN AVG(amount_paid_per_quantity) < 1000 THEN '2. Low (500-999)'
      WHEN AVG(amount_paid_per_quantity) < 2000 THEN '3. Mid (1000-1999)'
      WHEN AVG(amount_paid_per_quantity) < 4000 THEN '4. Premium (2000-3999)'
      ELSE                                           '5. Luxury (4000+)'
    END AS price_tier
  FROM `tira-prod.derived_table.TransactionalData`
  WHERE order_date BETWEEN '2024-01-01' AND '2026-03-31'
  GROUP BY brand_name
),
brand_first_order AS (
  SELECT t.user_id, bt.price_tier
  FROM `tira-prod.derived_table.TransactionalData` t
  JOIN (SELECT user_id, order_id FROM order_seq WHERE order_rank = 1) fo USING (user_id, order_id)
  JOIN brand_tier bt USING (brand_name)
  WHERE t.order_date BETWEEN '2024-01-01' AND '2026-03-31'
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY t.user_id
    ORDER BY t.amount_paid_per_quantity * t.no_of_items_purchased DESC
  ) = 1
)
SELECT
  bfo.price_tier,
  COUNT(DISTINCT bfo.user_id)                                                       AS new_users,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT bfo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id     IS NOT NULL) / COUNT(DISTINCT bfo.user_id) * 100, 1) AS ret_to_2nd_pct,
  ROUND(COUNTIF(s5.user_id     IS NOT NULL) / COUNT(DISTINCT bfo.user_id) * 100, 1) AS ret_to_5th_pct
FROM brand_first_order bfo
LEFT JOIN second_order_30d                                           s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2) s2 USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5) s5 USING (user_id)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- FINDING 6: Retention by First-Order Basket Size (item count)
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    SUM(no_of_items_purchased)                                             AS total_items,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (
  SELECT * FROM order_seq WHERE order_rank = 1
),
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
)
SELECT
  CASE
    WHEN fo.total_items = 1  THEN '1. 1 item'
    WHEN fo.total_items <= 3 THEN '2. 2-3 items'
    WHEN fo.total_items <= 5 THEN '3. 4-5 items'
    ELSE                          '4. 6+ items'
  END                                                                               AS basket_size,
  COUNT(DISTINCT fo.user_id)                                                        AS new_users,
  ROUND(AVG(fo.order_value), 0)                                                     AS avg_first_aov,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_pct,
  ROUND(COUNTIF(s5.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_5th_pct
FROM first_order fo
LEFT JOIN second_order_30d                                           s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2) s2 USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5) s5 USING (user_id)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- FINDING 7: Premiumization — Downgraders vs Premiumizers
-- (No retention column — ASP trajectory is the metric)
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
early_orders AS (
  SELECT user_id,
    AVG(asp)         AS early_asp,
    AVG(order_value) AS early_aov
  FROM order_seq
  WHERE order_rank <= 3
  GROUP BY user_id
),
recent_orders AS (
  SELECT user_id,
    AVG(asp)         AS recent_asp,
    AVG(order_value) AS recent_aov
  FROM (
    SELECT *, MAX(order_rank) OVER (PARTITION BY user_id) AS max_rank
    FROM order_seq
  )
  WHERE order_rank >= max_rank - 2
    AND max_rank >= 6
  GROUP BY user_id
),
prem AS (
  SELECT
    e.user_id,
    ROUND(e.early_asp, 0)                                                  AS early_asp,
    ROUND(r.recent_asp, 0)                                                 AS recent_asp,
    ROUND(e.early_aov, 0)                                                  AS early_aov,
    ROUND(r.recent_aov, 0)                                                 AS recent_aov,
    ROUND((r.recent_asp - e.early_asp) / NULLIF(e.early_asp, 0) * 100, 1) AS asp_growth_pct,
    CASE
      WHEN (r.recent_asp - e.early_asp) / NULLIF(e.early_asp, 0) >  0.30 THEN 'Premiumizing'
      WHEN (r.recent_asp - e.early_asp) / NULLIF(e.early_asp, 0) < -0.10 THEN 'Downgrading'
      ELSE 'Stable'
    END AS status
  FROM early_orders e
  JOIN recent_orders r USING (user_id)
)
SELECT
  status,
  COUNT(user_id)                                                         AS users,
  ROUND(COUNT(user_id) / SUM(COUNT(user_id)) OVER () * 100, 1)          AS pct_of_6plus_users,
  ROUND(AVG(asp_growth_pct), 1)                                          AS avg_asp_growth_pct,
  ROUND(AVG(early_asp), 0)                                               AS avg_early_asp,
  ROUND(AVG(recent_asp), 0)                                              AS avg_recent_asp
FROM prem
GROUP BY 1
ORDER BY users DESC;


-- ============================================================
-- FINDING 8: Cohort Retention by Acquisition Month
-- Includes: lifetime retention + 30-day retention to 2nd order
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean)                                                  AS event_type,
    SUM(revenue)                                                           AS order_value,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2)        AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
first_order AS (
  SELECT * FROM order_seq WHERE order_rank = 1
),
second_order_30d AS (
  SELECT o2.user_id
  FROM order_seq o2
  JOIN (SELECT user_id, order_date AS fo_date FROM order_seq WHERE order_rank = 1) o1
    USING (user_id)
  WHERE o2.order_rank = 2
    AND DATE_DIFF(o2.order_date, o1.fo_date, DAY) <= 30
)
SELECT
  FORMAT_DATE('%Y-%m', fo.order_date)                                               AS cohort_month,
  COUNT(DISTINCT fo.user_id)                                                        AS new_users,
  ROUND(AVG(fo.order_value), 0)                                                     AS avg_first_aov,
  ROUND(COUNTIF(s2_30d.user_id IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_30d_pct,
  ROUND(COUNTIF(s2.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_2nd_pct,
  ROUND(COUNTIF(s3.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_3rd_pct,
  ROUND(COUNTIF(s5.user_id     IS NOT NULL) / COUNT(DISTINCT fo.user_id) * 100, 1) AS ret_to_5th_pct
FROM first_order fo
LEFT JOIN second_order_30d                                           s2_30d USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 2) s2  USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 3) s3  USING (user_id)
LEFT JOIN (SELECT DISTINCT user_id FROM order_seq WHERE order_rank = 5) s5  USING (user_id)
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- FINDING 9: Time to Second Order vs Retention to 3rd Order
-- (Already time-based — no change needed)
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    MAX(event_type_clean) AS event_type,
    SUM(revenue)          AS order_value
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
),
o1 AS (SELECT user_id, order_date AS date_1 FROM order_seq WHERE order_rank = 1),
o2 AS (SELECT user_id, order_date AS date_2 FROM order_seq WHERE order_rank = 2),
o3 AS (SELECT DISTINCT user_id    FROM order_seq WHERE order_rank = 3),
gap AS (
  SELECT
    o1.user_id,
    DATE_DIFF(o2.date_2, o1.date_1, DAY) AS days_to_2nd,
    (o3.user_id IS NOT NULL)              AS reached_3rd
  FROM o1
  JOIN o2 USING (user_id)
  LEFT JOIN o3 USING (user_id)
)
SELECT
  CASE
    WHEN days_to_2nd <=   7 THEN '1. 0-7 days'
    WHEN days_to_2nd <=  14 THEN '2. 8-14 days'
    WHEN days_to_2nd <=  30 THEN '3. 15-30 days'
    WHEN days_to_2nd <=  60 THEN '4. 31-60 days'
    WHEN days_to_2nd <=  90 THEN '5. 61-90 days'
    WHEN days_to_2nd <= 180 THEN '6. 91-180 days'
    ELSE                         '7. 180+ days'
  END                                                         AS days_to_2nd_bucket,
  COUNT(user_id)                                              AS users,
  ROUND(AVG(days_to_2nd), 1)                                 AS avg_days,
  ROUND(COUNTIF(reached_3rd) / COUNT(user_id) * 100, 1)      AS ret_to_3rd_pct
FROM gap
GROUP BY 1
ORDER BY 1;


-- ============================================================
-- SUPPLEMENTAL: Platform-Level Headline Numbers
-- ============================================================
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
  SELECT
    user_id, order_id, order_date,
    SUM(revenue)                                                    AS order_value,
    ROUND(SUM(revenue) / NULLIF(SUM(no_of_items_purchased), 0), 2) AS asp
  FROM base
  GROUP BY user_id, order_id, order_date
),
order_seq AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS order_rank
  FROM orders
)
SELECT
  COUNT(DISTINCT user_id)                                                       AS total_users,
  COUNT(DISTINCT order_id)                                                      AS total_orders,
  ROUND(SUM(order_value) / 1e7, 1)                                              AS total_revenue_crore,
  ROUND(AVG(order_value), 0)                                                    AS platform_avg_aov,
  ROUND(AVG(asp), 0)                                                            AS platform_avg_asp,
  ROUND(
    COUNT(DISTINCT CASE WHEN order_rank >= 2 THEN user_id END) /
    COUNT(DISTINCT CASE WHEN order_rank  = 1 THEN user_id END) * 100
  , 1)                                                                          AS repeat_user_pct
FROM order_seq;
