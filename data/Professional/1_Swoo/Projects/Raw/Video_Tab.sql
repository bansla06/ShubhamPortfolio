## New App DAU

SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type = 'OPEN' AND app_version >= '7.0.0' AND app_version NOT LIKE '%debug%'
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2


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


## Video Tab Open and watched videos

Select date,body_name,count(distinct device_channel) as users from `analytics_data.ua_derived_data_v1` 
where date >= "2019-03-02" and lower(body_name) in ("videostab_open","videoplayer_open") group by 1,2


## TimeSpent Per Hour

SELECT date,EXTRACT(HOUR FROM occurred) as hour,Round(SUM(Seconds)/3600,2) as Time_Spent_hrs from (
SELECT *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, MILLISECOND)/1000 as Seconds from (
SELECT * FROM (
SELECT *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Time_Stamp,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Event
FROM (
SELECT DATE(occurred) as date,occurred ,device_channel,body_name,session_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= "2019-03-01"
--AND device_channel = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND body_name IN ("videoplayer_open","videoplayer_exit")
GROUP BY 1,2,3,4,5)) WHERE Next_Event = "videoplayer_exit")) GROUP BY 1,2 ORDER BY 1


## users & videos_watched per hour basis

SELECT date,hour,SUM(videos) as videos_watched,COUNT(DISTINCT device_channel) as users
FROM (
SELECT DATE(occurred) as date,EXTRACT(HOUR FROM occurred) as hour,device_channel,session_id,COUNT(DISTINCT video_id) as videos
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= "2019-03-01"
AND body_name IN ("videoplayer_playing")
GROUP BY 1,2,3,4)
GROUP BY 1,2 ORDER BY 1