import io
import re

import pandas as pd
import requests


def apply_combo_penalty(
    df: pd.DataFrame,
    price_threshold: float = 500,
    penalty_pct: float = 0.40,
) -> pd.DataFrame:
    """Reduce rank score for COMBO items below a price threshold."""
    df = df.copy()
    mask = (df["item_price"] <= price_threshold) & (
        df["item_code"].astype(str).str.startswith("COMBO_")
    )
    df.loc[mask, "rank_score"] = df.loc[mask, "rank_score"] * (1 - penalty_pct)
    return df


def apply_item_overrides(df: pd.DataFrame, overrides_df: pd.DataFrame) -> pd.DataFrame:
    """Boost or penalize specific item codes by a given percentage.

    overrides_df columns: item_code, override_type ('boost'/'penalty'), adjustment_pct
    """
    df = df.copy()
    for _, row in overrides_df.iterrows():
        item_code = str(row["item_code"])
        override_type = str(row["override_type"]).strip().lower()
        adj_pct = float(row["adjustment_pct"])
        mask = df["item_code"].astype(str) == item_code
        if override_type == "boost":
            df.loc[mask, "rank_score"] = df.loc[mask, "rank_score"] * (1 + adj_pct)
        elif override_type == "penalty":
            df.loc[mask, "rank_score"] = df.loc[mask, "rank_score"] * (1 - adj_pct)
    return df


def apply_brand_boost(
    df: pd.DataFrame,
    brands: list,
    boost_pct: float = 0.60,
) -> pd.DataFrame:
    """Move selected brands higher by reducing their score (lower score = better rank)."""
    df = df.copy()
    df.loc[df["brandname"].isin(brands), "rank_score"] = (
        df.loc[df["brandname"].isin(brands), "rank_score"] * (1 - boost_pct)
    )
    df["rank_score"] = df["rank_score"].round()
    df = df.sort_values("rank_score", ascending=True).reset_index(drop=True)
    df["rank_score"] = range(1, len(df) + 1)
    return df


def remove_free_l1(df: pd.DataFrame) -> pd.DataFrame:
    """Drop items categorised as Free-L1."""
    return df[df["categoryl1"] != "Free-L1"].reset_index(drop=True)


def apply_anti_clustering(df: pd.DataFrame) -> pd.DataFrame:
    """Prevent consecutive products from the same brand by nudging ranks apart."""
    df = df.copy()
    df = df.sort_values("rank_score", ascending=False).reset_index(drop=True)
    for i in range(1, len(df) - 1):
        if df.loc[i, "brandname"] == df.loc[i + 1, "brandname"]:
            df.loc[i + 1, "rank_score"] += 2
    df["rank_score"] = df["rank_score"].rank(method="first")
    df = df.sort_values("rank_score", ascending=False).reset_index(drop=True)
    return df


def finalize_ranking(df: pd.DataFrame) -> pd.DataFrame:
    """Assign final integer product_priority (1 = best)."""
    df = df.copy()
    df["product_priority"] = (
        df["rank_score"].rank(ascending=False, method="first").astype(int)
    )
    df = df.sort_values("product_priority").reset_index(drop=True)
    return df


def load_brand_boost_from_sheet(sheet_url: str) -> list:
    """Read brand names from a Google Sheet with a 'BrandBoost' column."""
    pattern = r"https://docs\.google\.com/spreadsheets/d/([a-zA-Z0-9-_]+)"
    match = re.search(pattern, sheet_url)
    if not match:
        raise ValueError("Invalid Google Sheet URL.")
    sheet_id = match.group(1)

    gid_match = re.search(r"gid=(\d+)", sheet_url)
    gid_param = f"gid={gid_match.group(1)}&" if gid_match else ""

    export_url = (
        f"https://docs.google.com/spreadsheets/d/{sheet_id}/export?{gid_param}format=csv"
    )
    response = requests.get(export_url, verify=False, timeout=15)
    response.raise_for_status()
    gdf = pd.read_csv(io.StringIO(response.text))
    return gdf["BrandBoost"].dropna().tolist()
