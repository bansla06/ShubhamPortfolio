import os

from dotenv import load_dotenv
from google.cloud import bigquery
from google.oauth2 import service_account

from config.settings import settings

load_dotenv()


def get_bq_client() -> bigquery.Client:
    creds_path = settings.credentials_path
    if creds_path and os.path.exists(creds_path):
        credentials = service_account.Credentials.from_service_account_file(creds_path)
        return bigquery.Client(project=settings.project_id, credentials=credentials)
    return bigquery.Client(project=settings.project_id)


def run_query(sql: str) -> bigquery.table.RowIterator:
    client = get_bq_client()
    return client.query(sql).result()


def _load_sql_template(filename: str) -> str:
    path = os.path.join(os.path.dirname(__file__), "..", "sql", filename)
    with open(path) as f:
        return f.read()


def _table_placeholders() -> dict:
    return dict(
        project_id=settings.project_id,
        dataset_agg=settings.dataset_agg,
        dataset_dwh=settings.dataset_dwh,
        dataset_derived=settings.dataset_derived,
        table_orders=settings.table_orders,
        table_events=settings.table_events,
        table_item=settings.table_item,
        table_brand=settings.table_brand,
        table_category=settings.table_category,
        table_article=settings.table_article,
        table_popularity_cache=settings.table_popularity_cache,
    )


def build_part1_query() -> str:
    return _load_sql_template("part1_views_sales.sql").format(**_table_placeholders())


def build_part2_query() -> str:
    return _load_sql_template("part2_final_dataset.sql").format(**_table_placeholders())


def fetch_raw_data():
    """Run Part 2 SQL and return a DataFrame ready for scoring."""
    import pandas as pd
    result = run_query(build_part2_query())
    return result.to_dataframe().fillna(0)
