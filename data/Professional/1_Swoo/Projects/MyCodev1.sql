SELECT event_name FROM `analytics_data.bingo_clicks` 
WHERE DATE(timestamp) = DATE("2018-07-14") GROUP BY 1



def table_truncate(query,table_name,db_name):
	# dataset_id = 'your_dataset_id'
	dataset_id = db_name
	# Set the destination table
	table_ref = client.dataset(dataset_id).table(table_name)
	job_config = bigquery.QueryJobConfig()
	# For TRUNCATING or OVERWRITING the table
	job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
	sql = query
	print('Query to table has started {}'.format(table_ref.path))
	query_job = client.query(
    	sql,
    	# Location must match that of the dataset(s) referenced in the query
    	# and of the destination table.
    	location='US',
    	job_config=job_config) # API request - starts the query
	query_job.result()  # Waits for the query to finish
	print('Query results loaded to table {}'.format(table_ref.path))



dau_wau_mau = """
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
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 30 DAY) AND a.date <= b.date
GROUP BY 1) c
ON b.date = c.date
WHERE a.date >= DATE_SUB(CURRENT_DATE(), INTERVAL 15 DAY)
ORDER BY 1"""

table_truncate(dau_wau_mau,'DAU_WAU_MAU','derived_data')




select DATE(occurred) as date,

,
REPLACE(JSON_EXTRACT(body, "$['properties'].quesNumber"), "\"", "") as question_number,
CASE REPLACE(JSON_EXTRACT(body, "$['properties'].isExpired"), "\"", "")
 WHEN "true" THEN "Expired"
 WHEN "false" THEN "Valid"
 ELSE "NA"
END as expired, count(distinct(device_channel)) as count
from analytics_data.urban_airship
WHERE occurred BETWEEN TIMESTAMP('2018-09-12') AND TIMESTAMP('2018-09-14')
AND JSON_EXTRACT(body, "$['properties'].signalName") in ('"DISPLAY_QUESTION"')
AND JSON_EXTRACT(body, "$['properties'].gameId") = '"044d4f15-0bfa-4655-8b05-fba6fd2919e5"'
AND body_name='trivia_signal_received'
group by 1, 2, 3, 4 ORDER BY 3 ASC, 4 desc;


SELECT REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") as game_id,body_name,MIN(occurred) as min_occ FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-12') AND TIMESTAMP('2018-09-13')  
AND REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") IN ('1031959c-e619-4734-a168-d1214cfb68a1')
--,'36cde1ef-1f47-46cc-9a90-e0be2c6b2fcc','0a24582f-c016-4727-9259-06d5ba368fce')
--AND body_session_id IN ('b9d99a9a-fb4b-49f5-8ea6-48cb8c3c725d','830adfd0-4c9a-4617-8dc1-9eee40320175','4c2ba24d-278d-4532-85d6-fb51cf1f0362')
GROUP BY 1,2 ORDER BY 3 LIMIT 2000


SELECT body_name FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-01') AND TIMESTAMP('2018-09-24') GROUP BY 1


SELECT body_name,occurred,COUNT(*) FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-23') AND TIMESTAMP('2018-09-24') 
AND REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") IN ('75d7daca-6375-459c-b0e2-0ff8a729c935')
AND LOWER(body_name) LIKE '%bingo%'
GROUP BY 1,2 ORDER BY 2


SELECT a.date as Date,COUNT(DISTINCT a.device_channel) as Users_Dismmed_Ringer FROM (
SELECT DATE(occurred) as date,device_channel FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-01') AND TIMESTAMP('2018-09-25') 
AND body_name IN ('triviaringer_open','bingoringer_open')
GROUP BY 1,2) a
JOIN (
SELECT DATE(occurred) as date,device_channel FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-01') AND TIMESTAMP('2018-09-25') 
AND body_name IN ('triviaringer_dismiss','bingoringer_dismiss')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel GROUP BY 1


SELECT DATE(occurred) as date,COUNT(DISTINCT device_channel) as Users_who_got_ringer FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-01') AND TIMESTAMP('2018-09-25') 
AND body_name IN ('triviaringer_open','bingoringer_open')
GROUP BY 1



SELECT DATE(occurred) as date,COUNT(DISTINCT device_channel) as Users_who_dismissed_ringer FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-01') AND TIMESTAMP('2018-09-25') 
AND body_name IN ('triviaringer_dismiss','bingoringer_dismiss')
GROUP BY 1


ringer_back


SELECT REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") as game_id,body_session_id --,body_name,EXTRACT(HOUR(occurred),COUNT(*)
FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-23') AND TIMESTAMP('2018-09-24') 
AND REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") IN ('75d7daca-6375-459c-b0e2-0ff8a729c935')
--AND LOWER(body_name) LIKE '%bingo%'
GROUP BY 1,2


SELECT body_name,occurred,COUNT(*)
FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-23') AND TIMESTAMP('2018-09-24') 
AND REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") IN ('75d7daca-6375-459c-b0e2-0ff8a729c935')
AND LOWER(body_name) LIKE '%bingo%'
GROUP BY 1,2 ORDER BY 2



SELECT body_name,EXTRACT(HOUR(occurred),COUNT(*)
FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-23') AND TIMESTAMP('2018-09-24') 
AND REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") IN ('75d7daca-6375-459c-b0e2-0ff8a729c935')
AND LOWER(body_name) LIKE '%bingo%'
GROUP BY 1,2 ORDER BY 2


SELECT REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") as game_id, body --body_session_id, body_name,EXTRACT(HOUR(occurred),COUNT(*)
FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-23') AND TIMESTAMP('2018-09-24') 
AND REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "") IN ('75d7daca-6375-459c-b0e2-0ff8a729c935')
AND LOWER(body_name) LIKE '%bingo%'
GROUP BY 1,2


SELECT DATE(occurred) as date,device_device_type as OS,COUNT(*) as Users_who_clicked_ringer_back FROM `analytics_data.urban_airship` 
WHERE occurred BETWEEN TIMESTAMP('2018-09-01') AND TIMESTAMP('2018-09-25') 
AND body_name IN ('ringer_back')
GROUP BY 1,2 ORDER BY 3 DESC




SELECT CAST(CAST(date AS STRING) AS DATE), count(distinct userid)
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP By 1
LIMIT 10

SELECT DATE(TIMESTAMP(STRING(date))) as Date, count(distinct userid)
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME >= TIMESTAMP("2018-09-25") 
GROUP By 1


SELECT PARSE_DATE('%Y%m%d',date) FROM (
SELECT CAST(date AS STRING) as date
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP By 1) LIMIT 100


SELECT PARSE_DATE('%Y%m%d',CAST(date AS STRING)) as Date,COUNT(DISTINCT userid) as DAU
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP By 1





SELECT COUNT(DISTINCT device_channel) FROM analytics_data.urban_airship
WHERE occurred BETWEEN TIMESTAMP('2018-09-23') AND TIMESTAMP('2018-09-24')
AND body_name IN ('trivia_signal_received','bingo_signal_received') --,'_signal_received')

159760

SELECT DATE(occurred) as Date,COUNT(DISTINCT device_channel) as Users FROM analytics_data.urban_airship
WHERE DATE(occurred) >= DATE('2018-01-01')
AND body_name IN ('trivia_signal_received','bingo_signal_received','candyrush_signal_received') GROUP BY 1

165343



select date, x_games_played, count(distinct(users)) from 
(select date,users, count(times) as x_games_played 
from (select distinct(developer_identity) as users, date(timestamp) as date, EXTRACT(HOUR FROM timestamp) as times  
from `analytics_data.branch_data` where dATE(timestamp)>='2018-07-01' AND date(timestamp) <= '2018-09-24'
and name='TRIVIA_STARTED_PLAYING'
group by 1, 2, 3) 
group by 1,2)
group by 1,2;



SELECT PARSE_DATE('%Y%m%d',CAST(date AS STRING)) as Date,COUNT(DISTINCT userid) as DAU
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP BY 1


SELECT a.Date as Date,COUNT(DISTINCT userid) as MAU FROM (
SELECT PARSE_DATE('%Y%m%d',CAST(date AS STRING)) as Date,userid
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP BY 1,2) a
CROSS JOIN (
SELECT PARSE_DATE('%Y%m%d',CAST(date AS STRING)) as Date
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP BY 1) b WHERE a.Date BETWEEN DATE_SUB(b.Date,INTERVAL 30 DAY) AND b.Date
GROUP BY 1



SELECT PARSE_DATE('%Y%m%d',CAST(date AS STRING)) as Date,COUNT(DISTINCT userid) as DAU
FROM `swoo-analytics-bq.analytics_data.user_opened_watched` 
WHERE _PARTITIONTIME = TIMESTAMP("2018-09-26") 
GROUP BY 1



select date, x_games_played, count(distinct(users)) from 
(select date,users, count(times) as x_games_played 
from (select distinct(developer_identity) as users, date(timestamp) as date, EXTRACT(HOUR FROM timestamp) as times  
from `analytics_data.branch_data` where dATE(timestamp)>='2018-07-01' AND date(timestamp) <= '2018-09-24'
and name='BINGO_STARTED_PLAYING'
group by 1, 2, 3) 
group by 1,2)
group by 1,2;





select date, x_games_played, count(distinct(users)) from 
(select date,users, count(times) as x_games_played 
from () 
group by 1,2)
group by 1,2;


SELECT developer_identity
select date(timestamp) as date , developer_identity
from `analytics_data.branch_data` where dATE(timestamp)>='2018-07-01' AND date(timestamp) <= '2018-09-24'
and name='BINGO_STARTED_PLAYING'
group by 1, 2


select date,count(distinct case when date between date and DATE_ADD(date, INTERVAL -7 DAY) AS five_days_later


select date,COUNT(distinct  CASE WHEN date >= DATE_SUB(date, INTERVAL 6 DAY) AND date <= date THEN developer_identity END) AS l7users from (
select date(timestamp) as date, developer_identity
from `analytics_data.branch_data` where dATE(timestamp)>='2018-09-01' AND date(timestamp) <= '2018-09-24'
and name='BINGO_STARTED_PLAYING'
group by 1,2) group by 1


select date,COUNT(distinct ul7) from (
select a.date as date,CASE WHEN a.date >= DATE_SUB(a.date, INTERVAL 6 DAY) AND a.date <= a.date THEN developer_identity END AS ul7,
CASE WHEN b.date >= DATE_SUB(a.date, INTERVAL 13 DAY) AND b.date <= DATE_SUB(a.date, INTERVAL 7 DAY) THEN developer_identity END AS ul7_14
from (
select date(timestamp) as date,developer_identity --DATE_SUB(date, INTERVAL 6 DAY) as l7date,
from `analytics_data.branch_data` where dATE(timestamp)>='2018-09-01' AND date(timestamp) <= '2018-09-24'
and name='BINGO_STARTED_PLAYING'
group by 1,2) a
UNION ALL (
select date(timestamp) as date,developer_identity --DATE_SUB(date, INTERVAL 6 DAY) as l7date,
from `analytics_data.branch_data` where dATE(timestamp)>='2018-09-01' AND date(timestamp) <= '2018-09-24'
and name='BINGO_STARTED_PLAYING'
group by 1,2) b GROUP BY 1,2,3)) WHERE ul7 = ul7_14 GROUP BY 1




SELECT user_id,SUM(cnt) as noofevents FROM (
SELECT user_id,occurred,body_name
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush` 
WHERE game_id = '3966c0ed-3aa9-4dac-b637-17e7f634b17a' AND DATE(occurred) = DATE('2018-09-27')
AND user_id IN (7572334,7928263,9772836,9544627,6123750,9787946,9225567,9819147,9191653,8537610,9302867,8353756,9043324,8565169,9769557,9832202,7926911,9441973,9585457,8412693,9519666,8655405,9274770,9313582,9100829,8840567,9752814,9776557,9303455,7775346,7955547,9844235,7862388,6262743,7010402,7030493,8809714,7025234,7995207,9068890,9848508,8615603,8446971,6863538,9219601,9664893,9565799,7215820,9536829,9848193)
GROUP BY 1,2,3 ORDER BY 1,2) GROUP BY 1 ORDER BY 2 DESC



SELECT user_id,level_no,occurred,body_name
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush` 
WHERE game_id = '3966c0ed-3aa9-4dac-b637-17e7f634b17a' AND DATE(occurred) = DATE('2018-09-27')
AND user_id IN (9848898,9211458,9846695,8409859,9807898,6304046,9821726,6506736,8114599,8907828,9846863,6510711,8446586,9127476,6436512,7438181,8212589,9413381,9841678,8352669,6955067,7101760,9844200,9821996,9412909,9633787,8761318,9556275,9142252,8036433,9826307,9843999,9848613,8920117,9764731,9828622,6914979,9068890,7542269,8233930,8332508,8475608,9556557,8998288,9849324,9670841,9156389,8615603,7656727,9542938,9846917,9836056,6874883,9849076,9465909,7902456,8841850,9836105,8663908,9470330,8237801,9636906,7541515,9387764,8809153,9616605,9644887,8621017,7119034,8876342,8170415,8033939,8780844,9846146,9418413,8900372,9014049,9760858,9771844,9400733,8138996,7809546,9801375,9067006,7913463,7803537,9758096,8542415,9778202,9560583,8422467,9660854,7195280,9425835,8837039,9804738,7712945,8451482,9257879,9706739)
AND level_no in  ('1','2','3','4','5')
GROUP BY 1,2,3,4 ORDER BY 1,3


SELECT user_id,body_name,MIN(occurred) as min_time
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush` 
WHERE game_id = '3966c0ed-3aa9-4dac-b637-17e7f634b17a' AND DATE(occurred) = DATE('2018-09-27')
AND user_id IN (7572334)
GROUP BY 1,2 ORDER BY 1,3


SELECT user_id,body_name,MIN(occurred) as min_time
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush` 
WHERE game_id = '3966c0ed-3aa9-4dac-b637-17e7f634b17a' AND DATE(occurred) = DATE('2018-09-27')
AND user_id IN (7572334,7928263,9772836,9544627,6123750,9787946,9225567,9819147,9191653,8537610,9302867,8353756,9043324,8565169,9769557,9832202,7926911,9441973,9585457,8412693,9519666,8655405,9274770,9313582,9100829,8840567,9752814,9776557,9303455,7775346,7955547,9844235,7862388,6262743,7010402,7030493,8809714,7025234,7995207,9068890,9848508,8615603,8446971,6863538,9219601,9664893,9565799,7215820,9536829,9848193)
GROUP BY 1,2 ORDER BY 1,3


SELECT user_id,body_name,occurred
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush` 
WHERE game_id = '3966c0ed-3aa9-4dac-b637-17e7f634b17a'
GROUP BY 1,2,3 ORDER BY 3 LIMIT 9800


SELECT body_name,COUNT(*) as cnt
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush` 
-- WHERE game_id = '3966c0ed-3aa9-4dac-b637-17e7f634b17a' 
AND DATE(occurred) = DATE('2018-09-27')
AND user_id IN (9848898,9211458,9846695,8409859,9807898,6304046,9821726,6506736,8114599,8907828,9846863,6510711,8446586,9127476,6436512,7438181,8212589,9413381,9841678,8352669,6955067,7101760,9844200,9821996,9412909,9633787,8761318,9556275,9142252,8036433,9826307,9843999,9848613,8920117,9764731,9828622,6914979,9068890,7542269,8233930,8332508,8475608,9556557,8998288,9849324,9670841,9156389,8615603,7656727,9542938,9846917,9836056,6874883,9849076,9465909,7902456,8841850,9836105,8663908,9470330,8237801,9636906,7541515,9387764,8809153,9616605,9644887,8621017,7119034,8876342,8170415,8033939,8780844,9846146,9418413,8900372,9014049,9760858,9771844,9400733,8138996,7809546,9801375,9067006,7913463,7803537,9758096,8542415,9778202,9560583,8422467,9660854,7195280,9425835,8837039,9804738,7712945,8451482,9257879,9706739)
AND level_no in  ('1','2','3','4','5')
GROUP BY 1,2,3,4 ORDER BY 1,3




SELECT a.Date as Date,
COUNT(DISTINCT a.user_id) as UsersWhoStartedTheGame,
COUNT(DISTINCT b.user_id) as UsersJoinedTheGame,
COUNT(DISTINCT c.user_id) as UsersEnteredL1,
COUNT(DISTINCT d.user_id) as UsersSeenL1Statsboard,
COUNT(DISTINCT e.user_id) as UsersEnteredL2,
COUNT(DISTINCT f.user_id) as UsersSeenL2Statsboard,
COUNT(DISTINCT g.user_id) as UsersEnteredL3,
COUNT(DISTINCT h.user_id) as UsersSeenL3Statsboard,
COUNT(DISTINCT i.user_id) as UsersEnteredL4,
COUNT(DISTINCT j.user_id) as UsersSeenL4Statsboard,
COUNT(DISTINCT k.user_id) as UsersEnteredL5,
COUNT(DISTINCT l.user_id) as UsersSeenL5Statsboard
FROM (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrush_signal_received' 
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushgame_joingame' 
GROUP BY 1,2) b
ON a.Date = b.Date AND a.user_id = b.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushplayboard_open' AND level_no in  ('1')
GROUP BY 1,2) c
ON b.Date = c.Date AND b.user_id = c.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushgame_statsboardshown' AND level_no in  ('1')
GROUP BY 1,2) d
ON c.Date = d.Date AND c.user_id = d.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushplayboard_open' AND level_no in  ('2')
GROUP BY 1,2) e
ON d.Date = e.Date AND d.user_id = e.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushgame_statsboardshown' AND level_no in  ('2')
GROUP BY 1,2) f
ON e.Date = f.Date AND e.user_id = f.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushplayboard_open' AND level_no in  ('3')
GROUP BY 1,2) g
ON f.Date = g.Date AND f.user_id = g.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushgame_statsboardshown' AND level_no in  ('3')
GROUP BY 1,2) h
ON g.Date = h.Date AND g.user_id = h.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushplayboard_open' AND level_no in  ('4')
GROUP BY 1,2) i
ON h.Date = i.Date AND h.user_id = i.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushgame_statsboardshown' AND level_no in  ('4')
GROUP BY 1,2) j
ON i.Date = j.Date AND i.user_id = j.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushplayboard_open' AND level_no in  ('5')
GROUP BY 1,2) k
ON j.Date = k.Date AND j.user_id = k.user_id
LEFT OUTER JOIN (
SELECT DATE(occurred) as Date,user_id
FROM `swoo-analytics-bq.analytics_data.ua_candy_crush`
WHERE body_name = 'candyrushgame_statsboardshown' AND level_no in  ('5')
GROUP BY 1,2) l
ON k.Date = l.Date AND k.user_id = l.user_id
GROUP BY 1













------ urban_airship
SELECT DATE(occurred) as Date,COUNT(DISTINCT device_channel) as Users FROM analytics_data.urban_airship
WHERE DATE(occurred) >= DATE('2018-09-01')
AND body_name IN ('trivia_signal_received','bingo_signal_received','candyrush_signal_received') 
GROUP BY 1


SELECT DATE(occurred) as Date,COUNT(DISTINCT device_channel) as Users FROM analytics_data.urban_airship
WHERE DATE(occurred) >= DATE('2018-09-01')
AND body_name IN ('trivia_started_playing','bingo_started_playing','candyrush_started_playing') 
GROUP BY 1


SELECT Date,COUNT(DISTINCT device_channel) as Users,SUM(games) as NoOfGamesPlayed FROM (
SELECT DATE(occurred) as Date,device_channel,COUNT(DISTINCT REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "")) as games
FROM analytics_data.urban_airship 
WHERE DATE(occurred) >= DATE('2018-05-01')
AND body_name IN ('trivia_signal_received','bingo_signal_received','candyrush_signal_received') GROUP BY 1,2) GROUP BY 1


SELECT Date,COUNT(DISTINCT device_channel) as Users,SUM(games) as NoOfGamesPlayed FROM (
SELECT DATE(occurred) as Date,device_channel,COUNT(DISTINCT REPLACE(JSON_EXTRACT(body, "$['properties'].GameId"), "\"", "")) as games
FROM analytics_data.urban_airship 
WHERE DATE(occurred) >= DATE('2018-05-01')
AND body_name IN ('trivia_signal_received','bingo_signal_received','candyrush_signal_received') GROUP BY 1,2) GROUP BY 1


------ branch


SELECT DATE(timestamp) as Date, COUNT(DISTINCT developer_identity)as Users FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) >= '2018-05-01'
and name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1


SELECT Date,COUNT(DISTINCT developer_identity) as DistinctUsersPlayed,SUM(games) as NoOfGamesPlayed FROM (
SELECT DATE(timestamp) as Date,developer_identity,COUNT(DISTINCT REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "")) as games
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) >= '2018-05-01'
and name in ('BINGO_SIGNAL_RECEIVED', 'TRIVIA_SIGNAL_RECEIVED', 'CANDYRUSH_SIGNAL_RECEIVED')
--and name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2) GROUP BY 1


SELECT * FROM (
SELECT developer_identity,name,metadata,
--LAST_VALUE(SPLIT(metadata,':')) OVER (PARTITION BY timestamp,developer_identity,metadata ORDER BY timestamp ASC) AS value
--OVER (PARTITION BY division ORDER BY finish_time ASC
--JSON_EXTRACT(metadata, "$.gameId") as game_id
REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "") as game_id
--COUNT(DISTINCT )as Users 
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) = '2018-09-01'
--and name in ('BINGO_SIGNAL_RECEIVED', 'TRIVIA_SIGNAL_RECEIVED', 'CANDYRUSH_SIGNAL_RECEIVED')
and name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')--,'BINGO_SIGNAL_RECEIVED', 'TRIVIA_SIGNAL_RECEIVED', 'CANDYRUSH_SIGNAL_RECEIVED')
--developer_identity = "8854052"
GROUP BY 1,2,3,4) WHERE game_id IS NULL



SELECT Date,COUNT(DISTINCT developer_identity) as DistinctUsersPlayed,SUM(games) as NoOfGamesPlayed FROM (
SELECT Date,developer_identity,COUNT(DISTINCT game_id) as games FROM (
SELECT DATE(timestamp) as Date,developer_identity,REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "") as game_id
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) >= '2018-05-01'
AND name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2,3 ORDER BY 1,2 LIMIT 1000) WHERE game_id IS NOT NULL 
GROUP BY 1,2 ORDER BY 1,2)
GROUP BY 1






SELECT Date,COUNT(DISTINCT developer_identity) as DistinctUsersPlayed,SUM(games) as NoOfGamesPlayed FROM (
SELECT Date,developer_identity,COUNT(DISTINCT game_id) as games FROM (
SELECT DATE(timestamp) as Date,developer_identity,REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "") as game_id
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) >= '2018-05-01'
AND name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2,3 ORDER BY 1,2 LIMIT 1000) WHERE game_id IS NOT NULL 
GROUP BY 1,2 ORDER BY 1,2)
GROUP BY 1


SELECT Date,COUNT(DISTINCT developer_identity) as DistinctUsersPlayed,SUM(games) as NoOfGamesPlayed FROM (
SELECT Date,developer_identity,COUNT(DISTINCT game_id) as games FROM (
SELECT DATE(timestamp) as Date,developer_identity,REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "") as game_id
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) >= '2018-05-01'
AND name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2,3) WHERE game_id IS NOT NULL 
GROUP BY 1,2)
GROUP BY 1


EXTRACT(HOUR FROM timestamp) as times 

SELECT EXTRACT(HOUR FROM timestamp) as Hour,name,COUNT(DISTINCT developer_identity) AS Users 
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) = DATE('2018-10-01') 
GROUP BY 1,2





SELECT TIME "15:30:00" AS orginal_time


SELECT body
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) = DATE('2018-10-01') 
GROUP BY 1





SELECT developer_identity,timestamp,name,metadata
--MAX(REPLACE(JSON_EXTRACT(metadata, "$.Points"), "\"", "")) AS Max_Points
FROM `swoo-analytics-bq.analytics_data.branch_io` 
WHERE timestamp BETWEEN TIMESTAMP("2018-10-01") AND TIMESTAMP("2018-10-02")
AND developer_identity IN ("9613933","9357238","8749266","10045286","8915290","9229432","9806411","8208455","9283042","10023359","8908644","9820279","9535781","10031458","9350302","9903062")
--AND name = 'CandyRushPlayBoard_Open'
--AND name = 'CandyRushWinnerBoard_Open'
--AND REPLACE(JSON_EXTRACT(metadata, "$.LevelNo"), "\"", "") = "5"
--AND REPLACE(JSON_EXTRACT(metadata, "$.UserId"), "\"", "") = "7423477"
--AND REPLACE(JSON_EXTRACT(metadata, "$.GameId"), "\"", "") = "c7d0da80-1f83-4bb0-8c77-add33748ed72"
GROUP BY 1,2,3,4 ORDER BY 1,2




SELECT device_channel,occurred,body_name,body 
FROM `swoo-analytics-bq.analytics_data.urban_airship` 
WHERE DATE(occurred) = DATE("2018-09-30")
--AND body_name = "candyrushwinnerboard_open"
AND device_channel IN ("97c895d5-8ddc-4566-8c8c-d094079f91e0","31fb1e9d-59ca-461d-8831-9c24f8a1e452","00b2a9a3-f5a5-4f2a-ac9f-caa0a88f8713","3cbaa01c-9bf5-422b-9bff-0eae2525c75d","93e77c94-4bef-4e61-864b-688b8b5d3bdd","9a8b08f5-3d1c-4fe1-a3f1-be8d6a58b425","cf413e70-9d56-4541-bd59-ba9b6500a31f","6bca6ba9-0eaf-487a-8bae-2093eecc9414","5cbb4b29-364c-4050-b3b7-8edb9ee83175","bad7c567-422e-4c8f-acda-5dd99c9a15f7","2a10633e-af43-4f83-8889-1ac07434817e","11d8ab3f-0629-4dcf-a7c7-05d54b50a47b","616974d8-5c8b-4dd3-b876-193a00f43cea")
GROUP BY 1,2,3,4 ORDER BY 1,2




SELECT TIME(TIMESTAMP_TRUNC(timestamp, HOUR),'Asia/Dubai') AS GST_HOUR,
CASE WHEN name = 'BINGO_STARTED_PLAYING' THEN 'BINGO'
WHEN name = 'TRIVIA_STARTED_PLAYING' THEN 'TRIVIA'
WHEN name = 'CANDYRUSH_STARTED_PLAYING' THEN 'CANDYRUSH' ELSE 'NA' END AS Game,
COUNT(DISTINCT developer_identity) AS Users
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2 HAVING Users >= 1000



select b.date,COUNT(distinct developer_identity) AS mau from (
select date(timestamp) as date, developer_identity
from `swoo-analytics-bq.analytics_data.branch_io` 
WHERE Date(timestamp)>='2018-08-01'
group by 1,2) a
cross join (
select date(timestamp) as date
from `swoo-analytics-bq.analytics_data.branch_io` 
WHERE Date(timestamp)>='2018-09-01' group by 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 30 DAY) AND a.date <= b.date
group by 1

    

select b.date,COUNT(distinct  CASE WHEN a.date >= DATE_SUB(b.date, INTERVAL 30 DAY) AND a.date <= b.date THEN developer_identity END) AS mau from (
select date(timestamp) as date, developer_identity
from `swoo-analytics-bq.analytics_data.branch_io` 
WHERE Date(timestamp)>='2018-08-01'
group by 1,2) a
cross join (
select date(timestamp) as date
from `swoo-analytics-bq.analytics_data.branch_io` 
WHERE Date(timestamp)>='2018-09-01' group by 1) b
group by 1




SELECT date,COUNT(DISTINCT device_channel) as users,SUM(plays) as game_plays FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT REPLACE(JSON_EXTRACT(body, "$['properties'].gameId"), "\"", "")) as plays
FROM analytics_data.urban_airship
WHERE DATE(occurred) >= DATE('2018-05-01')
AND body_name IN ('trivia_signal_received','bingo_signal_received','candyrush_signal_received') 
GROUP BY 1,2) 
GROUP BY 1


SELECT date,COUNT(DISTINCT developer_identity) as users,SUM(plays) as game_plays FROM (
SELECT DATE(timestamp) as date, developer_identity,COUNT(DISTINCT REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "")) as plays
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) >= '2018-05-01'
and name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2) 
GROUP BY 1



SELECT DATE(timestamp) as date, developer_identity, name, metadata, REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "") as game_id
FROM `swoo-analytics-bq.analytics_data.branch_io`
where DATE(timestamp) = '2018-09-01'
and name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2,3,4,5 LIMIT 1000


SELECT developer_identity,COUNT(DISTINCT REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "")) as plays --DATE(timestamp) AS date,
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING')
AND DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY)
GROUP BY 1 HAVING plays >= 5 ORDER BY 2 DESC LIMIT 10000





*****************

SELECT email--a.developer_identity as id,,full_name,phone 
FROM (
SELECT developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY 1 LIMIT 60000) a
LEFT JOIN (
SELECT CAST(id AS STRING) as id,email,full_name,phone  FROM `swoo-analytics-bq.analytics_data.user` 
GROUP BY 1,2,3,4) b
ON a.developer_identity = b.id
GROUP BY 1



SELECT email--a.developer_identity as id,,full_name,phone 
FROM (
SELECT a.developer_identity as developer_identity FROM (
SELECT developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-05-01')
GROUP BY 1) a
LEFT JOIN (
SELECT developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-05-01')
GROUP BY 1) b
ON a.developer_identity = b.developer_identity
WHERE b.developer_identity IS NULL
GROUP BY 1 LIMIT 30000) a
LEFT JOIN (
SELECT CAST(id AS STRING) as id,email,full_name,phone  FROM `swoo-analytics-bq.analytics_data.user` 
GROUP BY 1,2,3,4) b
ON a.developer_identity = b.id
GROUP BY 1



SELECT email--a.developer_identity as id,,full_name,phone 
FROM (
SELECT a.developer_identity as developer_identity FROM (
SELECT developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('TRIVIA_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-05-01')
GROUP BY 1) a
LEFT JOIN (
SELECT developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-05-01')
GROUP BY 1) b
ON a.developer_identity = b.developer_identity
WHERE b.developer_identity IS NULL
GROUP BY 1 LIMIT 30000) a
LEFT JOIN (
SELECT CAST(id AS STRING) as id,email,full_name,phone  FROM `swoo-analytics-bq.analytics_data.user` 
GROUP BY 1,2,3,4) b
ON a.developer_identity = b.id
GROUP BY 1




SELECT email--a.developer_identity as id,,full_name,phone 
FROM (
SELECT developer_identity,COUNT(DISTINCT REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "")) as noofgameplays
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('TRIVIA_STARTED_PLAYING','BINGO_STARTED_PLAYING','CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-05-01')
GROUP BY 1 ORDER BY 2 DESC LIMIT 30000) a
LEFT JOIN (
SELECT CAST(id AS STRING) as id,email,full_name,phone  FROM `swoo-analytics-bq.analytics_data.user` 
GROUP BY 1,2,3,4) b
ON a.developer_identity = b.id
GROUP BY 1



*****************

#standardSQL
SELECT AVG(session_length)/60 as avg_length
from (
SELECT bi1.developer_identity as user_id , bi2.branch_session_id as session_id, (UNIX_SECONDS(bi1.timestamp)-UNIX_SECONDS(bi2.session_start_timestamp)) as session_length, MAX(bi1.timestamp) as max_time, Min(bi2.session_start_timestamp) as min_session_time 
FROM `swoo-analytics-bq.analytics_data.branch_io` bi1
JOIN `swoo-analytics-bq.analytics_data.branch_io` bi2
ON bi1.developer_identity = bi2.developer_identity
AND bi1.branch_session_id = bi2.branch_session_id
WHERE date(bi1.timestamp) = "2018-10-05"
AND date(bi2.timestamp) = "2018-10-05"
AND bi1.browser_os IS NULL
AND bi1.branch_device_fingerprint_id IS NOT NULL
AND bi2.browser_os IS NULL
AND bi2.branch_device_fingerprint_id IS NOT NULL
GROUP BY 1,2,3)
LIMIT 10;


#standardSQL
SELECT Date, avg(time_spent)
FROM 
(SELECT date(max_time) as Date, developer_identity, SUM(TIME_DIFF(TIME(max_time), TIME(max_session_time), SECOND)) as time_spent
FROM (SELECT developer_identity, branch_session_id, MAX(timestamp) as max_time, Min(session_start_timestamp) as max_session_time 
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE date(timestamp) >= "2018-10-01" and date(timestamp) <='2018-10-06'
GROUP BY 1,2)
group by 1,2)
group by 1
ORDER BY 1;



SELECT browser_os,COUNT(*) as cnt
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05"
GROUP BY 1

SELECT device_os,COUNT(*) as cnt
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05"
GROUP BY 1


SELECT developer_identity,COUNT(DISTINCT branch_session_id) as sessions
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05"
GROUP BY 1 ORDER BY 2 LIMIT 1000


SELECT * --id,name,metadata,timestamp,session_start_timestamp
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05" AND developer_identity = '10213896'
AND device_os IN ('Android','iOS')
ORDER BY 11,4



SELECT developer_identity,COUNT(DISTINCT branch_session_id) as sessions,AVG(stop-start)/60 as ss_time FROM (
SELECT developer_identity,branch_session_id,UNIX_SECONDS(session_start_timestamp) as start,UNIX_SECONDS(MAX(timestamp)) as stop
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05"
AND device_os IN ('Android','iOS') 
GROUP BY 1,2,3) GROUP BY 1 ORDER BY 2





SELECT developer_identity,COUNT(DISTINCT game_id) as games,AVG(stop-start)/60 as ss_time FROM (
SELECT developer_identity,REPLACE(JSON_EXTRACT(metadata, "$.GameId"), "\"", "") as game_id,UNIX_SECONDS(MIN(session_start_timestamp)) as start,UNIX_SECONDS(MAX(timestamp)) as stop
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05" AND developer_identity = '9695675'
AND device_os IN ('Android','iOS') 
GROUP BY 1,2)
WHERE game_id IS NOT NULL
GROUP BY 1 
ORDER BY 2








SELECT developer_identity,(stop-start) as ss_time FROM (
SELECT developer_identity,UNIX_SECONDS(MIN(session_start_timestamp)) as start,UNIX_SECONDS(MAX(timestamp)) as stop
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05" AND developer_identity = '9695675'
GROUP BY 1) GROUP BY 1,2



SELECT developer_identity,(MIN(session_start_timestamp)) as start,(MAX(timestamp)) as stop
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05" AND developer_identity = '9695675'
GROUP BY 1


SELECT developer_identity,(stop-start) as ss_time FROM (
SELECT developer_identity,UNIX_SECONDS(MIN(session_start_timestamp)) as start,UNIX_SECONDS(MAX(timestamp)) as stop
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-05" AND developer_identity = '10158940'
GROUP BY 1,2) GROUP BY 1,2



SELECT a.device_channel as device_channel,a.game_id as game_id,(UNIX_SECONDS(b.occurred)-UNIX_SECONDS(a.occurred)) as diff  FROM (
SELECT device_channel,game_id,occurred FROM `swoo-analytics-bq.derived_data.fullevents_for_users_containing_candy` 
WHERE body_name = "candyrush_signal_received" AND signal_name = "GAME_STARTED"
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT device_channel,game_id,occurred FROM `swoo-analytics-bq.derived_data.fullevents_for_users_containing_candy` 
WHERE body_name = "candyrushplayboard_open" AND level_no  = "1"
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel AND a.game_id = b.game_id
GROUP BY 1,2,3 ORDER BY 3 DESC





SELECT b.date as Date,
COUNT(DISTINCT CASE WHEN a.min_date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.min_date <= b.date THEN a.developer_identity END) as NewUsers,
COUNT(DISTINCT CASE WHEN a.min_date <= DATE_SUB(b.date, INTERVAL 7 DAY) AND a.dum_id IS NOT NULL THEN a.developer_identity END) as LastWeekUsers,
COUNT(DISTINCT CASE WHEN a.min_date <= DATE_SUB(b.date, INTERVAL 7 DAY) AND a.dum_id IS NULL THEN a.developer_identity END) as ReturnUsers
FROM (
-- Here I am getting both his play_date , min_date & dum_id
SELECT a.developer_identity as developer_identity,a.date as date,b.min_date as min_date,c.developer_identity as dum_id FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-01' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
LEFT JOIN ( 
-- The below code will give the min_date of the game
SELECT developer_identity,MIN(DATE(timestamp)) as min_date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-01' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1) b
ON a.developer_identity = b.developer_identity
LEFT JOIN (
SELECT developer_identity,date FROM `derived_data.bingo_wau_cohort_temp_table` 
GROUP BY 1,2) c
ON a.date = c.date AND a.developer_identity = c.developer_identity
-- WHERE c.developer_identity IS NULL
GROUP BY 1,2,3,4) a
CROSS JOIN (
-- The below code will just give the date as a reference
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-07-10' AND date <= CURRENT_DATE()) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1





SELECT COUNT(DISTINCT a.developer_identity) as LastWeekUsers FROM (
SELECT developer_identity FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >='2018-10-08' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN (
-- The below code will just give the date as a reference
SELECT DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = '2018-10-16'
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1) a
JOIN (
SELECT developer_identity FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >='2018-10-01' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN (
-- The below code will just give the date as a reference
SELECT DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = '2018-10-16'
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1) b
ON a.developer_identity = b.developer_identity


SELECT b.date as Date,COUNT(DISTINCT developer_identity) AS WAU FROM (
SELECT DATE(timestamp) as date, developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-01'
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN (
SELECT DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-10'
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1



SELECT developer_identity,MIN(date) as min_date FROM (
SELECT date,developer_identity,game_id,DENSE_RANK() OVER(PARTITION BY developer_identity ORDER BY date DESC) AS rank FROM (
SELECT DATE(timestamp) as date,developer_identity,LOWER(metadata),REPLACE(JSON_EXTRACT(LOWER(metadata), "$.gameid"), "\"", "") as game_id
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-07-01'
AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING" 
GROUP BY 1,2,3,4)
GROUP BY 1,2,3)
WHERE rank IN (1,2)
GROUP BY 1,2






SELECT
  ProdName,
  NoofProds,
  RANK() OVER(ORDER BY NoofProds DESC) AS rank_ 
FROM
(
  SELECT
    ProdName,
    COUNT(ProdName) AS NoofProds 
  FROM [prodtable]
  WHERE (STRFTIME_UTC_USEC(Timestamp,"%Y%m%d")) = (STRFTIME_UTC_USEC(DATE_ADD(CURRENT_TIMESTAMP(), -1, "day"), "%Y%m%d"))
  GROUP BY 1
)
ORDER BY rank_ DESC




SELECT body_name,GST_HOUR,COUNT(DISTINCT device_channel) AS Users FROM (
SELECT body_name, EXTRACT(HOUR FROM occurred) as times --TIME(TIMESTAMP_TRUNC(occurred, HOUR),'Asia/Dubai') AS GST_HOUR
,device_channel--,COUNT(DISTINCT device_channel) AS Users
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE body_name in ('bingo_started_playing', 'trivia_started_playing', 'candyrush_started_playing')
AND DATE(occurred) = DATE("2018-10-20")
GROUP BY 1,2,3)
GROUP BY 1,2 HAVING Users > 1000



SELECT body_name,
occurred,
TIMESTAMP_TRUNC(occurred, MINUTE) as trnc,
TIMESTAMP_SUB(TIMESTAMP_TRUNC(occurred, MINUTE), INTERVAL MOD(EXTRACT(MINUTE FROM TIMESTAMP_TRUNC(occurred, MINUTE)),10) MINUTE),
device_channel
--EXTRACT(HOUR FROM occurred) as hour, EXTRACT(MINUTE FROM occurred) as minute
--,COUNT(DISTINCT device_channel) AS Users
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE body_name in ('bingo_started_playing', 'trivia_started_playing', 'candyrush_started_playing')
AND DATE(occurred) = DATE("2018-10-20")
GROUP BY 1,2,3,4,5 LIMIT 2000



SELECT body_name,time,COUNT(DISTINCT device_channel) AS Users FROM (
SELECT body_name,
TIMESTAMP_SUB(TIMESTAMP_TRUNC(occurred, MINUTE), INTERVAL MOD(EXTRACT(MINUTE FROM TIMESTAMP_TRUNC(occurred, MINUTE)),10) MINUTE) as time,
device_channel --COUNT(DISTINCT device_channel) AS Users
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE body_name in ('bingo_started_playing', 'trivia_started_playing', 'candyrush_started_playing')
AND DATE(occurred) = DATE("2018-10-20")
GROUP BY 1,2,3)
GROUP BY 1,2





TIMESTAMP_SUB(TIMESTAMP_TRUNC(occurred, MINUTE), INTERVAL MOD(EXTRACT(MINUTE FROM TIMESTAMP_TRUNC(occurred, MINUTE)),10) MINUTE)





SELECT DATE(timestamp) as date,developer_identity,branch_session_id,UNIX_SECONDS(session_start_timestamp) as start,UNIX_SECONDS(MAX(timestamp)) as stop
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = "2018-10-20"
AND device_os IN ('Android','iOS')
AND name IN ('BINGO_STARTED_PLAYING','TRIVIA_STARTED_PLAYING','CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2) GROUP BY 1 ORDER BY 2



SELECT date as Date,CASE WHEN name = 'CANDYRUSH_STARTED_PLAYING' THEN 'CandyKrack'
WHEN name = 'BINGO_STARTED_PLAYING' THEN 'Bingo' 
WHEN name = 'TRIVIA_STARTED_PLAYING' THEN 'Trivia'
ELSE 'NA' END AS Game_Type,COUNT(game_id) as noofgamesplayed,COUNT(DISTINCT developer_identity) as noofgameplayers,SUM(game_time) as total_gameplaytime
FROM (
SELECT DATE(timestamp) as date,name,developer_identity,REPLACE(JSON_EXTRACT(metadata, "$.GameId"), "\"", "") as game_id,
TIME(TIMESTAMP_TRUNC(timestamp, HOUR),'Asia/Dubai') as GST_HOUR,
(UNIX_SECONDS(MAX(timestamp))-UNIX_SECONDS(MIN(session_start_timestamp))) as game_time
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('BINGO_STARTED_PLAYING', 'TRIVIA_STARTED_PLAYING', 'CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-07-01') 
AND timestamp >= TIMESTAMP_TRUNC(timestamp, HOUR) AND timestamp < TIMESTAMP_ADD(TIMESTAMP_TRUNC(timestamp, HOUR), INTERVAL 60 MINUTE)
GROUP BY 1,2,3,4,5) 
WHERE game_time <= 1800
GROUP BY 1,2



SELECT b.date as Date,COUNT(DISTINCT device_channel) as WAU 
FROM (
SELECT DATE(occurred) as date, device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 37 DAY)
AND type = 'OPEN'
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) AND date <= CURRENT_DATE()
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1


SELECT DATE(occurred) as created_date, count(distinct device_channel) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 40 DAY)
AND DATE(occurred) < CURRENT_DATE()
AND type='OPEN'
GROUP BY 1
ORDER BY 1




SELECT
DATE(bi2.timestamp),
COUNT(DISTINCT bi2.developer_identity)
FROM
`swoo-analytics-bq.analytics_data.branch_io` bi1
RIGHT JOIN
`swoo-analytics-bq.analytics_data.branch_io` bi2
ON
bi1.developer_identity = bi2.developer_identity
AND DATE(bi1.timestamp)= DATE(bi2.timestamp)
WHERE
DATE(bi1.timestamp) >= '2018-10-15'
AND DATE(bi2.timestamp) >= '2018-10-15'
AND bi1.name = 'GAMES_OPEN'
AND bi2.name IN ('CANDYRUSH_STARTED_PLAYING',
'TRIVIA_STARTED_PLAYING',
'BINGO_STARTED_PLAYING')
GROUP BY
1
ORDER BY
1;



select date(timestamp), name, count(distinct developer_identity)
from `swoo-analytics-bq.analytics_data.branch_io`
where date(timestamp) >= '2018-10-15'
AND name = 'GAMES_OPEN'
--AND name not in ('CANDYRUSH_STARTED_PLAYING','TRIVIA_STARTED_PLAYING','BINGO_STARTED_PLAYING')
--AND developer_identity !='null'
AND device_os in ('Android', 'iOS')
group by 1, 2
ORDER BY 1 ASC








SELECT date as Date,CASE WHEN name = 'CANDYRUSH_STARTED_PLAYING' THEN 'CandyKrack'
WHEN name = 'BINGO_STARTED_PLAYING' THEN 'Bingo' 
WHEN name = 'TRIVIA_STARTED_PLAYING' THEN 'Trivia'
ELSE 'NA' END AS Game_Type,COUNT(game_id) as noofgamesplayed,COUNT(DISTINCT developer_identity) as noofgameplayers,SUM(game_time) as total_gameplaytime
FROM (
SELECT DATE(occurred) as date,body_name,device_channel,game_id,TIME(TIMESTAMP_TRUNC(occurred, HOUR),'Asia/Dubai') as GST_HOUR,
(UNIX_SECONDS(MAX(occurred))-UNIX_SECONDS(MIN(session_start_timestamp))) as game_time
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND DATE(occurred) >= DATE('2018-05-01') 
AND occurred >= TIMESTAMP_TRUNC(occurred, HOUR) AND occurred < TIMESTAMP_ADD(TIMESTAMP_TRUNC(occurred, HOUR), INTERVAL 60 MINUTE)
GROUP BY 1,2,3,4,5) 
WHERE game_time <= 1800
GROUP BY 1,2


SELECT count(user_id)
FROM `analytics_data.user_sessions`
WHERE cast(user_id as int64) NOT IN (
SELECT CAST(users AS int64) AS user_id
FROM ()
GROUP BY 1 HAVING COUNT(times)>=6)
    


SELECT DISTINCT(developer_identity) AS users, DATE(timestamp) AS date, EXTRACT(HOUR FROM timestamp) AS times, name AS game
FROM `analytics_data.branch_io`
WHERE DATE(timestamp)='2018-10-02'
AND name IN ('BINGO_STARTED_PLAYING','TRIVIA_STARTED_PLAYING','CANDYRUSH_STARTED_PLAYING')
GROUP BY 1,2,3,4




SELECT DATE(occurred) AS DATE,game_id,--TIME(TIMESTAMP_TRUNC(occurred, HOUR),'Asia/Dubai') AS GST_HOUR,
CASE WHEN body_name = 'bingo_started_playing' THEN 'BINGO'
WHEN body_name = 'trivia_started_playing' THEN 'TRIVIA'
WHEN body_name = 'candyrush_started_playing' THEN 'CANDYRUSH' ELSE 'NA' END AS GAME_NAME,
COUNT(DISTINCT device_channel) AS USERS
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE body_name in ('bingo_started_playing','trivia_started_playing','candyrush_started_playing')
AND DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)
GROUP BY 1,2,3 HAVING Users >= 1000 ORDER BY 1,2



SELECT TIMESTAMP_TRUNC(occurred, MINUTE)--,  EXTRACT(HOUR FROM occurred),EXTRACT(MINUTE FROM occurred)
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = DATE("2018-10-15") GROUP BY 1,2


SELECT FORMAT_TIME("%r", TIME "15:30:00") as formatted_time;

SELECT ROUND(11/30) as ratio

SELECT DATETIME(TIMESTAMP('2018-10-04 10:04:57.180 UTC')

SELECT TIMESTAMP_TRUNC(occurred, MINUTE)--,  EXTRACT(HOUR FROM occurred),EXTRACT(MINUTE FROM occurred)
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = DATE("2018-10-15") GROUP BY 1,2

SELECT DATETIME_DIFF(TIMESTAMP('2018-10-04 10:04:57.180 UTC'),DATETIME "2008-12-25 15:30:00", DAY) as difference;
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = DATE("2018-10-15") GROUP BY 1,2




SELECT date,developer_identity,game_id,DENSE_RANK(developer_identity) OVER(PARTITION BY date,developer_identity ORDER BY date DESC) AS rank FROM (
SELECT DATE(timestamp) as date,developer_identity,LOWER(metadata),REPLACE(JSON_EXTRACT(LOWER(metadata), "$.gameid"), "\"", "") as game_id
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-10-10' DATE(timestamp) <= '2018-10-13' 
AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING" 
GROUP BY 1,2,3,4)
GROUP BY 1,2,3





SELECT date as Date,a.users as Users
SELECT b.date as date,CASE WHEN (a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date) AND (a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)) THEN "LastWeekUser"
ELSE "Other" END AS UserType,COUNT(DISTINCT a.developer_identity) AS users FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-01' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN (
-- The below code will just give the date as a reference
SELECT DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-10'
GROUP BY 1) b
--WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2)
WHERE UserType = "LastWeekUser"
GROUP BY 1






SELECT COUNT(DISTINCT a.developer_identity) as LastWeekUsers FROM (
SELECT developer_identity FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >='2018-10-08' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN `swoo-analytics-bq.analytics_data.dates_refer` b
WHERE b.date >= '2018-10-16' AND b.date <= CURRENT_DATE()
AND a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1) a
JOIN (
SELECT developer_identity FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >='2018-10-01' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN `swoo-analytics-bq.analytics_data.dates_refer` b
WHERE b.date >= '2018-10-16' AND b.date <= CURRENT_DATE()
AND a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1) b
ON a.developer_identity = b.developer_identity






SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,
COUNT(DISTINCT a.developer_identity) as Users FROM (
SELECT DATE(identity_creation_timestamp) as date,developer_identity --device_first_seen_timestamp 
FROM `analytics_data.branch_io`
WHERE DATE(identity_creation_timestamp) >= '2018-07-01' --DATE_SUB(CURRENT_DATE(),INTERVAL 65 DAY)
AND DATE(timestamp) >= '2018-07-01' --DATE_SUB(CURRENT_DATE(),INTERVAL 65 DAY)
AND device_os IN ("Android","iOS")
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(timestamp) as date,developer_identity --device_first_seen_timestamp 
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-07-01' --DATE_SUB(CURRENT_DATE(),INTERVAL 65 DAY) 
AND device_os IN ("Android","iOS")
GROUP BY 1,2) b
ON a.developer_identity = b.developer_identity
GROUP BY 1,2





SELECT a.date as Acq_Date,b.date as Req_Date,COUNT(DISTINCT a.developer_identity) as Users 
FROM (
SELECT DATE(identity_creation_timestamp) as date,developer_identity --device_first_seen_timestamp 
FROM `analytics_data.branch_io`
WHERE DATE(identity_creation_timestamp) >= '2018-07-01' --DATE_SUB(CURRENT_DATE(),INTERVAL 30 DAY)
AND DATE(timestamp) >= '2018-07-01' --DATE_SUB(CURRENT_DATE(),INTERVAL 45 DAY)
AND device_os IN ("Android","iOS")
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(timestamp) as date,developer_identity --device_first_seen_timestamp 
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-07-01' --DATE_SUB(CURRENT_DATE(),INTERVAL 65 DAY) 
AND device_os IN ("Android","iOS")
GROUP BY 1,2) b
ON a.developer_identity = b.developer_identity
GROUP BY 1,2




SELECT DATE(timestamp) as Date,COUNT(DISTINCT developer_identity) as DistinctPlayers
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-10-10'
AND device_os IN ("Android","iOS") 
AND name in ('TRIVIA_STARTED_PLAYING','BINGO_STARTED_PLAYING','CANDYRUSH_STARTED_PLAYING')
GROUP BY 1

SELECT Date,noofgameplays,COUNT(DISTINCT developer_identity) as DistinctPlayers FROM (
SELECT DATE(timestamp) as Date,developer_identity,COUNT(DISTINCT REPLACE(JSON_EXTRACT(metadata, "$.gameId"), "\"", "")) as noofgameplays
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE name in ('TRIVIA_STARTED_PLAYING','BINGO_STARTED_PLAYING','CANDYRUSH_STARTED_PLAYING')
AND DATE(timestamp) >= DATE('2018-10-10')
GROUP BY 1,2) 
GROUP BY 1,2



SELECT a.date as Date,a.dau as DAU,b.mau as MAU,((a.dau/b.mau)*100) as DAU_MAU_Percent FROM (
SELECT DATE(timestamp) as date,COUNT(DISTINCT developer_identity) as dau
FROM `swoo-analytics-bq.analytics_data.branch_io` ds
WHERE Date(timestamp)>='2018-10-10'
GROUP BY 1) a
JOIN (
SELECT b.date as date,COUNT(DISTINCT developer_identity) AS mau FROM (
SELECT DATE(timestamp) as date, developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-09-01'
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-10-10' AND date <= CURRENT_DATE()
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 30 DAY) AND a.date <= b.date
GROUP BY 1) b
ON a.date = b.date
ORDER BY 1








SELECT b.date as Date,CASE WHEN a.min_date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.min_date <= b.date THEN "NewUser"
WHEN a.dum_id IS NOT NULL THEN "LastWeekUser"
ELSE "ReturnUser" END AS User_Type
,COUNT(DISTINCT a.developer_identity) AS Users FROM (
-- Here I am getting both his play_date & min_date
SELECT a.developer_identity as developer_identity,a.date as date,b.min_date as min_date,c.developer_identity as dum_id FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-09-15' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
LEFT JOIN ( 
-- The below code will give the min_date of the game
SELECT developer_identity,MIN(DATE(timestamp)) as min_date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-07-01' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1) b
ON a.developer_identity = b.developer_identity
LEFT JOIN (
SELECT b.date as date,developer_identity FROM (
SELECT DATE(timestamp) as date, developer_identity
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-09-01'
AND name = "BINGO_STARTED_PLAYING" AND device_os IN ("Android","iOS")
GROUP BY 1,2) a
CROSS JOIN (
SELECT DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-09-15'
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) c
ON a.date = c.date
GROUP BY 1,2,3,4) a
CROSS JOIN (
-- The below code will just give the date as a reference
SELECT DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp)>='2018-09-25'
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2




SELECT b.date as date,a.developer_identity FROM (
-- The below code will give play_date of the game
SELECT developer_identity,DATE(timestamp) as date
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >='2018-06-25' AND device_os IN ("Android","iOS")
AND name = "BINGO_STARTED_PLAYING"
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-07-13' AND date <= CURRENT_DATE()) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2




SELECT a.app_version as app_version,COUNT(DISTINCT a.developer_identity) as game_openers FROM (
SELECT app_version,developer_identity,name
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) = '2018-10-20' AND device_os IN ('Android', 'iOS')
--AND app_version IS NOT NULL
AND name = 'GAMES_OPEN'
GROUP BY 1,2,3 LIMIT 1000) a
JOIN (
SELECT app_version,developer_identity,name
FROM `swoo-analytics-bq.analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-10-28' AND device_os IN ('Android', 'iOS')
--AND app_version IS NOT NULL
AND name IN ('CANDYRUSH_STARTED_PLAYING','TRIVIA_STARTED_PLAYING','BINGO_STARTED_PLAYING')
GROUP BY 1,2,3 LIMIT 1000) b
ON a.developer_identity = b.developer_identity AND a.app_version = b.app_version
GROUP BY 1




SELECT a.app_version as app_version,COUNT(DISTINCT a.developer_identity) as game_players FROM (
SELECT app_version,device_channel as developer_identity
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-10-20' --AND device_os IN ('Android', 'iOS')
AND app_version IS NOT NULL
AND body_name = 'games_open'
GROUP BY 1,2) a
JOIN (
SELECT app_version,device_channel as developer_identity,body_name
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-10-20' --AND device_os IN ('Android', 'iOS')
--AND app_version IS NOT NULL
AND body_name IN ('games_open') --'candyrush_started_playing','trivia_started_playing','bingo_started_playing')
GROUP BY 1,2,3 LIMIT 1000 ) b
ON a.developer_identity = b.developer_identity AND a.app_version = b.app_version
GROUP BY 1



SELECT * FROM (
)
WHERE Users > 500


SELECT a.date as Acq_Date,CASE WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 2 DAY) THEN 'D2'
WHEN b.date = DATE_ADD(a.date,INTERVAL 3 DAY) THEN 'D3'
WHEN b.date = DATE_ADD(a.date,INTERVAL 4 DAY) THEN 'D4'
WHEN b.date = DATE_ADD(a.date,INTERVAL 5 DAY) THEN 'D5'
WHEN b.date = DATE_ADD(a.date,INTERVAL 6 DAY) THEN 'D6'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 8 DAY) THEN 'D8'
WHEN b.date = DATE_ADD(a.date,INTERVAL 9 DAY) THEN 'D9'
WHEN b.date = DATE_ADD(a.date,INTERVAL 10 DAY) THEN 'D10'
WHEN b.date = DATE_ADD(a.date,INTERVAL 11 DAY) THEN 'D11'
WHEN b.date = DATE_ADD(a.date,INTERVAL 12 DAY) THEN 'D12'
WHEN b.date = DATE_ADD(a.date,INTERVAL 13 DAY) THEN 'D13'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 15 DAY) THEN 'D15'
WHEN b.date = DATE_ADD(a.date,INTERVAL 16 DAY) THEN 'D16'
WHEN b.date = DATE_ADD(a.date,INTERVAL 17 DAY) THEN 'D17'
WHEN b.date = DATE_ADD(a.date,INTERVAL 18 DAY) THEN 'D18'
WHEN b.date = DATE_ADD(a.date,INTERVAL 19 DAY) THEN 'D19'
WHEN b.date = DATE_ADD(a.date,INTERVAL 20 DAY) THEN 'D20'
WHEN b.date = DATE_ADD(a.date,INTERVAL 21 DAY) THEN 'D21'
WHEN b.date = DATE_ADD(a.date,INTERVAL 22 DAY) THEN 'D22'
WHEN b.date = DATE_ADD(a.date,INTERVAL 23 DAY) THEN 'D23'
WHEN b.date = DATE_ADD(a.date,INTERVAL 24 DAY) THEN 'D24'
WHEN b.date = DATE_ADD(a.date,INTERVAL 25 DAY) THEN 'D25'
WHEN b.date = DATE_ADD(a.date,INTERVAL 26 DAY) THEN 'D26'
WHEN b.date = DATE_ADD(a.date,INTERVAL 27 DAY) THEN 'D27'
WHEN b.date = DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'D28'
WHEN b.date = DATE_ADD(a.date,INTERVAL 29 DAY) THEN 'D29'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30' ELSE 'NA' END AS Retention,COUNT(DISTINCT a.developer_identity) as Users 
FROM (
SELECT DATE(identity_creation_timestamp) as date,developer_identity --device_first_seen_timestamp 
FROM `analytics_data.branch_io`
WHERE DATE(identity_creation_timestamp) >= DATE_SUB(CURRENT_DATE(),INTERVAL 30 DAY) AND DATE(timestamp) <= CURRENT_DATE()
AND DATE(timestamp) >= DATE_SUB(CURRENT_DATE(),INTERVAL 60 DAY) AND DATE(timestamp) <= CURRENT_DATE()
AND device_os IN ("Android","iOS")
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(timestamp) as date,developer_identity --device_first_seen_timestamp 
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(),INTERVAL 30 DAY) AND DATE(timestamp) <= CURRENT_DATE()
AND device_os IN ("Android","iOS")
GROUP BY 1,2) b
ON a.developer_identity = b.developer_identity
GROUP BY 1,2




SELECT device_channel,SUM(games_played) as total_games_played FROM (
SELECT device_channel,DATE(occurred) as date,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as games_played
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-02-01'
AND body_name = 'bingo_started_playing'
GROUP BY 1,2)
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 500


SELECT developer_identity,SUM(games_played) as total_games_played FROM (
SELECT developer_identity,DATE(timestamp) as date,COUNT(DISTINCT EXTRACT(HOUR FROM timestamp)) as games_played
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-07-01'
AND name='BINGO_STARTED_PLAYING'
GROUP BY 1,2)
GROUP BY 1 ORDER BY 2 DESC LIMIT 500


SELECT DATE(timestamp) as date,COUNT(DISTINCT developer_identity) as users
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-10-10'
AND name IN ('Trivia_BengaliLang','Games_BengaliLang')
GROUP BY 1 ORDER BY 1



SELECT
DATE(timestamp) AS date,
EXTRACT(HOUR
FROM
timestamp) AS hour,
COUNT(DISTINCT(developer_identity)) AS users
FROM
`analytics_data.branch_io`
WHERE
DATE(timestamp)>='2018-10-14'
AND DATE(timestamp) <= CURRENT_DATE()
AND name='BINGO_STARTED_PLAYING' 
GROUP BY
1,
2

SELECT
DATE(timestamp) AS date,
EXTRACT(HOUR
FROM
timestamp) AS hour,
COUNT(DISTINCT(developer_identity)) AS users
FROM
`analytics_data.branch_io`
WHERE
DATE(timestamp)>='2018-10-01'
AND DATE(timestamp) <= CURRENT_DATE()
AND name='BINGO_STARTED_PLAYING'
GROUP BY
1,
2


SELECT a.date as Date,b.time_ist as time_ist,a.ball_sequnce as ball_sequnce,
a.claim_type as claim_type,SUM(a.s_claims) as s_claims
FROM (
SELECT DATE(created_at) as date,current_sequence as ball_sequnce,game_id,
CASE WHEN claim_type = "1" THEN "top_row"
WHEN claim_type = "2" THEN "middle_row"
WHEN claim_type = "3" THEN "bottom_row"
WHEN claim_type = "4" THEN "all_corners"
ELSE "full_house" END AS claim_type,COUNT(DISTINCT id) as s_claims 
FROM `swoo_gaming_service`.`user_claim`
WHERE status = "1" 
AND DATE(created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY)
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT DATE(start_time) as date,game_id,TIME_FORMAT(TIME(CONVERT_TZ(start_time,'+00:00','+05:30')), '%h:%i %p') as time_ist
FROM `swoo_gaming_service`.`game`
WHERE DATE(start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY)
AND game_type_id = "Bingo" AND is_deleted = "0"
GROUP BY 1,2,3) b
ON a.date = b.date AND a.game_id = b.game_id
GROUP BY 1,2,3,4 ORDER BY 1,2



















SELECT date,body_name,COUNT(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND (body_name IN ('games_open','games_swoochallenge','games_banner_click','games_trivia','games_bingo','games_candyrush','games_trivia_click','games_bingo_click','games_candyrush_click') 
OR body_name LIKE '%_upcoming_click'
OR body_name LIKE '%_ringer_%')
GROUP BY 1,2


SELECT date,body_name,COUNT(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND (body_name IN ('games_open','games_swoochallenge','games_banner_click','games_trivia','games_bingo','games_candyrush','games_trivia_click','games_bingo_click','games_candyrush_click') 
OR body_name LIKE '%_upcoming_click'
OR body_name LIKE '%_ringer_%')
AND body_name NOT LIKE '%_open'
AND body_name NOT LIKE '%_opengame'
AND body_name NOT LIKE '%_dismiss'
GROUP BY 1,2


SELECT date,body_name,COUNT(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND (body_name IN ('games_banner_click','games_trivia_click','games_bingo_click','games_candyrush_click') 
OR body_name LIKE '%_upcoming_click'
OR body_name LIKE '%_ringer_%')
GROUP BY 1,2








SELECT date,body_name,COUNT(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND (body_name IN ('games_open','games_swoochallenge','games_banner_click','games_trivia','games_bingo','games_candyrush','games_trivia_click','games_bingo_click','games_candyrush_click') 
OR body_name LIKE '%_upcoming_click'
OR body_name LIKE '%_ringer_%')
GROUP BY 1,2





SELECT a.date as date,COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date,device_channel --COUNT(DISTINCT device_channel) as users
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND (body_name IN ('games_banner_click','games_trivia_click','games_bingo_click','games_candyrush_click') 
OR body_name LIKE '%_upcoming_click'
OR body_name LIKE '%_ringer_%')
AND body_name NOT LIKE '%ringer_open'
AND body_name NOT LIKE '%ringer_opengame'
AND body_name NOT LIKE '%ringer_dismiss'
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel --COUNT(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND body_name IN ('trivia_started_playing','candyrush_started_playing','bingo_started_playing')
GROUP BY 1,2) b
ON a.device_channel= b.device_channel
GROUP BY 1




SELECT date,body_name,COUNT(DISTINCT device_channel) as users 
FROM `analytics_data.urban_airship_derived_data_v1`
WHERE date >= '2018-10-01' AND date <= '2018-11-12'
AND type  = 'CUSTOM'
AND (body_name IN ('games_banner_click','games_trivia_click','games_bingo_click','games_candyrush_click') 
OR body_name LIKE '%_upcoming_click'
OR body_name LIKE '%_ringer_%')
GROUP BY 1,2






SELECT date,(SUM(rec_watchtime)/(60*60)) as rec_watchtime 
FROM (
SELECT a.date,a.device_channel,a.id,SUM(rec_stop-rec_start) as rec_watchtime
FROM (
SELECT DATE(occurred) as date,id,device_channel,UNIX_SECONDS(occurred) as rec_stop
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-17'
AND body_name = 'recorded_broadcast_view_stop'
GROUP BY 1,2,3,4) a
JOIN (
SELECT DATE(occurred) as date,device_channel,id,UNIX_SECONDS(occurred) as rec_start
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-17'
AND body_name = 'recorded_broadcast_view_start'
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.id = b.id
GROUP BY 1,2,3)
WHERE rec_watchtime > 0 AND rec_watchtime < 86400
GROUP BY 1
ORDER BY 2 DESC





SELECT id,device_channel,occurred,body_name,duration 
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-11-17'
AND device_channel = '50d0495b-7840-4081-a155-e54f31087d14'
GROUP BY 1,2,3,4,5
ORDER BY 3 DESC





--- watchtime calculation UA
SELECT date,(SUM(watchtime)/(60*60)) as watchtime
FROM (
SELECT DATE(occurred) as date,device_channel,(CAST(duration AS INT64)) as watchtime
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-17'
AND body_name = 'recorded_broadcast_view_duration'
AND duration IS NOT NULL
GROUP BY 1,2,3)
GROUP BY 1





SELECT device_channel,DATE(occurred) as date,app_version
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-11-17'
GROUP BY 1,2,3
ORDER BY 1,2,3


SELECT *
FROM (
SELECT device_channel,COUNT(DISTINCT app_version) as versions
FROM (
SELECT device_channel,app_version,MIN(date)
FROM `derived_data.landing_page_temp_date_nov21`
WHERE app_version IS NOT NULL
GROUP BY 1,2)
GROUP BY 1)
WHERE versions > 1
ORDER BY 2 DESC LIMIT 1000



SELECT device_channel,COUNT(DISTINCT app_version) as versions
FROM `analytics_data.ua_v3` 
GROUP BY 1
ORDER BY 2 DESC




--- ua_app_version_details
SELECT device_channel,app_version,date,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY device_channel ORDER BY date) AS next_upd_date
FROM (
SELECT device_channel,app_version,MIN(DATE(occurred)) as date
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-10-01' AND DATE(occurred) <= '2018-11-20'
AND app_version IS NOT NULL
--AND device_channel = 'ab6bd8bd-795c-4772-afed-34e590e5b2cc'
GROUP BY 1,2)
GROUP BY 1,2,3






SELECT device_channel,app_version,date,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY device_channel ORDER BY date) AS next_upd_date
FROM (
SELECT device_channel,app_version,MIN(DATE(occurred)) as date
FROM `analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-10-01' AND DATE(occurred) <= '2018-11-20'
AND app_version IS NOT NULL
--AND device_channel = 'ab6bd8bd-795c-4772-afed-34e590e5b2cc'
GROUP BY 1,2)
GROUP BY 1,2,3


SELECT a.date as date,a.device_channel as device_channel,a.body_name as body_name,
(CASE WHEN a.date >= b.date AND a.date < b.next_upd_date THEN b.app_version END) as app_version
FROM (
SELECT date,device_channel,body_name 
FROM `analytics_data.ua_derived_data_v1`
GROUP BY 1,2,3) a
JOIN (
SELECT *
FROM `derived_data.ua_app_version_details`) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3,4





SELECT a.date as date,a.landpagetype as landpagetype,a.users as game_page_openers,b.users as game_players,(b.users/a.users) as conversion
FROM (
SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM `derived_data.ua_landing_page_comparision` 
WHERE body_name = 'games_open'
AND app_version IS NOT NULL AND app_version NOT LIKE '%debug%'
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM `derived_data.ua_landing_page_comparision` 
WHERE body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND app_version IS NOT NULL AND app_version NOT LIKE '%debug%'
GROUP BY 1,2) b
ON a.date = b.date AND a.landpagetype = b.landpagetype 
GROUP BY 1,2,3,4,5









SELECT a.date as date,a.landpagetype as landpagetype,a.users as game_page_openers,b.users as game_players,(b.users/a.users) as conversion
FROM (
SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM (
SELECT a.date,a.app_version,a.device_channel
FROM (
SELECT date,app_version,device_channel 
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE type = 'OPEN'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) a
JOIN (
SELECT date,app_version,device_channel 
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE type = 'CUSTOM' AND body_name = 'games_open'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
WHERE a.device_channel NOT IN (
SELECT device_channel 
FROM (
SELECT device_channel,MAX(app_version) as max_version 
FROM `derived_data.ua_app_version_details` 
GROUP BY 1)
WHERE max_version < '6.4.0' 
GROUP BY 1)
GROUP BY 1,2,3)
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE type = 'CUSTOM' AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND device_channel NOT IN (
SELECT device_channel 
FROM (
SELECT device_channel,MAX(app_version) as max_version 
FROM `derived_data.ua_app_version_details` 
GROUP BY 1)
WHERE max_version < '6.4.0' 
GROUP BY 1)
GROUP BY 1,2) b
ON a.date = b.date AND a.landpagetype = b.landpagetype 
GROUP BY 1,2,3,4,5






SELECT a.date as Date,
COUNT(DISTINCT a.device_channel) as NewUsers,
COUNT(DISTINCT b.device_channel) as SignUpStartedUsers,
COUNT(DISTINCT c.device_channel) as SignUpDoneUsers
FROM (
SELECT date,device_channel 
FROM `analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM' AND body_name = 'new_user'
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT date,device_channel 
FROM `analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM' AND body_name = 'signup_started'
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT OUTER JOIN (
SELECT date,device_channel 
FROM `analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
GROUP BY 1


SELECT date(ua.occurred), ua.device_named_user_id, ua.game_id, CAST(ua.trivia_question as int64) as Question, ua.trivia_answer, ua.body_name 
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`  ua
JOIN `swoo-analytics-bq.swoo_gaming_service.game` g
ON ua.game_id = g.game_id
WHERE date(occurred) >= '2018-11-21'
and ua.game_id = 'bfd82a50-f12f-428f-aa0a-9e8b1e6c3b45'
and ua.user_id = 7876631
and ua.body_name = 'trivia_answer_selected'
group by 1,2,3,4,5,6
order by Question



SELECT date(g.start_time), g.game_id, tqs.type, count(distinct ugs.user_id)
FROM `swoo-analytics-bq.swoo_gaming_service.trivia_question_set` tqs 
JOIN `swoo-analytics-bq.swoo_gaming_service.game` g
on g.game_id = tqs.game_id
JOIN `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` ugs
ON tqs.game_id = ugs.game_id
WHERE tqs.type = 'POLL'
AND ugs.games_won = 1
AND ugs.games_played = 1
group by 1,2,3
order by 1 desc
limit 10






SELECT a.date as date,a.device_channel as device_channel,a.type as type,a.body_name as body_name,
(CASE WHEN a.date >= b.date AND a.date < b.next_upd_date THEN b.app_version END) as app_version
FROM (
SELECT date,device_channel,type,body_name 
FROM `analytics_data.ua_derived_data_v1`
WHERE type IN ('OPEN','CUSTOM')
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT *
FROM `derived_data.ua_app_version_details`) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3,4,5


SELECT a.date as date,a.landpagetype as landpagetype,a.users as game_page_openers,b.users as game_players,(b.users/a.users) as conversion
FROM (
SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM (
SELECT a.date,a.app_version,a.device_channel
FROM (
SELECT date,app_version,device_channel 
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE type = 'OPEN'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) a
JOIN (
SELECT date,app_version,device_channel 
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE body_name = 'games_open'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND 
--AND app_version >= '6.4.0'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2,3)
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM `derived_data.ua_landing_page_comparision_v2` 
WHERE body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND app_version IS NOT NULL AND app_version NOT LIKE '%debug%'
GROUP BY 1,2) b
ON a.date = b.date AND a.landpagetype = b.landpagetype 
GROUP BY 1,2,3,4,5








SELECT date,COUNT(DISTINCT device_channel) as users
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE app_version IS NOT NULL
AND date >= '2018-10-26'
GROUP BY 1






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



SELECT Date,D1 FROM (
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
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)



SELECT *
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'








SELECT date,CASE WHEN app_version >= '6.4.0' THEN 'new' ELSE 'old' END AS landpagetype,COUNT(DISTINCT device_channel) as users
FROM (
SELECT a.date,a.app_version,a.device_channel
FROM (
SELECT date,app_version,device_channel 
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE type = 'OPEN' --IS NULL
GROUP BY 1,2,3) a
JOIN (
SELECT date,app_version,device_channel 
FROM `derived_data.ua_landing_page_comparision_v3` 
WHERE body_name = 'games_open'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND app_version >= '6.4.0'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2,3)
GROUP BY 1,2





SELECT date,(SUM(watchtime)/(60*60)) as watchtime
FROM (
SELECT DATE(occurred) as date,device_channel,(CAST(duration AS INT64)) as watchtime
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-20'
AND body_name = 'recorded_broadcast_view_duration'
AND duration IS NOT NULL
GROUP BY 1,2,3)
GROUP BY 1




SELECT a.date as date,a.gamepagetype as gamepagetype,a.game_page_openers as game_page_openers,
b.game_players_from_game_page_openers as game_players_from_game_page_openers,(b.game_players_from_game_page_openers/a.game_page_openers) as conversion
FROM (
SELECT a.date,CASE WHEN a.app_version < '6.4.0' THEN 'Old' ELSE 'New' END AS gamepagetype,COUNT(DISTINCT a.device_channel) as game_page_openers
FROM (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v4` 
WHERE type = 'FIRST_OPEN'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) a
JOIN (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v4` 
WHERE type = 'CUSTOM' AND body_name = 'games_open'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.date,CASE WHEN a.app_version < '6.4.0' THEN 'Old' ELSE 'New' END AS gamepagetype,COUNT(DISTINCT a.device_channel) as game_players_from_game_page_openers
FROM (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v4` 
WHERE type = 'FIRST_OPEN'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) a
JOIN (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v4` 
WHERE type = 'CUSTOM' AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2) b
ON a.date = b.date AND a.gamepagetype = b.gamepagetype
GROUP BY 1,2,3,4,5



SELECT a.*,b.device_os as device_os
FROM (
SELECT *
FROM `derived_data.ua_landing_page_comparision_v4`) a
LEFT JOIN (
SELECT ua_notification_token,device_os 
FROM `backend_tables.user_device`
GROUP BY 1,2) b
ON a.device_channel = b.ua_notification_token
GROUP BY 1,2,3,4,5,6



SELECT date,device_channel,COUNT(DISTINCT time) as games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,EXTRACT(HOUR FROM occurred) as time
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-11-24' AND DATE(occurred) <= '2018-11-26'
AND type IN ('CUSTOM')
AND body_name IN ('candyrush_started_playing')
GROUP BY 1,2,3)
GROUP BY 1,2



SELECT a.device_channel as device_channel,b.device_os as device_os,COUNT(DISTINCT a.date) as days_played,SUM(a.games_played) as total_games_played
FROM (
SELECT *
FROM `derived_data.CandyKrack_temp_data` 
WHERE games_played >= 2) a
LEFT JOIN (
SELECT ua_notification_token,device_os 
FROM `backend_tables.user_device`
GROUP BY 1,2) b
ON a.device_channel = b.ua_notification_token
GROUP BY 1,2




###################################################### CK campaign queries

--## CandyKrack_temp_data
SELECT date,device_channel,COUNT(DISTINCT time) as games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,EXTRACT(HOUR FROM occurred) as time
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-27' -->= '2018-11-24' AND DATE(occurred) <= '2018-11-26'
AND type IN ('CUSTOM')
AND body_name IN ('candyrush_started_playing')
GROUP BY 1,2,3)
GROUP BY 1,2


--## CK_campaign_set1_20181127_data
SELECT a.*,b.device_os as device_os
FROM (
SELECT a.device_channel as device_channel 
FROM (
SELECT device_channel,games_played
FROM `derived_data.CandyKrack_temp_data` 
WHERE date = '2018-11-26'
AND games_played >= 2) a
JOIN (
SELECT device_channel,games_played
FROM `derived_data.CandyKrack_temp_data` 
WHERE date = '2018-11-27'
AND games_played >= 2) b
ON a.device_channel = b.device_channel) a
LEFT JOIN (
SELECT ua_notification_token,device_os 
FROM `backend_tables.user_device`
GROUP BY 1,2) b
ON a.device_channel = b.ua_notification_token
GROUP BY 1,2


--## CK_campaign_set2_data
SELECT a.device_channel as device_channel,b.device_os as device_os,COUNT(DISTINCT a.date) as days_played,SUM(a.games_played) as total_games_played
FROM (
SELECT *
FROM `derived_data.CandyKrack_temp_data` 
WHERE games_played >= 2) a
LEFT JOIN (
SELECT ua_notification_token,device_os 
FROM `backend_tables.user_device`
GROUP BY 1,2) b
ON a.device_channel = b.ua_notification_token
GROUP BY 1,2


--## CK_campaign_set2_minus_set1_20181127_data
SELECT a.*
FROM (
SELECT * 
FROM `swoo-analytics-bq.derived_data.CK_campaign_set2_data`) a
LEFT JOIN (
SELECT * 
FROM `swoo-analytics-bq.derived_data.CK_campaign_set1_20181127_data`) b
ON a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1,2,3,4

######################################################


SELECT * FROM (
SELECT a.Date,(a.D0/b.NewUsers) as D0,(a.D1/b.NewUsers) as D1,(a.D7/b.NewUsers) as D7,(a.D14/b.NewUsers) as D14,(a.D30/b.NewUsers) as D30
FROM (
SELECT Date,MAX(IF(Retention = 'D0',GamePlayUsers,NULL)) as D0,MAX(IF(Retention = 'D1',GamePlayUsers,NULL)) as D1,MAX(IF(Retention = 'D7',GamePlayUsers,NULL)) as D7,MAX(IF(Retention = 'D14',GamePlayUsers,NULL)) as D14,MAX(IF(Retention = 'D30',GamePlayUsers,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as GamePlayUsers 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1` 
WHERE body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1) a
LEFT JOIN (
SELECT date,COUNT(DISTINCT device_channel) as NewUsers
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1) b
ON a.Date = b.date
GROUP BY 1,2,3,4,5,6)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)



#######################################################

SELECT a.date as date,a.gamepagetype as gamepagetype,a.game_page_openers as game_page_openers,
b.game_players_from_game_page_openers as game_players_from_game_page_openers,(b.game_players_from_game_page_openers/a.game_page_openers) as conversion
FROM (
SELECT a.date,CASE WHEN a.app_version < '6.4.0' THEN 'Old' ELSE 'New' END AS gamepagetype,COUNT(DISTINCT a.device_channel) as game_page_openers
FROM (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v5` 
WHERE type = 'FIRST_OPEN'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND device_os = 'iOS'
GROUP BY 1,2,3) a
JOIN (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v5` 
WHERE type = 'CUSTOM' AND body_name = 'games_open'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND device_os = 'iOS'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.date,CASE WHEN a.app_version < '6.4.0' THEN 'Old' ELSE 'New' END AS gamepagetype,COUNT(DISTINCT a.device_channel) as game_players_from_game_page_openers
FROM (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v5` 
WHERE type = 'FIRST_OPEN'
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND device_os = 'iOS'
GROUP BY 1,2,3) a
JOIN (
SELECT date,device_channel,app_version
FROM `derived_data.ua_landing_page_comparision_v5` 
WHERE type = 'CUSTOM' AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND app_version IS NOT NULL 
AND app_version NOT LIKE '%debug%'
AND app_version NOT LIKE '%unknown_package%'
AND device_os = 'iOS'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2) b
ON a.date = b.date AND a.gamepagetype = b.gamepagetype
GROUP BY 1,2,3,4,5



SELECT date,COUNT(DISTINCT device_channel ) as users
FROM `derived_data.ua_landing_page_comparision_v5` 
WHERE device_os = 'iOS' AND app_version <= '6.3.0' 
GROUP BY 1


SELECT a.date,a.game_page_openers,b.game_players_from_game_page_openers,(b.game_players_from_game_page_openers/a.game_page_openers) as conversion
FROM (
SELECT a.date,COUNT(DISTINCT a.device_channel) as game_page_openers
FROM (
SELECT date,a.device_channel
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device`
WHERE device_os = 'iOS'
GROUP BY 1) b
ON a.device_channel = b.device_channel 
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel   
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM'
AND body_name = 'games_open'
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1) a
LEFT JOIN (
SELECT a.date,COUNT(DISTINCT a.device_channel) as game_players_from_game_page_openers
FROM (
SELECT date,a.device_channel
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device`
WHERE device_os = 'iOS'
GROUP BY 1) b
ON a.device_channel = b.device_channel 
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel   
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM'
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1) b
ON a.date = b.date
GROUP BY 1,2,3,4

#######################################################


SELECT *
--REPLACE(JSON_EXTRACT(device, "$.device_type"), "\"", "") as OS 
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw`
WHERE DATE(occurred) = '2018-11-21'
AND type = 'CUSTOM'
--AND REPLACE(JSON_EXTRACT(device, "$.name"), "\"", "") = 'bingo_started_playing'
AND device LIKE '%bingo_started_playing%'
LIMIT 200





SELECT DATE(occurred) as Date, COUNT(DISTINCT device_channel)as DAU 
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred)= '2018-11-29'
AND type in('OPEN','CUSTOM','FIRST_OPEN','SCREEN_VIEWED') 
GROUP BY 1

SELECT DATE(occurred) AS Date, body_name AS Game, COUNT(DISTINCT device_channel) AS Users 
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-29' 
AND body_name IN ('bingo_started_playing','trivia_started_playing','candyrush_started_playing') 
GROUP BY 1,2 
ORDER BY 1


SELECT DATE(occurred) AS Date,COUNT(DISTINCT device_channel) AS DAU 
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-11-29' 
AND body_name IN ('bingo_started_playing','trivia_started_playing','candyrush_started_playing') 
GROUP BY 1


SELECT Date(occurred) as Date, count(distinct device_channel) as DAU
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-29' 
AND type in ('FIRST_OPEN') 
GROUP BY 1


SELECT * 
FROM `analytics_data.ua_user_opened` 
ORDER BY 1 DESC


SELECT *
FROM `swoo-analytics-bq.daily_dashboard.game_players_by_type`  
WHERE Date < CURRENT_DATE()
ORDER BY 1 DESC


#######################################################

---- Step 1
-- Append the below query data to `swoo-analytics-bq:daily_dashboard.ua_app_derived_data_v1`
SELECT DATE(occurred) as date,type,device_channel
FROM `analytics_data.urban_airship_v2`  
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND type IN ('OPEN','FIRST_OPEN','UNINSTALL')
GROUP BY 1,2,3

---- Step 2
-- Overwrite the below query data to `swoo-analytics-bq:daily_dashboard.ua_retention`
SELECT * FROM (
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
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
AND date < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
AND date < CURRENT_DATE()
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)


#######################################################


SELECT date,device_channel,COUNT(DISTINCT time) as games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,EXTRACT(HOUR FROM occurred) as time
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-11-27' -->= '2018-11-24' AND DATE(occurred) <= '2018-11-26'
AND type IN ('CUSTOM')
AND body_name IN ('candyrush_started_playing')
GROUP BY 1,2,3)
GROUP BY 1,2


SELECT * FROM (
SELECT device_channel,COUNT(DISTINCT date) as noofdays,SUM(games) as total_games_played
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT game_id) as games
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-11-24' AND DATE(occurred) <= '2018-11-30'
AND type IN ('CUSTOM')
AND body_name IN ('candyrush_started_playing')
GROUP BY 1,2)
WHERE games >= 2
GROUP BY 1)
WHERE noofdays >= 5


SELECT a.*,b.device_os FROM (
SELECT * 
FROM `swoo-analytics-bq.derived_data.CK_campaign_winners_raw_data` 
WHERE device_channel NOT IN (
SELECT device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-11-17' AND date <= '2018-11-23'
AND type IN ('OPEN','FIRST_OPEN')
--AND body_name IN ('trivia_started_playing', 'bingo_started_playing','candyrush_started_playing')
GROUP BY 1))a
LEFT JOIN (
SELECT ua_notification_token as device_channel,device_os
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel




SELECT a.*,b.device_os FROM (
SELECT * 
FROM `swoo-analytics-bq.derived_data.CK_campaign_winners_raw_data`)a
LEFT JOIN (
SELECT ua_notification_token as device_channel,device_os
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel


######################################################

SELECT a.* FROM (
SELECT device_channel 
FROM `swoo-analytics-bq.derived_data.users_inactive_data` 
GROUP BY 1) a
JOIN (
SELECT device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-02'
--AND type = 'CUSTOM'
AND body_name = 'trivia_started_playing'
AND game_id = '7d14c985-c506-4a7a-986b-a5d756792841'
GROUP BY 1) b
ON a.device_channel = b.device_channel 
GROUP BY 1



SELECT *
FROM `swoo-analytics-bq.backend_tables.user_device` 
WHERE ua_notification_token IN ('7034e73d-33e5-44ae-b9e4-8879f903340e','27ddec13-792c-47fe-8a3f-fae1e15ed97d','91eacfec-c8c6-4a5b-b976-e754a9928fc0',
'05d35682-f585-4998-baa1-479f82e1a5a0','53ea6057-43f8-4508-934e-167333e17d56','24eb3ef2-07d2-41c2-9c65-efa473336675','6e1c6a12-2917-4df7-97ec-e783eb05c5ff',
'89873133-c84c-4769-818b-8d867c37461f','cb7cf45e-5fe6-4bd2-a687-e17b68fe3ece','5fabdd01-bd68-4fe6-b9d5-ba061e79df1c')

SELECT *
FROM `swoo-analytics-bq.backend_tables.user` 
WHERE id IN (9659792,12792827,10772681,7559527,9184515,11283931,12541400,9915029,12774506,10199189,12773053,10994644)







SELECT COUNT(DISTINCT a.device_channel) as NewUsers,
COUNT(DISTINCT b.device_channel) as ActiveUsers,
COUNT(DISTINCT c.device_channel) as RegisteredUsers,
COUNT(DISTINCT d.device_channel) as GamePlayers,
COUNT(DISTINCT CASE WHEN d.noofdays <=2 THEN d.device_channel END) as GamePlayers_for_max_2_days,
COUNT(DISTINCT CASE WHEN d.noofdays >=3 AND d.noofdays <=5 THEN d.device_channel END) as GamePlayers_for_3_to_5_days,
COUNT(DISTINCT CASE WHEN d.noofdays >5 THEN d.device_channel END) as GamePlayers_for_more_than_5_days,
COUNT(DISTINCT CASE WHEN e.noofreferrals = 1 THEN e.device_channel END) as Referred_for_1_time,
COUNT(DISTINCT CASE WHEN e.noofreferrals > 1 THEN e.device_channel END) as Referred_for_more_than_1_time,
COUNT(DISTINCT CASE WHEN e.noofreferrals > 5 THEN e.device_channel END) as Referred_for_more_than_5_times
FROM (
SELECT device_channel
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'FIRST_OPEN'
--AND DATE(occurred) >= '2018-11-18' AND DATE(occurred) <= '2018-11-24'
GROUP BY 1) a
LEFT OUTER JOIN (
SELECT device_channel
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as opens
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'OPEN'
GROUP BY 1,2)
--WHERE opens >= 2
GROUP BY 1) b
ON a.device_channel = b.device_channel 
LEFT OUTER JOIN (
SELECT device_channel
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1) c
ON b.device_channel = c.device_channel
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT date) as noofdays,SUM(games) as games
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as games
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'CUSTOM' AND body_name LIKE '%started_playing%'
GROUP BY 1,2)
GROUP BY 1
ORDER BY 2 DESC) d
ON c.device_channel = d.device_channel
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT occurred) as noofreferrals
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'CUSTOM' AND body_name LIKE '%_referred%'
GROUP BY 1) e
ON a.device_channel = e.device_channel






SELECT *
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'





SELECT a.week,a.user_type as curr_user_type,b.user_type as prev_user_type,COUNT(DISTINCT a.user_id) as users
FROM (
SELECT week,user_id,CASE WHEN type = 'FIRST_OPEN' THEN 'New'
WHEN type = 'OPEN' AND x_days_opened <=2 THEN 'Low'
WHEN type = 'OPEN' AND (x_days_opened >=3 AND x_days_opened <=5) THEN 'Medium'
WHEN type = 'OPEN' AND x_days_opened >5 THEN 'High'
ELSE 'Reactivated' END AS user_type
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, type,device_channel AS user_id,COUNT(DISTINCT date) as x_days_opened
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3)
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT b.week as week,a.user_type,a.user_id--COUNT(DISTINCT a.user_id) AS users
FROM (
SELECT week,user_id,CASE WHEN type = 'FIRST_OPEN' THEN 'New'
WHEN type = 'OPEN' AND x_days_opened <=2 THEN 'Low'
WHEN type = 'OPEN' AND (x_days_opened >=3 AND x_days_opened <=5) THEN 'Medium'
WHEN type = 'OPEN' AND x_days_opened >5 THEN 'High'
ELSE 'Reactivated' END AS user_type
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, type,device_channel AS user_id,COUNT(DISTINCT date) as x_days_opened
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3)
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.week = b.week-1
GROUP BY 1,2,3) b
ON a.week = b.week AND a.user_id = b.user_id
GROUP BY 1,2,3




SELECT month,noofdays_played,COUNT(DISTINCT device_channel) as users_played
FROM (
SELECT EXTRACT(MONTH FROM date) as month,device_channel,COUNT(DISTINCT date) as noofdays_played
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1` 
WHERE EXTRACT(MONTH FROM date) IN (9,10,11)
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
AND device_channel IN (SELECT device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`  
WHERE EXTRACT(MONTH FROM date) = 9
AND type  IN ('FIRST_OPEN')
GROUP BY 1)
GROUP BY 1,2)
GROUP BY 1,2





SELECT a.user_id,a.handle,b.notification_id
FROM (
SELECT id as user_id,handle 
FROM `swoo-analytics-bq.backend_tables.user`
WHERE handle IN ("Pand123","sheetusekhri123","anvaralivaidya","shar2722","keshabchguin","IndhuPriya","Pand123","IndhuPriya","MurshidAliKhan","prachig789","skiwink","Sameersoni007","keshabchguin","7978424156","9880121122","prakash198523","vidhi_theweirdo","prashant1728","Shubh4321","piyushchandwani811","tikina1995","jagadash0","Sunnymaddy","truephylosophy","piyushchandwani811","Thakur072","Sunnymaddy","saurabhchinu1355","cdearth","kiddo_lovr","sumit_satralkar","Thakur072","PrajnaP3","raju657","Surve410","Surve410","kumbhardhaneshwar","arya33050","pizzaa","AkanshaChatterjee","akoundi","kutubali","shilpaid","AkanshaChatterjee","akoundi","userfqo05","akoundi","akb1978akb","avneeshrai","AkanshaChatterjee","neena3088","rk32480000","saakshi321","meenaxi2608","geetasave","mamit6352","mamit6352","mamit6352","7415541890","NielThakur","comedyke","7415541890","anik1995","Yogi74","tyagiavinash7","Yogi74","anik1995","pp1122","akalless","Yogi74","akalless","pp1122","pp1122","RahulMohil","pp1122","rarj1","nehasinghashu","lizakonwar0","nehasinghashu","anjalijampalwar01","mohibfbxjks","Vickysharma143","ashi_rana21","ashi_rana21","userft1xj","Shubham13443","ushad6130","sakshivashisht","rahulmaheshwari0406","Riserkrish","jaaat1996","aheer1234","userao49p","aheer1234","shantanusaxena10","userfi17s","shantanusaxena10","shantanusaxena10","notty123","kajalsinger","shantanusaxena10","shantanusaxena10","kamdevrakshit2","rahulmaheshwari0406","khanshahb","danishkhan1234567890","nvikram888","rawatviveksingh894","nvikram888","rawatviveksingh894","cdearth","cdearth","userbohlg","123Mohabbat","subhbarnwal","BishopDhimal","PoojaLakhan","PoojaLakhan","DeenuPrajapati21","arpitgupta9589","arpitgupta9589","clickonmintu","vivanmandavi784","Kristee1","DoraBabuGattem","dkshagarwal","inventific","dkshagarwal","CANikitaAgrawal","mahzabi3808","userfu909","nirgudadipali","mahzabi3808","adil28rehman","iampatel","samnan786313","samnan786313","inventific","pizzaa","HaariHarika","seamanship114","HaariHarika","shrikantmaheshwari","JJC98","nadiational","singhrakesh123985","abdwari1997","nadiational","nadiational","hussainsaif384","tjoscorp77","nadiational","sharmi_1883","nadiational","jyotidutta2468","userbte6s","Premta1","sharmi_1883","sharmi_1883","abdwari1997","abdwari1997","bablusiddiki","sharmarichaa86","UnnatiGoyal","bablusiddiki","Tripurayadav","Tripurayadav","mostnk55555","PuspaRathour","mostnk55555","Tripurayadav","Tripurayadav","tamannareyani","rahulavi16","mostnk55555","YashGosavi","MukhPustak","userbzl7n","rohitsailekar4","tamannareyani","userf29td","ShreyasHariharan","userc9fzg","KirtiNegiyo","darshkarkera","userc9fzg","abbasmolla103","norlay","nizamsaha836","KirtiNegiyo","allenpratheesha","usere88aw","userd0m3d","Pikachu123","PratimaKumari1","Pikachu123","RaiZop","userf7kc6","HifajatKaji","Pikachu123","abidkhan47","userf7kc6","sumitdey7253","ushad6130","Pikachu123","rintuborah","ushad6130","swathi_ss888","rkd_8","userb5879","swathi_ss888","neha12neha12","userb5879","Pikachu123","sheedahmed","PoojaCShaliyan","userb5879","rkd_8","pallavisingh438","userb5879","PoojaCShaliyan","Saipothina","simirajeevgumber","sarikonda1","AstanHortaAS","poojamorey","sangitakeshari","usere8pbc","mrobocop","rkd_8","jigneshchhunchha","AstanHortaAS","sangitakeshari","sheedahmed","AstanHortaAS","sangitakeshari","sheedahmed","sangitakeshari","mrobocop","sangitakeshari","alishaa7866","SuhasNanda","SuhasNanda","rohitsehara86","Hi_Man_Shu","sangitakeshari","sangitakeshari","mohinisinghnet20","sangitakeshari","kratikas778","pujapandey2000","mohinisinghnet20","usereif91","manishsorout458","erbrahmin","anushanu2909","erbrahmin","erbrahmin","tuku3","tuku3","tuku3","samikshadambhare0","chets009","samikshadambhare0","samikshadambhare0","ravikantchandra43","samikshadambhare0","767029","samikshadambhare0","JuliSahni","samikshadambhare0","ShreyasHariharan","smansuri799","JuliSahni","cutekunjpari123","amrutasahu1996","dimple999","JuliSahni","ShreyasHariharan")
GROUP BY 1,2) a
LEFT JOIN (
SELECT user_id,ua_notification_token as notification_id
FROM `swoo-analytics-bq.backend_tables.user_device`
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2,3




SELECT COUNT(DISTINCT a.device_channel) as NewUsers,
COUNT(DISTINCT b.device_channel) as ReferredUsers,
COUNT(DISTINCT CASE WHEN b.noofreferrals = 1 THEN b.device_channel END) as Referred_for_1_time,
COUNT(DISTINCT CASE WHEN b.noofreferrals > 1 THEN b.device_channel END) as Referred_for_more_than_1_time,
COUNT(DISTINCT CASE WHEN b.noofreferrals > 5 THEN b.device_channel END) as Referred_for_more_than_5_times
FROM (
SELECT device_channel
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'FIRST_OPEN'
AND DATE(occurred) >= '2018-11-18' AND DATE(occurred) <= '2018-11-24'
GROUP BY 1) a
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT occurred) as games
FROM `swoo-analytics-bq.derived_data.data_for_AARRR`
WHERE type = 'CUSTOM' AND body_name LIKE '%_started_playing%'
AND DATE(occurred) >= '2018-11-18' AND DATE(occurred) <= '2018-11-24'
GROUP BY 1) b
ON a.device_channel = b.device_channel 


SELECT date,CASE WHEN (body_name = 'trivia_started_playing' AND body_name = 'bingo_started_playing' AND body_name = 'candyrush_started_playing') THEN 'Trivia_Bingo_CK'
WHEN (body_name = 'trivia_started_playing' AND body_name NOT IN ('bingo_started_playing','candyrush_started_playing')) THEN 'Trivia Only'
WHEN (body_name = 'bingo_started_playing' AND body_name NOT IN ('trivia_started_playing','candyrush_started_playing')) THEN 'Bingo Only'
WHEN (body_name = 'candyrush_started_playing' AND body_name NOT IN ('trivia_started_playing','bingo_started_playing')) THEN 'CK Only'
WHEN (body_name = 'trivia_started_playing' AND body_name = 'bingo_started_playing' AND body_name != 'candyrush_started_playing') THEN 'Trivia & Bingo'
WHEN (body_name = 'trivia_started_playing' AND body_name = 'candyrush_started_playing' AND body_name != 'bingo_started_playing') THEN 'Trivia & CK'
WHEN (body_name = 'bingo_started_playing' AND body_name = 'candyrush_started_playing' AND body_name != 'trivia_started_playing') THEN 'Bingo & CK'
ELSE 'Others' END AS game_types,COUNT(DISTINCT device_channel) as Users
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1` 
WHERE date = '2018-12-02'
GROUP BY 1,2






SELECT DATE(occurred) as date,COUNT(DISTINCT device_named_user_id)--device_named_user_id) --device_channel,device_named_user_id,user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-12-06'
AND body_name  = 'signup_done'
GROUP BY 1--,2,3,4


SELECT body_name,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-12-10'
GROUP BY 1





SELECT a.week,a.user_type as curr_user_type,b.user_type as prev_user_type,COUNT(DISTINCT a.user_id) as users
FROM (
SELECT week,user_id,CASE WHEN type = 'FIRST_OPEN' THEN 'New'
WHEN type = 'OPEN' AND x_days_opened <=2 THEN 'Low'
WHEN type = 'OPEN' AND (x_days_opened >=3 AND x_days_opened <=5) THEN 'Medium'
WHEN type = 'OPEN' AND x_days_opened >5 THEN 'High'
ELSE 'Reactivated' END AS user_type
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, type,device_channel AS user_id,COUNT(DISTINCT date) as x_days_opened
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3)
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT b.week as week,a.user_type,a.user_id--COUNT(DISTINCT a.user_id) AS users
FROM (
SELECT week,user_id,CASE WHEN type = 'FIRST_OPEN' THEN 'New'
WHEN type = 'OPEN' AND x_days_opened <=2 THEN 'Low'
WHEN type = 'OPEN' AND (x_days_opened >=3 AND x_days_opened <=5) THEN 'Medium'
WHEN type = 'OPEN' AND x_days_opened >5 THEN 'High'
ELSE 'Reactivated' END AS user_type
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, type,device_channel AS user_id,COUNT(DISTINCT date) as x_days_opened
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3)
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.week = b.week-1
GROUP BY 1,2,3) b
ON a.week = b.week AND a.user_id = b.user_id
GROUP BY 1,2,3






SELECT a.date as Acq_date,b.date as Cashout_date,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE type = 'CUSTOM' AND body_name LIKE '%cashout%'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2



SELECT a.date as date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE type = 'CUSTOM' AND body_name LIKE '%cashout%'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2



SELECT date,COUNT(DISTINCT device_channel) as new_users
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1





SELECT b.device_os,b.notification_id
FROM (
SELECT id as user_id,handle 
FROM `swoo-analytics-bq.backend_tables.user`
WHERE handle IN ("Kichan1","rawatviveksingh894","PratimaKumari1","karanchugh003","atulpoddar76","BhaveshPratapSingh","hridima","userfggsc","mohsinkhanwow","danishsafdar2003","swathi_ss888","Prashantrajpoot00","userfvet8","kishwarrao04","userfu6f0","Adhampure","micky1855","vaibhavr801871999","danishsafdar2003","momidn","SuneetChak","AnjuBinani","BhaveshPratapSingh","TipKazama","PratimaKumari1","swathi_ss888","dk843","smdali080587","userfggsc","umerask061287","sunilsingh78","deepmegh","sawariyarahul88","userbkygs","hridima","prajapatimahesh011","userfggsc","deepmegh","mani1240","kkhhaja","PrernaKhanna","sunilsingh787721","shyam00712","mani1240","userfp1v1","MerlyJcBRozz","alokdiyalove","khanirshaad60","userbgn44","MoynishKhan","MansiBansal21","shalzmurthy91","deepshikha284","khanirshaad60","muraliedge","TabuSaifKhan","satyasseha","akaabhay","viveksingh1193","AnkitaSinghChundawat","yashbhivsane08","madhavi_singh227","himan11","sultan315","sanyasinayak569","sanyasinayak569","kuldeepkarotia","choudharysarita513","deepharsh1","thakur1998","akaabhay","deshlaihre","PayalVatsVashisht","TulikaSrivastava","PayalVatsVashisht","raunak136","XTREAM1","RaiZop","jyotikhatkar17","faizanmohamed59","userfu6f0","vkeksk","nayshapal","PayalVatsVashisht","riyasantra22032000","userbgpzx","kmal12","PayalVatsVashisht","induhpt206","priyasingh7504","lovelyoneness","PayalVatsVashisht","hackashish91","arjun19981604","PayelDasGhosh","userfvk33","Namani21","poojajha1995","msshantagiri1","hackashish91","Ven68793","poojajha1995","DevanshiTyagi","userdfi0r","nikki_121","ka2909","falaqjan19","ammulavi1508","lama904348","ammulavi1508","kapoor_1059","himan11","DevanshiTyagi","DevanshiTyagi","GopiPatru","tyagiavinash7","PradipChakraborty21","SamSamanthaSam","SamSamanthaSam","py0212","sultan315","SamSamanthaSam","FarshSe","neerajkumaruikey7","shrutikalyani","heena06","TheBong","TheBong","Hanumanth41","SravaniBandanapudi","july_21","aadesh27","guptasakshi123","sekpatel27","RishiChhajed","RishiChhajed","guptasakshi123","kutubali","RishiChhajed","swatigupta180688","shrutisaini","JainAnkit1","shrutisaini","Harshveertakkar","swatigupta180688","alokdiyalove","honeykumarbhagat","Bhavya1234","sanasheikh640","rahultripathi650","prabin34","SavitaPandey1","DhrmaramSeervi","raju0205","Bhavya1234","sundershyam0312","DevanshiTyagi","ManjuTanwar","sambit105","PremabrataRoy","sambit105","DevanshiTyagi","sambit105","DevanshiTyagi","chiraglama86","DevanshiTyagi","archanapatel74_204","PremabrataRoy","PremabrataRoy","PremabrataRoy","PremabrataRoy","vinusha21","vinusha21","vinusha21","NielThakur","RushiPatel21","userf6uwi","agrawalmohit1997","comedyke","comedyke","psumit393","sultan315","kailashambir","vijaypangare3","bittank123","suchi_0509","suchi_0509","Manjurachu","anik1995","amrutasahu1996","nishavashishtha1","raryan01","vivasimgh","Shru94","Shru94","vivanmandavi784","BoggarapuSudhaRani","PoojaBeauty","alokdiyalove","alokdiyalove","prajapat2000","simran100","dancing_girl","promise21","SrishtiSrivastava","tusharsorte","diggi1","jaysada87","147janu","147janu")
GROUP BY 1,2) a
LEFT JOIN (
SELECT user_id,device_os,ua_notification_token as notification_id
FROM `swoo-analytics-bq.backend_tables.user_device`
GROUP BY 1,2,3) b
ON a.user_id = b.user_id
GROUP BY 1,2


SELECT a.date,COUNT(DISTINCT a.device_channel) as NewUsers,COUNT(DISTINCT b.device_channel) as RegisteredUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM' AND body_name = 'signup_done'
AND date >= '2018-05-01'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel 
GROUP BY 1


SELECT a.date,COUNT(DISTINCT a.device_channel) as NewUsers,COUNT(DISTINCT b.device_channel) as RegisteredUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type = 'CUSTOM' AND body_name LIKE '%cashout%'
--WHERE type = 'CUSTOM' AND body_name = 'signup_done'
AND date >= '2018-05-01'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel AND a.date != b.date
GROUP BY 1






SELECT COUNT(DISTINCT device_channel) as game_players
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
WHERE date >= '2018-11-26' AND date <= '2018-12-02'

486199




SELECT DATE(occurred) as date,device_channel,device_named_user_id,user_id--COUNT(DISTINCT device_named_user_id)
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2018-12-06'
--AND type = 'FIRST_OPEN'
AND body_name  = 'signup_done'
-ND user_id IS NOT NULL
AND device_named_user_id != CAST(user_id AS STRING)
GROUP BY 1-2,3,4

23222 --user_id (signup_done)
28980 --device_named_user_id (signup_done)
32371 --device_channel (signup_done)
54027 --device_channel (FIRST_OPEN)


SELECT *
FROM `swoo-analytics-bq.backend_tables.user`
WHERE id IN (13384315,13410044,13414935,13423969,13414927,13401901,13386123,13416845,13412146,13399900,13425007,13386388,8473914,13386448,13402100,13391045,13389831,8920432,13401527,13389635,13412563,13396222,13385229,13366708,13198387,13405038,13406589,13422407,13409943,8464813,13389244,13410602,13412597,13404898,13387602,13317479,12853278,13396908,13381759,13420658,13383989,13420982,11129609,10234283,13196943,13422626,13389520,13301883,13409108,13392054,13386495,13359932,13218404,13400634,12601652,13420294,13398745,13403091,13379820,13382511,13405001,13378424,13407547,13391491,13399677,13384971,9058813,13415232,13398664,13425125,13410607,13387466,12864556,13397178,13408171,10860688,13404668,13398354,13417758,13384459,13383386,13421930,13390434,13406455,13414816,13419569,13381381,9612672,13408151,13401711,13395493,13415284,12864996,13378224,13417144,13391663,12795667,13420506,13002268,13396432,13379184,13394484,13395119,13147843,13416743,13406830,9381182,13411476,13394512,13393422,13419370,13295112,13381657,13390596,13395651,13398066,13381149,13421554,13377944,12753201,13403203,13394030,13410144,13390907,13395507,13421143,12105268,13390056,13414794,13380849,13421676,13412623,13406671,13378122,13424390,13410480,13383017,13419009,13418314,8933361,13406042,13423314,13402879,13413367,13405950,13419160,13405780,13398790,13237953,13423121,13410993,12590647,13387313,13401234,9998161,13417433,12420557,13411699,13396287,13425231,13394082,13391993,12709476,13407558,13369768,13398466,9348702,11306956,13402413,13394215,13387397,13384597,13366863,13401796,13398082,13383343,13395020,13380298,13416508,13379409,13409860,13420868,13422081,13405919,8235743,13402201,13381988,13397542,13388242,13406492,13399109,10930356,11107061,10234334,13379909,13415129,13382609,11327289,12700254,13406099,13416970,13386586,13411604,13421869,13421119,13403199,13399329,13391420,13400858,13423061,13410435,13359932,12418837,13406696,13354679,13409090,13125048,13420720,13422924,13372221,13405321,13288405,13384852,13397535,13385716,12566018,13406997,13421506,13390737,13382356,13419410,13419236,13386213,13390521,13423155,13403222,13408667,12671652,13410847,13414560,13412090,13392073,11691746,13365501,13411826,13411676,13411348,13413925,13413745,13411392,13403659,13421206,13419674,13390445,9590335,13422354,13424665,671274,13391963,13411284,13382793,12233145,13423593,13387503,13422603,13402058,13384822,9478133,13395278,13390075,13393399,13382222,13417112,13409259,13417117,13265727,13413574,13395267,8816848,13416920,13382147,10943342,13397718,13382450,13422855,13400517,13414520,13410498,13408353,13407063,11141767,13408193,13257184,13403000,13386137,13363182,13382326,13407601,9968691,13396650,13406497,13414238,13052057,13412783,13380426,13393918,13403237,13404214,13402775,13353630,13402663,13385160,13410782,13378254,13393083,13415151,12470831,13419313,13395805,13313357,12301536,13409328,12205148,13405579,13376730,12198562,13398544,12219577,9608527,13418175,13407798,13405017,13383929,13405479,13416519,13421994,13381497,13403013,10000119,13406000,11236863,12285423,13409744,13412565,13384269,13386833,13405260,13389753,12566018,13420394,13396578,13402250,13412380,12257830,13415390,13403489,13416994,13402104,13381439,13407793,13290602,13402576,13421489,13403361,13420250,13419095,13364703,13425228,12377988,13393109,13409487,13386270,13390558,13397666,13380458,12601856,13395938,13382123,13381339,13399247,13320150,13333313,13376027,13373919,10924245,13411744,13400588,13388859,12288327,13389629,12466642,13397099,129589,13039798,12415568,12864996,9742709,13399174,13381508,13400661,13384903,12752525,13378349,13407656,12887670,13413686,13396182,11171686,12043146,13402525,13417036,13407870,13421985,13404821,13394119,13394342,13422026,13381811,13415999,13391978,13398365,13386315,13420469,13413338,13411018,13423233,12876879,13413366,13382786,13410442,11512111,13421121,13421080,13393179,13423733,13363860,13382627,13388852,13417184,13402728,11756047,13385662,13407196,13421479,13294305,13421460,13013556,9515507,13240162,13383028,13406026,13401693,13397502,13406611,13394638,13368746,13422101,13383698,13390872,13421045,13046786,13408838,13408385,13423756,13419023,13334678,13360248,13411525,13170182,13402631,13390970,13393171,13408427,13398594,9349378,13363588,13388496,13410911,13388831,13384084,13401545,13406123,13403820,13403046,13383789,13389208,13419764,13404633,13390202,13417417,13417831,13385690,6854099,13411445,13420287,12988243,13412923,13339751,10664135,13386942,13421569,11856132,13392395,13408156,13408331,13416615,13405831,13400566,13423142,13400589,13381756,13380693,13293876,13409132,13279542,12564644,13400924,13392772,13408281,13408040,13413001,13419868,13389496,13405353,13402899,13405466,13410213,8514403,13381854,13424904,13420810,13402160,13384903,13423012,13421393,13393912,7312786,13394928,13207047,13411940,13417296,13393281,12579151,13421472,12507242,13383908,13385042,13414058,13386917,13059283,10843765,13415281,13397974,13384122,11512007,13392131,13383277,13403161,13422122,13392679,13383610,11845506,13373470,13418273,13410466,13106903,13408435,13415346,13410057,13405994,13383566,13400505,13358623,12644871,13384996,13421776,13389878,13387638,13392110,12566018,13379699,13403169,12209813,5617941,13396696,9982222,13411926,13380131,13396383,13387273,12994086,13411535,13414719,13411159,13391978,13393159,11870083,13416992,13405095,13422481,13365981,13420404,13408843,13422844,13392909,11547542,13410397,13385192,13190901,13415553,13407745,13414649,12011183,9543518,10350368,13397736,12497312,13413783,13399893,13398587,13420584,9280744,13384834,13423011,13396216,13399665,13383193,13419062,13401272,13421344,13410725,13424859,13394116,13406960,13405831,12803998,13425151,11395382,13393447,11864918,13393413,13412814,13410373,11962793,13394455,13391122,13400464,13332376,13396719,13399740,13424965,13421199,13041184,13380945,13368503,13418698,13403562,12787782,13384255,13409680,13395099,6837718,13390138,13382066,13395724,13383855,13388363,13413568,13401787,13398845,13379811,13390185,13383299,13388613,10547333,11373157,13394865,13388488,13390199,11005200,13389707,13413128,12707591,13372325,11367555,13307998,13399424,13389628,13372298,13423778,13420430,13384181,13379868,13415499,13389775,13420516,13385799,13417700,13384445,13415890,13415953,13422001,13389031,13237628,13424773,13391738,13377750,28970,13416239,13385059,13390681,12624176,13405017,13390518,13396924,13424364,13384472,13411408,13401731,13395071,13390099,13413405,13389764,13384682,11966205,13385984,12327183,13396931,13390029,13412294,13377348,8277557,13379918,8301659,13394438,13393322,13421043,13411898,13402570,13264824,13409388,13397315,13407229,13421260,13421332,13395892,13221514,13410563,13384221,13422634,13331760,13383406,13405016,13399640,10290484,13421287,13414644,13412809,13411719,13414872,13385804,13421912,360482,12676886,13381264,13386055,13415409,13400426,13420238,13406294,13410360,13389650,13391232,13359803,13416536,13409192,11537512,13401517,13349537,13389093,13381323,13386021,13421145,13389116,13196501,13396246,13389138,12998299,13412915,13400916,10027731,13412480,13393037,13421684,13398265,13396048,13394548,13417696,13398108,13404443,13392172,13380833,13417258,13384277,13390954,13389931,13395021,13243622,13396485,13399091,13391705,13407671,13395535,13415492,13413983,13413838,13404345,8030874,13387652,12504450,13422659,13414809,13422111,13288874,13419021,13406208,13229921,13409518,6728061,13411685,10945435,13408675,13051117,13052471,13411106,13399378,13393972,13418564,13422930,13408309,13394310,13385104,13420528,13389985,13394892,13414956,13363232,13399024,13407892,13417865,3381665,13419451,13420505,13409384,13382197,13283935,13424547,13420797,9642205,13415670,13391314,13401310,13369433,13406324,12043146,13406906,10687427,13390302,13371039,13422768,13424656,9515535,13391613,11742689,13393785,13420257,13390777,13382928,13391223,13397511,13385140,12564644,13422459,13390311,13301213,13401138,13396747,12095402,13395815,13421756,13390149,13385729,13413548,13390198,13419767,13408752,13420377,12645503,9318010,9699876,13421234,13403876,13416055,13399259,13413412,13412906,13380792,13395487,13413475,13222826,13398297,13396017,13410859,13420567,13425194,13406756,13416421,9965907,13402823,13407430,13383139,13415373,8544612,12578439,13408975,13417271,13402757,13404276,13399440,13415218)





SELECT a.date,COUNT(DISTINCT a.device_channel) as winning_device_channels,COUNT(DISTINCT a.user_id) as winners_from_new_users--a.device_channel
FROM (
SELECT a.date,a.device_channel,b.user_id--COUNT(DISTINCT b.user_id) as new_users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE date >= '2018-05-01'
AND body_name  = 'signup_done'
GROUP BY 1,2) a
JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
--WHERE ua_notification_token = '3d9b1443-8274-40c1-a48c-b9186423d65c'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 1
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id
GROUP BY 1,2





SELECT * FROM (
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
SELECT a.date,a.device_channel--COUNT(DISTINCT a.user_id) as winners_from_new_users
FROM (
SELECT a.date,a.device_channel,b.user_id--COUNT(DISTINCT b.user_id) as new_users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE date >= '2018-05-01'
AND body_name  = 'signup_done'
GROUP BY 1,2) a
JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
--WHERE ua_notification_token = '3d9b1443-8274-40c1-a48c-b9186423d65c'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 0
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)





SELECT DATE(timestamp) as date,name,COUNT(DISTINCT developer_identity) as users
FROM `analytics_data.branch_io`
WHERE DATE(timestamp) >= '2018-09-25'
AND name IN ('TriviaRinger_Open','TriviaRinger_OpenGame','TriviaRinger_Dismiss','BingoRinger_Open','BingoRinger_OpenGame','BingoRinger_Dismiss','CandyRushRinger_Open','CandyRushRinger_OpenGame','CandyRushRinger_Dismiss')
GROUP BY 1,2





SELECT a.date,COUNT(DISTINCT a.device_channel) as RegisteredUsers,COUNT(DISTINCT b.device_channel) as RingerOptInsfromNew
FROM (
SELECT date,device_channel
--FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE date >= '2018-05-01'
--AND type  = 'FIRST_OPEN'
AND body_name  = 'signup_done'
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-05-01'
AND body_name  IN ('games_candyrushoptin','games_triviaoptin','games_bingooptin','Games_BingoOptIn','Games_TriviaOptIn','Games_CandyRushOptIn','games_bingo_ringer_opted','games_candyrush_ringer_opted','games_trivia_ringer_opted','games_swooperstar_ringer_opted')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1





WITH candyrush_winners AS (
SELECT DATE(g.start_time) AS date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` AS ugs
JOIN `swoo-analytics-bq.swoo_gaming_service.game` AS g
ON g.game_id = ugs.game_id
WHERE games_won = 1 AND g.game_type_id = 'CandyRush'
GROUP BY 1,2),
first_time_ck_winner AS (
SELECT cw.date,cw.user_id
FROM candyrush_winners cw
INNER JOIN (
SELECT user_id,MIN(date) AS first_occurance
FROM candyrush_winners
GROUP BY user_id) AS occ
ON occ.user_id = cw.user_id AND cw.date = occ.first_occurance)
SELECT Date,D1,D7,D14,D30
FROM (
SELECT Date,(D1/D0) AS D1,(D7/D0) AS D7,(D14/D0) AS D14,(D30/D0) AS D30
FROM (
SELECT Date,
MAX(IF(Retention = 'D0',Users,NULL)) AS D0,
MAX(IF(Retention = 'D1',Users,NULL)) AS D1,
MAX(IF(Retention = 'D7',Users,NULL)) AS D7,
MAX(IF(Retention = 'D14',Users,NULL)) AS D14,
MAX(IF(Retention = 'D30',Users,NULL)) AS D30
FROM (
SELECT a.date AS Date,
CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.user_id) AS Users
FROM (
SELECT date, user_id from first_time_ck_winner
GROUP BY 1,2) a
LEFT JOIN (
SELECT date(g.start_time) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` as ugs
JOIN `swoo-analytics-bq.swoo_gaming_service.game` as g
ON g.game_id = ugs.game_id
WHERE games_won = 1 AND g.game_type_id = 'CandyRush'
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)



SELECT ref_applied_date,COUNT(DISTINCT user_id) as users
FROM (
SELECT DATE(referral_applied_time) as ref_applied_date,user_id,MIN(DATE(created_at)) as created_date
FROM `swoo-analytics-bq.swoo_gaming_service.user_statistics`
WHERE referral_code_applied IS NOT NULL
AND is_referral_applied = 1 
AND DATE(referral_applied_time) >= '2018-12-01' AND DATE(referral_applied_time) <= '2018-12-31'
GROUP BY 1,2) a
WHERE DATE_DIFF(ref_applied_date,created_date,DAY) <= 7
GROUP BY 1,2



SELECT a.ref_applied_date as date,b.device_chanel
FROM (
SELECT ref_applied_date,user_id
FROM (
SELECT DATE(referral_applied_time) as ref_applied_date,user_id,MIN(DATE(created_at)) as created_date
FROM `swoo-analytics-bq.swoo_gaming_service.user_statistics`
WHERE referral_code_applied IS NOT NULL
AND is_referral_applied = 1 
AND DATE(referral_applied_time) >= '2018-12-01' AND DATE(referral_applied_time) <= '2018-12-31'
GROUP BY 1,2) a
WHERE DATE_DIFF(ref_applied_date,created_date,DAY) <= 7
GROUP BY 1,2) a
LEFT JOIN (
SELECT user_id,ua_notification_token as device_chanel
FROM `swoo-analytics-bq.backend_tables.user_device`
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2



######### Refer & earn - app open retention
SELECT * FROM (
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
SELECT a.ref_applied_date as date,b.device_channel as device_channel
FROM (
SELECT ref_applied_date,user_id
FROM (
SELECT DATE(referral_applied_time) as ref_applied_date,user_id,MIN(DATE(created_at)) as created_date
FROM `swoo-analytics-bq.swoo_gaming_service.user_statistics`
WHERE referral_code_applied IS NOT NULL
AND is_referral_applied = 1 
AND DATE(referral_applied_time) >= '2018-10-18'-- AND DATE(referral_applied_time) <= '2018-12-31'
GROUP BY 1,2) a
WHERE DATE_DIFF(ref_applied_date,created_date,DAY) <= 7
GROUP BY 1,2) a
LEFT JOIN (
SELECT user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device`
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)



######### New Users retention (who haven't played any game on Day Zero-D0)
SELECT * FROM (
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
SELECT a.date,a.device_channel --COUNT(DISTINCT a.device_channel) as users_not_played
FROM (
SELECT date, device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
LEFT JOIN (
SELECT date, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)



######### New Users retention (who have played game & lose on Day Zero-D0)
SELECT * FROM (
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
SELECT a.date,a.device_channel
FROM (
SELECT a.date,a.device_channel,b.user_id
FROM (
SELECT a.date,a.device_channel --COUNT(DISTINCT a.device_channel) as users_not_played
FROM (
SELECT date, device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT date, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
--WHERE ua_notification_token = '3d9b1443-8274-40c1-a48c-b9186423d65c'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 0
GROUP BY 1,2) b
ON a.user_id = b.user_id AND a.date = b.date
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)



######### New Users retention (who have played game & won on Day Zero-D0)
SELECT * FROM (
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
SELECT a.date,a.device_channel
FROM (
SELECT a.date,a.device_channel,b.user_id
FROM (
SELECT a.date,a.device_channel --COUNT(DISTINCT a.device_channel) as users_not_played
FROM (
SELECT date, device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT date, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
--WHERE ua_notification_token = '3d9b1443-8274-40c1-a48c-b9186423d65c'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 1
GROUP BY 1,2) b
ON a.user_id = b.user_id AND a.date = b.date
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5)
WHERE Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)



######### Users from one game show coming to all other games (played the previous game)
SELECT a.date as game1_date,b.date as games2_date,a.title as game1_title,b.title as games2_title,COUNT(DISTINCT a.user_id) as users
FROM (
SELECT a.date,a.game_type_id,a.title,a.game_id,b.user_id
FROM (
SELECT DATE(start_time) as date,game_type_id,title,game_id
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE DATE(start_time) >= '2018-12-15'
AND is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '06:30:00'
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT DATE(created_at) as date,game_type_id,game_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.game_type_id = b.game_type_id AND a.game_id = b.game_id
GROUP BY 1,2,3,4,5) a
JOIN (
SELECT a.date,a.game_type_id,a.title,a.game_id,b.user_id
FROM (
SELECT DATE(start_time) as date,game_type_id,title,game_id
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE DATE(start_time) >= '2018-12-15'
AND is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT DATE(created_at) as date,game_type_id,game_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.game_type_id = b.game_type_id AND a.game_id = b.game_id
GROUP BY 1,2,3,4,5) b
ON a.user_id = b.user_id
GROUP BY 1,2,3,4



######### New Users retention (who have played game & won on Day Zero-D0 split by game_type) - D1 & Week 4 retention
SELECT Date,game_type,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'Week 4',Users,NULL)) as Week_4
FROM (
SELECT a.date as Date,a.body_name as game_type,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date >= DATE_ADD(a.date,INTERVAL 22 DAY) AND b.date <= DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'Week 4'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel,a.body_name
FROM (
SELECT a.date,a.device_channel,a.body_name,b.user_id
FROM (
SELECT a.date,a.device_channel,b.body_name --COUNT(DISTINCT a.device_channel) as users_not_played
FROM (
SELECT date, device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT date, body_name, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
--WHERE ua_notification_token = '3d9b1443-8274-40c1-a48c-b9186423d65c'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3,4) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 1
GROUP BY 1,2) b
ON a.user_id = b.user_id AND a.date = b.date
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3)
WHERE Retention != 'NA'
GROUP BY 1,2



######### New Users retention (who have played game & won on Day Zero-D0 split by game_type) - D1 & Week 4 retention
SELECT Date,game_type,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'Week 4',Users,NULL)) as Week_4
FROM (
SELECT a.date as Date,a.body_name as game_type,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date >= DATE_ADD(a.date,INTERVAL 22 DAY) AND b.date <= DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'Week 4'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel,a.body_name
FROM (
SELECT a.date,a.device_channel,a.body_name,b.user_id
FROM (
SELECT a.date,a.device_channel,b.body_name --COUNT(DISTINCT a.device_channel) as users_not_played
FROM (
SELECT date, device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT date, body_name, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
--WHERE ua_notification_token = '3d9b1443-8274-40c1-a48c-b9186423d65c'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3,4) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 1
GROUP BY 1,2) b
ON a.user_id = b.user_id AND a.date = b.date
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3)
WHERE Retention != 'NA'
GROUP BY 1,2



######### New Users retention (who have played game on Day Zero-D0) - D1 & Week 4 retention
SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'Week 4',Users,NULL)) as Week_4
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date >= DATE_ADD(a.date,INTERVAL 22 DAY) AND b.date <= DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'Week 4'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel
FROM (
SELECT date, device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
JOIN (
SELECT date, body_name, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1



######### AARRR version_1
SELECT COUNT(DISTINCT a.device_channel) as NewUsers,
COUNT(DISTINCT e.device_channel) as ActivatedUsers,
COUNT(DISTINCT b.device_channel) as RegisteredUsers,
COUNT(DISTINCT CASE WHEN c.noofdays <=2 THEN c.device_channel END) as GamePlayers_for_max_2_days,
COUNT(DISTINCT CASE WHEN c.noofdays >=3 AND c.noofdays <=5 THEN c.device_channel END) as GamePlayers_for_3_to_5_days,
COUNT(DISTINCT CASE WHEN c.noofdays >5 THEN c.device_channel END) as GamePlayers_for_more_than_5_days,
COUNT(DISTINCT CASE WHEN d.noofreferrals = 1 THEN d.device_channel END) as Referred_for_1_time,
COUNT(DISTINCT CASE WHEN d.noofreferrals > 1 THEN d.device_channel END) as Referred_for_more_than_1_time,
COUNT(DISTINCT CASE WHEN d.noofreferrals > 5 THEN d.device_channel END) as Referred_for_more_than_5_times
FROM (
SELECT device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-12-03' AND date <= '2018-12-09'
GROUP BY 1) a
LEFT OUTER JOIN (
SELECT device_channel
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as opens
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-12-03' AND DATE(occurred) <= '2018-12-09'
AND type = 'OPEN'
GROUP BY 1,2)
WHERE opens >= 2
GROUP BY 1) e
ON a.device_channel = e.device_channel
LEFT OUTER JOIN (
SELECT device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-12-03' AND date <= '2018-12-09'
AND type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1) b
ON a.device_channel = b.device_channel
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT date) as noofdays,SUM(games) as games
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as games
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-12-03' AND DATE(occurred) <= '2018-12-09'
AND type = 'CUSTOM' AND body_name LIKE '%started_playing%'
GROUP BY 1,2)
GROUP BY 1) c
ON a.device_channel = c.device_channel 
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT occurred) as noofreferrals
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-12-03' AND DATE(occurred) <= '2018-12-09'
AND type = 'CUSTOM' AND body_name LIKE '%_referred%'
GROUP BY 1) d
ON a.device_channel = d.device_channel




SELECT DATE(created) as date,COUNT(DISTINCT user_id) as users,COUNT(DISTINCT device_id) as distinct_device_ids,COUNT(DISTINCT ua_notification_token) as distinct_device_channels
FROM `swoo-analytics-bq.backend_tables.user_device` 
WHERE DATE(created) >= '2018-12-15' 
GROUP BY 1



SELECT *
FROM `swoo-analytics-bq.backend_tables.user_device` 
WHERE user_id = 7820788



SELECT a.date,DATE_DIFF(b.date,a.date, DAY) as days_diff,COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-12-10' 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-12-10' 
AND type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2



SELECT a.date,COUNT(DISTINCT a.device_channel) as new_installs,COUNT(DISTINCT b.device_channel) as reg_users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-11-15' 
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-11-15'  
AND type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1
ORDER BY 1



SELECT COUNT(DISTINCT a.device_channel) new_channels,
COUNT(DISTINCT b.device_named_user_id) as named_users,
COUNT(DISTINCT c.user_id) as users,
COUNT(DISTINCT d.device_channel) as reg_channels,
COUNT(DISTINCT d.user_id) as reg_users,
COUNT(DISTINCT d.device_named_user_id) as named_reg_users
FROM (
SELECT device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
AND type = 'FIRST_OPEN'
GROUP BY 1) a
LEFT JOIN (
SELECT device_channel,device_named_user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
LEFT JOIN (
SELECT device_channel,user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
GROUP BY 1,2) c
ON a.device_channel = c.device_channel
LEFT JOIN (
SELECT device_channel,user_id,device_named_user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
AND body_name = 'signup_done'
GROUP BY 1,2,3) d
ON a.device_channel = d.device_channel



SELECT DATE(created) as date,COUNT(DISTINCT user_id) as users,COUNT(DISTINCT device_id) as distinct_device_ids,COUNT(DISTINCT ua_notification_token) as distinct_device_channels
FROM `swoo-analytics-bq.backend_tables.user_device` 
WHERE DATE(created) >= '2018-12-15' 
GROUP BY 1



SELECT *
FROM `swoo-analytics-bq.backend_tables.user_device` 
WHERE user_id = 7820788



SELECT a.date,DATE_DIFF(b.date,a.date, DAY) as days_diff,COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-12-10' 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-12-10' 
AND type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2



SELECT a.date,COUNT(DISTINCT a.device_channel) as new_installs,COUNT(DISTINCT b.device_channel) as reg_users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-11-15' 
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-11-15'  
AND type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1
ORDER BY 1



SELECT COUNT(DISTINCT a.device_channel) new_channels,
COUNT(DISTINCT b.device_named_user_id) as named_users,
COUNT(DISTINCT c.user_id) as users,
COUNT(DISTINCT d.device_channel) as reg_channels,
COUNT(DISTINCT d.user_id) as reg_users,
COUNT(DISTINCT d.device_named_user_id) as named_reg_users
FROM (
SELECT device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
AND type = 'FIRST_OPEN'
GROUP BY 1) a
LEFT JOIN (
SELECT device_channel,device_named_user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
LEFT JOIN (
SELECT device_channel,user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
GROUP BY 1,2) c
ON a.device_channel = c.device_channel
LEFT JOIN (
SELECT device_channel,user_id,device_named_user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2018-12-30'
AND body_name = 'signup_done'
GROUP BY 1,2,3) d
ON a.device_channel = d.device_channel



SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'Week 4',Users,NULL)) as Week_4
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date >= DATE_ADD(a.date,INTERVAL 22 DAY) AND b.date <= DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'Week 4'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,c.device_channel
FROM (
SELECT DATE(created) as date,id as user_id
FROM `swoo-analytics-bq.backend_tables.user` 
GROUP BY 1,2) a
JOIN (
SELECT DATE(created_at) as date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_won = 1
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id 
LEFT JOIN (
SELECT DATE(created) as date,user_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3) c
ON a.user_id = c.user_id
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1




SELECT date, SUM(users) as users
FROM (
SELECT date(g.start_time) as date, g.game_id as game_id, count (distinct ugs.user_id) as users 
FROM `swoo-analytics-bq.swoo_gaming_service.game` g 
JOIN `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` ugs 
On ugs.game_id = g.game_id 
where date(g.start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 40 DAY) 
AND date(g.start_time) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
AND ugs.games_played = 1 group by 1,2) group by 1 order by 1



SELECT date,SUM(games_played) as total_games_played
FROM (
--SELECT DATE(created_at) as date, game_id, COUNT(DISTINCT user_id) as users
SELECT DATE(created_at) as date, user_id, COUNT(DISTINCT game_id) as games_played 
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
GROUP BY 1,2)
GROUP BY 1


######### Query for Ringer Test

## Poweruser Curve Query

SELECT month,days,COUNT(DISTINCT device_channel) as users
FROM (
SELECT EXTRACT(MONTH FROM date) as month,device_channel,COUNT(DISTINCT date) as days
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2)
GROUP BY 1,2)
GROUP BY 1,2

## Gamplayers MAU

SELECT EXTRACT(MONTH FROM date) as month,COUNT(DISTINCT device_channel) as game_players_mau
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1



######### Query for Ringer Test
-- Step 1
SELECT DATE(occurred) as date,body_name,device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2019-01-08'
AND type IN ('CUSTOM')
AND body_name LIKE '%_started_playing%' --IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3

-- Step 2
SELECT a.device_channel
FROM (
SELECT min_date,device_channel 
FROM (
SELECT device_channel,MIN(date) as min_date
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'OPEN'
GROUP BY 1) a
WHERE min_date = '2019-01-08'
GROUP BY 1,2) a
LEFT JOIN (
SELECT date, device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
GROUP BY 1,2) b
ON a.min_date = b.date AND a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1



SELECT DATE(occurred) as date,body_name,device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) = '2019-01-10'
AND type IN ('CUSTOM')
AND body_name LIKE '%_started_playing%' --IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3




SELECT COUNT(a.device_channel) as users
FROM (
SELECT device_channel 
FROM `swoo-analytics-bq.derived_data.ringers_test_set3`
GROUP BY 1) a
JOIN (
SELECT device_channel,type
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE date = '2019-01-10'
AND type = 'OPEN'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel


SELECT COUNT(a.device_channel) as users
FROM (
SELECT device_channel 
FROM `swoo-analytics-bq.derived_data.ringers_test_set3`
GROUP BY 1) a
JOIN (
SELECT device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`  
WHERE date = '2019-01-10'
GROUP BY 1) b
ON a.device_channel = b.device_channel



-- Testing of ringers performance
SELECT COUNT(a.device_channel) as users
FROM (
SELECT device_channel 
FROM `swoo-analytics-bq.derived_data.ringers_test_set1`
GROUP BY 1) a
JOIN (
SELECT device_channel,type
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE date = '2019-01-07'
AND type = 'OPEN'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel


SELECT COUNT(a.device_channel) as users
FROM (
SELECT device_channel 
FROM `swoo-analytics-bq.derived_data.ringers_test_set1`
GROUP BY 1) a
JOIN (
SELECT device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`  
WHERE date = '2019-01-08'
GROUP BY 1) b
ON a.device_channel = b.device_channel


######## AARRR version_2

SELECT COUNT(DISTINCT a.device_channel) as NewUsers,
COUNT(DISTINCT e.device_channel) as ActivatedUsers,
COUNT(DISTINCT b.device_channel) as RegisteredUsers,
COUNT(DISTINCT CASE WHEN c.noofdays <=2 THEN c.device_channel END) as GamePlayers_for_max_2_days,
COUNT(DISTINCT CASE WHEN c.noofdays >=3 AND c.noofdays <=5 THEN c.device_channel END) as GamePlayers_for_3_to_5_days,
COUNT(DISTINCT CASE WHEN c.noofdays >5 THEN c.device_channel END) as GamePlayers_for_more_than_5_days,
COUNT(DISTINCT CASE WHEN d.noofreferrals = 1 THEN d.device_channel END) as Referred_for_1_time,
COUNT(DISTINCT CASE WHEN d.noofreferrals > 1 THEN d.device_channel END) as Referred_for_more_than_1_time,
COUNT(DISTINCT CASE WHEN d.noofreferrals > 5 THEN d.device_channel END) as Referred_for_more_than_5_times
FROM (
SELECT device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type = 'FIRST_OPEN'
AND date >= '2018-12-03' AND date <= '2018-12-09'
GROUP BY 1) a
LEFT OUTER JOIN (
SELECT device_channel
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as opens
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-12-03' AND DATE(occurred) <= '2018-12-09'
AND type = 'OPEN'
GROUP BY 1,2)
WHERE opens >= 2
GROUP BY 1) e
ON a.device_channel = e.device_channel
LEFT OUTER JOIN (
SELECT device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2018-12-03' AND date <= '2018-12-09'
AND type = 'CUSTOM' AND body_name = 'signup_done'
GROUP BY 1) b
ON a.device_channel = b.device_channel
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT date) as noofdays,SUM(games) as games
FROM (
SELECT DATE(occurred) as date,device_channel,COUNT(DISTINCT EXTRACT(HOUR FROM occurred)) as games
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-12-03' AND DATE(occurred) <= '2018-12-09'
AND type = 'CUSTOM' AND body_name LIKE '%started_playing%'
GROUP BY 1,2)
GROUP BY 1) c
ON a.device_channel = c.device_channel 
LEFT OUTER JOIN (
SELECT device_channel,COUNT(DISTINCT occurred) as noofreferrals
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2`
WHERE DATE(occurred) >= '2018-12-03' AND DATE(occurred) <= '2018-12-09'
AND type = 'CUSTOM' AND body_name LIKE '%_referred%'
GROUP BY 1) d
ON a.device_channel = d.device_channel



######## Dormant_user_queries

-- version_1

SELECT DATE_DIFF(b.max_open_date,a.date, DAY) as Days_from_install,COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT OUTER JOIN (
SELECT device_channel,MAX(date) as max_open_date
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
GROUP BY 1) b
ON a.device_channel = b.device_channel
WHERE b.max_open_date > a.date
GROUP BY 1



-- version_2

SELECT a.date as date,COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT b.date as date,a.device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-12-01' AND date <= '2018-12-31'
GROUP BY 1) b
WHERE a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) a
LEFT JOIN (
SELECT b.date as date,a.device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-12-01' AND date <= '2018-12-31'
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1
ORDER BY 1

-- version_3

SELECT b.date,
--DATE_DIFF(b.date,a.date,DAY) as diff,COUNT(DISTINCT device_channel) as dormant_users
COUNT(DISTINCT CASE WHEN DATE_DIFF(b.date,a.date,DAY) = 14 THEN device_channel END) as dormant_users
FROM (
SELECT * 
FROM (
SELECT device_channel,date,LAG(date,1) OVER (PARTITION BY device_channel ORDER BY date) AS prev_open_date,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY date DESC) AS rank
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN' 
--AND device_channel = '00000591-0325-4c37-bd32-7809eb2c3209'
GROUP BY 1,2)
WHERE rank = 1
AND prev_open_date IS NOT NULL
) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE b.date >= a.date
GROUP BY 1

-- version_4

SELECT DATE_DIFF(date,prev_open_date,DAY) as days_between_open,COUNT(DISTINCT device_channel) as users
FROM (
SELECT device_channel,date,LAG(date,1) OVER (PARTITION BY device_channel ORDER BY date) AS prev_open_date,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY date DESC) AS rank
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN' --AND device_channel = '00000591-0325-4c37-bd32-7809eb2c3209'
GROUP BY 1,2)
WHERE prev_open_date IS NOT NULL
GROUP BY 1


SELECT device_channel
FROM (
SELECT device_channel,date as lastest_open_date,LAG(date,1) OVER (PARTITION BY device_channel ORDER BY date) AS prev_open_date,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY date DESC) AS rank
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN' 
--AND device_channel = '00000591-0325-4c37-bd32-7809eb2c3209'
GROUP BY 1,2)
WHERE prev_open_date IS NOT NULL
AND DATE_DIFF(lastest_open_date,prev_open_date,DAY) > 12
AND date < DATE_SUB(CURRENT_DATE(), INTERVAL 12 DAY)
GROUP BY 1

-- final_queries_used

SELECT DATE_DIFF(b.max_open_date,a.acq_date, DAY) as days_diff,b.days_active,COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date as acq_date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(date) as max_open_date,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
GROUP BY 1) b
ON a.device_channel = b.device_channel
WHERE b.max_open_date >= a.acq_date
--AND DATE_DIFF(b.max_open_date,a.acq_date, DAY) <= 14
--AND a.acq_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
GROUP BY 1,2


SELECT DATE_DIFF(b.max_open_date,a.acq_date, DAY) as days_diff,--b.days_active,
COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date as acq_date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(date) as max_open_date,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
GROUP BY 1) b
ON a.device_channel = b.device_channel
WHERE b.max_open_date >= a.acq_date
--AND DATE_DIFF(b.max_open_date,a.acq_date, DAY) <= 14
--AND a.acq_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
GROUP BY 1--,2


SELECT a.user_id,SUM(b.games_played) as total_games_played
FROM (
SELECT b.user_id,a.days_diff,a.days_active
FROM (
SELECT a.device_channel,DATE_DIFF(b.max_open_date,a.acq_date, DAY) as days_diff,b.days_active
FROM (
SELECT date as acq_date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(date) as max_open_date,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
GROUP BY 1) b
ON a.device_channel = b.device_channel
WHERE b.max_open_date >= a.acq_date
AND DATE_DIFF(b.max_open_date,a.acq_date, DAY) <= 14
AND a.acq_date < DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
AND days_active >= 2
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT DATE(created_at) as date,user_id,COUNT(DISTINCT game_id) as games_played
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_played = 1
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1






######## Game_players winning amount queries


SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
--APPROX_QUANTILES([DISTINCT] expression, number [{IGNORE|RESPECT} NULLS]) 
--percentiles[offset(25)], percentiles[offset(50)], percentiles[offset(75)]
--FROM (SELECT APPROX_QUANTILES(column, 100) percentiles FROM Table)
--DENSE_RANK() OVER(PARTITION BY month ORDER BY total_won_amount DESC) AS rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
--CAST(SUM(winning_amount) as FLOAT64) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3


# deciles query (version 1)

SELECT month,CASE WHEN 0 <= percentile_rank AND percentile_rank < 0.1 THEN '0-10'
WHEN 0.1 <= percentile_rank AND percentile_rank < 0.2 THEN '10-20'
WHEN 0.2 <= percentile_rank AND percentile_rank < 0.3 THEN '20-30'
WHEN 0.3 <= percentile_rank AND percentile_rank < 0.4 THEN '30-40'
WHEN 0.4 <= percentile_rank AND percentile_rank < 0.5 THEN '40-50'
WHEN 0.5 <= percentile_rank AND percentile_rank < 0.6 THEN '50-60'
WHEN 0.6 <= percentile_rank AND percentile_rank < 0.7 THEN '60-70'
WHEN 0.7 <= percentile_rank AND percentile_rank < 0.8 THEN '70-80'
WHEN 0.8 <= percentile_rank AND percentile_rank < 0.9 THEN '80-90'
WHEN 0.9 <= percentile_rank AND percentile_rank <= 1.0 THEN '90-100' ELSE 'NA' END AS decile,
COUNT(DISTINCT user_id) as noofusers,AVG(total_won_amount) as average_total_amount_won
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
--AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3)
GROUP BY 1,2



SELECT month,CEIL(percentile_rank*100) as percentile,COUNT(DISTINCT user_id) as noofusers,AVG(total_won_amount) as average_total_amount_won,SUM(total_won_amount) as total_amt
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
--AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3)
GROUP BY 1,2

# 100 buckets query (version 2, including the cummulative amount)

SELECT month,(CASE WHEN 0.99 <= percentile_rank AND percentile_rank <= 1.00 THEN 'Top 1%' END) as percentile,COUNT(DISTINCT user_id) as noofusers,AVG(total_won_amount) as average_total_amount_won,SUM(total_won_amount) as total_amt
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
--AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3)
GROUP BY 1,2


SELECT month,(CASE WHEN 0.99 <= percentile_rank AND percentile_rank <= 1.00 THEN 'Top 1%' END) as percentile,COUNT(DISTINCT user_id) as noofusers,AVG(total_won_amount) as average_total_amount_won,SUM(total_won_amount) as total_amt
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
--AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3)
GROUP BY 1,2


SELECT * 
FROM (
SELECT month,(CASE WHEN 0.999 <= percentile_rank AND percentile_rank <= 1.00 THEN 'Top 0.1%' END) as percentile,COUNT(DISTINCT user_id) as noofusers,AVG(total_won_amount) as average_total_amount_won,SUM(total_won_amount) as total_amt
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
--AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3)
GROUP BY 1,2)
WHERE percentile IS NOT NULL


# Top User

SELECT * 
FROM (
SELECT month,(CASE WHEN percentile_rank = 1.00 THEN 'Top User' END) as percentile,user_id,
--COUNT(DISTINCT user_id) as noofusers,
AVG(total_won_amount) as average_total_amount_won,SUM(total_won_amount) as total_amt
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY month ORDER BY total_won_amount) AS percentile_rank
FROM (
SELECT user_id,EXTRACT(MONTH FROM date) as month,SUM(winning_amount) as total_won_amount
FROM (
SELECT user_id,DATE(created_at) as date,game_type_id as game_type,game_id,balance as winning_amount
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1
--AND user_id IN (7820788,11371758,233597)
GROUP BY 1,2,3,4,5)
GROUP BY 1,2)
GROUP BY 1,2,3)
GROUP BY 1,2,3)
WHERE percentile IS NOT NULL



######### No of games on the day

SELECT DATE(start_time) as date,game_type_id,title,game_id
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE DATE(start_time) = '2019-01-16'
AND is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
--AND game_type_id = 'CandyRush'
--AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '06:30:00'
GROUP BY 1,2,3,4






SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device`
WHERE user_id = 9537522 -- 641148a5-784b-4617-ab71-3bab3ca192d0
GROUP BY 1,2


SELECT *
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE device_channel = '641148a5-784b-4617-ab71-3bab3ca192d0'
--AND type = 'OPEN'



SELECT days_diff,COUNT(DISTINCT user_id) as users
FROM (
SELECT b.user_id,a.days_diff,a.days_active
FROM (
SELECT a.device_channel,DATE_DIFF(b.max_open_date,a.acq_date, DAY) as days_diff,b.days_active
FROM (
SELECT date as acq_date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(date) as max_open_date,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
GROUP BY 1) b
ON a.device_channel = b.device_channel
WHERE b.max_open_date >= a.acq_date
AND DATE_DIFF(b.max_open_date,a.acq_date, DAY) <= 14
AND a.acq_date < DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
-- AND days_active >= 2
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
WHERE (a.days_diff+1) < a.days_active
GROUP BY 1,2,3)
--WHERE (days_diff+1) >= days_active
GROUP BY 1



SELECT DATE_DIFF(b.max_open_date,a.acq_date, DAY) as days_diff,--b.days_active,
COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT date as acq_date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date >= '2018-05-01'
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(date) as max_open_date,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
GROUP BY 1) b
ON a.device_channel = b.device_channel
WHERE b.max_open_date >= a.acq_date
--AND DATE_DIFF(b.max_open_date,a.acq_date, DAY) <= 14
--AND a.acq_date <= DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY)
GROUP BY 1--,2




######## Data for CK Rubber Banding (Logistic Regression Model)

#v1

SELECT a.user_id,a.game_id,a.points,a.win_type,CASE WHEN b.user_id IS NULL THEN 'NotRetained' ELSE 'Retained' END AS rentention_type
FROM (
SELECT a.user_id,a.game_id,a.points,CASE WHEN b.win_type IS NULL THEN 'Lose' ELSE b.win_type END AS win_type
FROM (
SELECT b.user_id,a.game_id,a.points
FROM (
SELECT a.device_channel,b.game_id,a.points 
FROM (
SELECT device_channel,game_id,points
--EXTRACT(HOUR FROM occurred) as hour,
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-09-20'
--DATETIME_ADD(DATETIME(occurred),INTERVAL 330 MINUTE) >= '2019-01-06 00:00:00'
--AND DATETIME_ADD(DATETIME(occurred),INTERVAL 330 MINUTE) <= '2019-01-06 23:59:59'
AND body_name = 'candyrushgame_statsboardshown'
AND level_no = '5' 
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(start_time) as date,game_type_id,title,game_id
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE DATE(start_time) = '2019-01-06'
AND is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
AND game_type_id = 'CandyRush'
--AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '06:30:00'
GROUP BY 1,2,3,4) b
ON a.game_id = b.game_id
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
WHERE b.user_id IS NOT NULL
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT user_id,game_id,CASE WHEN games_won = 1 THEN 'Won' ELSE 'Lose' END AS win_type
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE game_type_id = 'CandyRush'
AND DATE(created_at) = '2019-01-06' 
--AND games_won = 1
GROUP BY 1,2,3) b
ON a.user_id = b.user_id AND a.game_id = b.game_id
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT a.date,b.user_id
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
AND date = '2019-01-07'
GROUP BY 1,2) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
WHERE b.user_id IS NOT NULL
GROUP BY 1,2) b
ON a.user_id = b.user_id 
GROUP BY 1,2,3,4,5


#v2

SELECT user_id,games_won,games_played,(games_won/games_played) as win_ratio,DATE_DIFF(CURRENT_DATE(),min_date,DAY) as ck_age,DATE_DIFF(CURRENT_DATE(),max_date,DAY) as ck_days_since_played
FROM (
SELECT user_id,COUNT(DISTINCT CASE WHEN games_won = 1 THEN game_id END) as games_won,COUNT(DISTINCT game_id) as games_played,MIN(DATE(created_at)) as min_date,MAX(DATE(created_at)) as max_date
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE game_type_id = 'CandyRush'
GROUP BY 1)
GROUP BY 1,2,3,4,5,6 ORDER BY 5 DESC

#v3

SELECT device_channel,game_id,DATE(TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)) as date,EXTRACT(HOUR FROM TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)) as hour,points
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-09-17' AND DATE(occurred) < CURRENT_DATE()
AND body_name = 'candyrushgame_statsboardshown'
AND level_no = '5' 
GROUP BY 1,2,3,4,5

#### Iteration-2

#q1

SELECT a.user_id,a.games_won,a.games_played,a.win_ratio,a.ck_age_type,a.ck_days_since_played_type,a.ck_first_play_date,a.ck_last_play_date,CASE WHEN b.user_id IS NULL THEN 0 ELSE 1 END AS retention_type
FROM (
SELECT user_id,games_won,games_played,(games_won/games_played) as win_ratio,
CASE WHEN DATE_DIFF(CURRENT_DATE(),min_date,DAY) >= 0 AND DATE_DIFF(CURRENT_DATE(),min_date,DAY) < 7 THEN 1
WHEN DATE_DIFF(CURRENT_DATE(),min_date,DAY) >= 7 AND DATE_DIFF(CURRENT_DATE(),min_date,DAY) < 30 THEN 2
ELSE 3 END AS ck_age_type,
CASE WHEN DATE_DIFF(CURRENT_DATE(),max_date,DAY) >= 0 AND DATE_DIFF(CURRENT_DATE(),max_date,DAY) < 7 THEN 1
WHEN DATE_DIFF(CURRENT_DATE(),max_date,DAY) >= 7 AND DATE_DIFF(CURRENT_DATE(),max_date,DAY) < 30 THEN 2
ELSE 3 END AS ck_days_since_played_type,min_date as ck_first_play_date,max_date as ck_last_play_date
FROM (
SELECT user_id,COUNT(DISTINCT CASE WHEN games_won = 1 THEN game_id END) as games_won,COUNT(DISTINCT game_id) as games_played,MIN(DATE(created_at)) as min_date,MAX(DATE(created_at)) as max_date
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE game_type_id = 'CandyRush'
GROUP BY 1)
GROUP BY 1,2,3,4,5,6,7,8) a
LEFT JOIN (
SELECT a.user_id
FROM (
SELECT a.date,b.user_id
FROM (
SELECT device_channel,MIN(date) as date
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
WHERE body_name = 'candyrush_started_playing'
GROUP BY 1) a
JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2) a
JOIN (
SELECT a.date,b.user_id
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE date >= '2018-09-17'
AND type = 'OPEN'
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2) b
ON a.user_id = b.user_id AND b.date = DATE_ADD(a.date,INTERVAL 1 DAY)
GROUP BY 1) b
ON a.user_id = b.user_id 
GROUP BY 1,2,3,4,5,6,7,8,9

#q2

SELECT device_channel,game_id,DATE(occurred) as date,EXTRACT(HOUR FROM occurred) as hour,
--DATE(TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)) as date,
--EXTRACT(HOUR FROM TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)) as hour,
points
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-09-17' AND DATE(occurred) < CURRENT_DATE()
AND body_name = 'candyrushgame_statsboardshown'
AND level_no = '5' 
GROUP BY 1,2,3,4,5



######## Bingo preferential card analysis

### bingo_preferential_card_analysis_v1

SELECT a.date,COUNT(DISTINCT a.device_channel) as device_channels,COUNT(DISTINCT a.user_id) as new_users,COUNT(DISTINCT b.user_id) as new_users_wgpc,SUM(b.win_type) as wgpc_winners
FROM (
SELECT a.date,a.device_channel,b.user_id
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE date >= '2019-01-10' 
AND type = 'FIRST_OPEN'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(created) as date,ua_notification_token as device_channel,user_id 
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT a.date,a.game_id,a.user_id,CASE WHEN b.user_id IS NULL THEN 0 ELSE 1 END AS win_type
FROM (
SELECT a.date,a.game_id,a.user_id 
FROM (
SELECT DATE(created_at) as date,game_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE  tag_id IS NOT NULL --('1','2','3','4','5') --claim_type_id IN ('0','1','2','3','4','5') AND
AND DATE(created_at) >= '2019-01-14'
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(created_at) >= '2019-01-14'
AND prize_money >= 5000.0
GROUP BY 1,2,3) b
ON a.date = b.date AND a.game_id = b.game_id
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT DATE(created_at) as date,game_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1 AND is_deleted = 0
AND game_type_id = 'Bingo'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.game_id = b.game_id AND a.user_id = b.user_id
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.user_id = b.user_id
GROUP BY 1

### bingo_preferential_card_analysis_v2 (best_version and slightly different from v1)

SELECT a.date,a.game_id,a.title,b.tag_id,b.claim_type_id,b.users,b.winners--b.user_id
FROM (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(created_at) >= '2019-01-14'
AND prize_money >= 5000.0
GROUP BY 1,2,3) a
JOIN (
SELECT a.game_id,a.tag_id,a.claim_type_id,COUNT(DISTINCT a.user_id) as users,COUNT(DISTINCT CASE WHEN b.games_won = 1 THEN a.user_id END) as winners
FROM (
SELECT game_id,tag_id,claim_type_id,user_id--COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE  tag_id IS NOT NULL --AND claim_type_id IN ('0','1','2','3','4','5')
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
GROUP BY 1,2,3,4,5,6,7

### bingo_preferential_card_analysis_v3

SELECT a.date,a.game_id,b.title,a.tag_id,a.claim_type_id,COUNT(DISTINCT a.user_id) as users,COUNT(DISTINCT c.user_id) as winners
FROM (
SELECT DATE(created_at) as date,game_id,tag_id,claim_type_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE  tag_id IS NOT NULL --claim_type_id IN ('0','1','2','3','4','5')
AND DATE(created_at) >= '2019-01-14'
GROUP BY 1,2,3,4,5) a
JOIN (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(created_at) >= '2019-01-14'
AND prize_money >= 5000.0
GROUP BY 1,2,3) b
ON a.game_id = b.game_id --a.date = b.date
LEFT JOIN (
SELECT DATE(created_at) as date,game_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` 
WHERE games_won = 1 AND is_deleted = 0
AND game_type_id = 'Bingo'
GROUP BY 1,2,3) c
ON a.game_id = c.game_id AND a.user_id = c.user_id --a.date = c.date AND
GROUP BY 1,2,3,4,5

### bingo_preferential_card_analysis_v4

SELECT a.date,a.game_id,a.title,b.tag_id,b.claim_type_id,COUNT(DISTINCT b.user_id) as users--b.user_id
FROM (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(created_at) >= '2019-01-14'
AND prize_money >= 5000.0
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT game_id,tag_id,claim_type_id,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE  tag_id IS NOT NULL --claim_type_id IN ('0','1','2','3','4','5')
AND DATE(created_at) >= '2019-01-14'
GROUP BY 1,2,3,4) b
ON a.game_id = b.game_id
GROUP BY 1,2,3,4,5


### bingo_preferential_card_analysis_other_queries

##
SELECT reg_date,pc_game_date,claim_type_id,COUNT(DISTINCT user_id) as users
FROm (
SELECT a.date as pc_game_date,a.claim_type_id,a.user_id,b.date as reg_date--,COUNT(DISTINCT a.user_id) as users
FROM (
SELECT DATE(created_at) as date,claim_type_id,user_id --COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE tag_id IS NOT NULL
AND DATE(created_at) = '2019-01-15'
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(created) as date,user_id 
FROM `swoo-analytics-bq.backend_tables.user_device` 
-- WHERE DATE(created) = '2019-01-14' 
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2,3,4)
GROUP BY 1,2,3

##
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
SELECT a.date,a.device_channel,b.user_id
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1` 
WHERE date >= '2019-01-10' 
AND type = 'OPEN'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(created) as date,ua_notification_token as device_channel,user_id 
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5





SELECT REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as dc,body
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-01-17'
AND (LOWER(device) LIKE '%js_version%' OR LOWER(body) LIKE '%js_version%')
AND REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") IN ('be5092ce-80dc-4dd3-97b0-e00d249850c4','659aae29-3dc3-46eb-bfe5-edbf9a176172','1ce3d9a5-94f4-49a7-9b8c-80f197e0af0d ')
--as dc,REPLACE(JSON_EXTRACT(device, "$.properties.js_version"), "\"", "") as js_version
GROUP BY 1,2
ORDER BY 1





SELECT DATETIME_ADD(DATETIME(occurred),INTERVAL 330 MINUTE) as corrected_occurred,occurred,TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)
--EXTRACT(HOUR FROM occurred) as hour,
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2019-01-17'
AND body_name = 'candyrushgame_statsboardshown'
AND level_no = '5' 
GROUP BY 1,2,3
LIMIT 1000




SELECT device_channel,game_id,DATE(TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)) as date,EXTRACT(HOUR FROM TIMESTAMP_ADD(occurred, INTERVAL 330 MINUTE)) as hour,points
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2018-09-17' AND DATE(occurred) < CURRENT_DATE()
AND body_name = 'candyrushgame_statsboardshown'
AND level_no = '5' 
GROUP BY 1,2,3,4,5





SELECT date,win_type,(D1/D0) as D1,(D7/D0) as D7
FROM (
SELECT date,win_type,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7
FROM (
SELECT a.date as date,a.win_type,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
/* WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
WHEN b.date >= DATE_ADD(a.date,INTERVAL 22 DAY) AND b.date <= DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'Week 4' */
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.user_id) as Users 
FROM (
SELECT a.date,a.game_id,a.title,b.user_id,b.win_type,b.pc_type,b.pc_win_type
FROM (
SELECT DATE(start_time) as date,game_id,title
FROM `swoo-analytics-bq.swoo_gaming_service.game`
WHERE is_precomputation_enabled = 1 AND is_deleted = 0
AND DATE(created_at) >= '2019-01-14'
AND prize_money >= 5000.0
GROUP BY 1,2,3) a
JOIN (
SELECT a.game_id,a.user_id,CASE WHEN b.games_won = 1 THEN 1 ELSE 0 END AS win_type,CASE WHEN a.tag_id IS NOT NULL THEN 1 ELSE 0 END AS pc_type,CASE WHEN (a.tag_id IS NOT NULL AND b.games_won = 1) THEN 1 ELSE 0 END AS pc_win_type
FROM (
SELECT game_id,tag_id,claim_type_id,user_id--COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.grid` 
WHERE DATE(created_at) >= '2019-01-14'
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
GROUP BY 1,2,3,4,5,6,7) a
LEFT JOIN (
SELECT a.date,b.user_id
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device`
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2) b
ON a.user_id = b.user_id
GROUP BY 1,2,3)
WHERE Retention != 'NA'
GROUP BY 1,2)
GROUP BY 1,2,3,4



SELECT 
FROM `swoo-analytics-bq.swoo_gaming_service.lives_transaction_history`







SELECT a.user_id,a.points,b.winning_amount,b.life_consumption_type,b.win_type
FROM (
SELECT user_id,game_id,points
--COUNT(DISTINCT game_id) as games_played_on_1st_day,AVG(points) as avg_points--COUNT(DISTINCT date) as date,
FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY user_id ORDER BY date,hour) AS rank
FROM (
SELECT a.date,b.user_id,a.game_id,a.hour,CAST(a.points AS int64) as points
FROM (
SELECT date,device_channel,game_id,hour,points
FROM `swoo-analytics-bq.derived_data.Candy_krack_points_by_each_game`
GROUP BY 1,2,3,4,5) a
JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device`
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3,4,5)
GROUP BY 1,2,3,4,5)
WHERE rank = 1
GROUP BY 1,2,3) a
JOIN (
SELECT user_id,game_id,balance as winning_amount,CASE WHEN lives = -1 THEN 1 ELSE 0 END AS life_consumption_type,CASE WHEN games_won = 1 THEN 1 ELSE 0 END AS win_type
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE game_type_id = 'CandyRush'
GROUP BY 1,2,3,4,5) b
ON a.user_id = b.user_id AND a.game_id = b.game_id
GROUP BY 1,2,3,4,5




SELECT user_id,MIN(DATE(created_at)) as min_date
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE game_type_id = 'CandyRush'
GROUP BY 1,2





SELECT a.device_channel,b.user_id,a.retention_type
FROM (
SELECT a.device_channel,CASE WHEN (b.date = DATE_ADD(a.first_date,INTERVAL 1 DAY) AND b.device_channel IS NOT NULL) THEN 1 ELSE 0 END AS retention_type
FROM (
SELECT device_channel,MIN(date) as first_date
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
WHERE body_name = 'candyrush_started_playing'
GROUP BY 1) a
LEFT JOIN (
SELECT date,device_channel
FROM `analytics_data.ua_derived_data_v1` 
WHERE date >= '2018-09-17'
AND type = 'OPEN'
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
WHERE b.user_id IS NOT NULL
AND b.user_id IN (12843423,10650624,12686170)
GROUP BY 1,2,3



SELECT lives,COUNT(*) as cnt
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE game_type_id = 'CandyRush'
GROUP BY 1,2,3





SELECT a.date,b.user_id,c.handle,a.session_length
FROM (
SELECT *
FROM `swoo-analytics-bq.daily_dashboard.ua_user_sessions` 
--WHERE date = DATE("2019-02-10")   16704
--WHERE date = DATE("2019-02-09")   23273
WHERE date = DATE("2019-02-08")   
GROUP BY 1,2,3,4
ORDER BY 3 DESC LIMIT 17930) a
JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.user_id = b.device_channel
LEFT JOIN (
SELECT id as user_id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) c
ON b.user_id = c.user_id 
GROUP BY 1,2,3,4
ORDER BY 4 DESC


SELECT b.user_id,c.handle,a.days
FROM (
SELECT device_channel,days--,COUNT(DISTINCT device_channel) as users
FROM (
SELECT device_channel,COUNT(DISTINCT date) as days
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY) AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
AND type IN ('CUSTOM') AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen')))
GROUP BY 1,2)
GROUP BY 1)
WHERE days >= 30
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
LEFT JOIN (
SELECT id as user_id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) c
ON b.user_id = c.user_id 
GROUP BY 1,2,3





SELECT *
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw`
WHERE DATE(occurred) = '2019-02-12'
AND type = 'OPEN'


SELECT REPLACE(JSON_EXTRACT(device, "$[attributes].carrier"), "\"", "") as model,COUNT(DISTINCT REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-02-12'
AND type = 'OPEN'
GROUP BY 1
ORDER BY 2 DESC



SELECT da.days_active,COUNT(DISTINCT ru.device_channel) as distinct_users
FROM (
) ru
LEFT JOIN (
SELECT device_channel,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
AND date > '2019-02-09'
GROUP BY 1) da
ON ru.device_channel = da.device_channel
GROUP BY 1
ORDER BY 2 DESC



SELECT da.days_active,COUNT(DISTINCT ru.device_channel) as distinct_users
FROM (
SELECT a.Date,a.device_channel 
FROM (
SELECT wau.Date,wau.device_channel 
FROM (
SELECT b.date as Date,device_channel--COUNT(DISTINCT device_channel) as wau 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2) wau
LEFT JOIN (
SELECT a.date as Date,a.device_channel--COUNT(DISTINCT a.device_channel) as LastWeekUsers
FROM (
SELECT b.date as Date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
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
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2) lwu
ON wau.date = lwu.Date AND wau.device_channel = lwu.device_channel
LEFT JOIN (
SELECT b.date as Date,device_channel--COUNT(DISTINCT device_channel) as NewUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2) nu
ON wau.date = nu.Date AND wau.device_channel = nu.device_channel 
WHERE wau.device_channel IS NOT NULL AND lwu.device_channel IS NULL AND nu.device_channel IS NULL
AND wau.Date = '2019-02-09'
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
AND date = '2019-02-09' 
GROUP BY 1,2) b
ON a.Date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) ru
LEFT JOIN (
SELECT device_channel,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
AND date > '2019-02-09'
GROUP BY 1) da
ON ru.device_channel = da.device_channel
GROUP BY 1
ORDER BY 2 DESC



SELECT da.days_active,COUNT(DISTINCT ru.device_channel) as distinct_users
FROM (
SELECT a.Date,a.device_channel 
FROM (
SELECT lwu.Date,lwu.device_channel 
FROM (
SELECT a.date as Date,a.device_channel--COUNT(DISTINCT a.device_channel) as LastWeekUsers
FROM (
SELECT b.date as Date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
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
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2) lwu
WHERE lwu.Date = '2019-01-26'
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'OPEN'
AND date = '2019-01-26' 
GROUP BY 1,2) b
ON a.Date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) ru
LEFT JOIN (
SELECT device_channel,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
AND date > '2019-01-26'
GROUP BY 1) da
ON ru.device_channel = da.device_channel
GROUP BY 1
ORDER BY 2 DESC




-- Video Inflow

select date(occurred) as date,count(distinct device_channel) from `analytics_data.urban_airship_v2` 
where body_name = "swooperstar_recordingdone" 
and date(occurred) >= "2018-11-22" and date(occurred) <= "2018-11-25" group by 1


select date(occurred) as date,count(distinct device_channel) from `analytics_data.urban_airship_v2` 
where body_name = "swooperstar_recordingstarted" 
and date(occurred) >= "2018-11-26" and date(occurred) <= "2018-12-02" group by 1

select date(occurred) as date,count(distinct device_channel) from `analytics_data.urban_airship_v2` 
where body_name = "swooperstar_recordingdone" 
and date(occurred) >= "2019-01-25" and date(occurred) <= "2019-02-12" group by 1


select date,count(distinct device_channel) from `analytics_data.ua_derived_data_v1`
where body_name = "swooperstar_recordingstarted" 
and date >= "2019-01-25" and date <= "2019-02-12" group by 1


select date(created), count(distinct broadcast_id)
from contest_broadcast
group by 1
order by 1



SELECT week,x_games_played,COUNT(DISTINCT user_id) AS users
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, device_channel AS user_id,COUNT(DISTINCT date) AS x_games_played
FROM `analytics_data.ua_derived_data_v1`
WHERE date >='2019-01-01' AND date <= CURRENT_DATE()
--AND EXTRACT(WEEK FROM date) > 0 
AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen')))
GROUP BY 1,2)
GROUP BY 1,2



SELECT date as Date,COUNT(DISTINCT device_channel) as DistinctGamePlayers
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v1`
WHERE (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen'))) --body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1




SELECT date,body_name,times,COUNT(DISTINCT device_channel) as users 
FROM (
SELECT DATE(occurred) as date,device_channel,body_name,EXTRACT(HOUR FROM occurred) as times
FROM `analytics_data.urban_airship_v2` 
WHERE DATE(occurred) >= '2019-01-01' AND DATE(occurred) <= '2019-02-10'
AND type IN ('CUSTOM')
AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen')))
GROUP BY 1,2,3,4)
GROUP BY 1,2,3




SELECT a.date,a.game_type_id,a.title,a.prize_money,b.users,(b.users/a.prize_money) as users_prize_money_ratio
FROM (
SELECT DATE(start_time) as date,game_type_id,title,prize_money,game_id 
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
--AND DATE(start_time) = '2019-02-10'
--AND game_type_id = 'CandyRush'
--AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '06:30:00'
GROUP BY 1,2,3,4,5) a
LEFT JOIN (
SELECT game_id,COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_played = 1
GROUP BY 1) b
ON a.game_id = b.game_id 
GROUP BY 1,2,3,4,5,6



SELECT a.date,a.game_type_id,a.title,a.prize_money,b.users,(b.users/a.prize_money) as users_prize_money_ratio
FROM (
SELECT DATE(start_time) as date,game_type_id,title,prize_money,game_id 
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
--AND DATE(start_time) = '2019-02-10'
--AND game_type_id = 'CandyRush'
AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '17:00:00'
GROUP BY 1,2,3,4,5) a
LEFT JOIN (
SELECT game_id,COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_played = 1
GROUP BY 1) b
ON a.game_id = b.game_id 
GROUP BY 1,2,3,4,5,6




SELECT a.date,a.gametime,a.game_type_id,a.title,a.prize_money,b.users,(b.users/a.prize_money) as users_prize_money_ratio
FROM (
SELECT DATE(start_time) as date,TIME(TIMESTAMP_TRUNC(start_time, MINUTE),'Asia/Kolkata') as gametime,game_type_id,title,prize_money,game_id 
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
--AND DATE(start_time) = '2019-02-10'
--AND game_type_id = 'CandyRush'
--AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '17:00:00'
GROUP BY 1,2,3,4,5,6) a
LEFT JOIN (
SELECT game_id,COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics`
WHERE games_played = 1
GROUP BY 1) b
ON a.game_id = b.game_id 
GROUP BY 1,2,3,4,5,6,7




SELECT da.days_active,COUNT(DISTINCT ru.device_channel) as distinct_users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date = '2019-02-09' 
GROUP BY 1,2) ru
LEFT JOIN (
SELECT device_channel,COUNT(DISTINCT date) as days_active
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN')
AND date > '2019-02-09'
GROUP BY 1) da
ON ru.device_channel = da.device_channel
GROUP BY 1
ORDER BY 2 DESC



SELECT b.date as Date,device_channel--COUNT(DISTINCT device_channel) as NewUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2



SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") as ad_type,REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") as slot_type,REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") as is_clickable,COUNT(DISTINCT REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-01-26'
AND type = 'CUSTOM'
--AND LOWER(body) LIKE '%ad%'
GROUP BY 1,2,3,4


SELECT *
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-02-17'
AND type = 'CUSTOM'
AND LOWER(body) LIKE '%adslot%'
LIMIT 1000


SELECT *
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-02-18'
AND REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") = 'd3e9d79d-3015-4b1c-bb6b-35ff9ef51f19'
ORDER BY occurred 



SELECT *
FROM (
SELECT a.date,a.device_channel,COUNT(DISTINCT b.ad_type) as ad_types
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type = 'FIRST_OPEN'
AND date = '2019-02-17'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(device, "$.android_channel"), "\"", "") as device_channel,CASE WHEN REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Banner_top' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'false' THEN 'var1'
WHEN REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Banner_top' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' THEN 'var2'
WHEN REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Interstitial' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' AND REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") = 'feedpage_broadcast_started_pregame' THEN 'var3'
WHEN REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Interstitial' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' AND REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") = 'feedpage_game_ended_postgame' THEN 'var4'
WHEN REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Rewarded' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' AND REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") IN ('feedPage_video_ad','invitePage_video_ad') THEN 'var5'
WHEN (REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Banner_top' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true') AND (REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Interstitial' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' AND REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") = 'feedpage_broadcast_started_pregame') AND (REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Interstitial' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' AND REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") = 'feedpage_game_ended_postgame') AND (REPLACE(JSON_EXTRACT(body, "$[properties].ad_type"), "\"", "") = 'Rewarded' AND REPLACE(JSON_EXTRACT(body, "$[properties].is_clickable"), "\"", "") = 'true' AND REPLACE(JSON_EXTRACT(body, "$[properties].slot_type"), "\"", "") IN ('feedPage_video_ad','invitePage_video_ad')) THEN 'var6'
ELSE 'var0' END AS ad_type
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-02-17'
AND type = 'CUSTOM'
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE ad_types > 1



#### cummulative wallet balence of all users on daily_basis

## v6 (bestest_version)

WITH cumm_wallet_balence AS (
WITH day_wise_uwb AS (
WITH uwb AS (
WITH user_wallet_balence AS (
SELECT date,USER_ID,CURRENCY_CODE,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT DATE(createDateTime) as date,USER_ID,CURRENCY_CODE,SUM(CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_credited,SUM(CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5)
SELECT a.date,a.USER_ID,a.CURRENCY_CODE,ROUND(SUM(b.wallet_balence),2) as cum_wallet_balence
FROM user_wallet_balence a
JOIN user_wallet_balence b 
ON a.dummy = b.dummy 
WHERE b.date <= a.date AND a.USER_ID = b.USER_ID AND a.CURRENCY_CODE = b.CURRENCY_CODE  
AND a.date < CURRENT_DATE()
GROUP BY 1,2,3)
SELECT *,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY USER_ID ORDER BY date) AS next_date
FROM uwb)
SELECT b.date,a.USER_ID,c.handle,a.CURRENCY_CODE,a.cum_wallet_balence,DENSE_RANK() OVER(PARTITION BY CURRENCY_CODE ORDER BY cum_wallet_balence DESC) AS rank
--MAX(a.date) as last_txn_date
FROM day_wise_uwb a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer` 
WHERE  date >= '2018-05-01' AND date < CURRENT_DATE() GROUP BY 1) b
LEFT JOIN (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) c
ON a.USER_ID = c.user_id
WHERE b.date >= a.date AND b.date < a.next_date
--AND b.date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
--AND a.CURRENCY_CODE = 'USD' ORDER BY 5 DESC
GROUP BY 1,2,3,4,5)
SELECT date,CURRENCY_CODE,SUM(cum_wallet_balence) as cum_wallet_balence
FROM cumm_wallet_balence
WHERE date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
GROUP BY 1,2
ORDER BY 1

## v5 

WITH cumm_wallet_balence AS (
WITH day_wise_uwb AS (
WITH uwb AS (
WITH user_wallet_balence AS (
SELECT date,USER_ID,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT DATE(createDateTime) as date,USER_ID,SUM(CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_credited,SUM(CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
GROUP BY 1,2)
GROUP BY 1,2,3,4)
SELECT a.date,a.USER_ID,ROUND(SUM(b.wallet_balence),2) as cum_wallet_balence
FROM user_wallet_balence a
JOIN user_wallet_balence b 
ON a.dummy = b.dummy 
WHERE b.date <= a.date AND a.USER_ID = b.USER_ID
AND a.date < CURRENT_DATE()
GROUP BY 1,2)
SELECT *,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY USER_ID ORDER BY date) AS next_date
FROM uwb)
SELECT b.date,a.USER_ID,a.cum_wallet_balence
FROM day_wise_uwb a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer` 
WHERE  date >= '2018-05-01' AND date < CURRENT_DATE() GROUP BY 1) b
WHERE b.date >= a.date AND b.date < a.next_date
GROUP BY 1,2,3)
SELECT date,ROUN(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM cumm_wallet_balence
GROUP BY 1
ORDER BY 1

## v4 (best_version)

WITH wallet_balence AS (
SELECT date,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT a.date,SUM(a.money) as total_credited,SUM(CASE WHEN b.money IS NULL THEN 0 ELSE b.money END) as total_cash_out
FROM (
SELECT date,SUM(money) as money
FROM (
SELECT DATE(createDateTime) as date,USER_ID,SUM(TRANSACTION_AMOUNT) as money
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
AND TRANSACTION_TYPE = 'CREDIT'
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
--AND CURRENCY_CODE = 'INR'
AND CURRENCY_CODE = 'USD'
GROUP BY 1,2)
GROUP BY 1) a
LEFT JOIN (
SELECT date,SUM(money) as money
FROM (
SELECT DATE(createDateTime) as date,USER_ID,SUM(TRANSACTION_AMOUNT) as money
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
AND TRANSACTION_TYPE = 'DEBIT'
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
--AND CURRENCY_CODE = 'INR'
AND CURRENCY_CODE = 'USD'
GROUP BY 1,2)
GROUP BY 1) b
ON a.date = b.date
GROUP BY 1)
GROUP BY 1,2,3)
SELECT a.date,ROUND(SUM(b.wallet_balence)) as cum_wallet_balence
FROM wallet_balence a
JOIN wallet_balence b 
ON a.dummy = b.dummy
WHERE b.date <= a.date
AND a.date < CURRENT_DATE()
GROUP BY 1
ORDER BY 1

## v3 (very slightlymodified v2)

WITH wallet_balence AS (
SELECT date,(total_earned-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT date,SUM(total_earned) as total_earned,SUM(total_cash_out) as total_cash_out
FROM (
SELECT date,USER_ID,CASE WHEN total_earned IS NULL THEN 0 ELSE total_earned END AS total_earned,CASE WHEN total_cash_out IS NULL THEN 0 ELSE total_cash_out END AS total_cash_out
FROM (
SELECT DATE(createDateTime) as date,USER_ID,SUM(earned) as total_earned,SUM(cash_out) as total_cash_out
FROM (
SELECT createDateTime,USER_ID,CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT END as earned,CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT END as cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
GROUP BY 1,2,3,4)
GROUP BY 1,2)
--WHERE date = '2019-02-24'
--WHERE USER_ID = 7820788
GROUP BY 1,2,3,4)
GROUP BY 1)
GROUP BY 1,2,3)
SELECT a.date,ROUND(SUM(b.wallet_balence)) as cum_wallet_balence
FROM wallet_balence a
JOIN wallet_balence b 
ON a.dummy = b.dummy
WHERE b.date <= a.date
AND a.date < CURRENT_DATE()
GROUP BY 1
ORDER BY 1

## v2

WITH wallet_balence AS (
SELECT date,(total_earned-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT date,SUM(total_earned) as total_earned,SUM(total_cash_out) as total_cash_out
FROM (
SELECT date,USER_ID,CASE WHEN total_earned IS NULL THEN 0 ELSE total_earned END AS total_earned,CASE WHEN total_cash_out IS NULL THEN 0 ELSE total_cash_out END AS total_cash_out
FROM (
SELECT DATE(createDateTime,'Asia/Kolkata') as date,USER_ID,SUM(earned) as total_earned,SUM(cash_out) as total_cash_out
FROM (
SELECT createDateTime,USER_ID,CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT END as earned,CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT END as cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
GROUP BY 1,2,3,4)
GROUP BY 1,2)
--WHERE date = '2019-02-24'
--AND USER_ID = 11539819
GROUP BY 1,2,3,4)
GROUP BY 1)
GROUP BY 1,2,3)
SELECT a.date,ROUND(SUM(b.wallet_balence)) as cum_wallet_balence
FROM wallet_balence a
JOIN wallet_balence b 
ON a.dummy = b.dummy
WHERE b.date <= a.date
AND a.date < CURRENT_DATE()
GROUP BY 1
ORDER BY 1

## v1 (something is wrong in this)

WITH day_wise_wallet_balence as (
WITH day_wise_earnings AS (
SELECT date,USER_ID,CASE WHEN total_earned IS NULL THEN 0 ELSE total_earned END AS total_earned,CASE WHEN total_cash_out IS NULL THEN 0 ELSE total_cash_out END AS total_cash_out
FROM (
SELECT date,USER_ID,SUM(earned) as total_earned,SUM(cash_out) as total_cash_out
FROM (
SELECT DATE(createDateTime,'Asia/Kolkata') as date,USER_ID,CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT END as earned,CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT END as cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
GROUP BY 1,2,3,4)
GROUP BY 1,2)
GROUP BY 1,2,3,4)
SELECT date,USER_ID,ROUND(((SELECT SUM(total_earned) FROM day_wise_earnings b WHERE b.date <= a.date AND b.USER_ID = a.USER_ID)-(SELECT SUM(total_cash_out) FROM day_wise_earnings c WHERE c.date <= a.date AND c.USER_ID = a.USER_ID)),2) as wallet_balence
FROM day_wise_earnings a
GROUP BY 1,2,3)
SELECT date,ROUND(SUM(wallet_balence)/1000,2) as cumm_wallet_balence_in_K
FROM day_wise_wallet_balence
GROUP BY 1

## game_wise money distributed data

SELECT b.date as game_date,a.date as payment_process_date,b.title,a.game_id,b.game_type_id,a.amount_credited,b.prize_money 
FROM (
SELECT DATE(createDateTime,'Asia/Kolkata') as date,SUBSTR(PAYMENT_GATEWAY_TRANSACTION_ID,-36) as game_id,SUM(TRANSACTION_AMOUNT) as amount_credited
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION` 
WHERE STATUS = 'SUCCESS'
--AND DATE(createDateTime,'Asia/Kolkata') = '2019-02-06'
AND TRANSACTION_TYPE = 'CREDIT'
GROUP BY 1,2) a
JOIN (
SELECT DATE(start_time,'Asia/Kolkata') as date,title,game_id,game_type_id,prize_money
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
GROUP BY 1,2,3,4,5) b
ON a.game_id = b.game_id
GROUP BY 1,2,3,4,5,6,7


## ck_equation

y = 0.0697(games_won)+ 0.2643(win_ratio) + 0.0000(points) + 0.0887(winning_amount) + -0.3172(life_consumption_type) + -0.2526(win_type) + -0.1456(ck_age_type_1) + -0.0579(ck_age_type_2) + 0.3995(ck_age_type_3) + 0.4961(ck_days_since_played_type_1) + 0.3794(ck_days_since_played_type_2) + -0.6795(ck_days_since_played_type_3)





WITH cumm_wallet_balence AS (
WITH day_wise_uwb AS (
WITH uwb AS (
WITH user_wallet_balence AS (
SELECT date,USER_ID,CURRENCY_CODE,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT DATE(createDateTime) as date,USER_ID,CURRENCY_CODE,SUM(CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_credited,SUM(CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5)
SELECT a.date,a.USER_ID,a.CURRENCY_CODE,SUM(b.wallet_balence) as cum_wallet_balence
FROM user_wallet_balence a
JOIN user_wallet_balence b 
ON a.dummy = b.dummy 
WHERE b.date <= a.date AND a.USER_ID = b.USER_ID AND a.CURRENCY_CODE = b.CURRENCY_CODE  
AND a.date < CURRENT_DATE()
GROUP BY 1,2,3)
SELECT *,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY USER_ID ORDER BY date) AS next_date
FROM uwb)
SELECT b.date,a.USER_ID,c.handle,a.CURRENCY_CODE,a.cum_wallet_balence,DENSE_RANK() OVER(PARTITION BY CURRENCY_CODE ORDER BY cum_wallet_balence DESC) AS rank
--MAX(a.date) as last_txn_date
FROM day_wise_uwb a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer` 
WHERE  date >= '2018-05-01' AND date < CURRENT_DATE() GROUP BY 1) b
LEFT JOIN (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) c
ON a.USER_ID = c.user_id
WHERE b.date >= a.date AND b.date < a.next_date
--AND b.date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
--AND a.CURRENCY_CODE = 'USD' ORDER BY 5 DESC
GROUP BY 1,2,3,4,5)
SELECT date,CURRENCY_CODE,ROUND(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM cumm_wallet_balence
--WHERE date >= DATE_SUB(CURRENT_DATE(),INTERVAL 6 DAY)
GROUP BY 1,2
ORDER BY 1




### ua user sessions top decile for customer support

SELECT a.date,b.user_id,c.handle,a.session_length
FROM (
SELECT date,user_id,session_length
FROM (
SELECT *,PERCENT_RANK() OVER(PARTITION BY date ORDER BY rank) AS percentile_rank
FROM `swoo-analytics-bq.daily_dashboard.ua_user_sessions`
WHERE date >= DATE("2019-02-24") AND date <= DATE("2019-02-26")
--WHERE date = DATE("2019-02-10")   16704
--WHERE date = DATE("2019-02-09")   23273
--WHERE date = DATE("2019-02-08")   17930
GROUP BY 1,2,3,4)
WHERE percentile_rank >= 0.90
GROUP BY 1,2,3) a
JOIN (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) b
ON a.user_id = b.device_channel
LEFT JOIN (
SELECT id as user_id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) c
ON b.user_id = c.user_id 
GROUP BY 1,2,3,4




SELECT CASE WHEN cum_wallet_balence < 0.00 THEN 'LT 0'
WHEN cum_wallet_balence > 0.00 AND cum_wallet_balence < 0.10 THEN '0.0-0.1'
WHEN cum_wallet_balence >= 0.10 AND cum_wallet_balence < 0.20 THEN '0.1-0.2'
WHEN cum_wallet_balence >= 0.20 AND cum_wallet_balence < 0.30 THEN '0.2-0.3'
WHEN cum_wallet_balence >= 0.30 AND cum_wallet_balence < 0.40 THEN '0.3-0.4'
WHEN cum_wallet_balence >= 0.40 AND cum_wallet_balence < 0.50 THEN '0.4-0.5'
WHEN cum_wallet_balence >= 0.50 AND cum_wallet_balence < 1.00 THEN '0.5-1.0'
WHEN cum_wallet_balence >= 1.00 AND cum_wallet_balence < 1.50 THEN '1.0-1.5'
WHEN cum_wallet_balence >= 1.50 AND cum_wallet_balence < 2.00 THEN '1.5-2.0'
WHEN cum_wallet_balence >= 2.00 AND cum_wallet_balence < 2.50 THEN '2.0-2.5'
WHEN cum_wallet_balence >= 2.50 AND cum_wallet_balence < 3.00 THEN '2.5-3.0'
WHEN cum_wallet_balence >= 3.00 AND cum_wallet_balence < 3.50 THEN '3.0-3.5'
WHEN cum_wallet_balence >= 3.50 AND cum_wallet_balence < 4.00 THEN '3.5-4.0'
WHEN cum_wallet_balence >= 4.00 AND cum_wallet_balence < 4.50 THEN '4.0-4.5'
WHEN cum_wallet_balence >= 4.50 AND cum_wallet_balence < 5.00 THEN '4.5-5.0'
WHEN cum_wallet_balence >= 5.00 AND cum_wallet_balence < 7.50 THEN '5.0-7.5'
WHEN cum_wallet_balence >= 7.50 AND cum_wallet_balence < 10.00 THEN '7.5-10.0'
WHEN cum_wallet_balence >= 10.00 AND cum_wallet_balence < 20.00 THEN '10.0-20.0'
WHEN cum_wallet_balence >= 20.00 AND cum_wallet_balence < 30.00 THEN '20.0-30.0'
WHEN cum_wallet_balence >= 30.00 AND cum_wallet_balence < 40.00 THEN '30.0-40.0'
WHEN cum_wallet_balence >= 40.00 AND cum_wallet_balence < 50.00 THEN '40.0-50.0'
WHEN cum_wallet_balence >= 50.00 AND cum_wallet_balence < 100.00 THEN '50.00-100.00'
WHEN cum_wallet_balence >= 100.00 AND cum_wallet_balence < 250.00 THEN '100.00-250.00'
WHEN cum_wallet_balence >= 250.00 AND cum_wallet_balence < 500.00 THEN '250.00-500.00'
WHEN cum_wallet_balence >= 250.00 AND cum_wallet_balence < 500.00 THEN '250.00-500.00'
WHEN cum_wallet_balence >= 500.00 THEN 'GT 500' ELSE 'NA' END AS bucket_type,COUNT(DISTINCT USER_ID) as users
FROM (
SELECT USER_ID,ROUND(cum_wallet_balence,2) as cum_wallet_balence
FROM `swoo-analytics-bq.derived_data.Cumm_user_wallet_balence`
WHERE CURRENCY_CODE = 'INR'
GROUP BY 1,2)
GROUP BY 1



SELECT CASE WHEN cum_wallet_balence < 0.00 THEN 'LT 0'
WHEN cum_wallet_balence > 0.00 AND cum_wallet_balence < 0.10 THEN '0.0-0.1'
WHEN cum_wallet_balence >= 0.10 AND cum_wallet_balence < 0.20 THEN '0.1-0.2'
WHEN cum_wallet_balence >= 0.20 AND cum_wallet_balence < 0.30 THEN '0.2-0.3'
WHEN cum_wallet_balence >= 0.30 AND cum_wallet_balence < 0.40 THEN '0.3-0.4'
WHEN cum_wallet_balence >= 0.40 AND cum_wallet_balence < 0.50 THEN '0.4-0.5'
WHEN cum_wallet_balence >= 0.50 AND cum_wallet_balence < 1.00 THEN '0.5-1.0'
WHEN cum_wallet_balence >= 1.00 AND cum_wallet_balence < 1.50 THEN '1.0-1.5'
WHEN cum_wallet_balence >= 1.50 AND cum_wallet_balence < 2.00 THEN '1.5-2.0'
WHEN cum_wallet_balence >= 2.00 AND cum_wallet_balence < 2.50 THEN '2.0-2.5'
WHEN cum_wallet_balence >= 2.50 AND cum_wallet_balence < 3.00 THEN '2.5-3.0'
WHEN cum_wallet_balence >= 3.00 AND cum_wallet_balence < 3.50 THEN '3.0-3.5'
WHEN cum_wallet_balence >= 3.50 AND cum_wallet_balence < 4.00 THEN '3.5-4.0'
WHEN cum_wallet_balence >= 4.00 AND cum_wallet_balence < 4.50 THEN '4.0-4.5'
WHEN cum_wallet_balence >= 4.50 AND cum_wallet_balence < 5.00 THEN '4.5-5.0'
WHEN cum_wallet_balence >= 5.00 AND cum_wallet_balence < 7.50 THEN '5.0-7.5'
WHEN cum_wallet_balence >= 7.50 AND cum_wallet_balence < 10.00 THEN '7.5-10.0'
WHEN cum_wallet_balence >= 10.00 AND cum_wallet_balence < 20.00 THEN '10.0-20.0'
WHEN cum_wallet_balence >= 20.00 AND cum_wallet_balence < 30.00 THEN '20.0-30.0'
WHEN cum_wallet_balence >= 30.00 AND cum_wallet_balence < 40.00 THEN '30.0-40.0'
WHEN cum_wallet_balence >= 40.00 AND cum_wallet_balence < 50.00 THEN '40.0-50.0'
WHEN cum_wallet_balence >= 50.00 AND cum_wallet_balence < 100.00 THEN '50.00-100.00'
WHEN cum_wallet_balence >= 100.00 AND cum_wallet_balence < 250.00 THEN '100.00-250.00'
WHEN cum_wallet_balence >= 250.00 AND cum_wallet_balence < 500.00 THEN '250.00-500.00'
WHEN cum_wallet_balence >= 250.00 AND cum_wallet_balence < 500.00 THEN '250.00-500.00'
WHEN cum_wallet_balence >= 500.00 THEN 'GT 500' ELSE 'NA' END AS bucket_type,COUNT(DISTINCT USER_ID) as users
FROM (
SELECT USER_ID,ROUND(cum_wallet_balence,2) as cum_wallet_balence
FROM `swoo-analytics-bq.derived_data.Cumm_user_wallet_balence`
WHERE CURRENCY_CODE = 'INR'
GROUP BY 1,2)
GROUP BY 1


SELECT * 
FROM `swoo-analytics-bq.derived_data.Cumm_user_wallet_balence`
WHERE CURRENCY_CODE = 'INR'
AND cum_wallet_balence < 0.00
ORDER BY 5
LIMIT 500



### test query

SELECT REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") as iana_timezone,
--REPLACE(JSON_EXTRACT(device, "$[attributes].locale_country_code"), "\"", "") as locale_country_code,
COUNT(DISTINCT REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) IN ('2019-03-09') --,'2019-03-10')
AND REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") IN ('swooperstar_gamelandingscreen')
AND REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") IN ('Asia/Dubai')
GROUP BY 1
ORDER BY 2 DESC


-- actual query

WITH user_device_map AS (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2)
SELECT a.date,COUNT(DISTINCT a.user_id) as players,COUNT(DISTINCT b.user_id) as voters  
FROM (
SELECT a.date,b.user_id 
FROM (
SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "") as device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) IN ('2019-03-09','2019-03-10')
AND REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") IN ('swooperstar_gamelandingscreen')
AND REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") IN ('Asia/Dubai')
GROUP BY 1,2) a
LEFT JOIN user_device_map b
ON a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.date,b.user_id 
FROM (
SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "") as device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) IN ('2019-03-09','2019-03-10')
AND REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") IN ('swooperstar_videosubmitclick')
AND REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") IN ('Asia/Dubai')
GROUP BY 1,2) a
LEFT JOIN user_device_map b
ON a.device_channel = b.device_channel 
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id
GROUP BY 1


WITH user_device_map AS (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2),user_info AS (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5)
SELECT a.date,b.user_id,c.handle,c.name,c.email,c.phone
FROM (
SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "") as device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) IN ('2019-03-09','2019-03-10')
AND REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") IN ('swooperstar_gamelandingscreen')
AND REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") IN ('Asia/Dubai')
GROUP BY 1,2) a
LEFT JOIN user_device_map b
ON a.device_channel = b.device_channel
LEFT JOIN user_info c
ON b.user_id = c.user_id
GROUP BY 1,2,3,4,5,6



SELECT stream_id,broadcast_id
FROM `swoo-analytics-bq.swoo_gaming_service.swooperstar_shortlisted_videos` 
WHERE stream_id IN ('prodPub123585121552193781218','prodPub89518261552197562002','prodPub128122251552196243077','prodPub144477091552214106672','prodPub85430731552219064111','prodPub85401071552209566622')
GROUP BY 1,2



SELECT voted,COUNT(DISTINCT user_id) as noofvotes
FROM `swoo-analytics-bq.swoo_gaming_service.swooperstar_user_activity` 
GROUP BY 1




WITH swooperstar_top3_videos AS (
SELECT broadcast_id --date,game_id,
FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY game_id ORDER BY users DESC) AS rank
FROM (
SELECT DATE(created_at) as date,game_id,broadcast_id,COUNT(DISTINCT user_id) as users
FROM `swoo-analytics-bq.swoo_gaming_service.swooperstar_user_activity`
WHERE voted = 1 AND DATE(created_at) IN ('2019-03-09','2019-03-10')
GROUP BY 1,2,3))
WHERE rank < 4
GROUP BY 1)
SELECT DATE(created_at) as date,game_id,user_id,COUNT(DISTINCT broadcast_id) as count
FROM `swoo-analytics-bq.swoo_gaming_service.swooperstar_user_activity`
WHERE DATE(created_at) IN ('2019-03-10')
AND broadcast_id IN (SELECT broadcast_id FROM swooperstar_top3_videos)
GROUP BY 1,2,3



### Cummulative user wallet balence along with last open,last transaction, max unistall date

WITH Cumm_user_wallet_balence AS (
WITH day_wise_uwb AS (
WITH uwb AS (
WITH user_wallet_balence AS (
SELECT date,USER_ID,CURRENCY_CODE,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT DATE(createDateTime) as date,USER_ID,CURRENCY_CODE,SUM(CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_credited,SUM(CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5)
SELECT a.date,a.USER_ID,a.CURRENCY_CODE,SUM(b.wallet_balence) as cum_wallet_balence
FROM user_wallet_balence a
JOIN user_wallet_balence b 
ON a.dummy = b.dummy 
WHERE b.date <= a.date AND a.USER_ID = b.USER_ID AND a.CURRENCY_CODE = b.CURRENCY_CODE  
AND a.date < CURRENT_DATE()
GROUP BY 1,2,3)
SELECT *,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY USER_ID ORDER BY date) AS next_date
FROM uwb)
SELECT b.date,a.USER_ID as user_id,c.handle,a.CURRENCY_CODE as currency_code,a.cum_wallet_balence
--,DENSE_RANK() OVER(PARTITION BY CURRENCY_CODE ORDER BY cum_wallet_balence DESC) AS rank
,MAX(a.date) as last_txn_date
FROM day_wise_uwb a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer` 
WHERE  date >= '2018-05-01' AND date < CURRENT_DATE() GROUP BY 1) b
LEFT JOIN (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) c
ON a.USER_ID = c.user_id
WHERE b.date >= a.date AND b.date < a.next_date
AND b.date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
--AND a.CURRENCY_CODE = 'INR' --ORDER BY 5 DESC
GROUP BY 1,2,3,4,5)
SELECT a.*,b.max_open_date,max_uninstall_date
FROM Cumm_user_wallet_balence a
LEFT JOIN (
SELECT b.user_id,a.max_open_date,a.max_uninstall_date
FROM (
SELECT device_channel,MAX(CASE WHEN type = 'OPEN' THEN date END) as max_open_date,MAX(CASE WHEN type = 'UNINSTALL' THEN date END) as max_uninstall_date
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
GROUP BY 1) a
LEFT JOIN (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3) b
ON a.USER_ID = b.user_id
GROUP BY 1,2,3,4,5,6,7,8



SELECT CASE WHEN last_txn_date < DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY) THEN 'LastActivityMoreThan60daysBack' ELSE 'Other' END AS activity_type,currency_code,
COUNT(DISTINCT user_id) as users,ROUND(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM `swoo-analytics-bq.derived_data.Cum_user_wallet_balence_info`
GROUP BY 1,2


SELECT CASE WHEN max_uninstall_date < DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY) THEN 'UninstalledMoreThan60days' ELSE 'Other' END AS uninstall_type,currency_code,
COUNT(DISTINCT user_id) as users,ROUND(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM `swoo-analytics-bq.derived_data.Cum_user_wallet_balence_info`
WHERE max_open_date <= max_uninstall_date
GROUP BY 1,2


SELECT CASE WHEN max_uninstall_date IS NOT NULL THEN 'Not Null' ELSE 'Null' END AS type,currency_code,COUNT(DISTINCT user_id) as users,ROUND(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM `swoo-analytics-bq.derived_data.Cum_user_wallet_balence_info`
GROUP BY 1,2


SELECT * --currency_code,ROUND(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM `swoo-analytics-bq.derived_data.Cum_user_wallet_balence_info`
WHERE user_id = 8984567





WITH Cumm_user_wallet_balence AS (
WITH day_wise_uwb AS (
WITH uwb AS (
WITH user_wallet_balence AS (
SELECT date,USER_ID,CURRENCY_CODE,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT DATE(createDateTime) as date,USER_ID,CURRENCY_CODE,SUM(CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_credited,SUM(CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5)
SELECT a.date,a.USER_ID,a.CURRENCY_CODE,SUM(b.wallet_balence) as cum_wallet_balence
FROM user_wallet_balence a
JOIN user_wallet_balence b 
ON a.dummy = b.dummy 
WHERE b.date <= a.date AND a.USER_ID = b.USER_ID AND a.CURRENCY_CODE = b.CURRENCY_CODE  
AND a.date < CURRENT_DATE()
GROUP BY 1,2,3)
SELECT *,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY USER_ID ORDER BY date) AS next_date
FROM uwb)
SELECT b.date,a.USER_ID as user_id,c.handle,a.CURRENCY_CODE as currency_code,a.cum_wallet_balence
--,DENSE_RANK() OVER(PARTITION BY CURRENCY_CODE ORDER BY cum_wallet_balence DESC) AS rank
,MAX(a.date) as last_txn_date
FROM day_wise_uwb a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer` 
WHERE  date >= '2018-05-01' AND date < CURRENT_DATE() GROUP BY 1) b
LEFT JOIN (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) c
ON a.USER_ID = c.user_id
WHERE b.date >= a.date AND b.date < a.next_date
AND b.date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
--AND a.CURRENCY_CODE = 'INR' --ORDER BY 5 DESC
GROUP BY 1,2,3,4,5)
SELECT a.*,b.max_open_date,max_uninstall_date
FROM Cumm_user_wallet_balence a
LEFT JOIN (
SELECT a.user_id,b.max_open_date,b.max_uninstall_date
FROM (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(CASE WHEN type = 'OPEN' THEN date END) as max_open_date,MAX(CASE WHEN type = 'UNINSTALL' THEN date END) as max_uninstall_date
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
GROUP BY 1) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3) b
ON a.USER_ID = b.user_id
GROUP BY 1,2,3,4,5,6,7,8






SELECT *
FROM (
SELECT user_id,COUNT(DISTINCT max_open_date) as dates
FROM (
SELECT a.user_id,b.max_open_date,b.max_uninstall_date
FROM (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MAX(CASE WHEN type = 'OPEN' THEN date END) as max_open_date,MAX(CASE WHEN type = 'UNINSTALL' THEN date END) as max_uninstall_date
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
GROUP BY 1) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3)
GROUP BY 1)
WHERE dates > 1
ORDER BY 2 DESC





WITH Cumm_user_wallet_balence AS (
WITH day_wise_uwb AS (
WITH uwb AS (
WITH user_wallet_balence AS (
SELECT date,USER_ID,CURRENCY_CODE,(total_credited-total_cash_out) as wallet_balence,'dummy' as dummy
FROM (
SELECT DATE(createDateTime) as date,USER_ID,CURRENCY_CODE,SUM(CASE WHEN TRANSACTION_TYPE = 'CREDIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_credited,SUM(CASE WHEN TRANSACTION_TYPE = 'DEBIT' THEN TRANSACTION_AMOUNT ELSE 0 END) as total_cash_out
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS'
--AND USER_ID = 7820788
AND USER_ID NOT IN (5181193,6137229,4887396,3206745)
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5)
SELECT a.date,a.USER_ID,a.CURRENCY_CODE,SUM(b.wallet_balence) as cum_wallet_balence
FROM user_wallet_balence a
JOIN user_wallet_balence b 
ON a.dummy = b.dummy 
WHERE b.date <= a.date AND a.USER_ID = b.USER_ID AND a.CURRENCY_CODE = b.CURRENCY_CODE  
AND a.date < CURRENT_DATE()
GROUP BY 1,2,3)
SELECT *,LEAD(date,1,CURRENT_DATE()) OVER (PARTITION BY USER_ID ORDER BY date) AS next_date
FROM uwb)
SELECT b.date,a.USER_ID as user_id,c.handle,a.CURRENCY_CODE as currency_code,a.cum_wallet_balence
--,DENSE_RANK() OVER(PARTITION BY CURRENCY_CODE ORDER BY cum_wallet_balence DESC) AS rank
,MAX(a.date) as last_txn_date
FROM day_wise_uwb a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer` 
WHERE  date >= '2018-05-01' AND date < CURRENT_DATE() GROUP BY 1) b
LEFT JOIN (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) c
ON a.USER_ID = c.user_id
WHERE b.date >= a.date AND b.date < a.next_date
AND b.date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
--AND a.CURRENCY_CODE = 'INR' --ORDER BY 5 DESC
GROUP BY 1,2,3,4,5)
SELECT CASE WHEN last_txn_date < DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY) THEN 'LastActivityMoreThan60daysBack' ELSE 'Other' END AS activity_type,currency_code,
COUNT(DISTINCT user_id) as users,ROUND(SUM(cum_wallet_balence)) as cum_wallet_balence
FROM Cumm_user_wallet_balence
GROUP BY 1,2




WITH user_device_map AS (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2),user_info AS (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5)
SELECT a.date,b.user_id,c.handle,c.name,c.email,c.phone
FROM (
SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "") as device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) IN ('2019-03-09','2019-03-10','2019-03-11')
AND REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") IN ('swooperstar_videosubmitclick')
AND REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") IN ('Asia/Dubai')
GROUP BY 1,2) a
LEFT JOIN user_device_map b
ON a.device_channel = b.device_channel
LEFT JOIN user_info c
ON b.user_id = c.user_id
GROUP BY 1,2,3,4,5,6



WITH uae_trivia_players AS (
WITH user_device_map AS (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2),user_info AS (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5)
SELECT a.date,b.user_id,c.handle,c.name,c.email,c.phone
FROM (
SELECT DATE(occurred) as date,REPLACE(JSON_EXTRACT(device, "$.channel"), "\"", "") as device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) IN ('2019-03-08','2019-03-11','2019-03-12')
AND REPLACE(JSON_EXTRACT(body, "$.name"), "\"", "") IN ('trivia_started_playing')
AND REPLACE(JSON_EXTRACT(device, "$[attributes].iana_timezone"), "\"", "") IN ('Asia/Dubai')
GROUP BY 1,2) a
LEFT JOIN user_device_map b
ON a.device_channel = b.device_channel
LEFT JOIN user_info c
ON b.user_id = c.user_id
GROUP BY 1,2,3,4,5,6),all_trivia_winners AS (
SELECT g.date,user_id
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` AS ugs
JOIN (
SELECT DATE(start_time) as date,game_type_id,title,game_id
FROM `swoo-analytics-bq.swoo_gaming_service.game` 
WHERE DATE(start_time) IN ('2019-03-08','2019-03-11','2019-03-12')
AND is_deleted = 0 AND (country_codes like '%IN%' OR country_codes like '%AE%') AND status_id IN (11,12)
AND game_type_id = 'Trivia'
--AND TIME(TIMESTAMP_TRUNC(start_time, MINUTE)) = '06:30:00'
GROUP BY 1,2,3,4) AS g
ON g.game_id = ugs.game_id
WHERE ugs.games_won = 1 AND g.game_type_id = 'Trivia'
GROUP BY 1,2)
SELECT a.* FROM uae_trivia_players a
JOIN all_trivia_winners b
ON a.user_id = b.user_id
GROUP BY 1,2,3,4,5,6




Select date,Time_Spent/3600 as Time_Spent_hrs from (
Select date,Sum(seconds) as Time_Spent from (
select *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, SECOND) as Seconds
from (
select date(occurred) as date,occurred,body_name,device_channel,
LEAD(occurred,1) OVER (PARTITION BY device_channel ORDER BY occurred) AS Next_Time_Stamp,
LEAD(body_name,1) OVER (PARTITION BY device_channel ORDER BY occurred) AS Next_Event
from `analytics_data.urban_airship_v2` where date(occurred) >= "2019-03-01"
and lower(body_name) in ("videoplayer_open","videoplayer_exit")
--and device_channel = "e2b17ed7-6b16-4219-a50c-209839c3ca4e"
group by 1,2,3,4 order by 2
)
WHERE Next_Event != "videoplayer_open" group by 1,2,3,4,5,6) group by 1) order by 1


SELECT date,ROUND((total_seconds)/3600,2) as time_spent_in_hours
FROM (
SELECT date,SUM(Seconds) as total_seconds
FROM (
SELECT *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, MILLISECOND) as Seconds
FROM (
SELECT *,LEAD(occurred,1) OVER (PARTITION BY device_channel ORDER BY occurred) AS Next_Time_Stamp,LEAD(body_name,1) OVER (PARTITION BY device_channel ORDER BY occurred) AS Next_Event
FROM (
SELECT DATE(occurred) as date,occurred,body_name,device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) > '2019-03-01'
AND body_name IN ('videoplayer_open','videoplayer_exit')
--AND device_channel = "e2b17ed7-6b16-4219-a50c-209839c3ca4e"
GROUP BY 1,2,3,4 ORDER BY 2) --ORDER BY 2
GROUP BY 1,2,3,4)
GROUP BY 1,2,3,4,5,6 ORDER BY 7 DESC LIMIT 500)
WHERE Next_Event = 'videoplayer_exit'
GROUP BY 1)
GROUP BY 1,2 ORDER BY 1





SELECT DATE(occurred) as date,occurred,body_name,device_channel
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2019-03-09' 
AND body_name IN ('videoplayer_open','videoplayer_exit')
AND device_channel = "cbb74db1-f3c7-4c3f-8457-081379a363d4"
GROUP BY 1,2,3,4 ORDER BY 2




SELECT a.date,b.user_id,c.handle,a.session_length
FROM (
SELECT date,user_id,session_length
FROM (
SELECT a.*,PERCENT_RANK() OVER(PARTITION BY a.date ORDER BY a.rank) AS percentile_rank
FROM `swoo-analytics-bq.daily_dashboard.ua_user_sessions` a
JOIN (
SELECT a.date,a.device_channel
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= DATE("2019-02-27") AND date <= DATE("2019-03-17")
AND body_name IN ('swooperstar_gamelandingscreen') --AND body_name NOT IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing','teenpatti_started_playing')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= DATE("2019-02-27") AND date <= DATE("2019-03-17")
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing','teenpatti_started_playing')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
WHERE b.device_channel IS NULL
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.device_channel 
WHERE a.date >= DATE("2019-02-27") AND a.date <= DATE("2019-03-17")
GROUP BY 1,2,3,4)
WHERE percentile_rank >= 0.90
GROUP BY 1,2,3) a
JOIN (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) b
ON a.user_id = b.device_channel
LEFT JOIN (
SELECT id as user_id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) c
ON b.user_id = c.user_id 
GROUP BY 1,2,3,4



SELECT a.date,b.user_id,c.handle,a.session_length
FROM (
SELECT date,user_id,session_length
FROM (
SELECT a.*,PERCENT_RANK() OVER(PARTITION BY a.date ORDER BY a.rank) AS percentile_rank
FROM `swoo-analytics-bq.daily_dashboard.ua_user_sessions` a
JOIN (
SELECT a.date,a.device_channel
FROM (
SELECT date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= DATE("2019-02-27") AND date <= DATE("2019-03-17")
AND body_name IN ('swooperstar_gamelandingscreen') --AND body_name NOT IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing','teenpatti_started_playing')
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel --date,
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= DATE("2019-02-27") AND date <= DATE("2019-03-17")
AND body_name IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing','teenpatti_started_playing')
GROUP BY 1) b
ON a.device_channel = b.device_channel -- a.date = b.date AND
WHERE b.device_channel IS NULL
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.device_channel 
WHERE a.date >= DATE("2019-02-27") AND a.date <= DATE("2019-03-17")
GROUP BY 1,2,3,4)
WHERE percentile_rank >= 0.90
GROUP BY 1,2,3) a
JOIN (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY device_channel ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) b
ON a.user_id = b.device_channel
LEFT JOIN (
SELECT id as user_id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) c
ON b.user_id = c.user_id 
GROUP BY 1,2,3,4


WITH user_info AS (
SELECT id as user_id,handle,name,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5)
SELECT DATE(a.created_at) as date,a.user_id,b.handle,b.name,b.email,b.phone
FROM `swoo-analytics-bq.swoo_gaming_service.user_game_statistics` a
LEFT JOIN user_info b
ON a.user_id = b.user_id 
WHERE a.games_won = 1 AND a.is_deleted = 0 AND DATE(a.created_at) = '2019-03-13'
AND a.game_type_id = 'Trivia'
GROUP BY 1,2,3,4,5,6







Select date,Round(SUM(MilliSeconds)/3600000,0) as Time_Spent_hrs from (
Select *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, MILLISECOND) as MilliSeconds from (
select *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel ORDER BY occurred) AS Next_Time_Stamp,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel ORDER BY occurred) AS Next_Event
from (
select date(occurred) as date,occurred,body_name,device_channel
from `analytics_data.urban_airship_v2` where date(occurred) >= "2019-03-01" 
--and date(occurred) <= "2019-03-10" 
and lower(body_name) in ("videoplayer_open","videoplayer_exit") 
--and device_channel in ("2bbb2aa8-375e-40c3-8ff2-92641808527f","cbb74db1-f3c7-4c3f-8457-081379a363d4")
group by 1,2,3,4)) WHERE Next_Event = "videoplayer_exit") group by 1 order by 1



###

JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$[properties].UserId") as user_id

## user_id's

SELECT a.date,COUNT(DISTINCT a.user_id) as New_App_DAU, COUNT(DISTINCT b.user_id) as Videos_Tab_Openers
FROM (
SELECT date,device_channel as user_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`  
WHERE date >= '2019-03-01'
AND type = 'CUSTOM'
AND body_name IN ('livegamestab_open')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel as user_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE date >= '2019-03-01'
AND type = 'CUSTOM'
AND body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id
GROUP BY 1 ORDER BY 1

## device_channels

SELECT a.date,COUNT(DISTINCT a.user_id) as New_App_DAU, COUNT(DISTINCT b.user_id) as Videos_Tab_Openers
FROM (
SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(device, "$.channel") as user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-01'
AND type = 'CUSTOM'
AND JSON_EXTRACT_SCALAR(body, "$.name") IN ('livegamestab_open')
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(device, "$.channel") as user_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-01'
AND type = 'CUSTOM'
AND JSON_EXTRACT_SCALAR(body, "$.name") IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id
GROUP BY 1 ORDER BY 1

## visit_type

SELECT date,visit_type,COUNT(DISTINCT device_channel) as users
FROM (
SELECT a.date,a.device_channel,CASE WHEN a.date = b.min_date THEN 'first_visit' ELSE 'return_visit' END AS visit_type
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MIN(date) as min_date
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1) b
ON a.device_channel = b.device_channel  
WHERE a.date >= b.min_date
GROUP BY 1,2,3)
GROUP BY 1,2

## video watchers

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_playing')
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_open')
GROUP BY 1 ORDER BY 1

## shares & downloads

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_shareclicked')
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_downloadclicked')
GROUP BY 1 ORDER BY 1

## retention

SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2

SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2

## time_spent

SELECT date,ROUND((SUM(MilliSeconds)/1000)/3600,2) as Time_Spent_Hrs,
FROM (
SELECT *,TIMESTAMP_DIFF(next_occurred, occurred, MILLISECOND) as MilliSeconds
FROM (
SELECT *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS next_occurred,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS next_body_name
FROM (
SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,occurred,JSON_EXTRACT_SCALAR(body, "$.name") as body_name
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-01' AND DATE(occurred) < CURRENT_DATE() AND type = 'CUSTOM' 
AND JSON_EXTRACT_SCALAR(body, "$.name") IN ('videoplayer_open','videoplayer_exit')
--AND JSON_EXTRACT_SCALAR(body, "$[properties].UserId") = '14444872' -- keep the desired user_id here
GROUP BY 1,2,3,4,5)
GROUP BY 1,2,3,4,5)
WHERE next_body_name = "videoplayer_exit")
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as video_player_openers
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_open')
GROUP BY 1 ORDER BY 1



## App WoW Corrected

SELECT a.Date,(Users/LWAU) as WoW
FROM (
SELECT a.Date as Date,COUNT(DISTINCT a.device_channel) as Users
FROM (
SELECT b.date as Date,device_channel --COUNT(DISTINCT developer_identity) as WAU 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1` 
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2) a
JOIN (
SELECT b.date as Date,device_channel --COUNT(DISTINCT developer_identity) as WAU 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1` 
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
GROUP BY 1) a
LEFT JOIN (
SELECT b.date as Date,COUNT(DISTINCT a.device_channel) as LWAU 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v1` 
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1) b
ON a.Date = b.Date
GROUP BY 1,2



SELECT user_id,DATE(created_at) as reg_date,referral_code as user_handle,DATE(referral_applied_time) as referral_applied_date,game_type_id,CAST(referree_id as INT64) as referree_id,referral_code_applied
FROM `swoo-analytics-bq.swoo_gaming_service.user_statistics`
WHERE DATE(referral_applied_time) >= '2018-08-01'
AND is_referral_applied = 1
AND is_deleted = 0 
AND referral_code_applied = 'dhiradivakaran'
GROUP BY 1,2,3,4,5,6,7


SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,type,JSON_EXTRACT_SCALAR(body, "$.name") as body_name
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-21' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) >= '2019-03-01'
AND type IN ('FIRST_OPEN','OPEN','CUSTOM','UNINSTALL')
GROUP BY 1,2,3,4



## JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
## JSON_EXTRACT_SCALAR(body, "$[properties].UserId") as user_id


## visit_type

SELECT date,visit_type,COUNT(DISTINCT device_channel) as users
FROM (
SELECT a.date,a.device_channel,CASE WHEN a.date = b.min_date THEN 'first_visit' ELSE 'return_visit' END AS visit_type
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,MIN(date) as min_date
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1) b
ON a.device_channel = b.device_channel  
WHERE a.date >= b.min_date
GROUP BY 1,2,3)
GROUP BY 1,2

## video watchers

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_playing')
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_open')
GROUP BY 1 ORDER BY 1

## shares & downloads

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_shareclicked')
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_downloadclicked')
GROUP BY 1 ORDER BY 1

## retention

SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2



SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.date,a.device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2








## percent_of_video_played
SELECT date,CASE WHEN percent_of_played >= 0 AND percent_of_played < 0.25 THEN '< 25%'
WHEN percent_of_played >= 0.25 AND percent_of_played < 0.50 THEN '25% to 50%'
WHEN percent_of_played >= 0.50 AND percent_of_played < 0.75 THEN '50% to 75%'
ELSE '> 75%' END AS percent_of_video_played,COUNT(DISTINCT video_id) as videos --COUNT(DISTINCT device_channel) as users --
FROM (
SELECT *,(TIMESTAMP_DIFF(next_time_stamp, occurred, MILLISECOND)/1000)/30 as percent_of_played
FROM (
SELECT *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS next_time_stamp,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS next_event
FROM (
SELECT DATE(occurred) as date,occurred,
JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$.name") as body_name,
JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,
JSON_EXTRACT_SCALAR(body, "$.properties.VideoId") as video_id
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE date(occurred) = "2019-03-26"
AND JSON_EXTRACT_SCALAR(device, "$.channel") = "e2b17ed7-6b16-4219-a50c-209839c3ca4e"
AND JSON_EXTRACT_SCALAR(body, "$.name") IN ("videoplayer_open","videoplayer_exit","videoplayer_playing")
GROUP BY 1,2,3,4,5,6))
WHERE body_name = 'videoplayer_playing' AND next_event IN ('videoplayer_playing','videoplayer_exit'))
GROUP BY 1,2















SELECT Date,(D1/D0) as D1,
(D2/D0) as D2,
(D3/D0) as D3,
(D4/D0) as D4,
(D5/D0) as D5,
(D6/D0) as D6,
(D7/D0) as D7,
(D8/D0) as D8,
(D9/D0) as D9,
(D10/D0) as D10,
(D11/D0) as D11,
(D12/D0) as D12,
(D13/D0) as D13,
(D14/D0) as D14,
(D15/D0) as D15,
(D16/D0) as D16,
(D17/D0) as D17,
(D18/D0) as D18,
(D19/D0) as D19,
(D20/D0) as D20,
(D21/D0) as D21,
(D22/D0) as D22,
(D23/D0) as D23,
(D24/D0) as D24,
(D25/D0) as D25,
(D26/D0) as D26,
(D27/D0) as D27,
(D28/D0) as D28,
(D29/D0) as D29,
(D30/D0) as D30
FROM (
SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,
MAX(IF(Retention = 'D1',Users,NULL)) as D1,
MAX(IF(Retention = 'D2',Users,NULL)) as D2,
MAX(IF(Retention = 'D3',Users,NULL)) as D3,
MAX(IF(Retention = 'D4',Users,NULL)) as D4,
MAX(IF(Retention = 'D5',Users,NULL)) as D5,
MAX(IF(Retention = 'D6',Users,NULL)) as D6,
MAX(IF(Retention = 'D7',Users,NULL)) as D7,
MAX(IF(Retention = 'D8',Users,NULL)) as D8,
MAX(IF(Retention = 'D9',Users,NULL)) as D9,
MAX(IF(Retention = 'D10',Users,NULL)) as D10,
MAX(IF(Retention = 'D11',Users,NULL)) as D11,
MAX(IF(Retention = 'D12',Users,NULL)) as D12,
MAX(IF(Retention = 'D13',Users,NULL)) as D13,
MAX(IF(Retention = 'D14',Users,NULL)) as D14,
MAX(IF(Retention = 'D15',Users,NULL)) as D15,
MAX(IF(Retention = 'D16',Users,NULL)) as D16,
MAX(IF(Retention = 'D17',Users,NULL)) as D17,
MAX(IF(Retention = 'D18',Users,NULL)) as D18,
MAX(IF(Retention = 'D19',Users,NULL)) as D19,
MAX(IF(Retention = 'D20',Users,NULL)) as D20,
MAX(IF(Retention = 'D21',Users,NULL)) as D21,
MAX(IF(Retention = 'D22',Users,NULL)) as D22,
MAX(IF(Retention = 'D23',Users,NULL)) as D23,
MAX(IF(Retention = 'D24',Users,NULL)) as D24,
MAX(IF(Retention = 'D25',Users,NULL)) as D25,
MAX(IF(Retention = 'D26',Users,NULL)) as D26,
MAX(IF(Retention = 'D27',Users,NULL)) as D27,
MAX(IF(Retention = 'D28',Users,NULL)) as D28,
MAX(IF(Retention = 'D29',Users,NULL)) as D29,
MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 2 DAY) THEN 'D2'
WHEN b.date = DATE_ADD(a.date,INTERVAL 3 DAY) THEN 'D3'
WHEN b.date = DATE_ADD(a.date,INTERVAL 4 DAY) THEN 'D4'
WHEN b.date = DATE_ADD(a.date,INTERVAL 5 DAY) THEN 'D5'
WHEN b.date = DATE_ADD(a.date,INTERVAL 6 DAY) THEN 'D6'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 8 DAY) THEN 'D8'
WHEN b.date = DATE_ADD(a.date,INTERVAL 9 DAY) THEN 'D9'
WHEN b.date = DATE_ADD(a.date,INTERVAL 10 DAY) THEN 'D10'
WHEN b.date = DATE_ADD(a.date,INTERVAL 11 DAY) THEN 'D11'
WHEN b.date = DATE_ADD(a.date,INTERVAL 12 DAY) THEN 'D12'
WHEN b.date = DATE_ADD(a.date,INTERVAL 13 DAY) THEN 'D13'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 15 DAY) THEN 'D15'
WHEN b.date = DATE_ADD(a.date,INTERVAL 16 DAY) THEN 'D16'
WHEN b.date = DATE_ADD(a.date,INTERVAL 17 DAY) THEN 'D17'
WHEN b.date = DATE_ADD(a.date,INTERVAL 18 DAY) THEN 'D18'
WHEN b.date = DATE_ADD(a.date,INTERVAL 19 DAY) THEN 'D19'
WHEN b.date = DATE_ADD(a.date,INTERVAL 20 DAY) THEN 'D20'
WHEN b.date = DATE_ADD(a.date,INTERVAL 21 DAY) THEN 'D21'
WHEN b.date = DATE_ADD(a.date,INTERVAL 22 DAY) THEN 'D22'
WHEN b.date = DATE_ADD(a.date,INTERVAL 23 DAY) THEN 'D23'
WHEN b.date = DATE_ADD(a.date,INTERVAL 24 DAY) THEN 'D24'
WHEN b.date = DATE_ADD(a.date,INTERVAL 25 DAY) THEN 'D25'
WHEN b.date = DATE_ADD(a.date,INTERVAL 26 DAY) THEN 'D26'
WHEN b.date = DATE_ADD(a.date,INTERVAL 27 DAY) THEN 'D27'
WHEN b.date = DATE_ADD(a.date,INTERVAL 28 DAY) THEN 'D28'
WHEN b.date = DATE_ADD(a.date,INTERVAL 29 DAY) THEN 'D29'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
WHERE Date = '2019-02-15'






## DAU by app_version
SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version,COUNT(DISTINCT JSON_EXTRACT_SCALAR(device, "$.channel")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-04-01' --AND DATE(occurred) < CURRENT_DATE()
AND type IN  ('OPEN')
GROUP BY 1,2 ORDER BY 3 DESC


## video watchers

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_playing')
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_open')
GROUP BY 1 ORDER BY 1

## shares & downloads

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_shareclicked')
GROUP BY 1 ORDER BY 1

SELECT date,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videoplayer_downloadclicked')
GROUP BY 1 ORDER BY 1







SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2





SELECT * --JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,DATE(occurred) as date
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` videoplayer_playing
WHERE DATE(occurred) = "2019-03-26"
AND LOWER(JSON_EXTRACT_SCALAR(device, "$.channel")) = "e2b17ed7-6b16-4219-a50c-209839c3ca4e"
AND JSON_EXTRACT_SCALAR(body, "$.name") IN ("videoplayer_playing")
GROUP BY 1,2



## TeenPatti Events

Round - 1 started - amount
Displayed board for round 1
Sub round 1 started - amount
Place Bet -> amount, blind, round no, sub round no. || Default amount Bet -> amount, blind, round no, sub round no || Show click. ->,, amount, round no, sub round no, card type( rank & suite) ||
Showed Flip card. Count - card type( rank & suite)
sub round 2 started
——
sub round 2 ended
Round 1 ended.
User states - won/lost and how many points
Place Bet -> amount, blind, round no, sub round no
Default amount Bet -> amount, blind, round no, sub round no
Distribute coin bet 
Fold  click-> amount,, round no, sub round no
Show click. ->,, amount, round no, sub round no, card type( rank & suite)
User -> final points.
Life
Winner list - open/clase


     <Event_name>                      <Metadata>
TEENPATTI_ENTERED				- Timestamp,Lifelines,GameId
TEENPATTI_QUIT					- Timestamp,Lifelines,GameId
TEENPATTI_STARTED_PLAYING		- RoundNo,Amount
--TEENPATTI_ROUND_STARTED 		- RoundNo,Amount
TEENPATTI_PLAYBOARD_SHOWN 		- RoundNo,Amount
TEENPATTI_COINS_DISTRIBUTED 	- RoundNo,Amount
TEENPATTI_SUB_ROUND_STARTED 	- SubRoundNo,RoundNo,Amount
TEENPATTI_DEFAULT_BET_PLACED 	- FoldType,SubRoundNo,RoundNo,Amount
TEENPATTI_BET_PLACED 			- FoldType,SubRoundNo,RoundNo,Amount
TEENPATTI_HOST_CARD_FLIPPED		- SubRoundNo,RoundNo,CardType
TEENPATTI_SHOWCARDS_CLICK 		- SubRoundNo,RoundNo,CardType,Amount
TEENPATTI_FOLD_CLICK			- SubRoundNo,RoundNo,CardType,Amount
TEENPATTI_ROUND_FOLDED			- SubRoundNo,RoundNo,CardType,Amount
TEENPATTI_LIFE_CONSUMED			- SubRoundNo,RoundNo,Amount
--TEENPATTI_SUB_ROUND_ENDED		- SubRoundNo,RoundNo,Amount
TEENPATTI_ROUNDSTATS_SHOWN		- Won/Lost,RoundNo,Amount
--TEENPATTI_ROUND_ENDED 		- RoundNo,Amount

TEENPATTI_RESULTBOARD_SHOWN		- Won/Lost,Amount






-- analytics_data.ua_derived_data_v2
SELECT DATE(occurred) as date,occurred,type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version,
JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$.properties.UserId") as user_id,
JSON_EXTRACT_SCALAR(body, "$.properties.IsPro") as app_type,
JSON_EXTRACT_SCALAR(body, "$.name") as body_name,
JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,
JSON_EXTRACT_SCALAR(body, "$.properties.game_type") as game_type,
JSON_EXTRACT_SCALAR(body, "$.properties.game_id") as game_id,
JSON_EXTRACT_SCALAR(body, "$.properties.VideoId") as video_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Position") as position_of_video,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestType") as contest_type,
JSON_EXTRACT_SCALAR(body, "$.properties.GameState") as contest_state,
JSON_EXTRACT_SCALAR(body, "$.properties.NoOfGames") as no_of_games,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestId") as contest_id,
JSON_EXTRACT_SCALAR(body, "$.properties.RegistrationType") as contest_reg_type,
JSON_EXTRACT_SCALAR(body, "$.properties.EntryType") as contest_entry_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardType") as contest_reward_type,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestPlayId") as contest_play_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Score") as score,
JSON_EXTRACT_SCALAR(body, "$.properties.BestScore") as best_score,
JSON_EXTRACT_SCALAR(body, "$.properties.Rank") as rank,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageId") as package_id,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageCurrencyPaid") as package_currency_paid,
JSON_EXTRACT_SCALAR(body, "$.properties.CurrencyEarned") as package_currency_earned,
JSON_EXTRACT_SCALAR(body, "$.properties.TransactionId") as package_transaction_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ErrorMessage") as error_message
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-01' AND DATE(occurred) < CURRENT_DATE() -- DATE(occurred) <= '2019-04-01'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29



##-- analytics_data.ua_derived_data_v3
#v1
SELECT occurred,type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version,
JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$.properties.UserId") as user_id,
JSON_EXTRACT_SCALAR(body, "$.properties.IsPro") as app_type,
JSON_EXTRACT_SCALAR(body, "$.name") as body_name,
JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,
JSON_EXTRACT_SCALAR(body, "$.properties.game_type") as game_type,
JSON_EXTRACT_SCALAR(body, "$.properties.game_id") as game_id,
JSON_EXTRACT_SCALAR(body, "$.properties.VideoId") as video_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Position") as position_of_video,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestType") as contest_type,
JSON_EXTRACT_SCALAR(body, "$.properties.GameState") as contest_state,
JSON_EXTRACT_SCALAR(body, "$.properties.NoOfGames") as no_of_games,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestId") as contest_id,
JSON_EXTRACT_SCALAR(body, "$.properties.RegistrationType") as contest_reg_type,
JSON_EXTRACT_SCALAR(body, "$.properties.EntryType") as contest_entry_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardType") as contest_reward_type,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestPlayId") as contest_play_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Score") as score,
JSON_EXTRACT_SCALAR(body, "$.properties.BestScore") as best_score,
JSON_EXTRACT_SCALAR(body, "$.properties.Rank") as rank,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageId") as package_id,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageCurrencyPaid") as package_currency_paid,
JSON_EXTRACT_SCALAR(body, "$.properties.CurrencyEarned") as package_currency_earned,
JSON_EXTRACT_SCALAR(body, "$.properties.TransactionId") as package_transaction_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ErrorMessage") as error_message,
JSON_EXTRACT_SCALAR(device, "$.device_type") as os_type
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-01' AND DATE(occurred) < CURRENT_DATE()
#v2
SELECT occurred,type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version,
JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$.properties.UserId") as user_id,
JSON_EXTRACT_SCALAR(body, "$.properties.IsPro") as app_type,
JSON_EXTRACT_SCALAR(body, "$.name") as body_name,
JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,
JSON_EXTRACT_SCALAR(body, "$.properties.game_type") as game_type,
JSON_EXTRACT_SCALAR(body, "$.properties.game_id") as game_id,
JSON_EXTRACT_SCALAR(body, "$.properties.VideoId") as video_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Position") as position_of_video,
JSON_EXTRACT_SCALAR(body, "$.properties.Quarantile") as video_quartile,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestType") as contest_type,
JSON_EXTRACT_SCALAR(body, "$.properties.GameState") as contest_state,
JSON_EXTRACT_SCALAR(body, "$.properties.NoOfGames") as no_of_games,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestId") as contest_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestPlayId") as contest_play_id,
JSON_EXTRACT_SCALAR(body, "$.properties.RegistrationType") as contest_registration_type,
JSON_EXTRACT_SCALAR(body, "$.properties.EntryType") as contest_entry_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardType") as contest_daily_reward_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardUnit") as daily_reward_unit,
JSON_EXTRACT_SCALAR(body, "$.properties.Score") as score,
JSON_EXTRACT_SCALAR(body, "$.properties.BestScore") as best_score,
JSON_EXTRACT_SCALAR(body, "$.properties.Rank") as rank,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageId") as package_id,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageCurrencyPaid") as package_currency_paid,
JSON_EXTRACT_SCALAR(body, "$.properties.CurrencyEarned") as package_currency_earned,
JSON_EXTRACT_SCALAR(body, "$.properties.TransactionId") as package_transaction_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ErrorMessage") as error_message,
JSON_EXTRACT_SCALAR(device, "$.device_type") as os_type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_package_name") as app_pro_type
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-01' AND DATE(occurred) < CURRENT_DATE()



-- videos_tab_analytics_v1

SELECT a.date,COUNT(DISTINCT a.device_channel) as New_App_DAU,COUNT(DISTINCT b.device_channel) as Videos_Tab_Openers,COUNT(DISTINCT c.device_channel) as Video_Watchers,COUNT(DISTINCT d.device_channel) as ShareAndDownload_Users
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v2`
WHERE type = 'OPEN' AND app_version >= '6.8.0' AND app_version NOT LIKE '%debug%'
AND date >= '2019-03-01' AND date < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name = 'videostab_open'
AND date >= '2019-03-01' AND date < CURRENT_DATE()
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('videoplayer_playing')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('videoplayer_shareclicked','videoplayer_downloadclicked')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
GROUP BY 1 ORDER BY 1 DESC


## new app dau & video_tab DAU

SELECT a.date,COUNT(DISTINCT a.device_channel) as New_App_DAU,COUNT(DISTINCT CASE WHEN body_name = 'videostab_open' THEN b.device_channel END) as Videos_Tab_Openers,COUNT(DISTINCT CASE WHEN body_name = 'videoplayer_open' THEN b.device_channel END) as VideoPlayer_Openers
FROM (
SELECT DATE(occurred) as date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-03-01'
AND type = 'OPEN' 
AND app_version >= '6.8.0' AND app_version NOT LIKE '%debug%'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-03-01'
AND body_name IN ('videostab_open','videoplayer_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1 ORDER BY 1

## video watchers

SELECT DATE(occurred) as date,CASE WHEN body_name = 'videoplayer_playing' THEN 'playing' ELSE 'open' END AS play_type,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= "2019-03-06" AND body_name IN ('videoplayer_playing','videoplayer_open')
GROUP BY 1,2 ORDER BY 1

## time_spent
SELECT date,Round(SUM(Seconds)/3600,0) as Time_Spent_hrs from (
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
GROUP BY 1,2,3,4,5)) WHERE Next_Event = "videoplayer_exit")) GROUP BY 1 ORDER BY 1

sudo -iu jenkins

## time_spent per hour basis
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


## App Open retention for users who have opened Videos Tab on D0 
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2

## Video Tab Open retention for users who have opened Videos Tab on D0 
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.date,a.device_channel 
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN')
GROUP BY 1,2) a
JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2

## App Open retention for users who have NOT opened Videos Tab on D0
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
WHERE b.device_channel IS NULL
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2

## Video Tab Open retention for users who have NOT opened Videos Tab on D0
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT a.date,a.device_channel 
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
WHERE b.device_channel IS NULL
GROUP BY 1,2) a
LEFT JOIN (
SELECT a.date,a.device_channel 
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN')
GROUP BY 1,2) a
JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('videostab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2


## Video_Tab_Metrics
WITH A AS (
SELECT DATE(occurred) as date,COUNT(distinct device_channel) as New_App_DAU
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type = "OPEN" AND app_version >= "6.8.0" AND app_version NOT LIKE "%debug%"
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
GROUP BY 1),
B AS (
SELECT date,SUM(CASE WHEN body_name = "videostab_open" THEN users END) AS videostab_open,SUM(CASE WHEN body_name = "videoplayer_open" THEN users END) AS videoplayer_open 
FROM (
SELECT date,body_name,COUNT(DISTINCT device_channel) AS users 
FROM `analytics_data.ua_derived_data_v1` 
WHERE date = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY) 
AND LOWER(body_name) IN ("videostab_open","videoplayer_open") 
GROUP BY 1,2) GROUP BY 1),
C AS (
SELECT A.*,B.videostab_open,B.videoplayer_open FROM A JOIN B ON A.date = B.date), 
D AS (
SELECT date,ROUND(SUM(Seconds)/3600,0) as Time_Spent_hrs FROM (
SELECT *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, MILLISECOND)/1000 as Seconds from (
SELECT * FROM (
SELECT *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Time_Stamp,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Event
FROM (
SELECT DATE(occurred) as date,occurred,device_channel,body_name,session_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY)
AND LOWER(body_name) in ("videoplayer_open","videoplayer_exit")
GROUP BY 1,2,3,4,5 HAVING device_channel IS NOT NULL)) WHERE Next_Event = "videoplayer_exit")) GROUP BY 1)
SELECT C.*,D.Time_Spent_hrs FROM c JOIN d ON c.date = d.date


## Video_Tab_Metrics_Per_Hour
WITH per_hour_timespent AS (
SELECT date,EXTRACT(HOUR FROM occurred) as hour,Round(SUM(Seconds)/3600,2) as Time_Spent_hrs from (
SELECT *,TIMESTAMP_DIFF(Next_Time_Stamp, occurred, MILLISECOND)/1000 as Seconds from (
SELECT * FROM (
SELECT *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Time_Stamp,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS Next_Event
FROM (
SELECT DATE(occurred) as date,occurred ,device_channel,body_name,session_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY) --DATE(occurred) >= "2019-03-01" AND DATE(occurred) < CURRENT_DATE()
--AND device_channel = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
AND body_name IN ("videoplayer_open","videoplayer_exit")
GROUP BY 1,2,3,4,5)) WHERE Next_Event = "videoplayer_exit")) 
GROUP BY 1,2),
per_hour_videos_and_users AS (
SELECT date,hour,SUM(videos) as videos_watched,COUNT(DISTINCT device_channel) as users
FROM (
SELECT DATE(occurred) as date,EXTRACT(HOUR FROM occurred) as hour,device_channel,session_id,COUNT(DISTINCT video_id) as videos
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(),INTERVAL 1 DAY) --DATE(occurred) >= "2019-03-01" AND DATE(occurred) < CURRENT_DATE()
AND body_name IN ("videoplayer_playing")
GROUP BY 1,2,3,4)
GROUP BY 1,2)
SELECT a.*,b.videos_watched,b.users
FROM per_hour_timespent a
LEFT JOIN per_hour_videos_and_users b
ON a.date = b.date AND a.hour = b.hour 






-- pay_2_play_analytics_v1

# v4
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type = 'OPEN' AND app_version >= '7.0.0' AND app_version NOT LIKE '%debug%'
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gamelistingpageopen')
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) c
ON a.date = c.date AND a.device_channel = c.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) d
ON a.date = d.date AND a.device_channel = d.device_channel
GROUP BY 1 ORDER BY 1 DESC

-- ua_p2p_funnel
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type = 'OPEN' 
AND ((os_type = 'ANDROID' AND app_version >= '7.0.0' AND app_version NOT LIKE '%debug%') OR (os_type = 'IOS' AND app_version >= '6.7.0' AND app_version NOT LIKE '%debug%'))
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gamelistingpageopen')
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) c
ON a.date = c.date AND a.device_channel = c.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('pay2playgamepage_startedplaying')
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) d
ON a.date = d.date AND a.device_channel = d.device_channel
GROUP BY 1

-- ua_p2p_updated_funnel
## latest_version
WITH pay2play_updated AS (
SELECT DATE(occurred) as date,device_channel,type,body_name,os_type,app_version
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-04-05' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2,3,4,5,6)
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT c.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT d.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT e.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM pay2play_updated
WHERE type = 'OPEN' 
AND ((os_type = 'ANDROID' AND app_version >= '7.0.1' AND app_version NOT LIKE '%debug%') OR (os_type = 'IOS' AND app_version >= '6.7.0' AND app_version NOT LIKE '%debug%'))
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gamelistingpageopen')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) e
ON d.date = e.date AND d.device_channel = e.device_channel
GROUP BY 1 --ORDER BY 1

## v1
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT e.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT b.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type = 'OPEN' 
AND ((os_type = 'ANDROID' AND app_version >= '7.0.1' AND app_version NOT LIKE '%debug%') OR (os_type = 'IOS' AND app_version >= '6.7.0' AND app_version NOT LIKE '%debug%'))
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_open')
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2) e
ON a.date = e.date AND a.device_channel = e.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gamelistingpageopen')
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2) c
ON a.date = c.date AND a.device_channel = c.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('pay2playgamepage_startedplaying')
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2) d
ON a.date = d.date AND a.device_channel = d.device_channel
GROUP BY 1 ORDER BY 1

-- ua_p2p_contest_players
SELECT DATE(occurred) as date,contest_type,COUNT(DISTINCT device_channel) as contest_players,COUNT(DISTINCT contest_play_id) as contest_plays
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND body_name  = 'pay2playgamepage_startedplaying'
GROUP BY 1,2 ORDER BY 1 DESC,2,3 DESC

-- ua_p2p_contest_time
SELECT date,contest_type,ROUND(SUM(seconds)/3600,2) as time_spent_hrs_in_p2p_games
FROM (
SELECT *,TIMESTAMP_DIFF(occurred, prev_occurred, MILLISECOND)/1000 as seconds
FROM (
SELECT *,
LAG(occurred,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_occurred,
LAG(body_name,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_body_name
FROM (
SELECT DATE(occurred) as date,occurred,device_channel,session_id,body_name,contest_type,contest_id,contest_play_id,score,best_score,rank
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
--AND device_channel = 'aba08f42-c562-4ea3-8c09-2d366508f000'--'af0169a9-bcc2-4e77-a13e-28db0bec623f'
AND body_name IN ('pay2playgamepage_startedplaying','pay2playgamepage_finishedplaying')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11))
WHERE body_name = 'pay2playgamepage_finishedplaying' AND prev_body_name = 'pay2playgamepage_startedplaying')
GROUP BY 1,2




-- pay_2_play_analytics_v1_archived

# v3
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v2`
WHERE type = 'OPEN' AND app_version >= '7.0.0' AND app_version NOT LIKE '%debug%'
AND date >= '2019-03-30' AND date < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('allconteststab_open','allconteststab_gamelistingpageopen','allcontests_tab_open')
AND date >= '2019-03-30' AND date < CURRENT_DATE()
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) c
ON a.date = c.date AND a.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) d
ON a.date = d.date AND a.device_channel = d.device_channel
GROUP BY 1 ORDER BY 1 DESC

# v2
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v2`
WHERE type = 'OPEN' AND app_version >= '7.0.0' AND app_version NOT LIKE '%debug%'
AND date >= '2019-03-30' AND date < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) c
ON a.date = c.date AND a.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
GROUP BY 1 ORDER BY 1 DESC

# v1
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_AllcontestsTab,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v2`
WHERE type = 'OPEN' AND app_version >= '7.0.0' 
AND date >= '2019-03-30' AND date < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('allconteststab_open','allcontests_tab_open') --'allconteststab_gamelistingpageopen',
AND date >= '2019-03-01' AND date < CURRENT_DATE()
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_derived_data_v2`
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
GROUP BY 1 ORDER BY 1 DESC


-- ua_app_derived_data_v2
SELECT DATE(occurred) as date,type,JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-01' AND DATE(occurred) < CURRENT_DATE()
AND type IN  ('FIRST_OPEN','OPEN','UNINSTALL')
GROUP BY 1,2,3,4

-- derived_data.ua_derived_data_v2
SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,type,JSON_EXTRACT_SCALAR(body, "$.name") as body_name--,COUNT(DISTINCT ) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= '2019-03-28' AND DATE(occurred) < CURRENT_DATE()
AND type IN ('FIRST_OPEN','OPEN','CUSTOM','UNINSTALL')
GROUP BY 1,2,3,4






-- genral queries


SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(body, "$.properties.ContestType") as contest_type,JSON_EXTRACT_SCALAR(body, "$.properties.ContestId") as contest_id,COUNT(DISTINCT JSON_EXTRACT_SCALAR(device, "$.channel")) as contest_players,COUNT(DISTINCT JSON_EXTRACT_SCALAR(body, "$.properties.ContestPlayId")) as contest_plays
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-04-01'
AND JSON_EXTRACT_SCALAR(body, "$.name") = 'pay2playgamepage_startedplaying'
GROUP BY 1,2,3 ORDER BY 4 DESC


SELECT *
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-04-01'
AND JSON_EXTRACT_SCALAR(body, "$.name") = 'pay2playgamepage_startedplaying'
LIMIT 100



SELECT DATE(occurred) as date,contest_type,COUNT(DISTINCT device_channel) as contest_players,COUNT(DISTINCT contest_play_id) as contest_plays
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-03-30'
AND body_name  = 'pay2playgamepage_startedplaying'
GROUP BY 1,2 ORDER BY 3 DESC


SELECT date,contest_type,ROUND(SUM(seconds)/3600,2) as time_spent_hrs_in_p2p_games
FROM (
SELECT *,TIMESTAMP_DIFF(occurred, prev_occurred, MILLISECOND)/1000 as seconds
FROM (
SELECT *,
LAG(occurred,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_occurred,
LAG(body_name,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_body_name
FROM (
SELECT DATE(occurred) as date,occurred,device_channel,session_id,body_name,contest_type,contest_id,contest_play_id,score,best_score,rank
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND body_name IN ('pay2playgamepage_startedplaying','pay2playgamepage_finishedplaying')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11))
WHERE body_name = 'pay2playgamepage_finishedplaying' AND prev_body_name = 'pay2playgamepage_startedplaying')
GROUP BY 1,2


def bq_insert_urban_airship_derived_data_v3():
    session_insert_query = """
    INSERT INTO `swoo-analytics-bq.analytics_data.ua_derived_data_v3` (occurred, type, app_version, device_channel, user_id, app_type, body_name, session_id, game_type, game_id, video_id, position_of_video, contest_type, contest_state, no_of_games, contest_id, contest_reg_type, contest_entry_type, contest_reward_type, contest_play_id, score, best_score, rank, package_id, package_currency_paid, package_currency_earned, package_transaction_id, error_message, os_type) 
    SELECT occurred,type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version,
JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$.properties.UserId") as user_id,
JSON_EXTRACT_SCALAR(body, "$.properties.IsPro") as app_type,
JSON_EXTRACT_SCALAR(body, "$.name") as body_name,
JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,
JSON_EXTRACT_SCALAR(body, "$.properties.game_type") as game_type,
JSON_EXTRACT_SCALAR(body, "$.properties.game_id") as game_id,
JSON_EXTRACT_SCALAR(body, "$.properties.VideoId") as video_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Position") as position_of_video,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestType") as contest_type,
JSON_EXTRACT_SCALAR(body, "$.properties.GameState") as contest_state,
JSON_EXTRACT_SCALAR(body, "$.properties.NoOfGames") as no_of_games,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestId") as contest_id,
JSON_EXTRACT_SCALAR(body, "$.properties.RegistrationType") as contest_reg_type,
JSON_EXTRACT_SCALAR(body, "$.properties.EntryType") as contest_entry_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardType") as contest_reward_type,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestPlayId") as contest_play_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Score") as score,
JSON_EXTRACT_SCALAR(body, "$.properties.BestScore") as best_score,
JSON_EXTRACT_SCALAR(body, "$.properties.Rank") as rank,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageId") as package_id,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageCurrencyPaid") as package_currency_paid,
JSON_EXTRACT_SCALAR(body, "$.properties.CurrencyEarned") as package_currency_earned,
JSON_EXTRACT_SCALAR(body, "$.properties.TransactionId") as package_transaction_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ErrorMessage") as error_message,
JSON_EXTRACT_SCALAR(device, "$.device_type") as os_type
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)"""
    print(session_insert_query)
    res = bq_client.query(session_insert_query)
    print(res.result())

def bq_insert_ua_p2p_funnel():
    session_insert_query = """
    INSERT INTO `swoo-analytics-bq.analytics_data.ua_derived_data_v3` (date, Pay2Play_App_DAU, Pay2Play_GameLisitingUsers, Pay2Play_SuccesfulRegistrations, Pay2Play_GamePlayers) 
    SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT c.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT d.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type = 'OPEN' AND app_version >= '7.0.0' AND app_version NOT LIKE '%debug%'
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gamelistingpageopen')
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) c
ON a.date = c.date AND a.device_channel = c.device_channel
LEFT JOIN (
SELECT DATE(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('pay2playgamepage_startedplaying')
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
GROUP BY 1,2) d
ON a.date = d.date AND a.device_channel = d.device_channel
GROUP BY 1"""
    print(session_insert_query)
    res = bq_client.query(session_insert_query)
    print(res.result())


def bq_insert_ua_p2p_contest_players():
    session_insert_query = """
    INSERT INTO `swoo-analytics-bq.analytics_data.ua_derived_data_v3` (date, contest_type, contest_players, contest_plays) 
    SELECT DATE(occurred) as date,contest_type,COUNT(DISTINCT device_channel) as contest_players,COUNT(DISTINCT contest_play_id) as contest_plays
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND body_name  = 'pay2playgamepage_startedplaying'
GROUP BY 1,2"""
    print(session_insert_query)
    res = bq_client.query(session_insert_query)
    print(res.result())


def bq_insert_ua_p2p_contest_time():
    session_insert_query = """
    INSERT INTO `swoo-analytics-bq.analytics_data.ua_derived_data_v3` (date, contest_type, time_spent_hrs_in_p2p_games) 
    SELECT date,contest_type,ROUND(SUM(seconds)/3600,2) as time_spent_hrs_in_p2p_games
FROM (
SELECT *,TIMESTAMP_DIFF(occurred, prev_occurred, MILLISECOND)/1000 as seconds
FROM (
SELECT *,
LAG(occurred,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_occurred,
LAG(body_name,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_body_name
FROM (
SELECT DATE(occurred) as date,occurred,device_channel,session_id,body_name,contest_type,contest_id,contest_play_id,score,best_score,rank
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND body_name IN ('pay2playgamepage_startedplaying','pay2playgamepage_finishedplaying')
GROUP BY 1,2,3,4,5,6,7,8,9,10,11))
WHERE body_name = 'pay2playgamepage_finishedplaying' AND prev_body_name = 'pay2playgamepage_startedplaying')
GROUP BY 1,2"""
    print(session_insert_query)
    res = bq_client.query(session_insert_query)
    print(res.result())



## april fools day campaign

#v2
SELECT b.user_id,b.handle as user_handle,b.device_channel,a.Phone_Number 
FROM (
SELECT Swoo_ID,Phone_Number
FROM `swoo-analytics-bq.derived_data.april_fools_day_campaign_resposnses`
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,user_id,handle
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY handle ORDER BY created DESC) AS rank 
FROM (
SELECT a.device_channel,a.user_id,a.created,b.handle
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) b
ON a.user_id = b.id
GROUP BY 1,2,3,4
HAVING b.handle IS NOT NULL)))
WHERE rank = 1
GROUP BY 1,2,3) b
ON a.Swoo_ID = b.handle
GROUP BY 1,2,3,4
HAVING b.device_channel IS NOT NULL

#v1
SELECT a.id as user_id,a.Swoo_ID as user_handle,b.device_channel,a.Phone_Number 
FROM (
SELECT b.id,a.Swoo_ID,a.Phone_Number 
FROM (
SELECT Swoo_ID,Phone_Number
FROM `swoo-analytics-bq.derived_data.april_fools_day_campaign_resposnses`
GROUP BY 1,2) a
JOIN (
SELECT id,handle
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2) b
ON a.Swoo_ID = b.handle
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT device_channel,user_id
FROM (
SELECT * FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY user_id ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3)))
WHERE rank = 1
GROUP BY 1,2) b
ON a.id = b.user_id
GROUP BY 1,2,3,4
HAVING b.device_channel IS NOT NULL


## App_components_of_WAU (day_wise)
WITH app_derived_data AS (
SELECT date,device_channel,type
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3),
wau AS (
SELECT Date,WAU
FROM `swoo-analytics-bq.daily_dashboard.App_DAU_WAU_MAU`
--WHERE Date = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY)
GROUP BY 1,2),
last_week_users AS (
SELECT a.date as Date,COUNT(DISTINCT a.device_channel) as LastWeekUsers
FROM (
SELECT b.date as Date,device_channel
FROM (
SELECT date,device_channel
FROM app_derived_data
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
FROM app_derived_data
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1),
new_users AS (
SELECT b.date as Date,COUNT(DISTINCT device_channel) as NewUsers
FROM (
SELECT date,device_channel
FROM app_derived_data
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1)
SELECT a.Date,ROUND(a.WAU/7,0) as WAU,ROUND(b.LastWeekUsers/7,0) as LastWeekUsers,ROUND(c.NewUsers/7,0) as NewUsers,ROUND((a.WAU-(b.LastWeekUsers+c.NewUsers))/7,0) as ReactivatedUsers
FROM wau a
LEFT JOIN last_week_users b ON a.Date = b.Date
LEFT JOIN new_users c ON a.Date = c.Date
GROUP BY 1,2,3,4,5
ORDER BY 1



SELECT DATE(occurred) AS date,body_name,EXTRACT(HOUR FROM DATETIME(occurred, "Asia/Kolkata")) AS hour,COUNT(DISTINCT(device_channel)) AS users
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-03-25' AND DATE(occurred) <= '2019-04-07'
AND body_name = "trivia_started_playing"
GROUP BY 1,2,3
ORDER BY 1,3


-- p2p app install retention
SELECT Date,app_version,(D1/D0) as D1,(D7/D0) as D7,(D14/D0) as D14,(D30/D0) as D30
FROM (
SELECT Date,app_version,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,a.app_version,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT device_channel,CASE WHEN app_version >= '7.0.0' AND os_type = 'ANDROID' THEN 'p2p_app'
WHEN app_version >= '6.7.0' AND os_type = 'IOS' THEN 'p2p_app'
ELSE 'non_p2p_app' END AS app_version,MIN(date) as date
FROM (
SELECT a.date,a.os_type,a.device_channel,CASE WHEN a.app_version IS NULL THEN b.app_version ELSE a.app_version END AS app_version
FROM (
SELECT date(occurred) as date,os_type,app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND type = 'FIRST_OPEN'
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT date(occurred) as date,os_type,app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND type = 'CUSTOM'
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.os_type = b.os_type
GROUP BY 1,2,3,4
HAVING app_version IS NOT NULL)
WHERE app_version NOT LIKE '%debug%'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,CASE WHEN app_version >= '7.0.0' AND os_type = 'ANDROID' THEN 'p2p_app'
WHEN app_version >= '6.7.0' AND os_type = 'IOS' THEN 'p2p_app'
ELSE 'non_p2p_app' END AS app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN') 
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2,3)
WHERE Retention != 'NA'
GROUP BY 1,2)
GROUP BY 1,2,3,4,5,6


#### p2p_funnel_7_1_0
## funnel
WITH pay2play_updated AS (
SELECT DATE(occurred) as date,device_channel,type,body_name,os_type,app_version
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-04-17' AND DATE(occurred) < CURRENT_DATE()
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3,4,5,6)
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT c.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT d.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT e.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM pay2play_updated
WHERE type = 'OPEN' 
--AND ((os_type = 'ANDROID' AND app_version >= '7.1.0' AND app_version NOT LIKE '%debug%') OR (os_type = 'IOS' AND app_version >= '6.7.0' AND app_version NOT LIKE '%debug%'))
AND (os_type = 'ANDROID' AND app_version >= '7.1.0')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gamelistingpageopen')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) e
ON d.date = e.date AND d.device_channel = e.device_channel
GROUP BY 1 --ORDER BY 1
#######################
## funnel_NOTOpen_LG_VP
WITH pay2play_updated AS (
SELECT DATE(occurred) as date,device_channel,type,body_name,os_type,app_version
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-04-17' AND DATE(occurred) < CURRENT_DATE()
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3,4,5,6)
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b0.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT b.device_channel) as Pay2Play_ContestsPageOpeners_WhoDidNOTOpenLiveGamesORVideosPage,COUNT(DISTINCT c.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT d.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT e.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM pay2play_updated
WHERE type = 'OPEN' 
--AND ((os_type = 'ANDROID' AND app_version >= '7.1.0' AND app_version NOT LIKE '%debug%') OR (os_type = 'IOS' AND app_version >= '6.7.0' AND app_version NOT LIKE '%debug%'))
AND (os_type = 'ANDROID' AND app_version >= '7.1.0')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) b0
ON a.date = b0.date AND a.device_channel = b0.device_channel
LEFT JOIN (
SELECT x.date,x.device_channel
FROM (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) x
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('livegamestab_open','videostab_open')
GROUP BY 1,2) y
ON x.date = y.date AND x.device_channel = y.device_channel
WHERE y.device_channel IS NULL
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gamelistingpageopen')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) e
ON d.date = e.date AND d.device_channel = e.device_channel
GROUP BY 1 --ORDER BY 1


#### referral fraud detection raw data code
SELECT a.*,b.*,c.*
FROM (
SELECT created as referral_applied,referee_id,referrer_id,referral_code,updated,referee_activity_count
FROM `swoo-analytics-bq.swoo_gaming_service.campaign_user_progress`
WHERE status IN ('REWARD_INPROGRESS','REWARDED') --AND referrer_id = 7331836
AND DATE(created) >= '2019-04-17') a
#user mapping
LEFT JOIN (
SELECT created,id as user_id,handle,name,full_name,email,phone,reg_status,user_status,is_tester,country,city,country_code,region_id
FROM `swoo-analytics-bq.backend_tables.user`) b
ON DATE(a.referral_applied) = DATE(b.created) AND a.referee_id = b.user_id
#user_device mapping
LEFT JOIN (
SELECT user_id as uid,created as device_channel_created,device_id,ua_notification_token as device_channel
FROM `swoo-analytics-bq.backend_tables.user_device`) c
ON a.referee_id = c.uid
#ORDER BY created


#### ua_p2p_new_user_funnel
WITH pay2play_updated AS (
SELECT DATE(occurred) as date,device_channel,type,body_name,os_type,app_version
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-04-17' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
--AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3,4,5,6)
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT c.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT d.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT e.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT date,device_channel
FROM (
SELECT a.date,a.device_channel,CASE WHEN a.app_version IS NULL THEN b.app_version ELSE a.app_version END AS app_version
FROM (
SELECT date,device_channel,app_version
FROM pay2play_updated
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT date,device_channel,app_version
FROM pay2play_updated
WHERE type = 'OPEN' AND app_version IS NOT NULL
GROUP BY 1,2,3) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2,3)
WHERE app_version >= '7.1.0') a
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gamelistingpageopen')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) e
ON d.date = e.date AND d.device_channel = e.device_channel
GROUP BY 1 ORDER BY 1



SELECT body_name,next_body_name,COUNT(DISTINCT occurred) as events_occured
FROM (
SELECT *,
LEAD(occurred,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS next_occurred,
LEAD(body_name,1) OVER (PARTITION BY date,device_channel,session_id ORDER BY occurred) AS next_body_name
FROM (
SELECT DATE(occurred)as date,occurred,device_channel,session_id,CASE WHEN type = 'CUSTOM' THEN body_name ELSE type END AS body_name
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = "2019-04-24" AND type = 'CUSTOM'
--AND device_channel = "6dacddab-5e28-4f67-89ba-a2e8bc6f9782"
GROUP BY 1,2,3,4,5))
WHERE body_name = 'allconteststab_open' AND next_body_name IS NOT NULL
GROUP BY 1,2



#### reactivated_users ##################################################
##### Raw Data
WITH raw_data AS (
SELECT a.date as a_date,b.date as b_date,device_channel,type
FROM (
SELECT date,device_channel,type
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
GROUP BY 1,2,3,4), 
##### WAU
wau_data AS (
SELECT b_date as Date,device_channel
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 6 DAY) AND a_date <= b_date
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2), 
##### LastWeekUsers
lwu_data AS (
SELECT a.Date,a.device_channel --COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT b_date as Date,device_channel
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 6 DAY) AND a_date <= b_date
AND type IN ('OPEN')
GROUP BY 1,2) a
JOIN (
SELECT b_date as Date,device_channel
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 13 DAY) AND a_date <= DATE_SUB(b_date, INTERVAL 7 DAY)
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
GROUP BY 1,2), 
##### NewUsers
nu_data AS (
SELECT b_date as Date,device_channel --COUNT(DISTINCT a.device_channel) as users
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 6 DAY) AND a_date <= b_date
AND type IN ('FIRST_OPEN')
GROUP BY 1,2),
##### ReactivatedUsers
reactivated_users AS (
SELECT a.Date,a.device_channel --COUNT(DISTINCT a.device_channel) as Reactivated_Users
FROM wau_data a
LEFT JOIN lwu_data b
ON a.Date = b.Date AND a.device_channel = b.device_channel
LEFT JOIN nu_data c
ON a.Date = c.Date AND a.device_channel = c.device_channel
WHERE b.device_channel IS NULL AND c.device_channel IS NULL
AND a.Date >= '2019-04-17' AND a.Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
--AND a.Date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2),
#### pay2play_funnel ##################################################
##### Raw Data
pay2play_updated AS (
SELECT b.date,device_channel,type,body_name,os_type,app_version
FROM (
SELECT DATE(occurred) as date,device_channel,type,body_name,os_type,app_version
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-04-10' AND DATE(occurred) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
--DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND DATE(occurred) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3,4,5,6) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-04-17' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
--date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2,3,4,5,6)
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT c.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT d.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT e.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT a.date,a.device_channel
FROM (
SELECT Date as date,device_channel
FROM reactivated_users) a
JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE type = 'OPEN' AND (os_type = 'ANDROID' AND app_version >= '7.1.0') --7.0.0
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gamelistingpageopen')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) e
ON d.date = e.date AND d.device_channel = e.device_channel
GROUP BY 1
ORDER BY 1


-- for daily_dashboard
#### reactivated_users ##################################################
##### Raw Data
WITH raw_data AS (
SELECT a.date as a_date,b.date as b_date,device_channel,type
FROM (
SELECT date,device_channel,type
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
GROUP BY 1,2,3,4), 
##### WAU
wau_data AS (
SELECT b_date as Date,device_channel
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 6 DAY) AND a_date <= b_date
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2), 
##### LastWeekUsers
lwu_data AS (
SELECT a.Date,a.device_channel --COUNT(DISTINCT a.device_channel) as users
FROM (
SELECT b_date as Date,device_channel
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 6 DAY) AND a_date <= b_date
AND type IN ('OPEN')
GROUP BY 1,2) a
JOIN (
SELECT b_date as Date,device_channel
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 13 DAY) AND a_date <= DATE_SUB(b_date, INTERVAL 7 DAY)
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
GROUP BY 1,2), 
##### NewUsers
nu_data AS (
SELECT b_date as Date,device_channel --COUNT(DISTINCT a.device_channel) as users
FROM raw_data
WHERE a_date >= DATE_SUB(b_date, INTERVAL 6 DAY) AND a_date <= b_date
AND type IN ('FIRST_OPEN')
GROUP BY 1,2),
##### ReactivatedUsers
reactivated_users AS (
SELECT a.Date,a.device_channel --COUNT(DISTINCT a.device_channel) as Reactivated_Users
FROM wau_data a
LEFT JOIN lwu_data b
ON a.Date = b.Date AND a.device_channel = b.device_channel
LEFT JOIN nu_data c
ON a.Date = c.Date AND a.device_channel = c.device_channel
WHERE b.device_channel IS NULL AND c.device_channel IS NULL
AND --a.Date >= '2019-04-17' AND a.Date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
a.Date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2),
#### pay2play_funnel ##################################################
##### Raw Data
pay2play_updated AS (
SELECT b.date,device_channel,type,body_name,os_type,app_version
FROM (
SELECT DATE(occurred) as date,device_channel,type,body_name,os_type,app_version
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE --DATE(occurred) >= '2019-04-10' AND DATE(occurred) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AND DATE(occurred) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3,4,5,6) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE --date >= '2019-04-17' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2,3,4,5,6)
SELECT a.date,COUNT(DISTINCT a.device_channel) as Pay2Play_App_DAU,COUNT(DISTINCT b.device_channel) as Pay2Play_ContestsPageOpeners,COUNT(DISTINCT c.device_channel) as Pay2Play_GameLisitingUsers,COUNT(DISTINCT d.device_channel) as Pay2Play_SuccesfulRegistrations,COUNT(DISTINCT e.device_channel) as Pay2Play_GamePlayers
FROM (
SELECT a.date,a.device_channel
FROM (
SELECT Date as date,device_channel
FROM reactivated_users) a
JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE type = 'OPEN' AND (os_type = 'ANDROID' AND app_version >= '7.1.0')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_open')
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gamelistingpageopen')
GROUP BY 1,2) c
ON b.date = c.date AND b.device_channel = c.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
GROUP BY 1,2) d
ON c.date = d.date AND c.device_channel = d.device_channel
LEFT JOIN (
SELECT date,device_channel
FROM pay2play_updated
WHERE body_name IN ('pay2playgamepage_startedplaying')
GROUP BY 1,2) e
ON d.date = e.date AND d.device_channel = e.device_channel
GROUP BY 1



SELECT DATE(occurred) as date,device_channel,contest_type,contest_id,best_score
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = '2019-05-02' AND body_name = 'pay2playgamepage_finishedplaying'
AND best_score > '1,000,000'
GROUP BY 1,2,3,4,5
ORDER BY 5 DESC


SELECT DATE(createDateTime) as date,USER_PAYMENT_GATEWAY_ID as paytm_number,COUNT(DISTINCT USER_ID) as no_of_user_accounts_used_for_cashout,SUM(TRANSACTION_AMOUNT) as cashout_amount
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS' AND USER_ID NOT IN (5181193,6137229,4887396,3206745) AND CURRENCY_CODE = 'INR'
AND TRANSACTION_TYPE = 'DEBIT'
AND DATE(createDateTime) >= '2019-04-17'
GROUP BY 1,2 HAVING no_of_user_accounts_used_for_cashout >= 2
ORDER BY 3 DESC,2 ASC


SELECT createDateTime,CURRENCY_CODE,IS_MOBILE,PAYMENT_GATEWAY_TRANSACTION_ID
,PAYMENT_METHOD,USER_PAYMENT_GATEWAY_ID,STATUS,TRANSACTION_AMOUNT,TRANSACTION_TYPE,USER_ID,TRANSACTION_SOURCE,REQUEST_ID,DESCRIPTION,CONVERSION_RATE
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS' --AND DATE(createDateTime) = '2019-05-02'
AND TRANSACTION_TYPE = 'DEBIT'--'CREDIT'
--AND USER_ID = 7820788
--AND PAYMENT_GATEWAY_TRANSACTION_ID LIKE '%-10001-%'
AND USER_PAYMENT_GATEWAY_ID = '9952981481'
ORDER BY createDateTime




SELECT date,contest_type,AVG(DISTINCT avg_score_per_second) as avg_score_per_second
FROM (
SELECT date,device_channel,contest_type,contest_id,AVG(DISTINCT (score/seconds)) as avg_score_per_second
FROM (
SELECT date,device_channel,contest_type,contest_id,CAST(REPLACE(REPLACE(score, ",", ""),"--","") AS FLOAT64) as score,(TIMESTAMP_DIFF(occurred, prev_occurred, MILLISECOND)/1000) as seconds
FROM (
SELECT *,
LAG(occurred,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_occurred,
LAG(body_name,1) OVER (PARTITION BY date,device_channel,contest_type,contest_id ORDER BY occurred) AS prev_body_name
FROM (
SELECT DATE(occurred) as date,occurred,device_channel,contest_type,contest_id,body_name,score
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = '2019-05-02' --DATE(occurred) >= '2019-04-22' AND DATE(occurred) <= '2019-05-02'
AND type = 'CUSTOM'
--AND body_name IN ('pay2playgamepage_startedplaying','pay2playgamepage_finishedplaying')
--AND score IS NOT NULL
--AND device_channel = '00160d59-3722-456e-8d0c-0c02ed7965d8'
GROUP BY 1,2,3,4,5,6,7))
WHERE body_name = 'pay2playgamepage_finishedplaying' AND prev_body_name = 'pay2playgamepage_startedplaying')
WHERE score < 1000000
GROUP BY 1,2,3,4)
GROUP BY 1,2



REPLACE(score, ",", "")
REPLACE(REPLACE(REPLACE(score, ",", ""),"--",""),"\","")
SELECT REGEXP_REPLACE("1,000,000", r',', '') AS Output



SELECT DATE(createDateTime) as date,USER_PAYMENT_GATEWAY_ID as paytm_number,COUNT(DISTINCT USER_ID) as no_of_user_accounts_used_for_cashout,SUM(TRANSACTION_AMOUNT) as cashout_amount
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS' AND USER_ID NOT IN (5181193,6137229,4887396,3206745) AND CURRENCY_CODE = 'INR'
AND TRANSACTION_TYPE = 'DEBIT'
AND DATE(createDateTime) >= '2019-04-17'
GROUP BY 1,2 HAVING no_of_user_accounts_used_for_cashout >= 2
ORDER BY 3 DESC,2 ASC


SELECT createDateTime,CURRENCY_CODE,IS_MOBILE,PAYMENT_GATEWAY_TRANSACTION_ID
,PAYMENT_METHOD,USER_PAYMENT_GATEWAY_ID,STATUS,TRANSACTION_AMOUNT,TRANSACTION_TYPE,USER_ID,TRANSACTION_SOURCE,REQUEST_ID,DESCRIPTION,CONVERSION_RATE
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS' --AND DATE(createDateTime) = '2019-05-02'
AND TRANSACTION_TYPE = 'DEBIT'--'CREDIT'
--AND USER_ID = 7820788
--AND PAYMENT_GATEWAY_TRANSACTION_ID LIKE '%-10001-%'
AND USER_PAYMENT_GATEWAY_ID = '8606435558'
ORDER BY createDateTime


SELECT contest_reg_type
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = "2019-05-05" 
AND type = 'CUSTOM'
AND body_name = 'allconteststab_gameregistrationsuccessful'
GROUP BY 1


SELECT contest_entry_type   
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = "2019-05-05" 
AND type = 'CUSTOM'
AND body_name = 'allconteststab_gameregistrationclicked'
GROUP BY 1


SELECT *
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = "2019-05-05" 
AND type = 'CUSTOM'
AND body LIKE '%allconteststab_gameregistrationclicked%'
LIMIT 100



SELECT created as referral_applied,referee_id,referrer_id,referral_code,updated,referee_activity_count
FROM `swoo-analytics-bq.swoo_gaming_service.campaign_user_progress`
WHERE status IN ('REWARD_INPROGRESS','REWARDED') --AND referrer_id = 7331836
AND DATE(created) >= '2019-04-17'




SELECT DATE(occurred) as date,JSON_EXTRACT_SCALAR(body, "$.properties.RewardUnit") as RewardUnit,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardType") as RewardType,COUNT(DISTINCT JSON_EXTRACT_SCALAR(device, "$.channel")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw`  
WHERE DATE(occurred) >= "2019-04-29" 
AND JSON_EXTRACT_SCALAR(body, "$.name") = 'pay2playgamepage_dailyrewardredeemed'
GROUP BY 1,2,3


SELECT DATE(occurred) as date,COUNT(DISTINCT JSON_EXTRACT_SCALAR(device, "$.channel")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw`  
WHERE DATE(occurred) = "2019-05-05" 
AND JSON_EXTRACT_SCALAR(body, "$.name") = 'pay2playgamepage_dailyrewardredeemed'
GROUP BY 1



SELECT DATE(occurred) as date,contest_type,contest_id, COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = "2019-05-05" 
AND body_name = 'allconteststab_gameregistrationsuccessful'
GROUP BY 1,2,3


SELECT a.Date as date,b.device_channel 
FROM (
SELECT DATE(created) as Date, referee_id
FROM `swoo-analytics-bq.swoo_gaming_service.campaign_user_progress` 
WHERE status IN ("NOT_REWARDED","REWARD_INPROGRESS") 
AND DATE(created) < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,user_id 
FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY user_id ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3))
WHERE rank = 1
GROUP BY 1,2) b
ON a.referee_id = b.user_id 
GROUP BY 1,2


-- Daily referrals happening
SELECT DATE(created) as Date, 
COUNT(DISTINCT CASE WHEN status = "REWARD_INPROGRESS" THEN referee_id END) AS successful_referal_bonus_given,
COUNT(DISTINCT CASE WHEN status = "NOT_REWARDED" THEN referee_id END)  AS successful_referal_bonus_notgiven,
COUNT(DISTINCT CASE WHEN status IN ("NOT_REWARDED","REWARD_INPROGRESS") THEN referee_id END) AS total_successful_referal
FROM `swoo-analytics-bq.swoo_gaming_service.campaign_user_progress` 
WHERE DATE(created) < CURRENT_DATE()
GROUP BY 1 ORDER BY 1


-- Referral retention data
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
SELECT a.Date as date,b.device_channel 
FROM (
SELECT DATE(created) as Date, referee_id
FROM `swoo-analytics-bq.swoo_gaming_service.campaign_user_progress` 
WHERE status IN ("NOT_REWARDED","REWARD_INPROGRESS") 
AND DATE(created) < CURRENT_DATE()
GROUP BY 1,2) a
LEFT JOIN (
SELECT device_channel,user_id 
FROM (
SELECT *,DENSE_RANK() OVER(PARTITION BY user_id ORDER BY created DESC) AS rank 
FROM (
SELECT ua_notification_token as device_channel,user_id,created
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2,3))
WHERE rank = 1
GROUP BY 1,2) b
ON a.referee_id = b.user_id 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` --Daily_Referral_Retention_Data
WHERE type IN ('OPEN') 
AND date >= '2019-04-17' AND date < CURRENT_DATE()
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA' AND Date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1)
GROUP BY 1,2,3,4,5



def upload_blob(bucket_name, source_file_name, destination_blob_name):
    """Uploads a file to the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_name)
    print('File {} uploaded to {}.'.format(source_file_name,destination_blob_name))


WITH pro_app_data AS (
SELECT occurred,device_channel,type,body_name,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
GROUP BY 1,2,3,4,5) 
SELECT DATE(occurred) as date,
COUNT(DISTINCT CASE WHEN type = 'OPEN' THEN device_channel END) as pro_app_dau,
COUNT(DISTINCT CASE WHEN type = 'FIRST_OPEN' THEN device_channel END) as pro_app_new_installs,
COUNT(DISTINCT CASE WHEN body_name = 'pay2playgamepage_startedplaying' THEN device_channel END) as pro_app_contest_players,
COUNT(DISTINCT CASE WHEN body_name = 'p2pmarketplace_marketplacetransactionsuccess' THEN device_channel END) as pro_app_succesful_transacted_users,
COUNT(DISTINCT CASE WHEN body_name = 'p2pmarketplace_marketplacetransactionsuccess' THEN package_transaction_id END) as pro_app_succesful_transactions
FROM pro_app_data
GROUP BY 1


SELECT occurred,type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_version") as app_version,
JSON_EXTRACT_SCALAR(device, "$.channel") as device_channel,
JSON_EXTRACT_SCALAR(body, "$.properties.UserId") as user_id,
JSON_EXTRACT_SCALAR(body, "$.properties.IsPro") as app_type,
JSON_EXTRACT_SCALAR(body, "$.name") as body_name,
JSON_EXTRACT_SCALAR(body, "$.session_id") as session_id,
JSON_EXTRACT_SCALAR(body, "$.properties.game_type") as game_type,
JSON_EXTRACT_SCALAR(body, "$.properties.game_id") as game_id,
JSON_EXTRACT_SCALAR(body, "$.properties.VideoId") as video_id,
JSON_EXTRACT_SCALAR(body, "$.properties.Position") as position_of_video,
JSON_EXTRACT_SCALAR(body, "$.properties.Quarantile") as video_quartile,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestType") as contest_type,
JSON_EXTRACT_SCALAR(body, "$.properties.GameState") as contest_state,
JSON_EXTRACT_SCALAR(body, "$.properties.NoOfGames") as no_of_games,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestId") as contest_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ContestPlayId") as contest_play_id,
JSON_EXTRACT_SCALAR(body, "$.properties.RegistrationType") as contest_registration_type,
JSON_EXTRACT_SCALAR(body, "$.properties.EntryType") as contest_entry_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardType") as contest_daily_reward_type,
JSON_EXTRACT_SCALAR(body, "$.properties.RewardUnit") as daily_reward_unit,
JSON_EXTRACT_SCALAR(body, "$.properties.Score") as score,
JSON_EXTRACT_SCALAR(body, "$.properties.BestScore") as best_score,
JSON_EXTRACT_SCALAR(body, "$.properties.Rank") as rank,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageId") as package_id,
JSON_EXTRACT_SCALAR(body, "$.properties.PackageCurrencyPaid") as package_currency_paid,
JSON_EXTRACT_SCALAR(body, "$.properties.CurrencyEarned") as package_currency_earned,
JSON_EXTRACT_SCALAR(body, "$.properties.TransactionId") as package_transaction_id,
JSON_EXTRACT_SCALAR(body, "$.properties.ErrorMessage") as error_message,
JSON_EXTRACT_SCALAR(device, "$.device_type") as os_type,
JSON_EXTRACT_SCALAR(device, "$.attributes.app_package_name") as app_pro_type
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) >= DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY) AND DATE(occurred) < CURRENT_DATE()
AND JSON_EXTRACT_SCALAR(device, "$.attributes.app_package_name") =  "com.kryptolabs.android.speakerswire.pro"



SELECT COUNT(DISTINCT device_channel)
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`  
WHERE DATE(occurred) = '2019-05-09' AND type = 'OPEN'
AND app_pro_type  =  "com.kryptolabs.android.speakerswire.pro"



WITH pro_app_data AS (
SELECT occurred,device_channel,type,body_name,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
GROUP BY 1,2,3,4,5) 
SELECT DATE(occurred) as date,
COUNT(DISTINCT CASE WHEN type = 'OPEN' THEN device_channel END) as pro_app_dau,
COUNT(DISTINCT CASE WHEN type = 'FIRST_OPEN' THEN device_channel END) as pro_app_new_installs,
COUNT(DISTINCT CASE WHEN body_name = 'pay2playgamepage_startedplaying' THEN device_channel END) as pro_app_contest_players,
COUNT(DISTINCT CASE WHEN body_name = 'p2pmarketplace_marketplacetransactionsuccess' THEN device_channel END) as pro_app_succesful_transacted_users,
COUNT(DISTINCT CASE WHEN body_name = 'p2pmarketplace_marketplacetransactionsuccess' THEN package_transaction_id END) as pro_app_succesful_transactions
FROM pro_app_data
GROUP BY 1



SELECT * 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = '2019-05-08' AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
ORDER BY occurred 


WITH pro_app_data AS (
SELECT occurred,device_channel,type,body_name 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE()
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
GROUP BY 1,2,3,4) 
SELECT DATE(occurred) as date,
COUNT(DISTINCT CASE WHEN type = 'OPEN' THEN device_channel END) as pro_app_dau,
COUNT(DISTINCT CASE WHEN type = 'FIRST_OPEN' THEN device_channel END) as pro_app_new_installs,
COUNT(DISTINCT CASE WHEN body_name = 'pay2playgamepage_startedplaying' THEN device_channel END) as pro_app_contest_players,
COUNT(DISTINCT CASE WHEN body_name = 'p2pmarketplace_marketplacetransactionsuccess' THEN device_channel END) as pro_app_succesful_transactions
FROM pro_app_data
GROUP BY 1


SELECT a.USER_ID,b.*
FROM (
SELECT USER_ID
FROM (
SELECT createDateTime,CURRENCY_CODE,IS_MOBILE,PAYMENT_GATEWAY_TRANSACTION_ID
,PAYMENT_METHOD,USER_PAYMENT_GATEWAY_ID,STATUS,TRANSACTION_AMOUNT,TRANSACTION_TYPE,USER_ID,TRANSACTION_SOURCE,REQUEST_ID,DESCRIPTION,CONVERSION_RATE
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS' --AND DATE(createDateTime) = '2019-05-09'
AND TRANSACTION_TYPE = 'DEBIT'--'CREDIT'
--AND USER_ID = 7820788
--AND PAYMENT_GATEWAY_TRANSACTION_ID LIKE '%-10001-%'
--AND USER_PAYMENT_GATEWAY_ID IN ('7416744327','7842346590','8886789543','9290484817') #neelus's phone numbers
AND USER_PAYMENT_GATEWAY_ID IN ('8309866176','8074277832','8309020342','9948526606') 
--AND TRANSACTION_AMOUNT = 130.00
ORDER BY createDateTime)
GROUP BY 1) a
LEFT JOIN (
SELECT id,handle,name,full_name,email
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) b
ON a.USER_ID = b.id


SELECT DATE(createDateTime) as date,USER_PAYMENT_GATEWAY_ID as paytm_number,USER_ID as user_id,SUM(TRANSACTION_AMOUNT) as cash_out_amount
FROM `swoo-analytics-bq.swoo_wallet.WALLET_TRANSACTION`
WHERE STATUS = 'SUCCESS' 
AND TRANSACTION_TYPE = 'DEBIT'
GROUP BY 1,2,3
HAVING cash_out_amount > 10000.00
ORDER BY 4 DESC --LIMIT 100



def create_table_using_gcs_csv(dataset_id, uri, table_ref):
    client = bigquery.Client()
    dataset_ref = client.dataset(dataset_id)
    job_config = bigquery.LoadJobConfig()
    job_config.autodetect = True
    job_config.skip_leading_rows = 1
    # The source format defaults to CSV, so the line below is optional.
    job_config.source_format = bigquery.SourceFormat.CSV
    uri = uri
    load_job = client.load_table_from_uri(uri, dataset_ref.table(table_ref), job_config=job_config) # API request
    print("Starting job {}".format(load_job.job_id))
    load_job.result()  # Waits for table load to complete.
    print("Job finished.")
    destination_table = client.get_table(dataset_ref.table(table_ref))
    print("Loaded {} rows.".format(destination_table.num_rows))


def upload_blob(bucket_name, source_file_name, destination_blob_name):
    """Uploads a file to the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_name)
    print('File {} uploaded to {}.'.format(source_file_name,destination_blob_name))


SELECT Date,(D45/D0) as D45,(D60/D0) as D60,(D90/D0) as D90,(D120/D0) as D120
FROM (
SELECT Date,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D45',Users,NULL)) as D45,MAX(IF(Retention = 'D60',Users,NULL)) as D60,MAX(IF(Retention = 'D90',Users,NULL)) as D90,MAX(IF(Retention = 'D120',Users,NULL)) as D120
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 45 DAY) THEN 'D45'
WHEN b.date = DATE_ADD(a.date,INTERVAL 60 DAY) THEN 'D60'
WHEN b.date = DATE_ADD(a.date,INTERVAL 90 DAY) THEN 'D90'
WHEN b.date = DATE_ADD(a.date,INTERVAL 120 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN')
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
GROUP BY 1,2,3,4,5
ORDER BY 1


SELECT date,package_type,COUNT(DISTINCT device_channel) as users,COUNT(DISTINCT package_transaction_id) as transactions,(COUNT(DISTINCT package_transaction_id)*package_type) as package_type_transaction_value
FROM (
SELECT DATE(occurred) as date,device_channel,CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 10 
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 20
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 50
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 100 ELSE 0 END AS package_type,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-06' 
AND app_pro_type = "com.kryptolabs.android.speakerswire.pro"
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3,4)
GROUP BY 1,2


WITH swoo_plus_transactions_data AS (
SELECT DATE(occurred) as date,device_channel,CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 10 
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 20
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 50
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 100 ELSE 0 END AS package_amount,
CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 'INR 10'
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 'INR 20'
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 'INR 50'
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 'INR 100' ELSE 'Other' END AS package_type,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-06' 
AND app_pro_type = "com.kryptolabs.android.speakerswire.pro"
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3,4,5)
SELECT date,package_type,users,transactions,(transactions*package_amount) as package_type_transaction_value
FROM (
SELECT date,package_type,package_amount,COUNT(DISTINCT device_channel) as users,COUNT(DISTINCT package_transaction_id) as transactions
FROM swoo_plus_transactions_data
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5


WITH swoo_plus_transactions_data AS (
SELECT DATE(occurred) as date,device_channel,CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 10 
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 20
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 50
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 100 ELSE 0 END AS package_amount,
CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 'INR 10'
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 'INR 20'
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 'INR 50'
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 'INR 100' ELSE 'Other' END AS package_type,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-05-06' 
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3,4,5)
SELECT date,package_type,users,transactions,(transactions*package_amount) as package_type_transaction_value
FROM (
SELECT date,package_type,package_amount,COUNT(DISTINCT device_channel) as users,COUNT(DISTINCT package_transaction_id) as transactions
FROM swoo_plus_transactions_data
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5


SELECT date,SUM(sessions) as total_sessions,ROUND(SUM(total_session_time),2) as total_session_time,ROUND((SUM(total_session_time)/SUM(sessions))/60,2) as avg_session_time
FROM (
SELECT date,device_channel,COUNT(DISTINCT session_id) as sessions,SUM(seconds) as total_session_time
FROM (
SELECT date,device_channel,session_id,TIMESTAMP_DIFF(max_time, min_time, MILLISECOND)/1000 as seconds
FROM (
SELECT DATE(occurred) as date,device_channel,session_id,MAX(occurred) as max_time,MIN(occurred) as min_time
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-05-07'
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
--AND device_channel = '66194688-ad93-4016-85a5-a4bbcf7bbc33'
GROUP BY 1,2,3)
GROUP BY 1,2,3,4)
GROUP BY 1,2)
GROUP BY 1



SELECT Date,ROUND((D1/D0)*100,2) as D1,ROUND((D7/D0)*100,2) as D7,ROUND((D14/D0)*100,2) as D14,ROUND((D30/D0)*100,2) as D30
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
SELECT date(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE type IN ('FIRST_OPEN')
and app_pro_type IN ("com.kryptolabs.android.speakerswire.pro")
and date(occurred) >= "2019-05-07"
GROUP BY 1,2) a
LEFT JOIN (
SELECT date(occurred) as date,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN')
and app_pro_type IN ("com.kryptolabs.android.speakerswire.pro")
and DATE(occurred) >= "2019-05-07"
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
WHERE Date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5
ORDER BY 1



SELECT Date,app_version,(D1/D0) as D1,(D7/D0) as D7,(D14/D0) as D14,(D30/D0) as D30
FROM (
SELECT Date,app_version,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,a.app_version,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT device_channel,CASE WHEN app_version >= '7.0.0' AND os_type = 'ANDROID' THEN 'p2p_app'
WHEN app_version >= '6.7.0' AND os_type = 'IOS' THEN 'p2p_app'
ELSE 'non_p2p_app' END AS app_version,MIN(date) as date
FROM (
SELECT a.date,a.os_type,a.device_channel,CASE WHEN a.app_version IS NULL THEN b.app_version ELSE a.app_version END AS app_version
FROM (
SELECT date(occurred) as date,os_type,app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND type = 'FIRST_OPEN'
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT date(occurred) as date,os_type,app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND type = 'CUSTOM'
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.os_type = b.os_type
GROUP BY 1,2,3,4
HAVING app_version IS NOT NULL)
WHERE app_version NOT LIKE '%debug%'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,CASE WHEN app_version >= '7.0.0' AND os_type = 'ANDROID' THEN 'p2p_app'
WHEN app_version >= '6.7.0' AND os_type = 'IOS' THEN 'p2p_app'
ELSE 'non_p2p_app' END AS app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN') 
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2,3)
WHERE Retention != 'NA'
GROUP BY 1,2)
GROUP BY 1,2,3,4,5,6



SELECT DATE(occurred) as date,body_name,COUNT(DISTINCT device_channel) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_v2` 
WHERE DATE(occurred) = '2019-05-08'
AND type = 'CUSTOM'
GROUP BY 1,2 ORDER BY 3 DESC


SELECT JSON_EXTRACT_SCALAR(body, "$.name") as body_name,COUNT(DISTINCT JSON_EXTRACT_SCALAR(device, "$.channel")) as users
FROM `swoo-analytics-bq.analytics_data.urban_airship_raw` 
WHERE DATE(occurred) = '2019-05-07'
AND type = 'CUSTOM' 
AND JSON_EXTRACT_SCALAR(device, "$.attributes.app_package_name") =  "com.kryptolabs.android.speakerswire.pro"
GROUP BY 1


SELECT *
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = '2019-05-08'
AND type = 'CUSTOM' AND app_pro_type  =  "com.kryptolabs.android.speakerswire.pro"
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'


WITH pro_app_data AS (
SELECT occurred,device_channel,type,body_name 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE()
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
GROUP BY 1,2,3,4) 
SELECT DATE(occurred) as date,
COUNT(DISTINCT CASE WHEN type = 'OPEN' THEN device_channel END) as pro_app_dau,
COUNT(DISTINCT CASE WHEN type = 'FIRST_OPEN' THEN device_channel END) as pro_app_new_installs,
COUNT(DISTINCT CASE WHEN body_name = 'pay2playgamepage_startedplaying' THEN device_channel END) as pro_app_contest_players,
COUNT(DISTINCT CASE WHEN body_name = 'p2pmarketplace_marketplacetransactionsuccess' THEN device_channel END) as pro_app_succesful_transactions
FROM pro_app_data
GROUP BY 1



SELECT CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 'INR 10'
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 'INR 20'
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 'INR 50'
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 'INR 100' ELSE 'Other' END AS package_type,
COUNT(DISTINCT device_channel) as users,COUNT(DISTINCT package_transaction_id) as transactions
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-07' 
AND app_pro_type = "com.kryptolabs.android.speakerswire.pro"
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1



SELECT date,CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 'INR 10'
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 'INR 20'
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 'INR 50'
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 'INR 100' ELSE 'Other' END AS package_type,
CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN (transactions*10)
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN (transactions*20)
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN (transactions*50)
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN (transactions*100) ELSE 'Other' END AS total_trasaction_amount
FROM (
)
GROUP BY 1,2



FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-05' 
AND app_pro_type = "com.kryptolabs.android.speakerswire.pro"
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3,4)
GROUP BY 1


-- p2p app install retention
SELECT Date,app_version,(D1/D0) as D1,(D7/D0) as D7,(D14/D0) as D14,(D30/D0) as D30
FROM (
SELECT Date,app_version,MAX(IF(Retention = 'D0',Users,NULL)) as D0,MAX(IF(Retention = 'D1',Users,NULL)) as D1,MAX(IF(Retention = 'D7',Users,NULL)) as D7,MAX(IF(Retention = 'D14',Users,NULL)) as D14,MAX(IF(Retention = 'D30',Users,NULL)) as D30
FROM (
SELECT a.date as Date,CASE WHEN b.date = a.date THEN 'D0'
WHEN b.date = DATE_ADD(a.date,INTERVAL 1 DAY) THEN 'D1'
WHEN b.date = DATE_ADD(a.date,INTERVAL 7 DAY) THEN 'D7'
WHEN b.date = DATE_ADD(a.date,INTERVAL 14 DAY) THEN 'D14'
WHEN b.date = DATE_ADD(a.date,INTERVAL 30 DAY) THEN 'D30'
ELSE 'NA' END AS Retention,a.app_version,COUNT(DISTINCT a.device_channel) as Users 
FROM (
SELECT device_channel,CASE WHEN app_version >= '7.0.0' AND os_type = 'ANDROID' THEN 'p2p_app'
WHEN app_version >= '6.7.0' AND os_type = 'IOS' THEN 'p2p_app'
ELSE 'non_p2p_app' END AS app_version,MIN(date) as date
FROM (
SELECT a.date,a.os_type,a.device_channel,CASE WHEN a.app_version IS NULL THEN b.app_version ELSE a.app_version END AS app_version
FROM (
SELECT date(occurred) as date,os_type,app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND type = 'FIRST_OPEN'
GROUP BY 1,2,3,4) a
LEFT JOIN (
SELECT date(occurred) as date,os_type,app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND type = 'CUSTOM'
GROUP BY 1,2,3,4) b
ON a.date = b.date AND a.device_channel = b.device_channel AND a.os_type = b.os_type
GROUP BY 1,2,3,4
HAVING app_version IS NOT NULL)
WHERE app_version NOT LIKE '%debug%'
GROUP BY 1,2) a
LEFT JOIN (
SELECT DATE(occurred) as date,CASE WHEN app_version >= '7.0.0' AND os_type = 'ANDROID' THEN 'p2p_app'
WHEN app_version >= '6.7.0' AND os_type = 'IOS' THEN 'p2p_app'
ELSE 'non_p2p_app' END AS app_version,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE type IN ('OPEN') 
AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE()
AND app_version NOT LIKE '%debug%'
GROUP BY 1,2,3) b
ON a.device_channel = b.device_channel AND a.app_version = b.app_version
GROUP BY 1,2,3)
WHERE Retention != 'NA'
GROUP BY 1,2)
GROUP BY 1,2,3,4,5,6


-- ua_p2p_pro_app_transactions
# v2
WITH swoo_plus_transactions_data AS (
SELECT DATE(occurred) as date,device_channel,package_id,COUNT(DISTINCT package_transaction_id) as transactions
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE() --DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3), 
package_id_info AS (
SELECT package_id,CONCAT(cost_currency,' ',cost_amount) as package_type,CAST(cost_amount AS INT64) as cost_amount
FROM (
SELECT package_id,
REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as cost_type,
REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as cost_amount,
REPLACE(REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(2)],":") [OFFSET(1)],"'",""),"}","") as cost_currency,
REPLACE(SPLIT(SPLIT(items,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as items_type,
REPLACE(SPLIT(SPLIT(items,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as items_amount
FROM `swoo-analytics-bq.swoo_plus_db.ripple_packages`
WHERE package_region IN ('IN'))
GROUP BY 1,2,3)
SELECT a.date,b.package_type,a.users,a.transactions,(a.transactions*b.cost_amount) as package_type_transaction_value
FROM (
SELECT date,package_id,COUNT(DISTINCT device_channel) as users,SUM(transactions) as transactions
FROM swoo_plus_transactions_data
GROUP BY 1,2) a
LEFT JOIN (
SELECT package_id,package_type,cost_amount
FROM package_id_info) b
ON a.package_id = b.package_id
GROUP BY 1,2,3,4,5
# v1
WITH swoo_plus_transactions_data AS (
SELECT DATE(occurred) as date,device_channel,CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 10 
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 20
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 50
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 100 ELSE 0 END AS package_amount,
CASE WHEN package_id = 'e2e79ff2-a4f5-4b3c-8601-2216cde189b0' THEN 'INR 10'
WHEN package_id = '00c54ce2-5c1d-4c9a-afd5-4012c7fcbc97' THEN 'INR 20'
WHEN package_id = '00391492-0108-42a9-843b-5702735ef465' THEN 'INR 50'
WHEN package_id = 'f7b17c36-05af-4b5c-a179-101876d77a24' THEN 'INR 100' ELSE 'Other' END AS package_type,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-05-06' AND DATE(occurred) < CURRENT_DATE()
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3,4,5)
SELECT date,package_type,users,transactions,(transactions*package_amount) as package_type_transaction_value
FROM (
SELECT date,package_type,package_amount,COUNT(DISTINCT device_channel) as users,COUNT(DISTINCT package_transaction_id) as transactions
FROM swoo_plus_transactions_data
GROUP BY 1,2,3)
GROUP BY 1,2,3,4,5


-- ua_p2p_pro_app_contest_winning_info
# v2
WITH user_contest_winnings AS (
SELECT contest_id,user_id,user_handle,--DATE(SAFE.TIMESTAMP_SECONDS(game_end_time)) as date,
REPLACE(SPLIT(SPLIT(winning_amount,",") [SAFE_OFFSET(0)],":") [SAFE_OFFSET(1)],"'","") as reward_type,
SAFE_CAST(SPLIT(SPLIT(winning_amount,",") [SAFE_OFFSET(1)],":") [SAFE_OFFSET(1)] as INT64) as reward_amount
FROM `swoo-analytics-bq.swoo_plus_db.user_contest_winnings`
--WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_end_time)) < CURRENT_DATE() --DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5),
contest_info AS (
SELECT contest_id,game_start_time,game_end_time
FROM `swoo-analytics-bq.swoo_plus_db.contest`
GROUP BY 1,2,3),
total_info AS (
SELECT a.*,b.game_start_time
FROM user_contest_winnings a
LEFT JOIN contest_info b
ON a.contest_id = b.contest_id
GROUP BY 1,2,3,4,5,6) 
SELECT DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) as date,reward_type,COUNT(DISTINCT contest_id) as contests,COUNT(DISTINCT CONCAT(contest_id,'-',CAST(user_id as STRING))) as winners,COUNT(DISTINCT user_id) as unique_winners,SUM(reward_amount) as reward_amount
FROM total_info
--WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) < CURRENT_DATE() 
WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2 
ORDER BY 1,2
# v1
WITH user_contest_winnings AS (
SELECT DATE(SAFE.TIMESTAMP_SECONDS(game_end_time)) as date,contest_id,user_id, 
REPLACE(SPLIT(SPLIT(winning_amount,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as reward_type,
CAST(REPLACE(SPLIT(SPLIT(winning_amount,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as INT64) as reward_amount
--COUNT(DISTINCT user_id) as users,COUNT(DISTINCT user_handle) as user_handles
FROM `swoo-analytics-bq.swoo_plus_db.user_contest_winnings`
WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_end_time)) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5)
SELECT date,reward_type,COUNT(DISTINCT contest_id) as contests,COUNT(DISTINCT CONCAT(contest_id,'-',CAST(user_id as STRING))) as winners,COUNT(DISTINCT user_id) as unique_winners,SUM(reward_amount) as reward_amount
FROM user_contest_winnings
GROUP BY 1,2 ORDER BY 1 DESC,2

WITH user_contest_winnings AS (
SELECT DATE(SAFE.TIMESTAMP_SECONDS(game_end_time)) as date,contest_id,user_id, 
REPLACE(SPLIT(SPLIT(winning_amount,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as reward_type,
CAST(REPLACE(SPLIT(SPLIT(winning_amount,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as INT64) as reward_amount
--COUNT(DISTINCT user_id) as users,COUNT(DISTINCT user_handle) as user_handles
FROM `swoo-analytics-bq.swoo_plus_db.user_contest_winnings`
WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_end_time)) <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5)
SELECT date,reward_type,COUNT(DISTINCT contest_id) as contests,COUNT(DISTINCT CONCAT(contest_id,'-',CAST(user_id as STRING))) as winners,COUNT(DISTINCT user_id) as unique_winners,SUM(reward_amount) as reward_amount
FROM user_contest_winnings
GROUP BY 1,2 ORDER BY 1 DESC,2


-- ua_p2p_contest_fill_rate
# v4
SELECT *,CONCAT(contest_type,'_',CAST(rank AS STRING)) as contest_name
FROM (
SELECT *,ROUND((users_registered/total_slots)*100,2) as fill_rate,RANK() OVER(PARTITION BY date ORDER BY game_start_time,game_end_time,contest_type,entry_type DESC,entry_fee DESC,reward_type,total_reward DESC) AS rank
FROM (
SELECT a.*,b.date,b.contest_type,b.total_slots,b.game_start_time,b.game_end_time,b.entry_type,b.entry_fee,b.reward_type,b.total_reward
FROM (
SELECT contest_id,COUNT(DISTINCT user_id) as users_registered
FROM `swoo-analytics-bq.swoo_plus_db.user_contest_registration` 
GROUP BY 1) a
JOIN (
SELECT a.*,b.reward_type,b.total_reward
FROM (
SELECT DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) as date,contest_type,contest_id,title,total_slots,
TIME(SAFE.TIMESTAMP_SECONDS(game_start_time),'Asia/Kolkata') as game_start_time,
TIME(SAFE.TIMESTAMP_SECONDS(game_end_time),'Asia/Kolkata') as game_end_time,
REPLACE(SPLIT(SPLIT(entry_fee,",") [SAFE_OFFSET(0)],":") [SAFE_OFFSET(1)],"'","") as entry_type,
REPLACE(SPLIT(SPLIT(entry_fee,",") [SAFE_OFFSET(1)],":") [SAFE_OFFSET(1)],"'","") as entry_fee
FROM `swoo-analytics-bq.swoo_plus_db.contest`
WHERE is_deleted = false 
--AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) >= '2019-03-30' AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) < CURRENT_DATE()
--AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5,6,7,8,9) a
JOIN (
SELECT contest_id,reward_type,((r1_size*r1_amount)+(r2_size*r2_amount)+(r3_size*r3_amount)+(r4_size*r4_amount)+(r5_size*r5_amount)+(r6_size*r6_amount)+(r7_size*r7_amount)) as total_reward
FROM (
SELECT contest_id,REPLACE(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(2)],':') [SAFE_OFFSET(2)],"'","") as reward_type,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(1)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(0)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r1_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(3)],':') [SAFE_OFFSET(1)] AS INT64),0) as r1_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(6)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(5)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r2_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(8)],':') [SAFE_OFFSET(1)] AS INT64),0) as r2_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(11)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(10)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r3_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(13)],':') [SAFE_OFFSET(1)] AS INT64),0) as r3_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(16)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(15)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r4_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(18)],':') [SAFE_OFFSET(1)] AS INT64),0) as r4_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(21)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(20)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r5_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(23)],':') [SAFE_OFFSET(1)] AS INT64),0) as r5_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(26)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(25)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r6_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(28)],':') [SAFE_OFFSET(1)] AS INT64),0) as r6_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(31)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(30)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r7_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(33)],':') [SAFE_OFFSET(1)] AS INT64),0) as r7_amount
FROM `swoo-analytics-bq.swoo_plus_db.contest`)
--WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
--WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) >= '2019-03-30' AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) < CURRENT_DATE())
GROUP BY 1,2,3) b
ON a.contest_id = b.contest_id) b
ON a.contest_id = b.contest_id --AND a.contest_type = b.contest_type AND a.date = b.date 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11))
ORDER BY 3,4,1
# v3
SELECT *,ROUND((users_registered/total_slots)*100,2) as fill_rate
FROM (
SELECT a.*,b.total_slots,b.game_start_time,b.game_end_time,b.entry_type,b.entry_fee,b.reward_type,b.total_reward
FROM (
SELECT DATE(occurred) as date,contest_type,contest_id,COUNT(DISTINCT device_channel) as users_registered
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
--AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() 
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3) a
JOIN (
SELECT a.*,b.reward_type,b.total_reward
FROM (
SELECT DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) as date,contest_type,contest_id,title,total_slots,
TIME(SAFE.TIMESTAMP_SECONDS(game_start_time),'Asia/Kolkata') as game_start_time,
TIME(SAFE.TIMESTAMP_SECONDS(game_end_time),'Asia/Kolkata') as game_end_time,
REPLACE(SPLIT(SPLIT(entry_fee,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as entry_type,
REPLACE(SPLIT(SPLIT(entry_fee,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as entry_fee
FROM `swoo-analytics-bq.swoo_plus_db.contest`
WHERE is_deleted = false 
--AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) >= '2019-03-30' AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) < CURRENT_DATE()
AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5,6,7,8,9) a
JOIN (
SELECT contest_id,reward_type,((r1_size*r1_amount)+(r2_size*r2_amount)+(r3_size*r3_amount)+(r4_size*r4_amount)+(r5_size*r5_amount)+(r6_size*r6_amount)+(r7_size*r7_amount)) as total_reward
FROM (
SELECT contest_id,REPLACE(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(2)],':') [SAFE_OFFSET(2)],"'","") as reward_type,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(1)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(0)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r1_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(3)],':') [SAFE_OFFSET(1)] AS INT64),0) as r1_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(6)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(5)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r2_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(8)],':') [SAFE_OFFSET(1)] AS INT64),0) as r2_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(11)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(10)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r3_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(13)],':') [SAFE_OFFSET(1)] AS INT64),0) as r3_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(16)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(15)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r4_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(18)],':') [SAFE_OFFSET(1)] AS INT64),0) as r4_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(21)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(20)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r5_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(23)],':') [SAFE_OFFSET(1)] AS INT64),0) as r5_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(26)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(25)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r6_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(28)],':') [SAFE_OFFSET(1)] AS INT64),0) as r6_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(31)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(30)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r7_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(33)],':') [SAFE_OFFSET(1)] AS INT64),0) as r7_amount
FROM `swoo-analytics-bq.swoo_plus_db.contest`
WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
--WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) >= '2019-03-30' AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) < CURRENT_DATE())
GROUP BY 1,2,3) b
ON a.contest_id = b.contest_id
ORDER BY game_start_time) b
ON a.date = b.date AND a.contest_id = b.contest_id AND a.contest_type = b.contest_type 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11)
ORDER BY 1,2,3
# v2
SELECT *,ROUND((users_registered/total_slots)*100,2) as fill_rate
FROM (
SELECT a.*,b.total_slots,b.game_start_time,b.game_end_time,b.entry_type,b.entry_fee
FROM (
SELECT DATE(occurred) as date,contest_type,contest_id,COUNT(DISTINCT device_channel) as users_registered
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE body_name IN ('allconteststab_gameregistrationsuccessful')
--AND DATE(occurred) >= '2019-03-30' AND DATE(occurred) < CURRENT_DATE() 
AND DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) as date,contest_type,contest_id,title,total_slots,SAFE.TIMESTAMP_SECONDS(game_start_time) as game_start_time,SAFE.TIMESTAMP_SECONDS(game_end_time) as game_end_time,
REPLACE(SPLIT(SPLIT(entry_fee,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as entry_type,
REPLACE(SPLIT(SPLIT(entry_fee,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as entry_fee
FROM `swoo-analytics-bq.swoo_plus_db.contest`
WHERE is_deleted = false 
--AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) >= '2019-03-30' AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) < CURRENT_DATE()
AND DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5,6,7,8,9) b
ON a.date = b.date AND a.contest_id = b.contest_id AND a.contest_type = b.contest_type 
GROUP BY 1,2,3,4,5,6,7,8,9)
ORDER BY game_start_time






SELECT contest_id,reward_type,((r1_size*r1_amount)+(r2_size*r2_amount)+(r3_size*r3_amount)+(r4_size*r4_amount)+(r5_size*r5_amount)) as total_reward
FROM (
SELECT contest_id,REPLACE(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(2)],':') [SAFE_OFFSET(2)],"'","") as reward_type,
(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(1)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(0)],':') [SAFE_OFFSET(1)] AS INT64) + 1) as r1_size,
SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(3)],':') [SAFE_OFFSET(1)] AS INT64) as r1_amount,
(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(6)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(5)],':') [SAFE_OFFSET(1)] AS INT64) + 1) as r2_size,
SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(8)],':') [SAFE_OFFSET(1)] AS INT64) as r2_amount,
(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(11)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(10)],':') [SAFE_OFFSET(1)] AS INT64) + 1) as r3_size,
SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(13)],':') [SAFE_OFFSET(1)] AS INT64) as r3_amount,
(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(16)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(15)],':') [SAFE_OFFSET(1)] AS INT64) + 1) as r4_size,
SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(18)],':') [SAFE_OFFSET(1)] AS INT64) as r4_amount,
(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(21)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(20)],':') [SAFE_OFFSET(1)] AS INT64) + 1) as r5_size,
SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(23)],':') [SAFE_OFFSET(1)] AS INT64) as r5_amount
FROM `swoo-analytics-bq.swoo_plus_db.contest`
WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = '2019-05-22')
--DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
GROUP BY 1,2,3


SELECT contest_id,reward_type,((r1_size*r1_amount)+(r2_size*r2_amount)+(r3_size*r3_amount)+(r4_size*r4_amount)+(r5_size*r5_amount)) as total_reward
FROM (
SELECT contest_id,REPLACE(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(2)],':') [SAFE_OFFSET(2)],"'","") as reward_type,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(1)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(0)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r1_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(3)],':') [SAFE_OFFSET(1)] AS INT64),0) as r1_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(6)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(5)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r2_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(8)],':') [SAFE_OFFSET(1)] AS INT64),0) as r2_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(11)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(10)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r3_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(13)],':') [SAFE_OFFSET(1)] AS INT64),0) as r3_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(16)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(15)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r4_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(18)],':') [SAFE_OFFSET(1)] AS INT64),0) as r4_amount,
IFNULL((SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(21)],':') [SAFE_OFFSET(1)] AS INT64) - SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(20)],':') [SAFE_OFFSET(1)] AS INT64) + 1),0) as r5_size,
IFNULL(SAFE_CAST(SPLIT(SPLIT(prize_per_head,",") [SAFE_OFFSET(23)],':') [SAFE_OFFSET(1)] AS INT64),0) as r5_amount
FROM `swoo-analytics-bq.swoo_plus_db.contest`
WHERE DATE(SAFE.TIMESTAMP_SECONDS(game_start_time)) = '2019-05-21')
--DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
GROUP BY 1,2,3


SELECT DATE(occurred) as date,device_channel,body_name 
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
--WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) 
WHERE DATE(occurred) >= '2019-05-22' AND DATE(occurred) < CURRENT_DATE()
AND type = 'CUSTOM' --IN ('OPEN','FIRST_OPEN')
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
GROUP BY 1,2,3




-- ua_p2p_pro_app_transactions_by_transaction_type
# v2
WITH yesterday_pro_app_transactions_info AS (
SELECT DATE(occurred) as date,device_channel,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
--WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
WHERE DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE()
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3),
pro_app_transactions_info AS (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2)
SELECT a.date,CASE WHEN a.date = b.date THEN 'First' ELSE 'Repeat' END AS transaction_type,COUNT(DISTINCT a.device_channel) as transaction_users,COUNT(DISTINCT a.package_transaction_id) as transactions
FROM (
SELECT date,device_channel,package_transaction_id
FROM yesterday_pro_app_transactions_info
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT device_channel,MIN(date) as date
FROM pro_app_transactions_info 
GROUP BY 1) b
ON a.device_channel = b.device_channel
GROUP BY 1,2
ORDER BY 1,2
# v1
WITH yesterday_pro_app_transactions_info AS (
SELECT DATE(occurred) as date,device_channel,package_transaction_id
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
--WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
WHERE DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE()
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2,3),
pro_app_transactions_info AS (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2)
SELECT a.date,CASE WHEN a.date = b.date THEN 'first'
WHEN b.date IS NULL THEN 'null' 
ELSE 'repeat' END AS transaction_type,COUNT(DISTINCT a.device_channel) as transaction_users,COUNT(DISTINCT a.package_transaction_id) as transactions
FROM (
SELECT date,device_channel,package_transaction_id
FROM yesterday_pro_app_transactions_info
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT device_channel,MIN(date) as date
FROM pro_app_transactions_info 
GROUP BY 1) b
ON a.device_channel = b.device_channel
GROUP BY 1,2
ORDER BY 1,2




SELECT a.user_id,b.name,b.handle,b.email,b.phone,a.date as last_active_date
FROM (
SELECT user_id,date
FROM (
SELECT b.user_id,a.date,DENSE_RANK() OVER(PARTITION BY b.user_id ORDER BY a.date DESC) AS rank
FROM (
SELECT device_channel,date
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel,user_id 
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE rank = 1
AND date <= '2018-12-31'
GROUP BY 1,2) a
LEFT JOIN (
SELECT id,name,handle,email,phone
FROM `swoo-analytics-bq.backend_tables.user`
GROUP BY 1,2,3,4,5) b
ON a.user_id = b.id
GROUP BY 1,2,3,4,5,6



SELECT *
FROM (
SELECT a.user_id,a.date as max_uninstall_date,b.date as max_open_date
FROM (
SELECT b.user_id,MAX(a.date) as date
FROM (
SELECT device_channel,date
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('UNINSTALL')
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel,user_id 
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1) a
JOIN (
SELECT b.user_id,MAX(a.date) as date
FROM (
SELECT device_channel,date
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
JOIN (
SELECT ua_notification_token as device_channel,user_id 
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1) b
ON a.user_id = b.user_id
GROUP BY 1,2,3)
WHERE max_uninstall_date > max_open_date


-- ua_p2p_pro_app_contest_players_retention
# v1
SELECT Date,ROUND((D1/D0)*100,2) as D1,ROUND((D7/D0)*100,2) as D7,ROUND((D14/D0)*100,2) as D14,ROUND((D30/D0)*100,2) as D30
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
SELECT a.date,a.device_channel
FROM (
SELECT device_channel,MIN(date) as date
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_game_derived_data_v1`
GROUP BY 1) a
JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_game_derived_data_v1` 
WHERE body_name = 'pay2playgamepage_startedplaying'
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1`
WHERE type IN ('OPEN')
AND date >= "2019-05-07"
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
WHERE Date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5
ORDER BY 1



-- ua_p2p_pro_app_contest_winners_retention
# v1
SELECT Date,ROUND((D1/D0)*100,2) as D1,ROUND((D7/D0)*100,2) as D7,ROUND((D14/D0)*100,2) as D14,ROUND((D30/D0)*100,2) as D30
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
SELECT a.date,a.device_channel
FROM (
SELECT a.date,a.device_channel,b.user_id
FROM (
SELECT date,device_channel --COUNT(DISTINCT device_channel) as users
FROM (
SELECT device_channel,MIN(date) as date
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_game_derived_data_v1` 
GROUP BY 1)
GROUP BY 1,2) a
LEFT JOIN (
SELECT ua_notification_token as device_channel,user_id
FROM `swoo-analytics-bq.backend_tables.user_device` 
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2,3) a
JOIN (
SELECT DATE(SAFE.TIMESTAMP_SECONDS(created_at)) as date,user_id --,user_handle
FROM `swoo-analytics-bq.swoo_plus_db.user_contest_winnings`
GROUP BY 1,2) b
ON a.date = b.date AND a.user_id = b.user_id 
GROUP BY 1,2) a
LEFT JOIN (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1`
WHERE type IN ('OPEN')
AND date >= "2019-05-07"
GROUP BY 1,2) b
ON a.device_channel = b.device_channel
GROUP BY 1,2)
WHERE Retention != 'NA'
GROUP BY 1)
WHERE Date < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1,2,3,4,5
ORDER BY 1



-- ua_p2p_pro_app_session_time
# v2
SELECT date,SUM(sessions) as total_sessions,ROUND(SUM(total_session_time),2) as total_session_time,ROUND((SUM(total_session_time)/SUM(sessions))/60,2) as avg_session_time
FROM (
SELECT date,device_channel,COUNT(DISTINCT session_id) as sessions,SUM(seconds) as total_session_time
FROM (
SELECT date,device_channel,session_id,TIMESTAMP_DIFF(max_time, min_time, MILLISECOND)/1000 as seconds
FROM (
SELECT DATE(occurred) as date,device_channel,session_id,MAX(occurred) as max_time,MIN(occurred) as min_time
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) --DATE(occurred) >= '2019-05-07' AND DATE(occurred) < CURRENT_DATE()
AND session_id IS NOT NULL
AND (app_pro_type = "com.kryptolabs.android.speakerswire.pro" OR app_type = 'true')
--AND device_channel = '66194688-ad93-4016-85a5-a4bbcf7bbc33'
GROUP BY 1,2,3)
GROUP BY 1,2,3,4)
GROUP BY 1,2)
GROUP BY 1



/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=bingo --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=candy_rush --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=candy_rush_round_detail --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=candy_rush_score_bucket --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=candy_rush_user_score --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=feedback --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=feedback_items --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=game_country --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=game_currency --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=game_signal --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=lives_transaction_history --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=swooperstar_user_activity --default-env delete=yes
#/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=trivia_question_bank --default-env delete=yes
#/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=trivia_question_set --default-env delete=yes
#/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=trivia_user_game_activity --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=user_game_statistics --default-env update_column=updated_at
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=user_lives --default-env delete=yes
/var/lib/jenkins/.local/bin/bonobo run /var/lib/jenkins/swoo-dwh/src/backend_tables/backend_tables_load.py --default-env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.backend_env_swoo_gaming_service --default-env table=user_statistics --default-env delete=yes
/usr/bin/python3 /var/lib/jenkins/swoo-dwh/src/backend_tables/backend-table-bq-load.py --env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.env-gaming --env CFG_FILE=/var/lib/jenkins/swoo-dwh/src/backend_tables/swooperstar_shortlisted_videos.json
/usr/bin/python3 /var/lib/jenkins/swoo-dwh/src/backend_tables/backend-table-bq-load.py --env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.env-gaming --env CFG_FILE=/var/lib/jenkins/swoo-dwh/src/backend_tables/swooperstar_game.json
/usr/bin/python3 /var/lib/jenkins/swoo-dwh/src/backend_tables/backend-table-bq-load.py --env-file /var/lib/jenkins/swoo-dwh/src/backend_tables/.env-gaming --env CFG_FILE=/var/lib/jenkins/swoo-dwh/src/backend_tables/campaign_user_progress.json




SELECT date(Date_IST) as date,CONCAT(SUBSTR(Time,0,LENGTH(Time)-6),SUBSTR(Time,9,LENGTH(Time))) as Time,game_type_id,game_id,users FROM (SELECT Date_IST,FORMAT_DATETIME('%r',Date_IST) AS Time,B.game_type_id,A.game_id,COUNT(DISTINCT B.user_id) AS users FROM ((SELECT DATETIME(start_time, 'Asia/Kolkata') AS Date_IST,game_id FROM `swoo_gaming_service.game` WHERE DATE(start_time) = DATE_SUB(CURRENT_DATE(), INTERVAL 2 DAY)) A LEFT JOIN (SELECT user_id,game_id,game_type_id FROM `swoo_gaming_service.user_game_statistics`) B ON A.game_id = B.game_id) GROUP BY 1,2,3,4 HAVING users > 0 ORDER BY 1)


-- ua_p2p_pro_app_dau_wau_mau
# v1
SELECT a.date as Date,a.dau as DAU,b.wau as WAU,c.mau as MAU 
FROM (
SELECT date,COUNT(DISTINCT device_channel) as dau
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1`  
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1) a
JOIN (
SELECT b.date as Date,COUNT(DISTINCT device_channel) as wau 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1) b
ON a.date = b.date
JOIN (
SELECT b.date as Date,COUNT(DISTINCT device_channel) as mau 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.swoo_plus_db.ua_pro_app_derived_data_v1` 
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2019-05-07' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 30 DAY) AND a.date <= b.date
GROUP BY 1) c
ON b.date = c.date
ORDER BY 1


-- ua_p2p_pro_app_gems_distribution
# v2
SELECT DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) as date,
CASE WHEN balance < 0 THEN '< 0'
WHEN balance >= 0 AND balance < 5 THEN '0 - 5'
WHEN balance = 5 THEN '5'
WHEN balance >= 6 AND balance < 10 THEN '6 - 10'
WHEN balance >= 10 AND balance < 50 THEN '10 - 50'
WHEN balance >= 50 AND balance < 100 THEN '50 - 100'
WHEN balance >= 100 THEN '>= 100' ELSE 'NA' END AS bucket_type,
CASE WHEN balance < 0 THEN 1
WHEN balance >= 0 AND balance < 5 THEN 2
WHEN balance = 5 THEN 3
WHEN balance >= 6 AND balance < 10 THEN 4
WHEN balance >= 10 AND balance < 50 THEN 5
WHEN balance >= 50 AND balance < 100 THEN 6
WHEN balance >= 100 THEN 7 ELSE 8 END AS rank_type,
COUNT(DISTINCT user_id) as users
FROM (
SELECT user_id,amount_type,SAFE_CAST(SPLIT(SPLIT(balance,",") [SAFE_OFFSET(1)],':') [SAFE_OFFSET(1)] AS INT64) as balance
FROM (
SELECT user_id,amount_type,balance,DENSE_RANK() OVER(PARTITION BY user_id,amount_type ORDER BY created_at DESC) AS rank 
FROM `swoo-analytics-bq.swoo_plus_db.ripple_transaction_details`)
WHERE rank = 1 
--AND user_id = 7820788
AND amount_type = 'GEMS')
GROUP BY 1,2,3
ORDER BY 4 DESC
# v1
WITH coin_gem_info AS (
SELECT user_id,amount_type,txn_type,SUM(txn_amount) as txn_amount
FROM `swoo-analytics-bq.swoo_plus_db.ripple_transaction_details`
--WHERE user_id = 7820788
GROUP BY 1,2,3)
SELECT user_id,amount_type,(credit-debit) as balance
FROM (
SELECT a.user_id,a.amount_type,a.txn_amount as credit,IFNULL(b.txn_amount,0) as debit
FROM (
SELECT user_id,amount_type,txn_amount
FROM coin_gem_info
WHERE txn_type = 'CREDIT'
GROUP BY 1,2,3) a
LEFT JOIN (
SELECT user_id,amount_type,txn_amount
FROM coin_gem_info
WHERE txn_type = 'DEBIT'
GROUP BY 1,2,3) b
ON a.user_id = b.user_id AND a.amount_type = b.amount_type 
GROUP BY 1,2,3,4)
WHERE amount_type = 'GEMS'
ORDER BY 3 DESC































# q1="cqlsh 11.0.5.168 -u qa_readonly -p7bx75esuep4z3a56 -e'select * from user_game_play_detail where created_at >= "
# yds=$(date -d "1 day ago 00:00:00" +%s)
# yde=$(date -d "1 day ago 23:59:59" +%s)
# fq="$q1$yds$q2$yde"


cqlsh 172.31.47.180 -u cassandra -pcassandra

output_date = (datetime.datetime.now() - datetime.timedelta(days=1)).strftime("%Y-%m-%d")


cqlsh 172.31.47.180 -u cassandra -pcassandra -f commands_test.list

cqlsh 11.0.5.168 -u qa_readonly -p7bx75esuep4z3a56

cqlsh 11.0.5.168 -u qa_readonly -p7bx75esuep4z3a56 -f commands_test.list

sudo docker run -it cassandra /usr/bin/cqlsh 11.0.5.168 -u qa_readonly -p7bx75esuep4z3a56

cqlsh 11.0.5.168 -u root -pgameqweQWE1!



sudo docker run -it --mount src=/home/munagala/tables_csv,target=/test_container,type=bind cassandra /usr/bin/cqlsh 11.0.5.168 -u qa_readonly -p7bx75esuep4z3a56

COPY swoo_ripple.ripple_transaction_details TO '/test_container/ripple_transaction_details.csv' WITH HEADER = TRUE;




sudo docker run -it --mount src=/home/munagala/tables_csv,target=/test_container,type=bind cassandra /usr/bin/cqlsh 11.0.5.168 -u qa_readonly -p7bx75esuep4z3a5









