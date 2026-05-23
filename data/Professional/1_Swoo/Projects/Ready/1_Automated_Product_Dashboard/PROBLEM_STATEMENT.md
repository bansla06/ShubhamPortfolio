# Project: Automated Product Analytics Dashboard

## Problem Statement
The product and leadership team at Swoo required a weekly product performance deck to track key business metrics — DAU/WAU/MAU, game participation, new user funnels, retention, referrals, and wallet activity. Manually pulling this data from BigQuery and updating the deck was time-consuming and error-prone.

## Objective
Build a fully automated data pipeline that pulls data from BigQuery, processes it, and pushes the updated metrics directly into a Google Sheets dashboard — eliminating manual effort and enabling real-time decision-making.

## Approach
- Connected to BigQuery using service account credentials
- Wrote modular SQL queries covering all key metrics (DAU/WAU/MAU, game DAU by type, retention D1/D7/D14/D30, new user funnel, wallet balance, referrals, etc.)
- Built Python automation scripts to execute queries, write results to derived tables, and push data to Google Sheets
- Scheduled the pipeline to run daily/weekly, ensuring the dashboard was always up to date

## Files
- `Dailydashboard_overwrite.ipynb` — Core pipeline notebook with all BQ-to-dashboard functions
- `Product_deck.py` — Product deck automation script (v1)
- `Weekly_PR_Deck_BQ_Automation_Script_v4.py` — Final version of weekly PR deck automation
- `Weekly_PRDeck_BQCode(UA)_20181122.sql` — SQL for UA-based derived data
- `MyCodev1.sql` — Mixed SQL + Python utility code for DAU/WAU/MAU and game metrics
- `Loading Swooperstar Config Sheet to BQ table.ipynb` — Script to sync config data from Sheets to BQ
- `Connection With BigQuery.ipynb` — BQ connection setup and test
- `DailyDashboard/` — PDF snapshot of the dashboard output

## Tech Stack
BigQuery · Python · Google Sheets API · gspread · pandas · bonobo
