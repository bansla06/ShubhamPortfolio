import pandas as pd
import numpy as np
from config.weights import Weights


def apply_social_nudge(df: pd.DataFrame) -> pd.DataFrame:
    def _sale_message(sale):
        if sale >= 1000:
            return "1000+ units sold in the last month"
        elif sale > 500:
            return "500+ units sold in the last month"
        return ""

    df = df.copy()
    df["social_nudge"] = df["last_30_days_sale"].apply(_sale_message)
    return df


def _normalize(series: pd.Series, reference: pd.Series = None) -> pd.Series:
    """Divide by reference series (or self), replace inf, then scale to [0, 1]."""
    if reference is not None:
        ratio = series / reference
    else:
        ratio = series.copy()

    ratio = ratio.replace([np.inf, -np.inf], 0).fillna(0)
    max_val = ratio.max()
    if max_val == 0:
        return ratio
    return ratio / max_val


def compute_scores(df: pd.DataFrame, weights: Weights) -> pd.DataFrame:
    df = df.copy()

    # Variable 1 — Product Aging (newer = better; items older than 20 days score 0)
    df["product_aging_value"] = _normalize(df["product_aging"], df["avg_product_aging"])
    df["product_aging_value"] = 1 - df["product_aging_value"]
    df.loc[df["product_aging"] > 20, "product_aging_value"] = 0
    df["product_aging_weighted"] = df["product_aging_value"] * weights.aging

    # Variable 2 — Inventory
    df["inventory_value"] = _normalize(df["cbrt_inventory_left"])
    df["inventory_weighted"] = df["inventory_value"] * weights.inventory

    # Variable 3 — Last 15 Days Revenue (two tracks)
    df["last_15_days_revenue_value"] = _normalize(
        df["cbrt_last_15_days_revenue"], df["avg_last_15_days_revenue"]
    )
    df["last_15_days_revenue_weighted_inv"] = (
        df["last_15_days_revenue_value"] * weights.last_15_days_revenue_inv_track
    )
    df["last_15_days_revenue_weighted_main"] = (
        df["last_15_days_revenue_value"] * weights.last_15_days_revenue_main_track
    )

    # Variable 4 — Older Revenue (15–75 days ago)
    df["older_revenue_value"] = _normalize(
        df["cbrt_after_75_before_last_15_days_revenue"],
        df["avg_after_75_before_last_15_days_revenue"],
    )
    df["older_revenue_weighted"] = df["older_revenue_value"] * weights.older_revenue

    # Variable 5 — Last 15 Days Views
    df["last_15_days_view_value"] = _normalize(
        df["cbrt_last_15_days_users_view"], df["avg_last_15_days_users_view"]
    )
    df["last_15_days_view_weighted"] = df["last_15_days_view_value"] * weights.last_15_days_views

    # Variable 6 — Older Views (15–75 days ago)
    df["older_view_value"] = _normalize(
        df["cbrt_after_75_before_last_15_days_users_view"],
        df["avg_after_75_before_last_15_days_users_view"],
    )
    df["older_view_weighted"] = df["older_view_value"] * weights.older_views

    # Variable 7 — Last 15 Days Sales
    df["last_15_days_sale_value"] = _normalize(
        df["cbrt_last_15_days_sale"], df["avg_last_15_days_sale"]
    )
    df["last_15_days_sale_weighted"] = df["last_15_days_sale_value"] * weights.last_15_days_sales

    # Variable 8 — Older Sales (15–75 days ago)
    df["older_sale_value"] = _normalize(
        df["cbrt_after_75_before_last_15_days_sale"],
        df["avg_after_75_before_last_15_days_sale"],
    )
    df["older_sale_weighted"] = df["older_sale_value"] * weights.older_sales

    # Variable 9 — RPV (Revenue Per View)
    rpv_raw = (df["cbrt_last_15_days_revenue"] / df["cbrt_last_15_days_users_view"]).replace(
        [np.inf, -np.inf], 0
    ).fillna(0)
    df["rpv_value"] = _normalize(rpv_raw)
    df["rpv_weighted"] = df["rpv_value"] * weights.rpv

    # Variable 10 — SPV (Sales Per View)
    spv_raw = (df["cbrt_last_15_days_sale"] / df["cbrt_last_15_days_users_view"]).replace(
        [np.inf, -np.inf], 0
    ).fillna(0)
    df["spv_value"] = _normalize(spv_raw)
    df["spv_weighted"] = df["spv_value"] * weights.spv

    # ── Rank Tracks ────────────────────────────────────────────────────────────
    df["inventory_age_rank"] = (
        df["product_aging_weighted"]
        + df["inventory_weighted"]
        + df["last_15_days_revenue_weighted_inv"]
    )
    # Items older than 20 days are excluded from the inventory/age track
    df.loc[df["product_aging"] > 20, "inventory_age_rank"] = 0

    df["rest_variable_rank"] = (
        df["last_15_days_revenue_weighted_main"]
        + df["older_revenue_weighted"]
        + df["last_15_days_view_weighted"]
        + df["older_view_weighted"]
        + df["last_15_days_sale_weighted"]
        + df["older_sale_weighted"]
        + df["rpv_weighted"]
        + df["spv_weighted"]
    )

    df["rank_score"] = df[["inventory_age_rank", "rest_variable_rank"]].max(axis=1)

    return df
