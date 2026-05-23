--- ===================================================== \
--- CTE Table 
--- =====================================================

WITH fenty_items AS (
SELECT item_id , item_name , 
item_code, l2.brand_name as  brandname, 
l3.l1_category as categoryl1,
l4.l2_category as  categoryl2,
l5.l3_category as categoryl3
FROM (

SELECT item_id, item_name, item_code,
 brand_uid,
 SAFE_CAST(JSON_EXTRACT_SCALAR(json_element, '$.l1') AS INT64) AS l1,
 SAFE_CAST(JSON_EXTRACT_SCALAR(json_element, '$.l2') AS INT64) AS l2,
 SAFE_CAST(JSON_EXTRACT_SCALAR(json_element, '$.l3') AS INT64) AS l3,
 
FROM (
SELECT uid as item_id ,name as item_name, 
item_code,JSON_EXTRACT_ARRAY(multi_categories)[OFFSET(0)] AS json_element,
brand_uid,
FROM `tira-prod.orbis_pipe_dwh.item`  
WHERE brand_uid IN (1280,1288)) ) l1 
LEFT JOIN (
SELECT uid, name as brand_name
FROM `tira-prod.orbis_pipe_dwh.brand` ) l2
ON l1.brand_uid = l2.uid
LEFT JOIN (
SELECT uid, name as l1_category
FROM `tira-prod.orbis_pipe_dwh.category` ) l3 
ON l1.l1 = l3.uid
LEFT JOIN (
SELECT uid, name as l2_category
FROM `tira-prod.orbis_pipe_dwh.category` ) l4
ON l1.l2 = l4.uid
LEFT JOIN (
SELECT uid, name as l3_category
FROM `tira-prod.orbis_pipe_dwh.category` ) l5
ON l1.l3 = l5.uid
GROUP BY 1,2,3,4,5,6,7) ,

 metric_2 AS (
SELECT p1.item_id  ,p2.item_code, p2.item_name , p2.categoryl3 , p2.categoryl2, p2.categoryl1 , p2.brandname, 
p2.product_live_date ,DATE_DIFF(CURRENT_DATE() , product_live_date, day) as product_aging , p2.item_price, 


--- Previous Bins
-- CASE WHEN    p2.item_price   >= 0 AND    p2.item_price   <= 500 THEN '0-500' 
--   WHEN    p2.item_price   >= 501 AND     p2.item_price   <= 1000 THEN '501-1000'
--   WHEN    p2.item_price   >= 1001 AND    p2.item_price   <= 1500 THEN '1001-1500'
--   WHEN    p2.item_price   >= 1501 AND    p2.item_price   <= 2000 THEN '1501-2000'
--   WHEN    p2.item_price   >= 2001 AND    p2.item_price   <= 2500 THEN '2001-2500'
--   WHEN    p2.item_price   >= 2501 AND    p2.item_price   <= 3000 THEN '2501-3000'
--   WHEN    p2.item_price   >= 3001 AND    p2.item_price   <= 3500 THEN '3001-3500'
--   WHEN    p2.item_price   >= 3501 AND    p2.item_price   <= 4000 THEN '3501-4000'
--   WHEN    p2.item_price   >= 4001 AND    p2.item_price   <= 4500 THEN '4001-4500'
--   WHEN    p2.item_price   >= 4501 AND    p2.item_price   <= 5000 THEN '4501-5000'
--   WHEN    p2.item_price   >= 5001 AND    p2.item_price   <= 5500 THEN '5001-5500'
--   WHEN    p2.item_price   >= 5501 AND    p2.item_price   <= 6000 THEN '5501-6000'
--   WHEN    p2.item_price   >= 6001 AND    p2.item_price   <= 7000 THEN '6001-7000'
--   WHEN    p2.item_price   >= 7001 AND    p2.item_price   <= 8000 THEN '7001-8000'
--   WHEN    p2.item_price   >= 8001 AND    p2.item_price   <= 9000 THEN '8001-9000'
--   WHEN    p2.item_price   >= 9001 AND    p2.item_price   <= 10000 THEN '9001-10000'
--   WHEN    p2.item_price   >= 10001  THEN 'above 10000' END as price_category,


CASE
WHEN p2.item_price >=0   AND p2.item_price <=600  THEN '0-600'
WHEN p2.item_price >600  AND p2.item_price <=1200 THEN '600-1200'
WHEN p2.item_price >1200 AND p2.item_price <=2000 THEN '1200-2000'
WHEN p2.item_price >2000 AND p2.item_price <=4000 THEN '2000-4000'
WHEN p2.item_price >4000 AND p2.item_price <=6000 THEN '4000-6000'
WHEN p2.item_price >6000 AND p2.item_price <=8000 THEN '6000-8000'
WHEN p2.item_price >8000 AND p2.item_price <=10000 THEN '8000-10000'
WHEN p2.item_price >10000 THEN 'above 10000'
END AS price_category,





p2.cbrt_inventory_left,p2.inventory_left,
p1.overall_view,   p1.last_15_days_users_view,p1.cbrt_last_15_days_users_view,  p1.after_75_before_last_15_days_users_view, p1.cbrt_after_75_before_last_15_days_users_view,
p1.overall_sales,  p1.last_15_days_sale,   p1.last_30_days_sale,   p1.cbrt_last_15_days_sale,        p1.after_75_before_last_15_days_sale,       p1.cbrt_after_75_before_last_15_days_sale,
p1.overall_revenue,p1.last_15_days_revenue,   p1.cbrt_last_15_days_revenue,     p1.after_75_before_last_15_days_revenue,    p1.cbrt_after_75_before_last_15_days_revenue,


-- *********************************** 
-- Commented columns 
-- p1.users_view,p1.before_75_days_users_view, p1.overall_sales, 
-- p1.before_75_days_sale, p1.overall_revenue , p1.befor_75_days_revenue
--************************************
FROM (
SELECT * 
FROM `derived_table.TestingPopularityLogicV0_1`) p1 
LEFT JOIN (
SELECT t1.item_id  , t1.fynd_item_code as item_code , t2.item_name , t2.brandname , t2.categoryl1, t2.categoryl2, t2.categoryl3,
t1.item_price, t1.product_live_date, t1.inventory_left,
CBRT(t1.inventory_left) as cbrt_inventory_left 
FROM (



SELECT
item_id, fynd_item_code,
SUM(CAST(REPLACE(JSON_EXTRACT(quantities,'$.sellable.count'),'"','') AS INT64)) as inventory_left,
MAX(CAST(JSON_EXTRACT(price,'$.marked') AS FLOAT64)) as item_price,
--date_meta

MIN(CASE WHEN JSON_EXTRACT(date_meta,'$.added_on_store') like ('%$date%') THEN  DATE(TIMESTAMP_MILLIS(CAST(REPLACE(REPLACE(JSON_EXTRACT(date_meta,'$.added_on_store'),'{"$date":',''),'}','') AS INTEGER)))  
    WHEN JSON_EXTRACT(date_meta,'$.added_on_store') like('%T%') THEN CAST(SUBSTR(JSON_EXTRACT(date_meta,'$.added_on_store'),2,10) AS DATE) END )

as product_live_date
FROM `tira-prod.orbis_pipe_dwh.article` 
WHERE is_active = true

-- item_id IN (SELECT DISTINCT item_id FROM fenty_items) OR is_active = true
GROUP BY 1,2



-- SELECT
-- item_id, fynd_item_code,
-- SUM(CAST(REPLACE(JSON_EXTRACT(quantities,'$.sellable.count'),'"','') AS INT64)) as inventory_left,
-- MAX(CAST(JSON_EXTRACT(price,'$.marked') AS FLOAT64)) as item_price,
-- MIN(DATE(PARSE_TIMESTAMP('%c',REPLACE(REPLACE(JSON_EXTRACT(date_meta,'$.added_on_store'),'UTC',''),'"','') ))) as product_live_date
-- FROM `tira-prod.tira_boltic_integrations.tira_orbis_article` 
-- WHERE is_active = true
-- GROUP BY 1,2




) t1 
INNER JOIN (


-- SELECT  id as item_id , name as item_name , 
-- code as item_code , brand as brandname, 
-- REPLACE(REPLACE(l1_category,'["',''),'"]','') as categoryl1, 
-- REPLACE(REPLACE(l2_category,'["',''),'"]','') as  categoryl2,
-- l3_category_name as categoryl3
-- FROM `tira-prod.avis_dwh.item` 

SELECT CAST(uid AS INT64) as item_id , 
CAST(TRIM(item_code) AS STRING) AS item_code,
TRIM(name) AS item_name, 
TRIM(REPLACE(JSON_EXTRACT(attributes,'$.brand-name'),'"','')) as brandname,
TRIM(REPLACE(JSON_EXTRACT(attributes,'$.category-l3'),'"','')) as categoryl3, 

REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(JSON_EXTRACT(attributes,'$.category-l2')),'"',''),'Bath   Shower','Bath & Shower'),'Brushes   Applicators','Brushes & Applicators'),'Face   Body Tools','Face & Body Tools'),'Hands   Feet','Hands & Feet'),'Health   Safety','Health & Safety'),'Kits   Combos','Kits & Combos'),'Shaving   Hair Removal','Shaving & Hair Removal'),'Tools   Accessories','Tools & Accessories'),'Tools   Brush','Tools & Brush') as categoryl2,

REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(JSON_EXTRACT(attributes,'$.category-l1')),'"',''),'Tools   Brush','Tools & Brush'),'Tools   Brushes','Tools & Brushes'),'Bath   Body','Bath & Body'),'Bath   Body','Bath & Body'),'Mom   Baby','Mom & Baby'),'Tools   Appliances','Tools & Appliances'),'Free L','Free-L1') as categoryl1, 
FROM `tira-prod.orbis_pipe_dwh.item` 
GROUP BY 1,2,3,4,5,6,7







-- UNION ALL 

-- SELECT * FROM fenty_items




-- SELECT uid as item_id ,name as item_name , item_code ,
-- REPLACE(JSON_EXTRACT(attributes, '$.category_l1'),'"','') as categoryl1,
-- REPLACE(JSON_EXTRACT(attributes, '$.category_l2'),'"','') as categoryl2,
-- REPLACE(JSON_EXTRACT(attributes, '$.category_l3'),'"','') as categoryl3,
-- REPLACE(JSON_EXTRACT(attributes, '$.brand_name'),'"','') as brandname,
-- FROM `tira-prod.orbis_pipe_dwh.item` 
-- GROUP BY 1,2,3,4,5,6,7


)t2 
ON t1.item_id = CAST(t2.item_id AS INT64) ) p2 
ON p1.item_id = p2.item_id)


