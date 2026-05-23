# Project: Cross-Game Recommendation Engine

## Problem Statement
Swoo offered multiple games — Bingo, Trivia, CandyRush, CardsGame, and SwooperStar — but most users were engaging with only one or two. The team wanted to understand user-game affinity patterns and build a foundation for a recommendation engine that would surface the right game to the right user at the right time.

## Objective
Build user attribute and item attribute profiles to power a collaborative filtering-based game recommendation engine, and use Venn diagrams to visualize cross-game user overlap for targeting strategy.

## Approach
- Built a **user attribute matrix**: games played per type, session time-of-day preferences (morning/afternoon/evening), country, and time spent on app
- Built an **item attribute matrix**: video metadata, broadcaster engagement (votes, shares, downloads), and watch-time segments
- Used Venn diagrams to visualize overlap between users of different game types and the Swoo Plus paid contest tab
- Identified high-value multi-game users vs. single-game users for personalized recommendations

## Key Insights
- CandyRush and Trivia had the highest cross-play overlap
- Users who opened the AllContests tab rarely played Pay2Play games — indicating a discovery gap
- Evening players had the highest multi-game engagement rate

## Files
- `Recommendation_Engine.sql` — User attribute + item attribute queries for the recommendation engine
- `venn diagram.ipynb` / `Venn Diagram.ipynb` — Cross-game and cross-feature user overlap visualizations

## Tech Stack
BigQuery · Python · pandas · matplotlib-venn · venn library
