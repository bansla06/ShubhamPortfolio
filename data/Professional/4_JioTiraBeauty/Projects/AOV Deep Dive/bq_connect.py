from google.cloud import bigquery
from google.oauth2 import service_account

CREDENTIALS_PATH = "/Users/shubham.bansla/Library/CloudStorage/OneDrive-RelianceCorporateITParkLimited/Permissions/bq_credential.json"
PROJECT_ID = "tira-prod"

credentials = service_account.Credentials.from_service_account_file(
    CREDENTIALS_PATH,
    scopes=["https://www.googleapis.com/auth/bigquery"]
)

client = bigquery.Client(credentials=credentials, project=PROJECT_ID)

# Test connection with a simple query
query = "SELECT 1 AS test"
result = client.query(query).result()

for row in result:
    print(f"Connection successful! Test value: {row.test}")
