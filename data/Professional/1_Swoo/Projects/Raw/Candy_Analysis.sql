## Candy Players By shows

SELECT DATE(occurred) AS DATE,extract(hour FROM occurred) AS show_time,count(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
AND body_name IN ("candyrush_started_playing") 
GROUP BY 1,2 
HAVING users >= 500


### CandyRush Winners

WITH A AS(
SELECT game_id,count(DISTINCT user_id) AS users 
FROM `swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1 AND game_type_id = "CandyRush"
GROUP BY 1)
,B AS(
SELECT DATE(start_time) AS DATE,game_id,title 
FROM `swoo_gaming_service.game` 
WHERE is_deleted = 0 AND status_id IN (11,12) 
AND game_type_id = "CandyRush" 
GROUP BY 1,2,3  
HAVING DATE >= "2019-03-03")

SELECT B.*,A.users FROM B 
LEFT JOIN A ON A.game_id = B.game_id


## Funnel Events for SwooperStar

SELECT DATE,body_name,COUNT(DISTINCT device_channel) AS users 
FROM `analytics_data.ua_derived_data_v1` 
WHERE DATE >= "2019-03-02" 
AND lower(body_name) IN ("livegamestab_open","videostab_open","videoplayer_open") 
GROUP BY 1,2


# Time Spent By Hour for CandyRush Game

WITH A AS(
SELECT CASE WHEN body_name  = "candyrush_started_playing" THEN occurred END AS candyrush_started_playing,
CASE WHEN body_name  = "candyrushgame_statsboardshown" THEN occurred END AS candyrushgame_statsboardshown,
device_channel,extract(hour FROM occurred) hour,DATE(occurred) AS DATE
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= "2019-02-10"
AND lower(body_name) IN ('candyrush_started_playing','candyrushgame_statsboardshown')
GROUP BY 1,2,3,4,5 ORDER BY 5,3,1,2)
, B AS(
SELECT min(candyrush_started_playing) AS start_time,max(candyrushgame_statsboardshown) AS end_time,device_channel,hour,date from A group by 3,4,5)
, C AS(
SELECT TIMESTAMP_DIFF(end_time, start_time, MINUTE) AS Minutes,device_channel,hour,date from B group by 1,2,3,4 having Minutes is not null)

Select date,Round(SUM(Minutes)/60,0) AS Time_Hours,hour from C group by 1,3 having Time_Hours > 10


## Candy Points

WITH A AS(
SELECT DATE(start_time) AS date,game_id,title 
FROM `swoo_gaming_service.game` 
WHERE DATE(start_time) = "2019-02-01"
AND is_deleted = 0 
AND (country_codes like '%IN%' OR country_codes like '%AE%')
AND status_id IN (11,12) group by 1,2,3)
,B AS(
SELECT game_id,round_number,level_number
FROM `swoo_gaming_service.candy_rush_round_detail` 
GROUP BY 1,2,3)
,C as(
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