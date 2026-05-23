# Players By Country

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