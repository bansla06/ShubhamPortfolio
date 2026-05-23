import os
from google.cloud import bigquery
from google.oauth2 import service_account
from dotenv import load_dotenv

load_dotenv()

CREDENTIALS_PATH = os.environ["BQ_CREDENTIALS_PATH"]
PROJECT_ID       = os.environ["BQ_PROJECT_ID"]
DATASET          = os.environ["BQ_DATASET"]
TABLE            = os.environ["BQ_TABLE"]

FULL_TABLE_ID = f"`{PROJECT_ID}.{DATASET}.{TABLE}`"

_client = None

def get_client() -> bigquery.Client:
    global _client
    if _client is None:
        credentials = service_account.Credentials.from_service_account_file(
            CREDENTIALS_PATH,
            scopes=["https://www.googleapis.com/auth/bigquery"],
        )
        _client = bigquery.Client(credentials=credentials, project=PROJECT_ID)
    return _client


def run_query(sql: str):
    return get_client().query(sql).result()


def test_connection():
    result = run_query(f"SELECT 1 AS ok FROM {FULL_TABLE_ID} LIMIT 1")
    return list(result)
