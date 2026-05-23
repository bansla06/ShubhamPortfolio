--- ***************************************************************************
-- CTE :- For orders Table :- For Calculating Booked Sales And Amount Paid
--- ***************************************************************************
WITH OrderSummaryT1 AS (
SELECT * FROM (
SELECT  a.*, b.bag_id as cancel_bag_id
FROM (
SELECT  date ,bag_id,order_id ,Amount_Paid,quantity ,parent_promo_bags,MRP,user_id,source,item_id
FROM  `tira-prod.dashboard_agg_tables.BagsStateDeriveTable`
WHERE state = 'Placed')a 
LEFT JOIN (
SELECT DISTINCT bag_id FROM `tira-prod.dashboard_agg_tables.BagsStateDeriveTable`
WHERE state IN ('Cancelled by Customer','Cancelled by Seller'))b
ON a.bag_id = b.bag_id
GROUP BY  1,2,3,4,5,6,7,8,9,10,11)
WHERE cancel_bag_id IS NULL ) , 

 fenty_items AS (
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
GROUP BY 1,2,3,4,5,6,7) 





---================================================================
-- Populairty logic Part - 1 Derived Table 
---================================================================
SELECT t2.item_id, 
-- 1. View
t2.users_view as overall_view,
t2.last_15_days_users_view, cbrt_last_15_days_users_view,
t2.after_75_before_last_15_days_users_view,cbrt_after_75_before_last_15_days_users_view,
-- 2. Sales / Quantity
overall_sales,
t3.last_15_days_sale, t3.cbrt_last_15_days_sale, 
t3.last_30_days_sale,
t3.after_75_before_last_15_days_sale,t3.cbrt_after_75_before_last_15_days_sale,  
-- 3.Revenue
overall_revenue,
t3.last_15_days_revenue, t3.cbrt_last_15_days_revenue, 
t3.after_75_before_last_15_days_revenue, t3.cbrt_after_75_before_last_15_days_revenue, 

-- Commented Out Columns 
-- t2.users_view, t2.before_75_days_users_view, t3.overall_sales,
-- t3.before_75_days_sale,t3.overall_revenue , t3.befor_75_days_revenue

FROM (



SELECT item_id , 
COUNT(DISTINCT user_pseudo_id) as users_view,
--- Non Normalise Column 
COUNT(DISTINCT CASE WHEN date >= (Current_date()-15 ) THEN user_pseudo_id END) as last_15_days_users_view,
COUNT(DISTINCT CASE WHEN date >=  (CURRENT_DATE() - 15)- 60
                     AND date < (CURRENT_DATE() - 15) 
                      THEN user_pseudo_id END) as after_75_before_last_15_days_users_view,


--- Normalised Column
CBRT(COUNT(DISTINCT CASE WHEN date >= (Current_date()-15 ) THEN user_pseudo_id END)) as cbrt_last_15_days_users_view,
CBRT(COUNT(DISTINCT CASE WHEN date >=  (CURRENT_DATE() - 15)- 60
                     AND date < (CURRENT_DATE() - 15) 
                      THEN user_pseudo_id END)) as cbrt_after_75_before_last_15_days_users_view,
-- COUNT(DISTINCT CASE WHEN date <=  (CURRENT_DATE() - 15)- 60   THEN user_pseudo_id END) as  before_75_days_users_view
FROM (
SELECT date,item_name , 
CASE WHEN item_id = 0 AND item_id_new IS NOT NULL THEN item_id_new ELSE item_id END as item_id , user_pseudo_id , session_id 
FROM (
SELECT event_timestamp,DATE(event_timestamp) as date ,item_id , item_name ,  LEAD(item_id) OVER (PARTITION BY item_name ORDER BY item_id) as item_id_new,
user_pseudo_id , session_id 
FROM `derived_table.dashboard_derived_table`
WHERE event_name = 'view_item'
AND event_date >= CURRENT_DATE()- 90
) 
WHERE item_id != 0 OR item_name != '(not set)'
GROUP BY 1,2,3,4,5)
GROUP BY 1

-- UNION ALL 

-- SELECT DISTINCT(item_id) as item_id, 1 as users_view, 1 as last_15_days_users_view, 
-- 1 as after_75_before_last_15_days_users_view, 1 as cbrt_last_15_days_users_view, 
-- 1 as cbrt_after_75_before_last_15_days_users_view 
-- FROM fenty_items

) t2 

LEFT JOIN (
SELECT Item_id as Item_uid , 
-- MAX(MRP) as item_price,
SUM(quantity) as overall_sales, 

-- **************************************************************
-- QUANTITY / SALES COLUMN 
-- **************************************************************
--- Non Normalise Column 
SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15) THEN quantity END) as last_15_days_sale,
SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 30) THEN quantity END) as last_30_days_sale,
SUM(CASE WHEN DATE(date) >=  (CURRENT_DATE() - 15)- 60 AND DATE(date) < (CURRENT_DATE() - 15) THEN quantity END) as after_75_before_last_15_days_sale,
--- Normalised Column
CBRT(SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15) THEN quantity END)) as cbrt_last_15_days_sale,
CBRT(SUM(CASE WHEN DATE(date) >=  (CURRENT_DATE() - 15)- 60 AND DATE(date) < (CURRENT_DATE() - 15) THEN quantity END)) as cbrt_after_75_before_last_15_days_sale,

-- ***************************************************************
-- REVENUE COLUMN 
-- **************************************************************
-- SUM(CASE WHEN DATE(date) <=  (CURRENT_DATE() - 15)- 60  THEN quantity END) as before_75_days_sale,
SUM(Amount_Paid * quantity) as overall_revenue,
--- Non Normalise Column 
SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15) THEN (Amount_Paid * quantity) END) as last_15_days_revenue,
SUM(CASE WHEN DATE(date) >=  (CURRENT_DATE() - 15)- 60 AND DATE(date) < (CURRENT_DATE() - 15) THEN (Amount_Paid * quantity) END) as after_75_before_last_15_days_revenue,
--- Normalised Column
CBRT(SUM(CASE WHEN DATE(date) >= (CURRENT_DATE() - 15) THEN (Amount_Paid * quantity) END)) as cbrt_last_15_days_revenue,
CBRT(SUM(CASE WHEN DATE(date) >=  (CURRENT_DATE() - 15)- 60 AND DATE(date) < (CURRENT_DATE() - 15) THEN (Amount_Paid * quantity) END)) as cbrt_after_75_before_last_15_days_revenue,
-- SUM(CASE WHEN DATE(date) <=  (CURRENT_DATE() - 15)- 60  THEN (Amount_Paid * quantity) END) as befor_75_days_revenue,

FROM OrderSummaryT1
GROUP BY 1) t3 
ON t2.item_id = t3.Item_uid 
ORDER BY overall_revenue DESC 









