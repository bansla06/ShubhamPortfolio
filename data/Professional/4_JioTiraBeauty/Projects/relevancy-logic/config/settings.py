import os
from dataclasses import dataclass
from dotenv import load_dotenv

load_dotenv()


@dataclass
class Settings:
    # GCP
    project_id: str = os.getenv("BQ_PROJECT_ID", "")
    credentials_path: str = os.getenv("BQ_CREDENTIALS_PATH", "")

    # Datasets
    dataset_agg: str = os.getenv("BQ_DATASET_AGG", "")
    dataset_dwh: str = os.getenv("BQ_DATASET_DWH", "")
    dataset_derived: str = os.getenv("BQ_DATASET_DERIVED", "")

    # Tables
    table_orders: str = os.getenv("BQ_TABLE_ORDERS", "")
    table_events: str = os.getenv("BQ_TABLE_EVENTS", "")
    table_item: str = os.getenv("BQ_TABLE_ITEM", "")
    table_brand: str = os.getenv("BQ_TABLE_BRAND", "")
    table_category: str = os.getenv("BQ_TABLE_CATEGORY", "")
    table_article: str = os.getenv("BQ_TABLE_ARTICLE", "")
    table_popularity_cache: str = os.getenv("BQ_TABLE_POPULARITY_CACHE", "")

    # Brand boost sheet
    brand_boost_sheet_url: str = os.getenv("BRAND_BOOST_SHEET_URL", "")


settings = Settings()
