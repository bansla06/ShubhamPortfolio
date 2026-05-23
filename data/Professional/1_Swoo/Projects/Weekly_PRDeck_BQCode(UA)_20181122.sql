--- Code for derived table (Destination table : swoo-analytics-bq:analytics_data.urban_airship_derived_data_v1)
SELECT DATE(occurred) as date,device_channel,type,body_name
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-05-01'
AND type IN ('FIRST_OPEN','OPEN','CUSTOM','UNINSTALL')
GROUP BY 1,2,3,4





--- DAU, WAU & MAU
SELECT a.date as Date,a.dau as DAU,b.wau as WAU,c.mau as MAU 
FROM (
SELECT date,COUNT(DISTINCT device_channel) as dau
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1) a
JOIN (
SELECT b.date as Date,COUNT(DISTINCT device_channel) as wau 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1) b
ON a.date = b.date
JOIN (
SELECT b.date as Date,COUNT(DISTINCT device_channel) as mau 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN 
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 30 DAY) AND a.date <= b.date
GROUP BY 1) c
ON b.date = c.date
ORDER BY 1




--- Components of WAU (LastWeekUsers)
SELECT a.date as Date,COUNT(DISTINCT a.device_channel) as LastWeekUsers
FROM (
SELECT b.date as Date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2) a
JOIN (
SELECT b.date as Date,device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1


--- Components of WAU (NewUsers)
SELECT b.date as Date,COUNT(DISTINCT device_channel) as NewUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1





--- D1, D7, D14 & D30 Retention (Install Retention)
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2



SELECT Date,(D1/D0) as D1,(D7/D0) as D7,(D14/D0) as D14,(D30/D0) as D30
FROM (
SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `derived_data.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `derived_data.ua_app_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5




--- distinct players query
SELECT date,COUNT(DISTINCT device_channel) as distinctgameplayers
FROM `analytics_data.ua_derived_data_v1`
WHERE type IN ('CUSTOM')
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1



--- x_games_played query
SELECT date,x_games_played,COUNT(DISTINCT device_channel) as users
FROM (
SELECT date,device_channel,COUNT(times) as x_games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,EXTRACT(HOUR FROM occurred) as times
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-11-10' AND DATE(occurred) <= '2018-11-19'
AND type IN ('CUSTOM')
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3)
GROUP BY 1,2)
GROUP BY 1,2




--- game_wise DAU (x_games_played) query
SELECT date,x_games_played,body_name,COUNT(DISTINCT device_channel) as users
FROM (
SELECT date,device_channel,body_name,COUNT(times) as x_games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,body_name,EXTRACT(HOUR FROM occurred) as times
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-11-10' AND DATE(occurred) <= '2018-11-19'
AND type IN ('CUSTOM')
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3,4)
GROUP BY 1,2,3)
GROUP BY 1,2,3




--- game players by shows (for all games)
SELECT DATE(occurred) AS date,EXTRACT(HOUR FROM occurred) AS hour,body_name,COUNT(DISTINCT(device_channel)) AS users
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred)>='2018-11-10' AND DATE(occurred) <= CURRENT_DATE()
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3




--- App users activity (low, medium & high)
SELECT week,x_games_played,COUNT(DISTINCT user_id) AS users
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, device_channel AS user_id,COUNT(DISTINCT date) AS x_games_played
FROM `analytics_data.ua_derived_data_v1`
WHERE date >='2018-04-01' AND date <= CURRENT_DATE()
--AND EXTRACT(WEEK FROM date) > 0 
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2)
GROUP BY 1,2



--- Game players activity (low, medium & high)
SELECT week,x_games_played,COUNT(DISTINCT user_id) AS users
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, device_channel AS user_id,COUNT(DISTINCT date) AS x_games_played
FROM `analytics_data.ua_derived_data_v1`
WHERE date >='2018-04-01' AND date <= CURRENT_DATE()
--AND EXTRACT(WEEK FROM date) > 0 
AND body_name IN ('bingo_started_playing', 'trivia_started_playing', 'candyrush_started_playing')
GROUP BY 1,2)
GROUP BY 1,2




--- Game wise WAU, Components of WAU table
--- Code for derived table (Destination table : swoo-analytics-bq:derived_data.ua_game_derived_data_v1)
SELECT date,body_name,device_channel
FROM `analytics_data.ua_derived_data_v1`
WHERE type IN ('CUSTOM')
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3





--- Game wise WAU
SELECT b.date as Date,CASE WHEN body_name = "trivia_started_playing" THEN "Trivia"
WHEN body_name = "bingo_started_playing" THEN "Bingo"
WHEN body_name = "candyrush_started_playing" THEN "CandyKrack"
ELSE "Other" END AS Game_Type, COUNT(DISTINCT device_channel) AS WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
AND b.date >= '2018-11-01'
GROUP BY 1,2


--- Game wise LastWeekUsers
SELECT b.date as Date,CASE WHEN b.body_name = "trivia_started_playing" THEN "Trivia"
WHEN b.body_name = "bingo_started_playing" THEN "Bingo"
WHEN b.body_name = "candyrush_started_playing" THEN "CandyKrack"
ELSE "Other" END AS Game_Type, COUNT(DISTINCT a.device_channel) as LastWeekUsers 
FROM (
SELECT b.date as date,body_name,device_channel 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2,3) a
JOIN (
SELECT b.date as date,body_name,device_channel 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3) b
ON a.date = b.date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2


--- Game wise NewUsers
SELECT b.date as Date,CASE WHEN a.body_name = "trivia_started_playing" THEN "Trivia"
WHEN a.body_name = "bingo_started_playing" THEN "Bingo"
WHEN a.body_name = "candyrush_started_playing" THEN "CandyKrack"
ELSE "Other" END AS Game_Type, COUNT(DISTINCT a.device_channel) AS NewUsers 
FROM (
SELECT body_name,device_channel,MIN(date) as date
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2





--- Game wise Retention WAU
SELECT b.date as Date,body_name,device_channel--COUNT(DISTINCT a.developer_identity) as WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2,3


--- Game wise Retention CURR
SELECT b.date as Date,b.body_name as body_name,b.device_channel as device_channel--COUNT(DISTINCT a.developer_identity) as LastWeekUsers 
FROM (
SELECT b.date as date,body_name,device_channel
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3) a
JOIN (
SELECT b.date as date,body_name,device_channel
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 20 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 14 DAY)
GROUP BY 1,2,3) b
ON a.date = b.date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2,3


