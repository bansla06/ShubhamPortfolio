# Project: CandyRush Game Analytics & Rubber Banding

## Problem Statement
CandyRush, a live trivia-style game on Swoo, had high churn among new players who were losing too frequently and disengaging early. The team needed to understand player skill levels, win patterns, and how to implement a "rubber banding" mechanism — dynamically adjusting game difficulty or incentives based on user performance to improve retention.

## Objective
Analyze CandyRush player behavior — win ratios, points scored, game session patterns, and life consumption — to identify cohorts of struggling players and design a rubber banding logic that keeps them engaged longer.

## Approach
- Segmented players by age of account (new vs. old), recency of play, and win ratio
- Analyzed first-game performance: points scored, lives consumed, and win outcome
- Built retention analysis: tracked if day-1 CandyRush players returned the next day
- Identified correlation between early win ratio and long-term retention
- Pinpointed the optimal difficulty threshold for rubber banding intervention

## Key Insights
- Players with win ratio < threshold on their first session had significantly lower D1 retention
- Morning hours (6–12) showed highest CandyRush engagement
- Rubber banding intervention targeted players with 0 wins in first 3 games

## Files
- `CK_rubber_banding_v1.2.ipynb` — Full analysis notebook with segmentation, retention modeling, and rubber banding logic
- `Candy_Analysis.sql` — SQL for players by show time, CandyRush winners, and time-spent analysis

## Tech Stack
BigQuery · Python · pandas · seaborn · matplotlib
