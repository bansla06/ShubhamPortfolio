-- =============================================================================
-- Part 1: Compute view and sales metrics per item
-- Run this query and store results as a BigQuery table.
-- Set BQ_TABLE_POPULARITY_CACHE in .env to that table name.
--
-- Placeholders (filled at runtime from .env):
--   {project_id}            BQ_PROJECT_ID
--   {dataset_agg}           BQ_DATASET_AGG
--   {table_orders}          BQ_TABLE_ORDERS
--   {dataset_derived}       BQ_DATASET_DERIVED
--   {table_events}          BQ_TABLE_EVENTS
-- =============================================================================

WITH OrderSummaryT1 AS (
  SELECT * FROM (
    SELECT
      a.*,
      b.bag_id AS cancel_bag_id
    FROM (
      SELECT
        date, bag_id, order_id, Amount_Paid, quantity,
        parent_promo_bags, MRP, user_id, source, item_id
      FROM `{project_id}.{dataset_agg}.{table_orders}`
      WHERE state = 'Placed'
    ) a
    LEFT JOIN (
      SELECT DISTINCT bag_id
      FROM `{project_id}.{dataset_agg}.{table_orders}`
      WHERE state IN ('Cancelled by Customer', 'Cancelled by Seller')
    ) b ON a.bag_id = b.bag_id
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
  )
  WHERE cancel_bag_id IS NULL
),

ViewMetrics AS (
  SELECT
    item_id,
    COUNT(DISTINCT user_pseudo_id)                                                        AS users_view,
    COUNT(DISTINCT CASE WHEN date >= (CURRENT_DATE() - 15)
                        THEN user_pseudo_id END)                                          AS last_15_days_users_view,
    COUNT(DISTINCT CASE WHEN date >= (CURRENT_DATE() - 75)
                         AND date <  (CURRENT_DATE() - 15)
                        THEN user_pseudo_id END)                                          AS after_75_before_last_15_days_users_view,
    CBRT(COUNT(DISTINCT CASE WHEN date >= (CURRENT_DATE() - 15)
                             THEN user_pseudo_id END))                                    AS cbrt_last_15_days_users_view,
    CBRT(COUNT(DISTINCT CASE WHEN date >= (CURRENT_DATE() - 75)
                              AND date <  (CURRENT_DATE() - 15)
                             THEN user_pseudo_id END))                                    AS cbrt_after_75_before_last_15_days_users_view
  FROM (
    SELECT
      DATE(event_timestamp)                                                               AS date,
      CASE WHEN item_id = 0 AND item_id_new IS NOT NULL
           THEN item_id_new ELSE item_id END                                              AS item_id,
      user_pseudo_id,
      session_id
    FROM (
      SELECT
        event_timestamp,
        item_id,
        item_name,
        LEAD(item_id) OVER (PARTITION BY item_name ORDER BY item_id)                    AS item_id_new,
        user_pseudo_id,
        session_id
      FROM `{dataset_derived}.{table_events}`
      WHERE event_name  = 'view_item'
        AND event_date >= CURRENT_DATE() - 90
    )
    WHERE item_id != 0 OR item_name != '(not set)'
    GROUP BY 1, 2, 3, 4
  )
  GROUP BY 1
),

SalesMetrics AS (
  SELECT
    item_id                                                                               AS item_uid,
    SUM(quantity)                                                                         AS overall_sales,
    SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15)  THEN quantity END)                AS last_15_days_sale,
    SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 30)  THEN quantity END)                AS last_30_days_sale,
    SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 75)
              AND DATE(date) <  (CURRENT_DATE() - 15)  THEN quantity END)                AS after_75_before_last_15_days_sale,
    CBRT(SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15) THEN quantity END))           AS cbrt_last_15_days_sale,
    CBRT(SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 75)
                   AND DATE(date) <  (CURRENT_DATE() - 15) THEN quantity END))           AS cbrt_after_75_before_last_15_days_sale,
    SUM(Amount_Paid * quantity)                                                           AS overall_revenue,
    SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15)
             THEN Amount_Paid * quantity END)                                             AS last_15_days_revenue,
    SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 75)
              AND DATE(date) <  (CURRENT_DATE() - 15)
             THEN Amount_Paid * quantity END)                                             AS after_75_before_last_15_days_revenue,
    CBRT(SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15)
                  THEN Amount_Paid * quantity END))                                       AS cbrt_last_15_days_revenue,
    CBRT(SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 75)
                   AND DATE(date) <  (CURRENT_DATE() - 15)
                  THEN Amount_Paid * quantity END))                                       AS cbrt_after_75_before_last_15_days_revenue
  FROM OrderSummaryT1
  GROUP BY 1
)

SELECT
  v.item_id,
  v.users_view                                     AS overall_view,
  v.last_15_days_users_view,
  v.cbrt_last_15_days_users_view,
  v.after_75_before_last_15_days_users_view,
  v.cbrt_after_75_before_last_15_days_users_view,
  s.overall_sales,
  s.last_15_days_sale,
  s.cbrt_last_15_days_sale,
  s.last_30_days_sale,
  s.after_75_before_last_15_days_sale,
  s.cbrt_after_75_before_last_15_days_sale,
  s.overall_revenue,
  s.last_15_days_revenue,
  s.cbrt_last_15_days_revenue,
  s.after_75_before_last_15_days_revenue,
  s.cbrt_after_75_before_last_15_days_revenue
FROM ViewMetrics v
LEFT JOIN SalesMetrics s ON v.item_id = s.item_uid
ORDER BY s.overall_revenue DESC
