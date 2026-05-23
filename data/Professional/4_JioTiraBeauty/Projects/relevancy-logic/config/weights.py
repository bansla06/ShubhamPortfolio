from dataclasses import dataclass


@dataclass
class Weights:
    aging: float = 0.66
    inventory: float = 1.00
    last_15_days_revenue_inv_track: float = 0.75
    last_15_days_revenue_main_track: float = 1.50
    older_revenue: float = 0.00
    last_15_days_views: float = 0.00
    older_views: float = 0.00
    last_15_days_sales: float = 0.25
    older_sales: float = 0.25
    rpv: float = 0.60
    spv: float = 0.40


DEFAULT_WEIGHTS = Weights()
