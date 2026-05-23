##################################################################################################################################
###******************************* Connecting to BigQuery
##################################################################################################################################
from google.cloud import bigquery
from google.oauth2 import service_account
credentials = service_account.Credentials.from_service_account_file('/path/to/service-account.json')
project_id = 'your-project-id'
client = bigquery.Client(credentials= credentials,project=project_id)
private_key = '/path/to/service-account.json'
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
creds = ServiceAccountCredentials.from_json_keyfile_name('/path/to/service-account.json', scope)
client_sheets = gspread.authorize(creds)
print('Connection to Google Sheets is successful')
#import pandas as pd
from gspread_dataframe import get_as_dataframe, set_with_dataframe

sheetname = "Product_deck_automated_sheet"


##################################################################################################################################
###******************************* Importing 'datetime' module
##################################################################################################################################

from datetime import datetime,timedelta
start_ref = datetime.today().date() - timedelta(days=9)
end_ref = datetime.today().date() - timedelta(days=3)

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
#### ua_app_processed_db_v3
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('ua_app_processed_db_v3')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT date,type,device_channel
FROM `your-project-id.reporting_db.ua_app_processed_db_v1`
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
#### ua_game_processed_db_v3
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('ua_game_processed_db_v3')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT date,body_name,device_channel
FROM `your-project-id.app_analytics.ua_processed_db_v1`
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
dataset_id = 'processed_db'
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
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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
dataset_id = 'processed_db'
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
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) a
JOIN (
SELECT b.date as date,device_channel
FROM (
SELECT date,device_channel
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_NURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,device_channel--,COUNT(DISTINCT developer_identity) AS NewUsers
FROM (
SELECT date,device_channel
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_RURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,device_channel 
FROM (
SELECT date,device_channel
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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

### -------------------------------------------------------...##################################################################################################################################
###******************************* Connecting to BigQuery
##################################################################################################################################
from google.cloud import bigquery
from google.oauth2 import service_account
credentials = service_account.Credentials.from_service_account_file('/path/to/service-account.json')
project_id = 'your-project-id'
client = bigquery.Client(credentials= credentials,project=project_id)
private_key = '/path/to/service-account.json'
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
creds = ServiceAccountCredentials.from_json_keyfile_name('/path/to/service-account.json', scope)
client_sheets = gspread.authorize(creds)
print('Connection to Google Sheets is successful')
#import pandas as pd
from gspread_dataframe import get_as_dataframe, set_with_dataframe

sheetname = "Product_deck_automated_sheet"


##################################################################################################################################
###******************************* Importing 'datetime' module
##################################################################################################################################

from datetime import datetime,timedelta
start_ref = datetime.today().date() - timedelta(days=9)
end_ref = datetime.today().date() - timedelta(days=3)

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
#### ua_app_processed_db_v3
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('ua_app_processed_db_v3')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT date,type,device_channel
FROM `your-project-id.reporting_db.ua_app_processed_db_v1`
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
#### ua_game_processed_db_v3
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('ua_game_processed_db_v3')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT date,body_name,device_channel
FROM `your-project-id.app_analytics.ua_processed_db_v1`
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
dataset_id = 'processed_db'
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
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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
dataset_id = 'processed_db'
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
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
WHERE date >= '2018-05-01' AND date <= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
GROUP BY 1) b
WHERE a.date >= DATE_SUB(b.date, INTERVAL 13 DAY) AND a.date <= DATE_SUB(b.date, INTERVAL 7 DAY)
GROUP BY 1,2) a
JOIN (
SELECT b.date as date,device_channel
FROM (
SELECT date,device_channel
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_NURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,device_channel--,COUNT(DISTINCT developer_identity) AS NewUsers
FROM (
SELECT date,device_channel
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
WHERE type = 'FIRST_OPEN'
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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
dataset_id = 'processed_db'
table_ref = client.dataset(dataset_id).table('App_UA_Retention_RURR')
job_config = bigquery.QueryJobConfig()
job_config.destination = table_ref
job_config.write_disposition = bigquery.WriteDisposition.WRITE_TRUNCATE
sql = """
SELECT b.date as Date,device_channel 
FROM (
SELECT date,device_channel
FROM `your-project-id.processed_db.ua_app_processed_db_v3`
GROUP BY 1,2) a
CROSS JOIN (
SELECT date FROM `your-project-id.app_analytics.dates_refer`
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

### -------------------------------------------------------...