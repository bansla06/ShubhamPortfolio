import os
from google.cloud import bigquery
from google.oauth2 import service_account
from dotenv import load_dotenv

load_dotenv()

CREDENTIALS_PATH = os.environ["BQ_CREDENTIALS_PATH"]
PROJECT_ID       = os.environ["BQ_PROJECT_ID"]
EVAL_DATASET     = os.environ["BQ_EVAL_DATASET"]
EVAL_TABLE       = os.environ.get("BQ_EVAL_TABLE", "evaluation_cache")

FULL_EVAL_TABLE = f"`{PROJECT_ID}.{EVAL_DATASET}.{EVAL_TABLE}`"

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


EVAL_SCHEMA = [
    bigquery.SchemaField("id",                "STRING",    mode="REQUIRED"),
    bigquery.SchemaField("timestamp",         "TIMESTAMP", mode="NULLABLE"),
    bigquery.SchemaField("query",             "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("query_description", "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("raw_description",   "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("dataset_name",      "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("metric_names",      "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("short_description", "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("query_result",      "STRING",    mode="NULLABLE"),
    bigquery.SchemaField("row_count",         "INTEGER",   mode="NULLABLE"),
]


def ensure_table_exists():
    client  = get_client()
    tbl_ref = bigquery.TableReference.from_string(
        f"{PROJECT_ID}.{EVAL_DATASET}.{EVAL_TABLE}"
    )
    try:
        table = client.get_table(tbl_ref)
        existing_fields = {f.name for f in table.schema}
        new_fields = [f for f in EVAL_SCHEMA if f.name not in existing_fields]
        if new_fields:
            table.schema = list(table.schema) + new_fields
            client.update_table(table, ["schema"])
    except Exception:
        table = bigquery.Table(tbl_ref, schema=EVAL_SCHEMA)
        client.create_table(table, exists_ok=True)


def run_query(sql: str):
    return get_client().query(sql).result()


def insert_row(row: dict):
    errors = get_client().insert_rows_json(
        f"{PROJECT_ID}.{EVAL_DATASET}.{EVAL_TABLE}", [row]
    )
    if errors:
        raise RuntimeError(f"BigQuery insert errors: {errors}")


def fetch_all_cache():
    return list(run_query(
        f"SELECT * FROM {FULL_EVAL_TABLE} ORDER BY timestamp DESC"
    ))


def update_entry(entry_id: str, fields: dict):
    set_clauses = ", ".join(f"{k} = @{k}" for k in fields)
    params = [
        bigquery.ScalarQueryParameter(k, "STRING", v)
        for k, v in fields.items()
    ] + [bigquery.ScalarQueryParameter("entry_id", "STRING", entry_id)]
    job_config = bigquery.QueryJobConfig(query_parameters=params)
    sql = f"UPDATE {FULL_EVAL_TABLE} SET {set_clauses} WHERE id = @entry_id"
    get_client().query(sql, job_config=job_config).result()
