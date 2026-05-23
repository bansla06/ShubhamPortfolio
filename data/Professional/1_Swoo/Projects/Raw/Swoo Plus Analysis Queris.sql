## Swoo Plus Analysis Queries By Shubham Bansla

#======================================================== Contest Players and Paying Demographics ===================================================== #
SELECT d.id , d.age , d.city, d.gender
FROM(
SELECT  distinct device_channel as device_channel
FROM `swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name = "pay2playgamepage_startedplaying")a
LEFT JOIN(
SELECT  device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name = "p2pmarketplace_marketplacetransactionsuccess")b
ON a.device_channel = b.device_channel
LEFT JOIN (
SELECT ua_notification_token, user_id
FROM `backend_tables.user_device` )c
ON b.device_channel = c.ua_notification_token
LEFT JOIN (
SELECT id , city , age , gender
FROM `backend_tables.user` )d
ON c.user_id = d.id
WHERE id IS NOT NULL

#======================================================= People Didnt Play Contest Games ==============================================================================#
SELECT device_channel, count(device_channel) AS count
from (
SELECT DISTINCT device_channel , date
FROM (
SELECT date , device_channel
FROM `swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name != "pay2playgamepage_startedplaying"
AND date >= "2019-06-04"
GROUP BY 1,2 ))
GROUP BY 1
ORDER BY count DESC

#=============================================================== Users Doing Repeated Transactions ======================================================================#
SELECT device_channel , count,  
CASE WHEN count = 1 THEN "ONCE REPEATED"
     WHEN count = 2 THEN "REPEATED TWICE"
     WHEN count = 3 THEN "REPEATED THRICE"
     WHEN count = 4 THEN "REPEATED FOUR TIMES"
     WHEN COUNT >= 5 THEN "REPEATED MORE THAN FIVE TIMES"
     ELSE 'NA' END AS repeatition, amt
FROM (
SELECT device_channel , count(device_channel) AS count
FROM  `swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name = "p2pmarketplace_marketplacetransactionsuccess"
GROUP BY 1) a
LEFT JOIN (
SELECT ua_notification_token, user_id
FROM `backend_tables.user_device` ) b
ON a.device_channel = b.ua_notification_token 
INNER JOIN(
SELECT user_id, sum(amount) AS amt
FROM `swoo_plus_db.ripple_user_successful_txn` 
GROUP BY 1) c
ON b.user_id = c.user_id 

"=========================================================== PACKAGE DETAILS ============================================================================================="

#=========================================================== Getting Gems Package Details ================================================================================ #
SELECT  B.package_id , B.cost_unit,B.items,B.package_name
FROM(
SELECT  DISTINCT package_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE date(occurred) = "2019-05-20"
AND device_channel = "5d52eadc-d4b1-4b1d-b472-ef4a54e39211") A
LEFT JOIN(
SELECT package_id , cost_unit,items,package_name
FROM `swoo-analytics-bq.swoo_plus_db.ripple_packages`) B
ON A.package_id = B.package_id

#====================== Package id and cost_amount
SELECT package_id , cost_amount
FROM(
SELECT package_id ,CAST (REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as INT64 ) as cost_amount
FROM `swoo_plus_db.ripple_packages` )
where cost_amount = 2


"=========================================================================================================================================================================="

##==================== ======================================================CAC-LTV MODEL================================================================== # 

#---------------------- PART-1-----------------------
SELECT b.date , count(distinct user_id) as distinct_transaction , sum(amount) as transaction_amount, count(amount) as no_of_transaction
FROM (
SELECT a.date , a.user_id , b.amount
FROM (
SELECT a.date , a.device_channel , b.user_id
FROM (
SELECT date,device_channel
FROM `swoo_plus_db.ua_pro_game_derived_data_v1`
WHERE body_name = "p2pmarketplace_marketplacetransactionsuccess"
GROUP BY 1,2) a
LEFT JOIN(
SELECT ua_notification_token , user_id 
FROM `backend_tables.user_device` ) b
ON a.device_channel = b.ua_notification_token ) a
LEFT JOIN( 
SELECT user_id ,  DATE(SAFE.TIMESTAMP_MILLIS(created_at)) AS date , amount
FROM `swoo-analytics-bq.swoo_plus_db.ripple_user_successful_txn` ) b
ON a.date = b.date AND a.user_id = b.user_id ) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 15 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 0 DAY)
GROUP BY 1
order BY 1

#------------------ PART- 2-------------------------
SELECT a.date , total_installs , new_users , (total_installs - new_users ) AS converted_users
FROM(
SELECT b.date , count(distinct device_channel) AS total_installs
FROM (
SELECT  device_channel, min(date) AS date
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN','OPEN')
GROUP BY 1) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 15 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 0 DAY)
GROUP BY 1
ORDER BY 1) a
LEFT JOIN (
SELECT b.date , count(distinct device_channel) AS new_users
FROM(
SELECT date , device_channel
FROM  `swoo_plus_db.ua_pro_app_derived_data_v1` 
WHERE type = "FIRST_OPEN") a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 15 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 0 DAY)
GROUP BY 1
ORDER BY 1) b
ON a.date = b.date
ORDER BY 1


#============================== Payment Gateway Success and Failure in Cash Out =======================================================#
SELECT a.date , no_of_failures , no_of_success 
FROM (
SELECT DATE(createDateTime) as date , count(DISTINCT USER_ID ) as no_of_failures 
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE TRANSACTION_SOURCE = "CASH_OUT"
AND TRANSACTION_TYPE = "DEBIT"
AND STATUS = "FAILURE"
GROUP BY 1 ) a
LEFT JOIN(
SELECT DATE(createDateTime) as date , count(DISTINCT USER_ID ) as no_of_success 
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE TRANSACTION_SOURCE = "CASH_OUT"
AND TRANSACTION_TYPE = "DEBIT"
AND STATUS = "SUCCESS"
GROUP BY 1 )b
ON a.date = b.date

#============================== DISTINCT TRANSACTION IN 15 DAYS =====================================================================#
SELECT b.date as Date,COUNT(distinct device_channel) as distinct_transactions
FROM (
SELECT date,device_channel
FROM `swoo_plus_db.ua_pro_game_derived_data_v1`
WHERE body_name = "p2pmarketplace_marketplacetransactionsuccess"
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 15 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 0 DAY)
GROUP BY 1
ORDER by 1


#=============================== Total Installs In 15 days =========================================================================== #
SELECT b.date , count(distinct device_channel) as total_installs
FROM (
SELECT  device_channel, min(date) as date
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN','OPEN')
GROUP BY 1) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 15 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 0 DAY)
group by 1
ORDER BY 1
