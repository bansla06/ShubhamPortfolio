import os
import base64
import requests
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

API_KEY    = os.environ["AMPLITUDE_API_KEY"]
SECRET_KEY = os.environ["AMPLITUDE_SECRET_KEY"]

BASE_URL = "https://amplitude.com/api/2"


def _auth_header() -> dict:
    token = base64.b64encode(f"{API_KEY}:{SECRET_KEY}".encode()).decode()
    return {"Authorization": f"Basic {token}"}


def _segmentation(event_type: str, start_date: str, end_date: str,
                  metric: str = "uniques", interval: int = 1,
                  group_by: str = None) -> pd.DataFrame:
    params = {
        "e":    f'{{"event_type":"{event_type}"}}',
        "start": start_date.replace("-", ""),
        "end":   end_date.replace("-", ""),
        "m":     metric,
        "i":     interval,
    }
    if group_by:
        params["s"] = f'[{{"prop":"{group_by}","type":"user"}}]'

    response = requests.get(f"{BASE_URL}/events/segmentation", params=params, headers=_auth_header())
    response.raise_for_status()
    data = response.json().get("data", {})

    series  = data.get("series", [[]])[0]
    xvalues = data.get("xValues", [])
    return pd.DataFrame({"date": xvalues, metric: series})


def _funnel(events: list, start_date: str, end_date: str) -> pd.DataFrame:
    events_payload = [{"event_type": e} for e in events]
    payload = {
        "e":     events_payload,
        "start": start_date.replace("-", ""),
        "end":   end_date.replace("-", ""),
    }
    response = requests.post(f"{BASE_URL}/funnels", json=payload, headers=_auth_header())
    response.raise_for_status()
    steps = response.json().get("data", {}).get("steps", [])
    return pd.DataFrame([
        {"step": s.get("step_label", events[i] if i < len(events) else f"Step {i+1}"),
         "users": s.get("users", 0)}
        for i, s in enumerate(steps)
    ])


def run_amplitude_query(params: dict) -> pd.DataFrame:
    query_type = params.get("query_type", "segmentation")
    if query_type == "funnel":
        return _funnel(
            events=params["events"],
            start_date=params["start_date"],
            end_date=params["end_date"],
        )
    return _segmentation(
        event_type=params["event_type"],
        start_date=params["start_date"],
        end_date=params["end_date"],
        metric=params.get("metric", "uniques"),
        interval=params.get("interval", 1),
        group_by=params.get("group_by"),
    )
