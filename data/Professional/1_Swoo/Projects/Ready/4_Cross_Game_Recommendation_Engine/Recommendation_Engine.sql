## Query for User Attributes

With Users as
(
Select device_channel from `app_analytics.ua_processed_db_v1` 
where date >= "2019-03-16" and body_name in ('videoplayer_playing') group by 1
)

, User_Ids as
(
Select user_id from Users A join `master_tables.user_device` B on A.device_channel = B.ua_notification_token
)

, Games_Played as
(
Select User_id, Sum(Case when game_type_id = "Bingo" then times end) as times_Bingo_Played,
                Sum(Case when game_type_id = "Trivia" then times end) as times_Trivia_Played,
                Sum(Case when game_type_id = "CandyRush" then times end) as times_CandyRush_Played,
                Sum(Case when game_type_id = "CardsGame" then times end) as times_CardsGame_Played,
                Sum(Case when game_type_id = "SwooperStar" then times end) as times_SwooperStar_Played
from (
select User_Id,B.game_type_id,count(distinct B.game_id) as times from `gaming_service_db.game` B 
join `gaming_service_db.user_game_statistics` A  on A.game_id = B.game_id where B.is_deleted = 0 and prize_money >= 1000 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND B.status_id IN (11,12)
group by 1,2) group by 1 
)

, Times_Games_Played as
(
 Select B.* from User_Ids A join Games_Played B on A.User_id = B.user_id
)

, Country as
(
Select A.*,B.country from Times_Games_Played A join `master_tables.user` B on A.user_id = B.id group by 1,2,3,4,5,6,7
)

, Session_Games_Played as
(
Select User_id,Sum(Case when Time = "Morning" then times end) as Games_Played_Morning,
               Sum(Case when Time = "AfterNoon" then times end) as Games_Played_AfterNoon,
               Sum(Case when Time = "Evening" then times end) as Games_Played_Evening
from (
Select User_id,Time,count(distinct game_id) as times from 
(
Select start_time,User_id,game_type_id,game_id,
Case when (extract(hour from start_time) >= 0 and extract(hour from start_time) < 6) then "Morning" 
     when (extract(hour from start_time) >= 6 and extract(hour from start_time) < 12) then "AfterNoon"
     when (extract(hour from start_time) >= 12 and extract(hour from start_time) <= 19) then "Evening"
end as Time
from (
select start_time,User_Id,B.game_type_id,B.game_id from `gaming_service_db.game` B 
join `gaming_service_db.user_game_statistics` A  on A.game_id = B.game_id where B.is_deleted = 0 and prize_money >= 1000 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND B.status_id IN (11,12)
group by 1,2,3,4
)) group by 1,2) group by 1 order by 1
)

Select A.*,B.Games_Played_Morning,B.Games_Played_AfterNoon,B.Games_Played_Evening from Country A join Session_Games_Played B on A.User_id = B.User_id


## Query for Item Attributes

With Video_Player_Opened as
(
select 
occurred,
REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "") as device_channel,
REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") as body_name,
REPLACE(JSON_EXTRACT(body, "$.properties.VideoId"), "\"", "") as VideoId,
REPLACE(JSON_EXTRACT(body, "$.properties.UserId"), "\"", "") as UserId
from `app_analytics.urban_airship_raw` 
where date(occurred) = "2019-03-01"
AND lower(REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "")) in ("videoplayer_playing")
GROUP BY 1,2,3,4,5
)
, Video_info as
(
Select A.occurred,A.device_channel,A.UserId,B.stream_id,B.user_id as broadcaster_id,B.id as Video_id,B.created from Video_Player_Opened A join `master_tables.broadcast` B on A.VideoId = B.stream_id order by stream_id
)
, Share_Download_ids as
(
Select device_channel,body_name from `app_analytics.ua_processed_db_v1` where body_name in ("videoplayer_shareclicked","videoplayer_downloadclicked")
and date = "2019-03-01"
)
, Share_Download as
(
Select occurred,device_channel,UserId,stream_id,broadcaster_id,Video_id,created,
case when videoplayer_shareclicked >=1 then "Yes" else "No" end as videoplayer_shareclicked,
case when videoplayer_downloadclicked >=1 then "Yes" else "No" end as videoplayer_downloadclicked from (
Select A.*,sum(case when B.body_name = "videoplayer_shareclicked" then 1 else 0 end) as videoplayer_shareclicked,
           sum(case when B.body_name = "videoplayer_downloadclicked" then 1 else 0 end) as videoplayer_downloadclicked
from Video_info A left join Share_Download_ids B on A.device_channel = B.device_channel group by 1,2,3,4,5,6,7)
)
, Watch_Time as
(
Select *,Case when (extract(hour from occurred) >= 0 and extract(hour from occurred) < 6) then "Morning" 
     when (extract(hour from occurred) >= 6 and extract(hour from occurred) < 12) then "AfterNoon"
     when (extract(hour from occurred) >= 12 and extract(hour from occurred) <= 19) then "Evening"
end as Watch_Time from Share_Download
)
, Votes as
(
Select broadcast_id,count(distinct user_id) as votes from `gaming_service_db.swooperstar_user_activity` where voted = 1 group by 1
)
, Details as
(
Select device_channel,UserId,stream_id,broadcaster_id,Video_id,created,videoplayer_shareclicked,videoplayer_downloadclicked,Watch_Time,B.votes from Watch_Time A left join Votes B on A.Video_id = B.broadcast_id
)
, Time_Spent_on_app as
(
Select user_id,Round(sum(session_length)/60,0) as Time_Spent_On_App_Minutes from `reporting_db.ua_user_sessions` group by 1 
)
, Details1 as
(
Select A.*,B.Time_Spent_On_App_Minutes from Details A left join Time_Spent_on_app B on A.device_channel = B.user_id
)

Select A.*,B.theme from Details1 A left join `gaming_service_db.swooperstar_game` B on date(A.created) = date(B.created_at)
group by 1,2,3,4,5,6,7,8,9,10,11,12























