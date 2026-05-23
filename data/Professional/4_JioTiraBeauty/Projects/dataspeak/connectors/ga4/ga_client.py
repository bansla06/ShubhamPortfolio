import os
import pandas as pd
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    RunReportRequest, DateRange, Dimension, Metric,
)
from google.oauth2 import service_account
from dotenv import load_dotenv

load_dotenv()

CREDENTIALS_PATH = os.environ["GA4_CREDENTIALS_PATH"]
PROPERTY_ID      = os.environ["GA4_PROPERTY_ID"]

_ga_client = None

def _get_client():
    global _ga_client
    if _ga_client is None:
        credentials = service_account.Credentials.from_service_account_file(
            CREDENTIALS_PATH,
            scopes=["https://www.googleapis.com/auth/analytics.readonly"],
        )
        _ga_client = BetaAnalyticsDataClient(credentials=credentials)
    return _ga_client


def run_ga_report(
    dimensions: list,
    metrics: list,
    start_date: str,
    end_date: str,
) -> pd.DataFrame:
    client = _get_client()
    request = RunReportRequest(
        property=f"properties/{PROPERTY_ID}",
        dimensions=[Dimension(name=d) for d in dimensions],
        metrics=[Metric(name=m) for m in metrics],
        date_ranges=[DateRange(start_date=start_date, end_date=end_date)],
    )
    response = client.run_report(request)

    dim_names    = [h.name for h in response.dimension_headers]
    metric_names = [h.name for h in response.metric_headers]
    rows = []
    for row in response.rows:
        record = {dim_names[i]: row.dimension_values[i].value for i in range(len(dim_names))}
        record.update({metric_names[i]: row.metric_values[i].value for i in range(len(metric_names))})
        rows.append(record)

    return pd.DataFrame(rows)