--- Game wise Retention NURR
SELECT b.date as Date,body_name,device_channel--,COUNT(DISTINCT developer_identity) AS NewUsers
FROM (
SELECT body_name,device_channel,MIN(date) as date
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3


--- Game wise Retention RURR
SELECT b.date as Date,body_name,device_channel 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3


--- Game wise NURR %
SELECT a.Date as Date,a.body_name as body_name,(b.NURR/a.NURR_D) as NURR FROM (
SELECT Date,body_name,COUNT(DISTINCT device_channel) as NURR_D
FROM `derived_data.Game_wise_UA_Retention_NURR` 
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.Date as Date,a.body_name as body_name,COUNT(DISTINCT a.device_channel) as NURR FROM (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_WAU` 
GROUP BY 1,2,3) a
JOIN (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_NURR` 
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2) b
ON a.Date = b.Date AND a.body_name = b.body_name


--- Game wise CURR %
SELECT a.Date as Date,a.body_name as body_name,(b.CURR/a.CURR_D) as CURR FROM (
SELECT Date,body_name,COUNT(DISTINCT device_channel) as CURR_D
FROM `derived_data.Game_wise_UA_Retention_CURR` 
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.Date as Date,a.body_name as body_name,COUNT(DISTINCT a.device_channel) as CURR FROM (
SELECT Date,body_name,device_channel 
FROM `derived_data.Game_wise_UA_Retention_WAU` 
GROUP BY 1,2,3) a
JOIN (
SELECT Date,body_name,device_channel 
FROM `derived_data.Game_wise_UA_Retention_CURR` 
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2) b
ON a.Date = b.Date AND a.body_name = b.body_name


--- Game wise RURR %
SELECT a.Date as Date,a.body_name as body_name,(b.RURR/a.RURR_D) as RURR FROM (
SELECT a.Date as Date,a.body_name as body_name,COUNT(DISTINCT a.device_channel) as RURR_D 
FROM (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_RURR`
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_CURR`
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_NURR`
GROUP BY 1,2,3) c
ON a.Date = c.Date AND a.body_name = c.body_name AND a.device_channel = c.device_channel
WHERE b.device_channel IS NULL AND c.device_channel IS NULL
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.Date as Date,a.body_name as body_name,COUNT(DISTINCT a.device_channel) as RURR 
FROM (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_WAU`
GROUP BY 1,2,3) a
JOIN (
SELECT a.Date as Date,a.body_name as body_name,a.device_channel as device_channel
FROM (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_RURR`
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT Date,body_name,device_channel 
FROM `derived_data.Game_wise_UA_Retention_CURR`
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT Date,body_name,device_channel
FROM `derived_data.Game_wise_UA_Retention_NURR`
GROUP BY 1,2,3) c
ON a.Date = c.Date AND a.body_name = c.body_name AND a.device_channel = c.device_channel
WHERE b.device_channel IS NULL AND c.device_channel IS NULL
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel 
GROUP BY 1,2) b
ON a.Date = b.Date AND a.body_name = b.body_name


--- Game wise WoW
SELECT a.Date as Date,a.body_name as body_name,COUNT(DISTINCT a.device_channel) as WoW FROM (
SELECT b.date as Date,body_name,device_channel --COUNT(DISTINCT developer_identity) as WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1` 
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT b.date as Date,body_name,device_channel --COUNT(DISTINCT developer_identity) as WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1` 
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel 
WHERE b.device_channel IS NOT NULL
GROUP BY 1,2









--- App Retention table
--- Code for derived table (Destination table : swoo-analytics-bq:derived_data.ua_app_derived_data_v1)
SELECT date,type,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3





--- App Retention WAU
SELECT b.date as Date,device_channel--COUNT(DISTINCT a.developer_identity) as WAU 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1` where type IN ('FIRST_OPEN','OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2


-- App Retention CURR
SELECT b.date as Date,b.device_channel as device_channel--COUNT(DISTINCT a.developer_identity) as LastWeekUsers 
FROM (
SELECT b.date as date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1` where type IN ('FIRST_OPEN','OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) a
JOIN (
SELECT b.date as date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1` where type IN ('FIRST_OPEN','OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 20 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 14 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2


--- App Retention NURR
SELECT b.date as Date,device_channel--,COUNT(DISTINCT developer_identity) AS NewUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2


--- App Retention RURR
SELECT b.date as Date,device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2


--- App Retention NURR %
SELECT a.Date as Date,(b.NURR/a.NURR_D) as NURR_P FROM (
SELECT Date,COUNT(DISTINCT device_channel) as NURR_D
FROM `derived_data.App_UA_Retention_NURR` 
GROUP BY 1) a
LEFT JOIN (
SELECT a.Date as Date,COUNT(DISTINCT a.device_channel) as NURR FROM (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_WAU` 
GROUP BY 1,2) a
JOIN (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_NURR` 
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
GROUP BY 1) b
ON a.Date = b.Date 


--- App Retention CURR %
SELECT a.Date as Date,(b.CURR/a.CURR_D) as CURR_P FROM (
SELECT Date,COUNT(DISTINCT device_channel) as CURR_D
FROM `derived_data.App_UA_Retention_CURR` 
GROUP BY 1) a
LEFT JOIN (
SELECT a.Date as Date,COUNT(DISTINCT a.device_channel) as CURR FROM (
SELECT Date,device_channel 
FROM `derived_data.App_UA_Retention_WAU` 
GROUP BY 1,2) a
JOIN (
SELECT Date,device_channel 
FROM `derived_data.App_UA_Retention_CURR` 
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
GROUP BY 1) b
ON a.Date = b.Date


--- App Retention RURR %
SELECT a.Date as Date,(b.RURR/a.RURR_D) as RURR_P FROM (
SELECT a.Date as Date,COUNT(DISTINCT a.device_channel) as RURR_D 
FROM (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_RURR`
GROUP BY 1,2) a
LEFT JOIN (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_CURR`
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_NURR`
GROUP BY 1,2) c
ON a.Date = c.Date AND a.device_channel = c.device_channel
WHERE b.device_channel IS NULL AND c.device_channel IS NULL
GROUP BY 1) a
LEFT JOIN (
SELECT a.Date as Date,COUNT(DISTINCT a.device_channel) as RURR 
FROM (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_WAU`
GROUP BY 1,2) a
JOIN (
SELECT a.Date as Date,a.device_channel as device_channel
FROM (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_RURR`
GROUP BY 1,2) a
LEFT JOIN (
SELECT Date,device_channel 
FROM `derived_data.App_UA_Retention_CURR`
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT Date,device_channel
FROM `derived_data.App_UA_Retention_NURR`
GROUP BY 1,2) c
ON a.Date = c.Date AND a.device_channel = c.device_channel
WHERE b.device_channel IS NULL AND c.device_channel IS NULL
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel 
GROUP BY 1) b
ON a.Date = b.Date





--- App WoW
	SELECT a.Date as Date,COUNT(DISTINCT a.device_channel) as WoW FROM (
	SELECT b.date as Date,device_channel --COUNT(DISTINCT developer_identity) as WAU 
	FROM (
	SELECT date,device_channel
	FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_dummy` 
	GROUP BY 1,2) a
	CROSS JOIN (
	SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
	WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
	GROUP BY 1) b
	WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
	GROUP BY 1,2) a
	LEFT JOIN (
	SELECT b.date as Date,device_channel --COUNT(DISTINCT developer_identity) as WAU 
	FROM (
	SELECT date,device_channel
	FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_dummy` 
	GROUP BY 1,2) a
	CROSS JOIN (
	SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
	WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
	GROUP BY 1) b
	WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
	GROUP BY 1,2) b
	ON a.Date = b.Date AND a.device_channel = b.device_channel 
	WHERE b.device_channel IS NOT NULL
	GROUP BY 1

--- VENN Diagram
-- 3 intersetion

SELECT COUNT(DISTINCT DEVICE_CHANNEL) FROM(
SELECT DEVICE_CHANNEL FROM `analytics_data.ua_derived_data_v1`
where body_name IN ('trivia_started_playing','bingo_started_playing','candyrush_started_playing') 
and date = '2018-11-25' and type = 'CUSTOM'
group by DEVICE_CHANNEL
having count(Distinct body_name) = 3)

-- 2 intersection

SELECT COUNT(DISTINCT DEVICE_CHANNEL) FROM(
SELECT DEVICE_CHANNEL FROM `analytics_data.ua_derived_data_v1`
where body_name IN ('trivia_started_playing','bingo_started_playing') and date = '2018-11-25' and type = 'CUSTOM'
AND device_channel not in
(select device_channel from `analytics_data.ua_derived_data_v1` where 
body_name in ('candyrush_started_playing') and date = '2018-11-25'
GROUP BY 1)
group by DEVICE_CHANNEL
having count(Distinct body_name) = 2)

-- unique

select date,count(Distinct device_channel) from(
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1`
WHERE type IN ('CUSTOM') AND date = '2018-11-25'
AND body_name IN ('trivia_started_playing') and device_channel not in
(select device_channel from `analytics_data.ua_derived_data_v1` where body_name in ('bingo_started_playing','candyrush_started_playing') and date = '2018-11-25'
GROUP BY 1)) group by 1

--- seperating trivia and poll mania

--step 1: get game ids
select start_time,game_id,game_type_id,EXTRACT(HOUR FROM start_time) AS hour,title 
from `swoo_gaming_service.game` 
where is_deleted = 0 and game_type_id in ('Trivia') and EXTRACT(HOUR FROM start_time) =16 
and date(start_time) >= '2018-11-23'

-- step 2: calculate users

select date(occurred) as date,count(Distinct device_channel) from `analytics_data.urban_airship_v2` 
where game_id in ("491f60ff-5387-414d-aa15-9940861f0379",
"84f61ecf-ae75-40df-b9f8-ba44252e1abe",
"7360aca2-1358-48c7-9f03-fcdf962be6e9",
"6a5d2da7-cce4-4449-8dfc-3b76c9cdb123",
"cd5812c4-ad1f-4f23-b7cf-5d6d5a21bad5",
"657ad5e8-5813-4af1-8965-b8247c31134c",
"6827be0e-d81a-411a-a7ea-e77bbca904d0",
"fd696aef-c28f-44cb-9767-cad5355ec84a",
"48ce5f8d-3d2a-43ed-b1d2-84072112259c",
"4c9acded-70e2-4c84-8d43-1b69f1eae462",
"7d14c985-c506-4a7a-986b-a5d756792841",
"c87f0841-7967-41f0-a65f-2fef32ab63b0",
"468ef3b1-8f45-4bc4-93e9-06e9f10cf257") and type = "CUSTOM" and body_name = "trivia_started_playing"
and date(occurred) >= "2018-11-23"
group by 1


-- Swoo In app Purchases
select DATE(std.`created_at`) as Date, Sum(Case When std.`store_type` = 0 Then b.`price` Else 0 End) as Android_Revenue, Sum(Case When std.`store_type` = 1 Then b.`price` Else 0 End)  as IOS_Revenue 
from `store_transaction_details`  std 
INNER JOIN `bundle`  b on std.`product_id` = b.`product_id` 
where b.`region_id` = 'IN' and std.`transaction_status` = 1 
and std.`verification_successful` = 1 and std.`is_test_order` = 0 
group by DATE(std.`created_at`)


-- Video Inflow

select date(occurred) as date,count(distinct device_channel),body_name from `analytics_data.urban_airship_v2` 
where body_name in ("swooperstar_recordingdone","swooperstar_recordingstarted")
and date(occurred) >= "2019-03-03"  group by 1,3



select date(created), count(distinct broadcast_id)
from speakerswire_service_db.contest_broadcast
group by 1
order by 1


-- After app feedback

“SELECT `feedback`.`id` AS `id`, `feedback`.`user_id` AS `user_id`, `feedback`.`comments` AS `comments`,
`feedback`.`language_code` AS `language_code`, `feedback`.`region` AS `region`,
`feedback`.`sub_type` AS `sub_type`, `feedback`.`time_stamp` AS `time_stamp`, `feedback`.`type` AS `type`, `feedback`.`user_handle` AS `user_handle`,
IF(`feedback_item_id_1` = “app_experience”, `feedback_item_value_1`,
   IF(`feedback_item_id_2` = “app_experience”, `feedback_item_value_2`,
       IF(`feedback_item_id_3` = “app_experience”, `feedback_item_value_3`,
           IF(`feedback_item_id_4` = “app_experience”, `feedback_item_value_4`,
               IF(`feedback_item_id_5` = “app_experience”, `feedback_item_value_5`,
                   IF(`feedback_item_id_6` = “app_experience”, `feedback_item_value_6`, 0
)))))) as `app_experience`
FROM `feedback` ORDER BY `time_stamp`”




SELECT a.date as acq_date,b.date as play_date,COUNT(DISTINCT b.user_id) as users
FROM (
SELECT DATE(created_at) as date,user_id
FROM `swoo_gaming_service`.`user_statistics`
WHERE DATE(created_at) >= '2018-10-18' AND DATE(created_at) <= '2018-12-03'
AND is_referral_applied = '1'
AND is_deleted = '0'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo_gaming_service`.`user_game_statistics`
WHERE DATE(created_at) >= '2018-10-18' AND DATE(created_at) <= '2018-12-03'
AND is_deleted = '0'
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2





select date(created_at) as date,game_id,game_type_id from `swoo-analytics-bq.swoo_gaming_service.game` 
where lower(game_type_id) = 'swooperstar' and is_deleted = 0 group by 1,2,3




Select date(occurred) as date,count(distinct device_channel),Extract(hour from occurred) as hour,body_name from `swoo-analytics-bq.analytics_data.urban_airship_v2` 
where date(occurred) >= "2019-03-03" 
and body_name in ("swooperstar_videosubmitclick","swooperstar_gamelandingscreen") group by 1,3,4

Select count(distinct device_channel) as users from `analytics_data.urban_airship_v2` where date(occurred) >= "2019-03-04"
and date(occurred) <= "2019-03-10"
and body_name in ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing','swooperstar_gamelandingscreen','teenpatti_started_playing')



"SwooperstarVideoFragment_Open"
"Swooperstar_Played"
swooperstar_gamelandingscreen
swooperstar_videosubmitclick
swooperstar_videosubmittedscreenshown
swooperstar_sharebuttonclicked
teenpatti_started_playing
"SWOOPERSTAR_SIGNAL_RECEIVED"

candyrushgame_statboardshown
candyrushgame_statsboardshown
candyrushwon_open
candyrushnotwon_open


## Winning Ratio

Select A.date,B.users_played,A.users_won,A.game_type_id,(A.users_won/B.users_played)*100 as Winning_Ratio from (
(select date(updated_at) as date,count(distinct user_id) as users_won,game_type_id from `swoo_gaming_service.user_game_statistics` where games_won = 1 and date(updated_at) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)group by 1,3 order by date desc) A
left join
(select date(updated_at) as date,count(distinct user_id) as users_played,game_type_id from `swoo_gaming_service.user_game_statistics`
where date(updated_at) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
group by 1,3 order by date desc) B on A.date = B.date and A.game_type_id = B.game_type_id)


--- Append to  (Destination table : swoo-analytics-bq:analytics_data.ua_derived_data_v1)
SELECT DATE(occurred) as date,device_channel,type,body_name
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND type IN ('FIRST_OPEN','OPEN','CUSTOM','UNINSTALL')
GROUP BY 1,2,3,4


--- Append to  (Destination table : `swoo-analytics-bq.daily_dashboard.Ringer_Optins`)
select A.date,Count(distinct A.device_channel) as Ringer_Optins from 
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where type = "FIRST_OPEN" and date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) group by 1,2) A
inner join 
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where lower(body_name) in ("games_cardsgame_ringer_opted",
"games_swooperstar_ringer_opted",
"games_candyrush_ringer_opted",
"games_bingo_ringer_opted",
"games_trivia_ringer_opted",
"games_triviaoptin",
"games_bingooptin",
"games_candyrushoptin") and date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) group by 1,2) B on A.date = B.date and A.device_channel = B.device_channel group by 1



--- Append to  (Destination table : `swoo-analytics-bq.daily_dashboard.New_Users_Winning_Ratio`)
select A.date,count(Distinct A.user_id) as new_users,count(Distinct B.user_id) as users_won
,count(Distinct B.user_id)*100/count(Distinct A.user_id) as winning_ratio from 
(select A.date,B.user_id from 
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where type = "FIRST_OPEN" and date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)) A
left join 
(select ua_notification_token,user_id from `swoo-analytics-bq.backend_tables.user_device` group by 1,2) B on A.device_channel = B.ua_notification_token group by 1,2) A
left outer join
(select date(updated_at) as date,user_id from `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
where games_won =1 group by 1,2) B on A.user_id = B.user_id and A.date = B.date group by 1




--- # No:of users per game in a week
Select A.week,A.games_played,A.users,b.date from 
(select week,games_played,count(distinct user_id) as users from (
select date(updated_at) as date,EXTRACT(ISOWEEK FROM updated_at) AS week,user_id,count(distinct game_id) as games_played 
from `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
group by date,user_id,week)
group by week,games_played order by week,games_played) A
inner join
(select min(date(updated_at)) as date,EXTRACT(ISOWEEK FROM updated_at) AS week
from `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
group by week) B on A.week = B.week order by date


## Lives consumed per day
Select A.start_time as CDate,sum(-B.transaction_amount) as TotalLivesConsumed	 from
(select game_id,date(start_time) as start_time from `swoo_gaming_service.game` group by 1,2) A
left join
(select user_id,source_id,transaction_amount from `swoo-analytics-bq.swoo_gaming_service.lives_transaction_history`
where source_type = 2 and date(created_at) >= "2019-01-09" group by 1,2,3) B on A.game_id = B.source_id
where A.start_time = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) group by 1 order by 1


## Number of games played and reffered others

With A as(
Select ua_notification_token from 
(select date,ua_notification_token from 
(select date(updated_at) as date,user_id from `swoo_gaming_service.user_game_statistics` where games_won = 1 
and date(updated_at) >= "2019-01-01" and date(updated_at) <= "2019-01-24" group by 1,2) A
left join
(select user_id,ua_notification_token from `backend_tables.user_device` group by 1,2) B on A.user_id = B.user_id) A
left join
(SELECT date,device_channel FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` WHERE LOWER(BODY_NAME) in ('profileothers_shareprofile','bingo_won_shared','bingowon_share','bingoreferral_share','bingowonnot_share','bingo_referred',
'bingonotwon_share','triviagetmorelives_share','triviawinners_share','trivia_reffered','candyrushreferral_share','candy_won_shared',
'candyrushwon_share','candyrushnotwon_share','candyrush_referred','cardsgame_inviteandearn','cardsgame_referred','cardsgame_signupfacebook',
'swooperstar_sharebuttonclicked','cardwon_share','cardnotwon_share') and date >= "2019-01-01" and date <= "2019-01-24" group by 1,2)
on ua_notification_token = device_channel where device_channel is null group by 1)

SELECT x_games_played,COUNT(DISTINCT user_id) AS users
FROM (
SELECT device_channel AS user_id,COUNT(DISTINCT date) AS x_games_played
FROM `analytics_data.ua_derived_data_v1`
WHERE body_name IN ('bingo_started_playing','trivia_started_playing','candyrush_started_playing','swooperstar_gamelandingscreen','teenpatti_started_playing')
and device_channel in (select ua_notification_token from A group by 1)
GROUP BY 1)
GROUP BY 1


### Number of lives consumed for game type

Select A.start_time,A.game_type_id,sum(-B.transaction_amount) as lives from
(select game_id,game_type_id,date(start_time) as start_time from `swoo_gaming_service.game` group by 1,2,3) A
left join
(select user_id,source_id,transaction_amount from `swoo-analytics-bq.swoo_gaming_service.lives_transaction_history`
where source_type = 2 and date(created_at) >= "2019-01-09" group by 1,2,3) B on A.game_id = B.source_id
where A.start_time >= "2019-01-09" and A.start_time < "2019-01-29" group by 1,2 having sum(-B.transaction_amount) is not null order by 1

## Joined through Referrals
select date(referral_applied_time) as date,count(user_id) from `swoo_gaming_service.user_statistics` 
where is_referral_applied = 1 and is_deleted = 0 and date(referral_applied_time) >= "2019-01-01" group by 1 order by 1 desc

With A as
(
select date(referral_applied_time) as date,user_id from `swoo_gaming_service.user_statistics` where is_referral_applied = 1 and is_deleted = 0 and date(referral_applied_time) >= "2018-12-01" 
)
, B as
(
select user_id,ua_notification_token from `backend_tables.user_device` 
)

Select A.date,count(distinct ua_notification_token) From A INNER JOIN B on A.user_id = B.user_id group by 1 order by 1 desc

## referrals made

SELECT date,count(device_channel) as referrals_made FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` WHERE LOWER(BODY_NAME) in ('bingo_won_shared','bingoreferral_share','bingowonnot_share',
'bingonotwon_share','triviagetmorelives_share','triviawinners_share','trivia_reffered','candyrushreferral_share',
'candyrushwon_share','candyrushnotwon_share','cardsgame_referred',
'swooperstar_sharebuttonclicked','cardwon_share','cardnotwon_share') and date >= "2019-01-01" and date <= "2019-01-27" group by 1 order by 1 desc

## Time Difference between Registrations and installs in Minutes

With A as
(
Select occurred as install_date,device_channel from `analytics_data.urban_airship_v2` where type = "FIRST_OPEN" 
and date(occurred) >= "2019-01-01" and date(occurred) <= "2019-01-27" group by 1,2 
)
, B as
(
Select occurred as signup_date,device_channel from `analytics_data.urban_airship_v2` where lower(body_name) = "signup_done" 
and date(occurred) >= "2019-01-01" and date(occurred) <= "2019-01-27" group by 1,2
)
Select TIMESTAMP_DIFF(B.signup_date,A.install_date,HOUR) as HOUR
      --,TIMESTAMP_DIFF(B.signup_date,A.install_date,SECOND) as CSECOND
      ,COUNT(DISTINCT A.device_channel)
from A INNER JOIN B 
ON A.device_channel = B.device_channel
WHERE B.signup_date > A.install_date
group by 1 
--having CMINUTE >= 0 
order by 1,2 

## Referrals aceepted users Retention

WITH A as
(
select date(referral_applied_time) as joined_date,user_id from `swoo_gaming_service.user_statistics` 
where is_referral_applied = 1 and is_deleted = 0 and date(referral_applied_time) >= "2018-12-01" group by 1,2
)
, B as
(
Select date(created) as created_date,user_id,ua_notification_token from `swoo-analytics-bq.backend_tables.user_device` group by 1,2,3
)
, C as
(
Select A.joined_date,B.created_date,B.ua_notification_token from  A inner join B on A.user_id = B.user_id 
group by 1,2,3
)
, D as
(
Select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` where type = "FIRST_OPEN" 
and date >= "2018-12-01" group by 1,2
)
, E as
(
Select C.joined_date,C.ua_notification_token from C left join D on C.ua_notification_token = D.device_channel
and C.joined_date = D.date group by 1,2 order by 1 desc
)

SELECT Date,(D1/D0) as D1,(D7/D0) as D7,(D14/D0) as D14,(D30/D0) as D30
FROM (
SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT E.joined_date AS DATE,E.ua_notification_token AS device_channel
FROM E
GROUP BY 1,2) a
Left JOIN (
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('OPEN') AND DATE >= "2018-12-01"
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5


### Number of lives generated for game type

select date(created_at) as date,sum(transaction_amount) as lives_generated from `swoo_gaming_service.lives_transaction_history` 
where source_type not in (0,2,8,9,10) and date(created_at) >= "2019-01-10" and date(created_at) <= "2019-02-21" group by 1 order by 1

## Lives Earned by Source

select date(created_at) as date,sum(transaction_amount) as lives_generated,case when source_type = 1 then "New User Live"
     when source_type = 4 then "Challenge"
     when source_type = 5 then "Trivia Game Bonus"
     when source_type = 7 then "SwooperStar Game Bonus"
     when (source_type = 11 or source_type = 12) then "Applied Referral Code" end as Source from `swoo_gaming_service.lives_transaction_history` 
where source_type not in (0,2) and date(created_at) >= "2019-01-10"  group by 1,3 order by 1

select date(created_at) as date,sum(transaction_amount) as lives_generated,case when source_type = 1 then 'New User Live'
     when source_type = 3 then 'Awarded For Game Played'
     when source_type = 4 then 'Challenge'
     when source_type = 5 then 'Trivia Game Bonus'
     when source_type = 7 then 'SwooperStar Game Bonus'
     when (source_type = 11 or source_type = 12) then 'Applied Referral Code'
     when source_type = 14 then 'CandyCashless/Watch N Earn'
     end as Source from `swoo_gaming_service.lives_transaction_history` 
where source_type not in (0,2,8,9,10) and date(created_at) >= "2019-01-10" and date(created_at) <= "2019-02-21" group by 1,3 order by 1


## Lives from Ads

select date,count(distinct device_CHANNEL) as users,body_name from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-29" and upper(body_name) in ('AD_VIDEO_OPENED','AD_REWARD_SUCCESS') group by 1,3 order by 1

## Seperate Trivia and Pollmania

WITH Games AS
(
SELECT EXTRACT(HOUR FROM start_time) AS CHour
      ,EXTRACT(MINUTE FROM start_time) AS CMinute
      ,game_id
      ,game_type_id
      ,title
FROM `swoo_gaming_service.game`
WHERE is_deleted = 0 AND game_type_id IN ('Trivia') AND EXTRACT(HOUR FROM start_time) =16
AND date(start_time) >= '2018-12-23'
)
SELECT EXTRACT(DATE FROM occurred) as CDate
      ,CMinute
      ,CASE 
          WHEN CMinute = 0 THEN "Trivia"
          WHEN CMinute = 30 THEN "Poll"
          ELSE "NA"
       END AS GameType
      ,COUNT(Distinct device_channel) AS DistinctUsers
FROM `analytics_data.urban_airship_v2` UAS
INNER JOIN Games 
ON uas.game_id = Games.game_id
AND type = "CUSTOM" 
AND body_name = "trivia_started_playing"
AND date(occurred) >= "2018-12-23"
GROUP BY CDate
        ,CMinute
        ,GameType
ORDER BY CDate
        ,CMinute
        ,GameType



## Number of GaMES HAPPENED

select date(start_time) as date,count(distinct game_id) as games from (
select DATETIME(start_time, 'Asia/Kolkata') as Date_IST,start_time,game_id,updated_at,game_type_id,prize_money from `swoo_gaming_service.game`  where is_deleted = 0 and prize_money >= 1000 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12) order by start_time) group by 1 order by date



## Bingo Preferential Cards
SELECT a.date,SUBSTR(title,STRPOS(title, ':')-2,8) as show_time,sum(b.users) as Players,sum(b.winners) as winners
FROM (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(created_at) >= '2019-01-14'
AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12) and game_type_id = "Bingo"
GROUP BY 1,2,3) a
JOIN (
SELECT a.game_id,a.tag_id,a.claim_type_id,COUNT(DISTINCT a.user_id) as users,COUNT(DISTINCT CASE WHEN b.games_won = 1 THEN a.user_id END) as winners
FROM (
SELECT game_id,tag_id,claim_type_id,user_id--COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE  tag_id IS NOT NULL AND claim_type_id IN ('0','1','2','3','4','5')
AND DATE(created_at) >= '2019-01-14'
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT game_id,user_id,games_won
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE is_deleted = 0
AND game_type_id = 'Bingo'
GROUP BY 1,2,3) b
ON a.game_id = b.game_id AND a.user_id = b.user_id 
GROUP BY 1,2,3) b
ON a.game_id = b.game_id
GROUP BY 1,2 order by date


## Bingo preferential card new users

WITH A AS
(
select A.date as Install_Date,B.date as Sign_Up_Started_Date,A.device_channel as Installs,B.device_channel as Signups from 
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-14" and type = 'FIRST_OPEN' group by 1,2) A
LEFT join
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-14" and LOWER(body_name) = 'signup_started' group by 1,2) B 
on A.device_channel = B.device_channel and A.date = B.date group by 1,2,3,4 order by 1
)
,B AS
(
select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-14" and LOWER(body_name) = 'logged_in'
group by 1,2
)
,C AS
(
select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-14" and LOWER(body_name) = 'signup_done'
group by 1,2
)
,D AS
(
Select A.date as date,A.device_channel as New_Users from 
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-14" and type = 'FIRST_OPEN' group by 1,2) A
left join 
(Select date as install_date,A.device_channel as new_installs,Logged_In as Reinstalls from 
(select date,device_channel from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-14" and type = 'FIRST_OPEN' group by 1,2) A
left join
(Select A.install_date,Logged_In from (
(Select A.install_date,A.Sign_Up_Started_Date,A.Installs,A.Signups,B.date as Logged_In_date,B.device_channel as Logged_In from A
LEFT JOIN B ON A.install_date = B.date and A.Signups = B.device_channel) A
LEFT JOIN
(Select A.install_date,A.Sign_Up_Started_Date,A.Installs,A.Signups,C.date as Signup_done_date,C.device_channel as Sign_up_done from A
LEFT JOIN C ON A.install_date = C.date and A.Signups = C.device_channel) B ON Logged_In = Sign_up_done
AND Logged_In_date = A.install_date) where Signup_done_date is null group by 1,2 order by 1) B
on B.Logged_In = A.device_channel and A.date = B.install_date group by 1,2,3 order by 1) B
on A.device_channel = B.Reinstalls where B.Reinstalls is null group by 1,2 order by 1)
,E AS
(
Select user_id, ua_notification_token from `backend_tables.user_device` group by 1,2
)
,F AS
(
Select date,user_id as new_user from D left join E on D.New_Users = E.ua_notification_token group by 1,2 order by 1
)
,G AS
(
SELECT a.date,SUBSTR(title,STRPOS(title, ':')-2,8) as show_time,b.users as users,b.winners as winners
FROM (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(start_time) >= '2019-01-14'
AND (country_codes like '%IN%' OR country_codes like '%AE%') and game_type_id = "Bingo"
GROUP BY 1,2,3) a
JOIN (
SELECT a.game_id,a.tag_id,a.claim_type_id,a.user_id as users,CASE WHEN b.games_won = 1 THEN a.user_id END as winners
FROM (
SELECT game_id,tag_id,claim_type_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE  tag_id IS NOT NULL AND claim_type_id IN ('0','1','2','3','4','5')
AND DATE(created_at) >= '2019-01-14'
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT game_id,user_id,games_won
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE is_deleted = 0
AND game_type_id = 'Bingo'
GROUP BY 1,2,3) b
ON a.game_id = b.game_id AND a.user_id = b.user_id 
GROUP BY 1,2,3,4,5) b
ON a.game_id = b.game_id
GROUP BY 1,2,3,4 order by date
)
, H AS
(
Select G.date as date1,show_time,count(distinct users) as users,count(distinct winners) as winners,count(distinct new_user) as new_user_winners from G left join F on F.date = G.date and winners = new_user
group by 1,2 order by 1,2
)
, I AS
(
Select F.date,count(distinct F.new_user) as new_users from F group by 1
)
Select H.*,new_users from H inner join I on date = date1 order by date


Select date,Players,winners,case when show_time = " 8:00 AM" then "08:00 AM"
when show_time = " 2:00 PM" then "02:00 PM" 
when show_time = " 7:30 PM" then "07:30 PM"
when show_time = " 6:00 PM" then "06:00 PM"
else show_time
end as show_timing
from `daily_dashboard.Bingo_Preferential_Cards` 


## Referrals

With A as
(
SELECT date,count(device_channel) as referrals_made FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` WHERE LOWER(BODY_NAME) in ('bingo_won_shared','bingoreferral_share','bingowonnot_share',
'bingonotwon_share','triviagetmorelives_share','triviawinners_share','trivia_reffered','candyrushreferral_share',
'candyrushwon_share','candyrushnotwon_share','cardsgame_referred',
'swooperstar_sharebuttonclicked','cardwon_share','cardnotwon_share') and date >= "2018-12-01" group by 1 order by 1 desc
), 
B as
(
SELECT date,count(distinct device_channel) as users_referred FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` WHERE LOWER(BODY_NAME) in ('bingo_won_shared','bingoreferral_share','bingowonnot_share',
'bingonotwon_share','triviagetmorelives_share','triviawinners_share','trivia_reffered','candyrushreferral_share',
'candyrushwon_share','candyrushnotwon_share','cardsgame_referred',
'swooperstar_sharebuttonclicked','cardwon_share','cardnotwon_share') and date >= "2018-12-01" group by 1 order by 1 desc
),
C as
(
Select A.date,referrals_made,users_referred from A join B on A.date = B.date
),
D as
(
select date(referral_applied_time) as date,user_id from `swoo_gaming_service.user_statistics` where is_referral_applied = 1 and is_deleted = 0 and date(referral_applied_time) >= "2018-12-01" 
),
E as
(
select user_id,ua_notification_token from `backend_tables.user_device` 
)
, F as
(
Select D.date,count(distinct ua_notification_token) as Joined_Through_Referrals From D INNER JOIN E on D.user_id = E.user_id group by 1 order by 1 desc
)
Select C.date,referrals_made,users_referred,Joined_Through_Referrals from C Join F on C.date = F.date order by 1

## Lives Generated Per Source

(select date(created_at) as date,sum(transaction_amount) as lives_generated,case when source_type = 1 then "New User Live"
     when source_type = 4 then "Challenge"
     when source_type = 5 then "Trivia Game Bonus"
     when source_type = 7 then "SwooperStar Game Bonus"
     when (source_type = 11 or source_type = 12) then "Applied Referral Code" end as Source from `swoo_gaming_service.lives_transaction_history` 
where source_type not in (0,2) and date(created_at) >= "2019-01-10" group by 1,3 having source is not null order by 1)
Union ALL
(select date,count(distinct device_CHANNEL) as Lives_generated,body_name as source from `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
where date >= "2019-01-29" and upper(body_name) in ('AD_VIDEO_OPENED','AD_REWARD_SUCCESS') group by 1,3 order by 1)

Munagala Snehit [2:53 PM]
http://etljobs.swoo.tv
snehit
welcome
`/var/lib/jenkins/swoo-dwh`

prod deck automatio

https://docs.google.com/spreadsheets/d/1ofa6ycC2yxnMgMwnymIZucX_wFX24rO5X5buOplLJ-I/edit?usp=sharing


## Cumulative Wallet Balance

WITH day_wise_wallet_balence as (
WITH day_wise_earnings AS (
SELECT date,USER_ID,CASE WHEN total_earned IS NULL THEN 0 ELSE total_earned END AS total_earned,CASE WHEN total_cash_out IS NULL THEN 0 ELSE total_cash_out END AS total_cash_out
FROM (
SELECT date,USER_ID,SUM(earned) as total_earned,SUM(cash_out) as total_cash_out
FROM (
SELECT DATE(createDateTime,'Asia/Kolkata') as date,USER_ID,CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT END as earned,CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT END as cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
-- AND USER_ID = 11371758
GROUP BY 1,2,3,4)
GROUP BY 1,2)
GROUP BY 1,2,3,4)
SELECT date,USER_ID,ROUND(((SELECT SUM(total_earned) FROM day_wise_earnings b WHERE b.date <= a.date AND b.USER_ID = a.USER_ID)-(SELECT SUM(total_cash_out) FROM day_wise_earnings c WHERE c.date <= a.date AND c.USER_ID = a.USER_ID)),2) as wallet_balence
FROM day_wise_earnings a
GROUP BY 1,2,3)
SELECT date,ROUND(SUM(wallet_balence),0) as cum_wallet_balence
FROM day_wise_wallet_balence where date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1 ORDER BY 1

## Retention for games by hour

With A as
(
select date(occurred) as date,extract(hour from occurred) as hour,game_id,user_id,device_channel from `analytics_data.urban_airship_v2` 
where lower(body_name) in ("candyrush_started_playing")
and date(occurred) >= "2019-02-22" group by 1,2,3,4,5
)
, B as
(
select date(start_time) as date,extract(hour from start_time)as hour,game_id,title,game_type_id from `swoo_gaming_service.game` 
where date(start_time) >= "2019-02-22" and date(start_time) <= "2019-02-25" and game_type_id = "CandyRush" order by 1,2
)
, C as
(
Select A.date,A.hour,A.game_id,A.user_id,A.device_channel,B.title from A left join B on A.game_id = B.game_id
)

SELECT Date,hour,title,(D1/D0) as D1,(D2/D0) as D2,(D3/D0) as D3,(D4/D0) as D4
FROM (
SELECT Date,hour,title,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D2',Users,NULL)) as D2,MAX(IF(Retention = 'D3',Users,NULL)) as D3,MAX(IF(Retention = 'D4',Users,NULL)) as D4
FROM ( 
SELECT a.date as Date,A.hour as hour,A.title,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 2 DAY) THEN 'D2'
WHEN b.date = DATE_ADD(a.date,INTERVAL 3 DAY) THEN 'D3'
WHEN b.date = DATE_ADD(a.date,INTERVAL 4 DAY) THEN 'D4'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.user_id) as Users
FROM
(Select C.date,C.hour,C.game_id,C.user_id,C.device_channel,C.title from C) A
left join
(Select C.date,C.hour,C.game_id,C.user_id,C.device_channel,C.title from C) B
on A.user_id = B.user_id and A.hour = B.hour GROUP BY 1,2,3,4 having Users > 100 order by 1)
WHERE Retention != 'NA'
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5,6,7 order by 1


## Candy Points

With A as
(
Select date(start_time) as date,game_id,title from `swoo_gaming_service.game` where date(start_time) = "2019-02-01"
and is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12) group by 1,2,3
)
,B as
(
select game_id,round_number,level_number from `swoo_gaming_service.candy_rush_round_detail` group by 1,2,3
), C as
(
Select date,title,round_number,level_number,B.game_id from A left join B on A.game_id = B.game_id where B.game_id is not null order by 1,2,3,4
)
, D as
(
select device_channel,level_no,box_level,points,game_id from `analytics_data.urban_airship_v2` where date(occurred) = "2019-02-01" 
and body_name = 'candyrushgame_statsboardshown' group by 1,2,3,4,5
)
, E as
(
Select date,device_channel,C.game_id,title,round_number,level_number,box_level,points,
COALESCE(LAG(points,1) OVER (PARTITION BY date,device_channel,C.game_id,title ORDER BY title,round_number),'0') AS Previous_Round_Points
from D left join C on CAST(C.round_number AS INT64) = CAST(D.level_no AS INT64) and C.game_id = D.game_id where C.game_id is not null and device_channel = "c76b613e-3258-41d8-b71e-0847f03f886c" group by 1,2,3,4,5,6,7,8 order by title,round_number
)

Select date,device_channel,game_id,title,round_number,level_number,box_level,
CAST((CAST(points as int64)-CAST(Previous_Round_Points as int64)) AS INT64) as points from E GROUP BY 1,2,3,4,5,6,7,8 order by title,round_number


## Time Spent By Hour for CandyRush Game

With A as
(
SELECT case when body_name  = "candyrush_started_playing" then occurred end as candyrush_started_playing,
case when body_name  = "candyrushgame_statsboardshown" then occurred end as candyrushgame_statsboardshown,
device_channel,extract(hour from occurred) hour,date(occurred) as date
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= "2019-02-10"
AND lower(body_name) in ('candyrush_started_playing','candyrushgame_statsboardshown')
group by 1,2,3,4,5 order by 5,3,1,2
)
, B as
(
Select min(candyrush_started_playing) as start_time,max(candyrushgame_statsboardshown) as end_time,device_channel,hour,date from A group by 3,4,5
)
, C as
(
Select TIMESTAMP_DIFF(end_time, start_time, MINUTE) as Minutes,device_channel,hour,date from B group by 1,2,3,4 having Minutes is not null
)

Select date,Round(SUM(Minutes)/60,0) AS Time_Hours,hour from C group by 1,3 having Time_Hours > 10



## Players By Country

With A as
(
select date(occurred) as date,REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") as event,REPLACE(JSON_EXTRACT(device, "$.attributes.locale_country_code"), "\"", "") as country_code,REPLACE(JSON_EXTRACT(device, "$.attributes.device_model"), "\"", "") as device_model,
REPLACE(JSON_EXTRACT(device, "$.attributes.carrier"), "\"", "") as carrier,
REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as device_channel,
REPLACE(JSON_EXTRACT(device, "$.attributes.iana_timezone"), "\"", "") as iana_timezone
from `analytics_data.urban_airship_raw` 
where date(occurred) >= "2019-03-01"
--and REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND lower(REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "")) in ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing','swooperstar_gamelandingscreen','teenpatti_started_playing')
GROUP BY 1,2,3,4,5,6,7 having device_channel is not null order by 1
)
, B as 
(
Select alpha2_code,name from `backend_tables.country` group by 1,2
)

Select iana_timezone,count(distinct device_channel) as users from A group by 1 order by 2 desc



## D1 Retention For New Version

With A as
(
select date(occurred) as date,
REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as device_channel
from `analytics_data.urban_airship_raw` 
where date(occurred) >= "2019-03-02"
--and REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND lower(REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "")) like ('livegamestab_open')
GROUP BY 1,2 having device_channel is not null order by 1
)
, B as
(
SELECT min(date) as start_date,device_channel from A group by 2
)
, C as
(
Select start_date,date as play_date,A.device_channel from A left join B on A.device_channel = B.device_channel group by 1,2,3
)


SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT start_date as date,device_channel
FROM C
GROUP BY 1,2) a
LEFT JOIN (
SELECT play_date as date,device_channel
FROM C
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1


## New User D1 Retention for Old Version

with A as
(
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('FIRST_OPEN') and date >= "2019-03-02"
GROUP BY 1,2
)
, B as
(
select date(occurred) as date,
REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as device_channel
from `analytics_data.urban_airship_raw` 
where date(occurred) >= "2019-03-02"
--and REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND lower(REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "")) in ('livegamestab_open')
GROUP BY 1,2 having device_channel is not null order by 1
)
, C as
(
Select A.date,A.device_channel from
(SELECT date,device_channel FROM A GROUP BY 1,2) a
LEFT JOIN 
(SELECT date,device_channel FROM B GROUP BY 1,2) b
ON a.device_channel = b.device_channel and A.date = B.date 
where B.device_channel is null group by 1,2
)


SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM C
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('OPEN') and date >= "2019-03-02"
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1

## New User D1 Retention for New Version

with A as
(
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('FIRST_OPEN') and date >= "2019-03-02"
GROUP BY 1,2
)
, B as
(
select date(occurred) as date,
REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as device_channel
from `analytics_data.urban_airship_raw` 
where date(occurred) >= "2019-03-02"
--and REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND lower(REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "")) in ('livegamestab_open')
GROUP BY 1,2 having device_channel is not null order by 1
)
, C as
(
Select A.date,A.device_channel from
(SELECT date,device_channel FROM A GROUP BY 1,2) a
LEFT JOIN 
(SELECT date,device_channel FROM B GROUP BY 1,2) b
ON a.device_channel = b.device_channel and A.date = B.date 
where B.device_channel is not null group by 1,2
)


SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM C
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE type IN ('OPEN') and date >= "2019-03-02"
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1


### CandyRush Winners

With A as
(
Select game_id,count(distinct user_id) as users from `swoo_gaming_service.user_game_statistics` where games_won = 1 and game_type_id = "CandyRush"
group by 1
)
,B as
(
Select date(start_time) as date,game_id,title from `swoo_gaming_service.game` where is_deleted = 0 and status_id in (11,12) 
and game_type_id = "CandyRush" group by 1,2,3  having date >= "2019-03-03"
)

Select B.*,A.users from B left join A on A.game_id = B.game_id


## Funnel Events for SwooperStar

Select date,body_name,count(distinct device_channel) as users from `analytics_data.ua_derived_data_v1` 
where date >= "2019-03-02" and lower(body_name) in ("livegamestab_open","videostab_open","videoplayer_open") group by 1,2


## Time Spent on SwooperStar Tab


Select date,Round(SUM(Seconds)/3600,0) as Time_Spent_hrs from (
Select *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, MILLISECOND)/1000 as Seconds from (
Select * from (
select *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Time_Stamp,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Event
from (
select date(occurred) as date,occurred ,
REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as device_channel,
REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") as body_name,
REPLACE(JSON_EXTRACT(body, "$.session_id"), "\"", "") as session_id
--REPLACE(JSON_EXTRACT(body, "$.last_delivered.time"), "\"", "") as time
from `analytics_data.urban_airship_raw` 
where date(occurred) >= "2019-03-01"
--and REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND lower(REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "")) in ("videoplayer_open","videoplayer_exit")
GROUP BY 1,2,3,4,5 having device_channel is not null)) where Next_Event = "videoplayer_exit")) group by 1 order by 1



## Candy Players By shows

Select date(occurred) as date,extract(hour from occurred) as show_time,count(distinct device_channel) as users from `analytics_data.urban_airship_v2` where date(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
and body_name in ("candyrush_started_playing") group by 1,2 having users >= 500


--Select UserId,Array_AGG(VideoId) AS Watched_Videos from Video_Player_Opened group by UserId


Select A.*,B.Time_Spent_On_App_Minutes,'dummy' as dummy from Details A 
join Time_Spent_on_app B on A.device_channel = B.user_id)
select a.*,(case when a.created >= b.submission_start_time AND a.created <= b.submission_end_time THEN b.theme END) as theme from details1 a
left join (select *,'dummy' as dummy from `swoo-analytics-bq.swoo_gaming_service.swooperstar_game`) b ON a.dummy = b.dummy group by 1,2,3,4,5,6,7,8,9,10,11,12,13 order by UserId


















