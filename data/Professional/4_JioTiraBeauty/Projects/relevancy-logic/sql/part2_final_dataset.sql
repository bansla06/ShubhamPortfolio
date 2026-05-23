-- =============================================================================
-- Part 2: Join Part 1 results with item metadata and compute category averages
-- Prerequisite: Run part1_views_sales.sql and store as BQ_TABLE_POPULARITY_CACHE.
--
-- Placeholders (filled at runtime from .env):
--   {project_id}              BQ_PROJECT_ID
--   {dataset_dwh}             BQ_DATASET_DWH
--   {dataset_derived}         BQ_DATASET_DERIVED
--   {table_item}              BQ_TABLE_ITEM
--   {table_brand}             BQ_TABLE_BRAND
--   {table_category}          BQ_TABLE_CATEGORY
--   {table_article}           BQ_TABLE_ARTICLE
--   {table_popularity_cache}  BQ_TABLE_POPULARITY_CACHE
-- =============================================================================

WITH ItemMetadata AS (
  SELECT
    CAST(i.uid AS INT64)                                                                  AS item_id,
    CAST(TRIM(i.item_code) AS STRING)                                                     AS item_code,
    TRIM(i.name)                                                                          AS item_name,
    TRIM(REPLACE(JSON_EXTRACT(i.attributes, '$.brand-name'), '"', ''))                   AS brandname,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      TRIM(JSON_EXTRACT(i.attributes, '$.category-l2')), '"', ''),
      'Bath   Shower',            'Bath & Shower'),
      'Brushes   Applicators',    'Brushes & Applicators'),
      'Face   Body Tools',        'Face & Body Tools'),
      'Hands   Feet',             'Hands & Feet'),
      'Kits   Combos',            'Kits & Combos'),
      'Shaving   Hair Removal',   'Shaving & Hair Removal'),
      'Tools   Accessories',      'Tools & Accessories')                                  AS categoryl2,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      TRIM(JSON_EXTRACT(i.attributes, '$.category-l1')), '"', ''),
      'Tools   Brush',            'Tools & Brush'),
      'Tools   Brushes',          'Tools & Brushes'),
      'Bath   Body',              'Bath & Body'),
      'Mom   Baby',               'Mom & Baby'),
      'Tools   Appliances',       'Tools & Appliances'),
      'Free L',                   'Free-L1'),
      'Shaving   Hair Removal',   'Shaving & Hair Removal')                              AS categoryl1,
    TRIM(REPLACE(JSON_EXTRACT(i.attributes, '$.category-l3'), '"', ''))                  AS categoryl3
  FROM `{project_id}.{dataset_dwh}.{table_item}` i
  GROUP BY 1, 2, 3, 4, 5, 6, 7
),

ArticleMetadata AS (
  SELECT
    item_id,
    fynd_item_code,
    SUM(CAST(REPLACE(JSON_EXTRACT(quantities, '$.sellable.count'), '"', '') AS INT64))   AS inventory_left,
    MAX(CAST(JSON_EXTRACT(price, '$.marked') AS FLOAT64))                                AS item_price,
    MIN(
      CASE
        WHEN JSON_EXTRACT(date_meta, '$.added_on_store') LIKE '%$date%'
          THEN DATE(TIMESTAMP_MILLIS(CAST(
                 REPLACE(REPLACE(JSON_EXTRACT(date_meta, '$.added_on_store'), '{"$date":', ''), '}', '')
               AS INTEGER)))
        WHEN JSON_EXTRACT(date_meta, '$.added_on_store') LIKE '%T%'
          THEN CAST(SUBSTR(JSON_EXTRACT(date_meta, '$.added_on_store'), 2, 10) AS DATE)
      END
    )                                                                                     AS product_live_date
  FROM `{project_id}.{dataset_dwh}.{table_article}`
  WHERE is_active = TRUE
  GROUP BY 1, 2
),