----- ===============================

SELECT * FROM (
SELECT y1.item_id  , y1.item_code , y1.item_name , y1.categoryl3 , y1.categoryl2, y1.categoryl1 , y1.brandname, 
y1.product_live_date ,  
y1.item_price, y1.price_category,
y1.inventory_left,
y1.cbrt_inventory_left,
-- CASE WHEN y1.product_aging > 45 THEN 0 ELSE y1.cbrt_inventory_left END as cbrt_inventory_left,
-- CASE WHEN y1.product_aging > 45 THEN 0 ELSE y1.product_aging END as product_aging ,
y1.product_aging,
y2.avg_product_aging,

-- 1. User View 
y1.overall_view, 
y1.last_15_days_users_view, y1.cbrt_last_15_days_users_view,  y2.avg_last_15_days_users_view,
y1.after_75_before_last_15_days_users_view, y1.cbrt_after_75_before_last_15_days_users_view,  y2.avg_after_75_before_last_15_days_users_view,
-- 2. User Sales / Quantity
y1.overall_sales,
y1.last_15_days_sale,y1.cbrt_last_15_days_sale, y2.avg_last_15_days_sale,
y1.last_30_days_sale,
y1.after_75_before_last_15_days_sale,y1.cbrt_after_75_before_last_15_days_sale, y2.avg_after_75_before_last_15_days_sale,
-- 3. Revenue 
y1.overall_revenue , 
y1.last_15_days_revenue,y1.cbrt_last_15_days_revenue, y2.avg_last_15_days_revenue,
y1.after_75_before_last_15_days_revenue,y1.cbrt_after_75_before_last_15_days_revenue, y2.avg_after_75_before_last_15_days_revenue,

FROM (
SELECT * 
FROM metric_2) y1
LEFT JOIN (
SELECT categoryl1, price_category, 
ROUND(AVG(product_aging),2) as avg_product_aging,

ROUND(AVG(cbrt_last_15_days_users_view),2) as avg_last_15_days_users_view,
ROUND(AVG(cbrt_after_75_before_last_15_days_users_view),2) as avg_after_75_before_last_15_days_users_view,

ROUND(AVG(cbrt_last_15_days_sale),2) as avg_last_15_days_sale,
ROUND(AVG(cbrt_after_75_before_last_15_days_sale),2) as avg_after_75_before_last_15_days_sale,

ROUND(AVG(cbrt_last_15_days_revenue),2) as avg_last_15_days_revenue,
ROUND(AVG(cbrt_after_75_before_last_15_days_revenue),2) as avg_after_75_before_last_15_days_revenue,

FROM metric_2
GROUP BY 1,2) y2 
ON y1.categoryl1 = y2.categoryl1 AND y1.price_category = y2.price_category) 
WHERE 
item_code IS NOT NULL 



GROUP BY 1,2,3,4,5,6,7,8,9,10,
11,12,13,14,15,16,17,18,19,20,
21,22,23,24,25,26,27,28,29,30,
31,32,33,34,35,36
ORDER BY last_15_days_sale DESC 

