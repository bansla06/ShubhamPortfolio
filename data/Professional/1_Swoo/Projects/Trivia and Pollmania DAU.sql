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