Metrics AS (
  SELECT
    i.item_id,
    i.item_code,
    i.item_name,
    i.brandname,
    i.categoryl1,
    i.categoryl2,
    i.categoryl3,
    a.item_price,
    CASE
      WHEN a.item_price >=     0 AND a.item_price <=   600 THEN '0-600'
      WHEN a.item_price >    600 AND a.item_price <=  1200 THEN '600-1200'
      WHEN a.item_price >   1200 AND a.item_price <=  2000 THEN '1200-2000'
      WHEN a.item_price >   2000 AND a.item_price <=  4000 THEN '2000-4000'
      WHEN a.item_price >   4000 AND a.item_price <=  6000 THEN '4000-6000'
      WHEN a.item_price >   6000 AND a.item_price <=  8000 THEN '6000-8000'
      WHEN a.item_price >   8000 AND a.item_price <= 10000 THEN '8000-10000'
      WHEN a.item_price >  10000                           THEN 'above 10000'
    END                                                                                   AS price_category,
    a.product_live_date,
    DATE_DIFF(CURRENT_DATE(), a.product_live_date, DAY)                                  AS product_aging,
    a.inventory_left,
    CBRT(a.inventory_left)                                                                AS cbrt_inventory_left,
    p.overall_view,
    p.last_15_days_users_view,
    p.cbrt_last_15_days_users_view,
    p.after_75_before_last_15_days_users_view,
    p.cbrt_after_75_before_last_15_days_users_view,
    p.overall_sales,
    p.last_15_days_sale,
    p.last_30_days_sale,
    p.cbrt_last_15_days_sale,
    p.after_75_before_last_15_days_sale,
    p.cbrt_after_75_before_last_15_days_sale,
    p.overall_revenue,
    p.last_15_days_revenue,
    p.cbrt_last_15_days_revenue,
    p.after_75_before_last_15_days_revenue,
    p.cbrt_after_75_before_last_15_days_revenue
  FROM `{dataset_derived}.{table_popularity_cache}` p
  LEFT JOIN ArticleMetadata a ON p.item_id = a.item_id
  INNER JOIN ItemMetadata   i ON p.item_id = i.item_id
),

CategoryAverages AS (
  SELECT
    categoryl1,
    price_category,
    ROUND(AVG(product_aging),                                    2) AS avg_product_aging,
    ROUND(AVG(cbrt_last_15_days_users_view),                     2) AS avg_last_15_days_users_view,
    ROUND(AVG(cbrt_after_75_before_last_15_days_users_view),     2) AS avg_after_75_before_last_15_days_users_view,
    ROUND(AVG(cbrt_last_15_days_sale),                           2) AS avg_last_15_days_sale,
    ROUND(AVG(cbrt_after_75_before_last_15_days_sale),           2) AS avg_after_75_before_last_15_days_sale,
    ROUND(AVG(cbrt_last_15_days_revenue),                        2) AS avg_last_15_days_revenue,
    ROUND(AVG(cbrt_after_75_before_last_15_days_revenue),        2) AS avg_after_75_before_last_15_days_revenue
  FROM Metrics
  GROUP BY 1, 2
)

SELECT
  m.item_id,
  m.item_code,
  m.item_name,
  m.brandname,
  m.categoryl1,
  m.categoryl2,
  m.categoryl3,
  m.item_price,
  m.price_category,
  m.product_live_date,
  m.product_aging,
  c.avg_product_aging,
  m.inventory_left,
  m.cbrt_inventory_left,
  m.overall_view,
  m.last_15_days_users_view,
  m.cbrt_last_15_days_users_view,
  c.avg_last_15_days_users_view,
  m.after_75_before_last_15_days_users_view,
  m.cbrt_after_75_before_last_15_days_users_view,
  c.avg_after_75_before_last_15_days_users_view,
  m.overall_sales,
  m.last_15_days_sale,
  m.cbrt_last_15_days_sale,
  c.avg_last_15_days_sale,
  m.last_30_days_sale,
  m.after_75_before_last_15_days_sale,
  m.cbrt_after_75_before_last_15_days_sale,
  c.avg_after_75_before_last_15_days_sale,
  m.overall_revenue,
  m.last_15_days_revenue,
  m.cbrt_last_15_days_revenue,
  c.avg_last_15_days_revenue,
  m.after_75_before_last_15_days_revenue,
  m.cbrt_after_75_before_last_15_days_revenue,
  c.avg_after_75_before_last_15_days_revenue
FROM Metrics m
LEFT JOIN CategoryAverages c
  ON m.categoryl1 = c.categoryl1
 AND m.price_category = c.price_category
WHERE m.item_code IS NOT NULL
GROUP BY
  1,  2,  3,  4,  5,  6,  7,  8,  9, 10,
  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
  31, 32, 33, 34, 35, 36
ORDER BY m.last_15_days_sale DESC
