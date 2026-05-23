##################################################################################################################################
###******************************* Connecting to BigQuery
##################################################################################################################################
from google.cloud import bigquery
from google.oauth2 import service_account
credentials = service_account.Credentials.from_service_account_file('/Users/shubham/Desktop/PRODUCT_DECK/Swoo/SWOO-Analytics-BQ-7ef282b1d58b.json')
project_id = 'swoo-analytics-bq'
client = bigquery.Client(credentials= credentials,project=project_id)
private_key = '/Users/shubham/Desktop/PRODUCT_DECK/Swoo/SWOO-Analytics-BQ-7ef282b1d58b.json'
import pandas as pd
import numpy as np
print('Connection to BigQuery is successful')


##################################################################################################################################
###******************************* Connecting to Google Sheets
##################################################################################################################################
import gspread
from oauth2client.service_account import ServiceAccountCredentials
# use creds to create a client to interact with the Google Drive API
scope = ['https://spreadsheets.google.com/feeds','https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name('/Users/shubham/Desktop/PRODUCT_DECK/Swoo/SWOO-Analytics-BQ-7ef282b1d58b.json', scope)
client_sheets = gspread.authorize(creds)
print('Connection to Google Sheets is successful')
#import pandas as pd
from gspread_dataframe import get_as_dataframe, set_with_dataframe

sheetname = "Product_deck_automated_sheet"


##################################################################################################################################
###******************************* Importing 'datetime' module
##################################################################################################################################

from datetime import datetime,timedelta
start_ref = datetime.today().date() - timedelta(days=13)
end_ref = datetime.today().date() - timedelta(days=1)

sd= str(start_ref.year)+'-'+str(start_ref.month)+'-'+str(start_ref.day)
ed= str(end_ref.year)+'-'+str(end_ref.month)+'-'+str(end_ref.day)


##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
###******************************* Creating required derived tables (temporary tables)
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################

####### --------------------------------------------------------------------------------------------------------------------------
#### ua_app_derived_data_v3
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('ua_app_derived_data_v3')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT date,type,device_channel
FROM `swoo-analytics-bq.daily_dashboard.ua_app_derived_data_v1`
WHERE type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2,3
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
####### --------------------------------------------------------------------------------------------------------------------------
#### ua_game_derived_data_v3
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('ua_game_derived_data_v3')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v1`
WHERE type IN ('CUSTOM')
AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen'))) --IN ('trivia_started_playing', 'bingo_started_playing', 'candyrush_started_playing')
GROUP BY 1,2,3
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))


##################################################################################################################################
###******************************* App UA Retention
##################################################################################################################################

### ------------------------------------------------------------------------------------------------------------------------------
## App_UA_Retention_WAU
# dataset_id = 'your_dataset_id'
dataset_id = 'derived_data'
# Set the destination table
table_ref = client.dataset(dataset_id).table('App_UA_Retention_WAU')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
# For APPENDING the table
#job_config.write_disposition = bigquery.WriteDisposition.WRITE_APPEND
# For TRUNCATING or OVERWRITING the table
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE

sql = """
SELECT b.date as Date,device_channel--COUNT(DISTINCT a.developer_identity) as WAU 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
### ------------------------------------------------------------------------------------------------------------------------------
## App_UA_Retention_CURR
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_CURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,b.device_channel as device_channel--COUNT(DISTINCT a.developer_identity) as LastWeekUsers 
FROM (
SELECT b.date as date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
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
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 20 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 14 DAY)
GROUP BY 1,2) b
ON a.date = b.date AND a.device_channel = b.device_channel
GROUP BY 1,2;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
### ------------------------------------------------------------------------------------------------------------------------------
## App_UA_Retention_NURR
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_NURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,device_channel--,COUNT(DISTINCT developer_identity) AS NewUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
### ------------------------------------------------------------------------------------------------------------------------------
## App_UA_Retention_RURR
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_RURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,device_channel 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))


##################################################################################################################################
###******************************* Game wise UA Retention
##################################################################################################################################

### ------------------------------------------------------------------------------------------------------------------------------
## Game_wise_UA_Retention_WAU
# dataset_id = 'your_dataset_id'
dataset_id = 'derived_data'
# Set the destination table
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_WAU')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
# For APPENDING the table
#job_config.write_disposition = bigquery.WriteDisposition.WRITE_APPEND
# For TRUNCATING or OVERWRITING the table
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE

sql = """
SELECT b.date as Date,body_name,device_channel--COUNT(DISTINCT a.developer_identity) as WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2,3;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
### ------------------------------------------------------------------------------------------------------------------------------
## Game_wise_UA_Retention_CURR
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_CURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,b.body_name as body_name,b.device_channel as device_channel--COUNT(DISTINCT a.developer_identity) as LastWeekUsers 
FROM (
SELECT b.date as date,body_name,device_channel
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
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
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 20 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 14 DAY)
GROUP BY 1,2,3) b
ON a.date = b.date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2,3;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
### ------------------------------------------------------------------------------------------------------------------------------
## Game_wise_UA_Retention_NURR
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_NURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,body_name,device_channel--,COUNT(DISTINCT developer_identity) AS NewUsers
FROM (
SELECT body_name,device_channel,MIN(date) as date
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))
### ------------------------------------------------------------------------------------------------------------------------------
## Game_wise_UA_Retention_RURR
dataset_id = 'derived_data'
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_RURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,body_name,device_channel 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3;
"""
# Start the query, passing in the extra configuration.
query_job = client.query(
    sql,
    # Location must match that of the dataset(s) referenced in the query
    # and of the destination table.
    location='US',
    job_config=job_config)  # API request - starts the query

query_job.result()  # Waits for the query to finish
print('Query results loaded to table {}'.format(table_ref.path))



##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
###******************************* Calculation of metrics
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################
##################################################################################################################################



##################################################################################################################################
###******************************* DAU, WAU, MAU & Distinct Game Players
##################################################################################################################################

## DAU, WAU & MAU
q1 = client.query("""
SELECT Date,DAU,WAU,MAU
FROM `swoo-analytics-bq.daily_dashboard.App_DAU_WAU_MAU`
GROUP BY 1,2,3,4
ORDER BY 1
""")
dau_wau_mau = q1.to_dataframe()

## Distinct Game Players
q2 = client.query("""
SELECT DATE as Date,MAX(Users) as DistinctGamePlayers
FROM `swoo-analytics-bq.daily_dashboard.ua_user_played`
GROUP BY 1
ORDER BY 1
""")
distinctgameplayers = q2.to_dataframe()

dau_wau_mau_dgp = pd.merge(dau_wau_mau, distinctgameplayers, how='left', on=['Date'])
dau_wau_mau_dgp['Distinct_Game_Players_Ratio'] = dau_wau_mau_dgp['DistinctGamePlayers']/dau_wau_mau_dgp['DAU']
dau_wau_mau_dgp['DAU_WAU_Ratio'] = dau_wau_mau_dgp['DAU']/dau_wau_mau_dgp['WAU']
dau_wau_mau_dgp['DAU_MAU_Ratio'] = dau_wau_mau_dgp['DAU']/dau_wau_mau_dgp['MAU']
dau_wau_mau_dgp.sort_values(by='Date',inplace=True)
dau_wau_mau_dgp = dau_wau_mau_dgp.reset_index()
dau_wau_mau_dgp = dau_wau_mau_dgp.drop('index',axis = 1)

dau_wau_mau_dgp.name = 'DAU_WAU_MAU_DistinctGamePlayers'

# dataset_ref = client.dataset('derived_data')
# table_ref = dataset_ref.table('DAU_WAU_MAU_DistinctGamePlayers')
# client.delete_table(table_ref)
# print('Table {}:{} deleted.'.format(dataset_ref, table_ref))
# client.load_table_from_dataframe(dau_wau_mau_dgp, table_ref).result()
# print('Dataframe loaded to table {}'.format(table_ref.path))

ws = client_sheets.open(sheetname).worksheet(dau_wau_mau_dgp.name)
set_with_dataframe(ws, dau_wau_mau_dgp)
print('Dataframe written to {} google sheet'.format(dau_wau_mau_dgp.name))

del q1,q2

##################################################################################################################################
###******************************* Components of App WAU
##################################################################################################################################

## WAU
components_of_wau = dau_wau_mau_dgp[['Date','WAU']]

## LastWeekUsers
q3 = client.query("""
SELECT a.date as Date,COUNT(DISTINCT a.device_channel) as LastWeekUsers
FROM (
SELECT b.date as Date,device_channel
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
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
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
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
""")
last_week_users = q3.to_dataframe()

## NewUsers
q4 = client.query("""
SELECT b.date as Date,COUNT(DISTINCT device_channel) as NewUsers
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
WHERE type IN ('FIRST_OPEN')
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1
""")
new_users = q4.to_dataframe()

components_of_wau = pd.merge(components_of_wau, last_week_users, how='left', on=['Date'])
components_of_wau = pd.merge(components_of_wau, new_users, how='left', on=['Date'])
components_of_wau['ReactivatedUsers'] = components_of_wau['WAU'] - components_of_wau['LastWeekUsers'] - components_of_wau['NewUsers']
components_of_wau.sort_values(by='Date',inplace=True)
components_of_wau = components_of_wau.reset_index()
components_of_wau = components_of_wau.drop('index',axis = 1)

components_of_wau.name = 'App_WAU'

#full_table_id = 'derived_data.components_of_wau'
#components_of_wau.to_gbq(full_table_id, project_id=project_id, if_exists = 'replace')

# dataset_ref = client.dataset('derived_data')
# table_ref = dataset_ref.table('App_WAU')
# client.delete_table(table_ref)
# print('Table {}:{} deleted.'.format(dataset_ref, table_ref))
# client.load_table_from_dataframe(components_of_wau, table_ref).result()
# print('Dataframe loaded to table {}'.format(table_ref.path))

ws = client_sheets.open(sheetname).worksheet(components_of_wau.name)
set_with_dataframe(ws, components_of_wau)
print('Dataframe written to {} google sheet'.format(components_of_wau.name))

del q3,q4

##################################################################################################################################
###******************************* Game wise components of WAU
##################################################################################################################################

## Game wise WAU
q5 = client.query("""
SELECT b.date as Date,body_name AS Game_Type, COUNT(DISTINCT device_channel) AS WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2
""")
game_wise_wau = q5.to_dataframe()

## Game wise LastWeekUsers
q6 = client.query("""
SELECT b.date as Date,a.body_name AS Game_Type, COUNT(DISTINCT a.device_channel) as LastWeekUsers 
FROM (
SELECT b.date as date,body_name,device_channel 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
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
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3) b
ON a.date = b.date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2
""")
game_wise_lastweekusers = q6.to_dataframe()

## Game wise NewUsers
q7 = client.query("""
SELECT b.date as Date,body_name AS Game_Type, COUNT(DISTINCT a.device_channel) AS NewUsers 
FROM (
SELECT body_name,device_channel,MIN(date) as date
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 6 DAY) AND a.date <= b.date
GROUP BY 1,2
""")
game_wise_newusers = q7.to_dataframe()

game_wise_wau = pd.merge(game_wise_wau, game_wise_lastweekusers, how='left', on=['Date','Game_Type'])
game_wise_wau = pd.merge(game_wise_wau, game_wise_newusers, how='left', on=['Date','Game_Type'])
game_wise_wau['ReactivatedUsers'] = game_wise_wau['WAU'] - game_wise_wau['LastWeekUsers'] - game_wise_wau['NewUsers']
game_wise_wau.sort_values(by=['Date','Game_Type'],inplace=True)
game_wise_wau = game_wise_wau.reset_index()
game_wise_wau = game_wise_wau.drop('index',axis = 1)

# game_wise_wau.name = 'Game_wise_WAU'

# # dataset_ref = client.dataset('derived_data')
# # table_ref = dataset_ref.table('Game_wise_WAU')
# # client.delete_table(table_ref)
# # print('Table {}:{} deleted.'.format(dataset_ref, table_ref))
# # client.load_table_from_dataframe(game_wise_wau, table_ref).result()
# # print('Dataframe loaded to table {}'.format(table_ref.path))

# ws = client_sheets.open(sheetname).worksheet(game_wise_wau.name)
# set_with_dataframe(ws, game_wise_wau)
# print('Dataframe written to {} google sheet'.format(game_wise_wau.name))

## Trivia_WAU
game_wau = game_wise_wau[game_wise_wau.Game_Type == 'trivia_started_playing'][['Date','LastWeekUsers','NewUsers','ReactivatedUsers','WAU']].reset_index()
game_wau = game_wau.drop('index',axis = 1)
game_wau.name = 'Trivia_WAU'

ws = client_sheets.open(sheetname).worksheet(game_wau.name)
set_with_dataframe(ws, game_wau)
print('Dataframe written to {} google sheet'.format(game_wau.name))

## Bingo_WAU
game_wau = game_wise_wau[game_wise_wau.Game_Type == 'bingo_started_playing'][['Date','LastWeekUsers','NewUsers','ReactivatedUsers','WAU']].reset_index()
game_wau = game_wau.drop('index',axis = 1)
game_wau.name = 'Bingo_WAU'

ws = client_sheets.open(sheetname).worksheet(game_wau.name)
set_with_dataframe(ws, game_wau)
print('Dataframe written to {} google sheet'.format(game_wau.name))

## CandyKrack_WAU
game_wau = game_wise_wau[game_wise_wau.Game_Type == 'candyrush_started_playing'][['Date','LastWeekUsers','NewUsers','ReactivatedUsers','WAU']].reset_index()
game_wau = game_wau.drop('index',axis = 1)
game_wau.name = 'CandyKrack_WAU'

ws = client_sheets.open(sheetname).worksheet(game_wau.name)
set_with_dataframe(ws, game_wau)
print('Dataframe written to {} google sheet'.format(game_wau.name))

## SwooperStar_WAU
game_wau = game_wise_wau[game_wise_wau.Game_Type == 'swooperstar_gamelandingscreen'][['Date','LastWeekUsers','NewUsers','ReactivatedUsers','WAU']].reset_index()
game_wau = game_wau.drop('index',axis = 1)
game_wau.name = 'SwooperStar_WAU'

ws = client_sheets.open(sheetname).worksheet(game_wau.name)
set_with_dataframe(ws, game_wau)
print('Dataframe written to {} google sheet'.format(game_wau.name))

## TeenPatti_WAU
game_wau = game_wise_wau[game_wise_wau.Game_Type == 'teenpatti_started_playing'][['Date','LastWeekUsers','NewUsers','ReactivatedUsers','WAU']].reset_index()
game_wau = game_wau.drop('index',axis = 1)
game_wau.name = 'TeenPatti_WAU'

ws = client_sheets.open(sheetname).worksheet(game_wau.name)
set_with_dataframe(ws, game_wau)
print('Dataframe written to {} google sheet'.format(game_wau.name))

del q5,q6,q7,game_wau

##################################################################################################################################
###******************************* Calculation of App CURR,NURR,RURR & WoW
##################################################################################################################################

## App NURR%
q12 = client.query("""
SELECT a.Date as Date,(b.NURR/a.NURR_D) as NURR FROM (
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
""")
app_nurr = q12.to_dataframe()

## App CURR%
q13 = client.query("""
SELECT a.Date as Date,(b.CURR/a.CURR_D) as CURR FROM (
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
""")
app_curr = q13.to_dataframe()

## App RURR%
q14 = client.query("""
SELECT a.Date as Date,(b.RURR/a.RURR_D) as RURR FROM (
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
""")
app_rurr = q14.to_dataframe()

## App WoW%
q15 = client.query("""
SELECT a.Date as Date,(COUNT(DISTINCT CASE WHEN b.device_channel IS NOT NULL THEN a.device_channel END)/COUNT(DISTINCT a.device_channel)) as WoW 
FROM (
SELECT b.date as Date,device_channel --COUNT(DISTINCT developer_identity) as WAU 
FROM (
SELECT date,device_channel
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3` 
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
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3` 
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) b
ON a.Date = b.Date AND a.device_channel = b.device_channel
GROUP BY 1
""")
app_wow = q15.to_dataframe()

app_retention = app_nurr
app_retention = pd.merge(app_retention, app_curr, how='left', on=['Date'])
app_retention = pd.merge(app_retention, app_rurr, how='left', on=['Date'])
app_retention = pd.merge(app_retention, app_wow, how='left', on=['Date'])
app_retention.sort_values(by='Date',inplace=True)
app_retention = app_retention.reset_index()
app_retention = app_retention.drop('index',axis = 1)

app_retention.name = 'App_UA_Retention'

# dataset_ref = client.dataset('derived_data')
# table_ref = dataset_ref.table('App_UA_Retention')
# client.delete_table(table_ref)
# print('Table {}:{} deleted.'.format(dataset_ref, table_ref))
# client.load_table_from_dataframe(app_retention, table_ref).result()
# print('Dataframe loaded to table {}'.format(table_ref.path))

ws = client_sheets.open(sheetname).worksheet(app_retention.name)
set_with_dataframe(ws, app_retention)
print('Dataframe written to {} google sheet'.format(app_retention.name))

del q12,q13,q14,q15

##################################################################################################################################
###******************************* Calculation of Game wise CURR,NURR,RURR & WoW
##################################################################################################################################

## Game wise NURR%
q8 = client.query("""
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
""")
game_wise_nurr = q8.to_dataframe()

## Game wise CURR%
q9 = client.query("""
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
""")
game_wise_curr = q9.to_dataframe()

## Game wise RURR%
q10 = client.query("""
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
""")
game_wise_rurr = q10.to_dataframe()

## Game wise WoW%
q11 = client.query("""
SELECT a.Date as Date,a.body_name as body_name,(COUNT(DISTINCT CASE WHEN b.device_channel IS NOT NULL THEN a.device_channel END)/COUNT(DISTINCT a.device_channel)) as WoW 
FROM (
SELECT b.date as Date,body_name,device_channel --COUNT(DISTINCT developer_identity) as WAU 
FROM (
SELECT date,body_name,device_channel
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3` 
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
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3` 
GROUP BY 1,2,3) a
CROSS JOIN (
SELECT date FROM `swoo-analytics-bq.analytics_data.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2,3) b
ON a.Date = b.Date AND a.body_name = b.body_name AND a.device_channel = b.device_channel
GROUP BY 1,2
""")
game_wise_wow = q11.to_dataframe()

game_wise_retention = game_wise_nurr
game_wise_retention = pd.merge(game_wise_retention, game_wise_curr, how='left', on=['Date','body_name'])
game_wise_retention = pd.merge(game_wise_retention, game_wise_rurr, how='left', on=['Date','body_name'])
game_wise_retention = pd.merge(game_wise_retention, game_wise_wow, how='left', on=['Date','body_name'])
game_wise_retention.sort_values(by=['Date','body_name'],inplace=True)
game_wise_retention = game_wise_retention.reset_index()
game_wise_retention = game_wise_retention.drop('index',axis = 1)

# game_wise_retention.name = 'Game_wise_UA_Retention'

# dataset_ref = client.dataset('derived_data')
# table_ref = dataset_ref.table('Game_wise_UA_Retention')
# client.delete_table(table_ref)
# print('Table {}:{} deleted.'.format(dataset_ref, table_ref))
# client.load_table_from_dataframe(game_wise_retention, table_ref).result()
# print('Dataframe loaded to table {}'.format(table_ref.path))

# ws = client_sheets.open(sheetname).worksheet(game_wise_retention.name)
# set_with_dataframe(ws, game_wise_retention)
# print('Dataframe written to {} google sheet'.format(game_wise_retention.name))

## Trivia_Retention
game_retention = game_wise_retention[game_wise_retention.body_name == 'trivia_started_playing'][['Date','CURR','NURR','RURR','WoW']].reset_index()
game_retention = game_retention.drop('index',axis = 1)
game_retention.name = 'Trivia_Retention'

ws = client_sheets.open(sheetname).worksheet(game_retention.name)
set_with_dataframe(ws, game_retention)
print('Dataframe written to {} google sheet'.format(game_retention.name))

## Bingo_Retention
game_retention = game_wise_retention[game_wise_retention.body_name == 'bingo_started_playing'][['Date','CURR','NURR','RURR','WoW']].reset_index()
game_retention = game_retention.drop('index',axis = 1)
game_retention.name = 'Bingo_Retention'

ws = client_sheets.open(sheetname).worksheet(game_retention.name)
set_with_dataframe(ws, game_retention)
print('Dataframe written to {} google sheet'.format(game_retention.name))

## CandyKrack_Retention
game_retention = game_wise_retention[game_wise_retention.body_name == 'candyrush_started_playing'][['Date','CURR','NURR','RURR','WoW']].reset_index()
game_retention = game_retention.drop('index',axis = 1)
game_retention.name = 'CandyKrack_Retention'

ws = client_sheets.open(sheetname).worksheet(game_retention.name)
set_with_dataframe(ws, game_retention)
print('Dataframe written to {} google sheet'.format(game_retention.name))

## SwooperStar_Retention
game_retention = game_wise_retention[game_wise_retention.body_name == 'swooperstar_gamelandingscreen'][['Date','CURR','NURR','RURR','WoW']].reset_index()
game_retention = game_retention.drop('index',axis = 1)
game_retention.name = 'SwooperStar_Retention'

ws = client_sheets.open(sheetname).worksheet(game_retention.name)
set_with_dataframe(ws, game_retention)
print('Dataframe written to {} google sheet'.format(game_retention.name))

## TeenPatti_Retention
game_retention = game_wise_retention[game_wise_retention.body_name == 'teenpatti_started_playing'][['Date','CURR','NURR','RURR','WoW']].reset_index()
game_retention = game_retention.drop('index',axis = 1)
game_retention.name = 'TeenPatti_Retention'

ws = client_sheets.open(sheetname).worksheet(game_retention.name)
set_with_dataframe(ws, game_retention)
print('Dataframe written to {} google sheet'.format(game_retention.name))

del q8,q9,q10,q11,game_retention

##################################################################################################################################
###******************************* Daily_new_installs
##################################################################################################################################

## Daily_new_installs
q18 = client.query("""
SELECT Date,MAX(DAU) as New_Installs
FROM `swoo-analytics-bq.daily_dashboard.ua_user_first_opened` 
GROUP BY 1
ORDER BY 1
""")
daily_new_installs = q18.to_dataframe()

daily_new_installs.sort_values(by='Date',inplace=True)
daily_new_installs = daily_new_installs.reset_index()
daily_new_installs = daily_new_installs.drop('index',axis = 1)

daily_new_installs.name = 'Daily_new_installs'

ws = client_sheets.open(sheetname).worksheet(daily_new_installs.name)
set_with_dataframe(ws, daily_new_installs)
print('Dataframe written to {} google sheet'.format(daily_new_installs.name))

del q18

##################################################################################################################################
###******************************* Install_retention
##################################################################################################################################

## Install_retention
q19 = client.query("""
SELECT *
FROM `swoo-analytics-bq.daily_dashboard.ua_retention`
ORDER BY 1 LIMIT 2000
""")
install_retention = q19.to_dataframe()

install_retention.sort_values(by='Date',inplace=True)
install_retention = install_retention.reset_index()
install_retention = install_retention.drop('index',axis = 1)

install_retention.name = 'Install_retention'

ws = client_sheets.open(sheetname).worksheet(install_retention.name)
set_with_dataframe(ws, install_retention)
print('Dataframe written to {} google sheet'.format(install_retention.name))

del q19

##################################################################################################################################
###******************************* Users_activity_by_their_usage
##################################################################################################################################

## Users_activity_by_their_usage
q20 = client.query("""
SELECT week,x_times_opened,COUNT(DISTINCT user_id) AS users
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, device_channel AS user_id,COUNT(DISTINCT date) AS x_times_opened
FROM `swoo-analytics-bq.derived_data.ua_app_derived_data_v3`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY) AND date < CURRENT_DATE()
AND type IN ('OPEN','FIRST_OPEN')
GROUP BY 1,2)
GROUP BY 1,2
""")
users_app_open_activity = q20.to_dataframe()

users_app_open_activity.sort_values(by=['week','x_times_opened'],inplace=True)
users_app_open_activity = users_app_open_activity.reset_index()
users_app_open_activity = users_app_open_activity.drop('index',axis = 1)

users_app_open_activity.name = 'Users_activity_by_their_usage'

ws = client_sheets.open(sheetname).worksheet(users_app_open_activity.name)
set_with_dataframe(ws, users_app_open_activity)
print('Dataframe written to {} google sheet'.format(users_app_open_activity.name))

del q20

##################################################################################################################################
###******************************* Game_players_activity
##################################################################################################################################

## Game_players_activity
q21 = client.query("""
SELECT week,x_times_games_played,COUNT(DISTINCT user_id) AS users
FROM (
SELECT EXTRACT(WEEK(MONDAY) FROM date) AS week, device_channel AS user_id,COUNT(DISTINCT date) AS x_times_games_played
FROM `swoo-analytics-bq.derived_data.ua_game_derived_data_v3`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 31 DAY) AND date < CURRENT_DATE()
GROUP BY 1,2)
GROUP BY 1,2
""")
game_players_activity = q21.to_dataframe()

game_players_activity.sort_values(by=['week','x_times_games_played'],inplace=True)
game_players_activity = game_players_activity.reset_index()
game_players_activity = game_players_activity.drop('index',axis = 1)

game_players_activity.name = 'Game_players_activity_by_their_usage'

ws = client_sheets.open(sheetname).worksheet(game_players_activity.name)
set_with_dataframe(ws, game_players_activity)
print('Dataframe written to {} google sheet'.format(game_players_activity.name))

del q21

##################################################################################################################################
###******************************* Overall_session_time_per_day
##################################################################################################################################

## Overall_session_time_per_day
q22 = client.query("""
SELECT date as Date,`range` as decile,MAX(users) as users,MAX(avg_session_length) as avg_session_length
FROM `swoo-analytics-bq.daily_dashboard.ua_user_session_decile` 
GROUP BY 1,2
ORDER BY 1,2
""")
avg_session_length = q22.to_dataframe()

avg_session_length.name = 'Overall_session_time_per_day'

ws = client_sheets.open(sheetname).worksheet(avg_session_length.name)
set_with_dataframe(ws, avg_session_length)
print('Dataframe written to {} google sheet'.format(avg_session_length.name))

del q22

##################################################################################################################################
###******************************* Game_wise DAU (x_games_played)
##################################################################################################################################

## Game_wise_DAU by x_games_played
s1="""
SELECT date,x_games_played,body_name,COUNT(DISTINCT device_channel) as users
FROM (
SELECT date,device_channel,body_name,COUNT(times) as x_games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,body_name,EXTRACT(HOUR FROM occurred) as times
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= """
s2=" AND DATE(occurred) <= "
s3="""
AND type IN ('CUSTOM')
AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen')))
GROUP BY 1,2,3,4)
GROUP BY 1,2,3)
GROUP BY 1,2,3"""

q16=s1+'\''+sd+'\''+s2+'\''+ed+'\''+s3
game_wise_dau = pd.read_gbq(q16, project_id=project_id, reauth=True, private_key=private_key, dialect='standard')

game_wise_dau.sort_values(by=['date','x_games_played','body_name'],inplace=True)
game_wise_dau = game_wise_dau.reset_index()
game_wise_dau = game_wise_dau.drop('index',axis = 1)

# game_wise_dau.name = 'Game_wise_DAU'

# ws = client_sheets.open(sheetname).worksheet(game_wise_dau.name)
# set_with_dataframe(ws, game_wise_dau)
# print('Dataframe written to {} google sheet'.format(game_wise_dau.name))

## Trivia_DAU
game_dau = pd.pivot_table(game_wise_dau[game_wise_dau.body_name == 'trivia_started_playing'][['date','x_games_played','users']], values='users', index=['date'], columns=['x_games_played'], aggfunc=np.sum)
game_dau = game_dau.reset_index()
game_dau.name = 'Trivia_DAU'

ws = client_sheets.open(sheetname).worksheet(game_dau.name)
set_with_dataframe(ws, game_dau)
print('Dataframe written to {} google sheet'.format(game_dau.name))

## Bingo_DAU
game_dau = pd.pivot_table(game_wise_dau[game_wise_dau.body_name == 'bingo_started_playing'][['date','x_games_played','users']], values='users', index=['date'], columns=['x_games_played'], aggfunc=np.sum)
game_dau = game_dau.reset_index()
game_dau.name = 'Bingo_DAU'

ws = client_sheets.open(sheetname).worksheet(game_dau.name)
set_with_dataframe(ws, game_dau)
print('Dataframe written to {} google sheet'.format(game_dau.name))

## CandyKrack_DAU
game_dau = pd.pivot_table(game_wise_dau[game_wise_dau.body_name == 'candyrush_started_playing'][['date','x_games_played','users']], values='users', index=['date'], columns=['x_games_played'], aggfunc=np.sum)
game_dau = game_dau.reset_index()
game_dau.name = 'CandyKrack_DAU'

ws = client_sheets.open(sheetname).worksheet(game_dau.name)
set_with_dataframe(ws, game_dau)
print('Dataframe written to {} google sheet'.format(game_dau.name))

## SwooperStar_DAU
game_dau = pd.pivot_table(game_wise_dau[game_wise_dau.body_name == 'swooperstar_gamelandingscreen'][['date','x_games_played','users']], values='users', index=['date'], columns=['x_games_played'], aggfunc=np.sum)
game_dau = game_dau.reset_index()
game_dau.name = 'SwooperStar_DAU'

ws = client_sheets.open(sheetname).worksheet(game_dau.name)
set_with_dataframe(ws, game_dau)
print('Dataframe written to {} google sheet'.format(game_dau.name))

## TeenPatti_DAU
game_dau = pd.pivot_table(game_wise_dau[game_wise_dau.body_name == 'teenpatti_started_playing'][['date','x_games_played','users']], values='users', index=['date'], columns=['x_games_played'], aggfunc=np.sum)
game_dau = game_dau.reset_index()
game_dau.name = 'TeenPatti_DAU'

ws = client_sheets.open(sheetname).worksheet(game_dau.name)
set_with_dataframe(ws, game_dau)
print('Dataframe written to {} google sheet'.format(game_dau.name))

del q16,s1,s2,s3,game_dau

##################################################################################################################################
###******************************* App_game_players DAU (x_games_played)
##################################################################################################################################

## App_game_players_DAU by x_games_played
s1="""
SELECT date,x_games_played,COUNT(DISTINCT device_channel) as users
FROM (
SELECT date,device_channel,COUNT(times) as x_games_played 
FROM (
SELECT DATE(occurred) as date,device_channel,EXTRACT(HOUR FROM occurred) as times
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3` 
WHERE DATE(occurred) >= """
s2=" AND DATE(occurred) <= "
s3="""
AND type IN ('CUSTOM')
AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen')))
GROUP BY 1,2,3)
GROUP BY 1,2)
GROUP BY 1,2"""

q17=s1+'\''+sd+'\''+s2+'\''+ed+'\''+s3
app_game_players_dau = pd.read_gbq(q17, project_id=project_id, reauth=True, private_key=private_key, dialect='standard')

app_game_players_dau.sort_values(by=['date','x_games_played'],inplace=True)
app_game_players_dau = app_game_players_dau.reset_index()
app_game_players_dau = app_game_players_dau.drop('index',axis = 1)

app_game_players_dau.name = 'App_game_players_DAU'

ws = client_sheets.open(sheetname).worksheet(app_game_players_dau.name)
set_with_dataframe(ws, app_game_players_dau)
print('Dataframe written to {} google sheet'.format(app_game_players_dau.name))

del q17,s1,s2,s3

##################################################################################################################################
###******************************* Game_players_by_shows
##################################################################################################################################

## Game_players_by_shows
s1="""
SELECT DATE(occurred) AS date,body_name,EXTRACT(HOUR FROM occurred) AS hour,COUNT(DISTINCT(device_channel)) AS users
FROM `swoo-analytics-bq.analytics_data.ua_derived_data_v3`
WHERE DATE(occurred) >= """
s2=" AND DATE(occurred) <= "
s3="""
AND (body_name LIKE '%_started_playing%' OR (body_name IN ('swooperstar_gamelandingscreen')))
GROUP BY 1,2,3"""

q23=s1+'\''+sd+'\''+s2+'\''+ed+'\''+s3
game_players_by_shows = pd.read_gbq(q23, project_id=project_id, reauth=True, private_key=private_key, dialect='standard')

game_players_by_shows.sort_values(by=['date','body_name','hour'],inplace=True)
game_players_by_shows = game_players_by_shows.reset_index()
game_players_by_shows = game_players_by_shows.drop('index',axis = 1)

game_players_by_shows.name = 'Game_players_by_shows'

ws = client_sheets.open(sheetname).worksheet(game_players_by_shows.name)
set_with_dataframe(ws, game_players_by_shows)
print('Dataframe written to {} google sheet'.format(game_players_by_shows.name))

del q23,s1,s2,s3

##################################################################################################################################
###******************************* Removing_the_created_temporary_tables
##################################################################################################################################

dataset_id = 'derived_data'
# Set the destination table
table_ref = client.dataset(dataset_id).table('App_UA_Retention_WAU')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('App_UA_Retention_CURR')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('App_UA_Retention_NURR')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('App_UA_Retention_RURR')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_WAU')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_CURR')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_NURR')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))
# Set the destination table
table_ref = client.dataset(dataset_id).table('Game_wise_UA_Retention_RURR')
client.delete_table(table_ref)
print('Follwing table {} has been deleted.'.format(table_ref.path))

##################################################################################################################################
###******************************* p2p_app_dau_and_contest_players
##################################################################################################################################

## p2p_app_dau_and_contest_players
q24 = client.query("""
SELECT date,Pay2Play_App_DAU as p2p_app_dau,Pay2Play_GamePlayers as contest_players
FROM `swoo-analytics-bq.daily_dashboard.ua_p2p_funnel_7_0_0`
GROUP BY 1,2,3
ORDER BY 1
""")
data = q24.to_dataframe()

data.name = 'p2p_app_dau_and_contest_players'

ws = client_sheets.open(sheetname).worksheet(data.name)
set_with_dataframe(ws, data)
print('Dataframe written to {} google sheet'.format(data.name))

del q24

##################################################################################################################################
###******************************* p2p_contest_players_by_contest_type_and_avg_replay
##################################################################################################################################

q25 = client.query("""
SELECT *
FROM `swoo-analytics-bq.daily_dashboard.ua_p2p_contest_players` 
ORDER BY 1,2
""")
data = q25.to_dataframe()

data['avg_replay'] = data['contest_plays']/data['contest_players']

## p2p_contest_players_by_contest_type
p2p_contest_players_by_contest_type = pd.pivot_table(data, values='contest_players', index=['date'], columns=['contest_type'], aggfunc=np.sum)
p2p_contest_players_by_contest_type = p2p_contest_players_by_contest_type.reset_index()
p2p_contest_players_by_contest_type.name = 'p2p_contest_players_by_contest_type'

ws = client_sheets.open(sheetname).worksheet(p2p_contest_players_by_contest_type.name)
set_with_dataframe(ws, p2p_contest_players_by_contest_type)
print('Dataframe written to {} google sheet'.format(p2p_contest_players_by_contest_type.name))

## p2p_avg_replay_by_contest_type
p2p_avg_replay_by_contest_type = pd.pivot_table(data, values='avg_replay', index=['date'], columns=['contest_type'], aggfunc=np.sum)
p2p_avg_replay_by_contest_type = p2p_avg_replay_by_contest_type.reset_index()
p2p_avg_replay_by_contest_type.name = 'p2p_avg_replay_by_contest_type'

ws = client_sheets.open(sheetname).worksheet(p2p_avg_replay_by_contest_type.name)
set_with_dataframe(ws, p2p_avg_replay_by_contest_type)
print('Dataframe written to {} google sheet'.format(p2p_avg_replay_by_contest_type.name))

del q25





