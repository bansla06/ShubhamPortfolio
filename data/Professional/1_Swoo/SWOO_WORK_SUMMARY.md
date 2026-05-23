# Swoo — Analytics Work Summary

**Role:** Product Analyst / Data Analyst
**Company:** Swoo (Live Gaming & Video Platform)
**Tech Stack:** BigQuery · Python · SQL · Google Sheets API · Urban Airship · pandas · scikit-learn

---

## Overview
At Swoo, a live interactive gaming and video platform, I owned the end-to-end analytics function — from raw event data ingestion to automated reporting and product experimentation. The platform hosted live games (Trivia, Bingo, CandyRush, SwooperStar, CardsGame) alongside a live video tab, and operated across India and the UAE.

---

## Key Projects

### 1. Automated Product Analytics Dashboard
Built a fully automated weekly product performance pipeline using Python and BigQuery. The system pulled 20+ metrics — DAU/WAU/MAU, game participation, new user funnels, D1/D7/D14/D30 retention, referrals, wallet balance, and lives data — and pushed them directly into a Google Sheets dashboard shared with leadership. Eliminated manual reporting effort entirely.

### 2. CandyRush Game Analytics & Rubber Banding
Analysed CandyRush player behaviour to address high early-churn among new users. Segmented players by win ratio, session recency, and account age. Built a rubber banding model that identified struggling players within their first 3 games and flagged them for difficulty adjustment or incentive intervention — directly improving D1 retention for the game.

### 3. Video Tab & SwooperStar Engagement
Measured time spent on the video tab and SwooperStar live talent show using session-level event tracking (LEAD window functions on open/exit events). Identified peak engagement windows, drop-off points in the video watch funnel, and quantified the impact of automated push notifications on re-engagement rates.

### 4. Cross-Game Recommendation Engine
Built the data foundation for a game recommendation engine by constructing user attribute profiles (game preferences, session timing, country) and item attribute profiles (video metadata, broadcaster engagement, watch-time segments). Used Venn diagram analysis to map cross-game user overlap and identify untapped audiences for personalised game nudges.

### 5. Swoo Plus Monetization Analytics
Analysed the Swoo Plus paid contest feature — profiling paying users by demographics (age, city, gender), tracking repeat transaction behaviour, and cross-joining wallet debit, credit, and in-app purchase data to understand the full financial journey of each user on the platform.

### 6. Geo & DAU Engagement Analytics
Mapped game participation across India and the UAE using timezone and device metadata from raw event streams. Separated Trivia vs. PollMania DAU from the shared 4PM game slot, and tracked region-specific engagement patterns to inform game scheduling and content strategy decisions.

---

## Impact
- Saved significant manual reporting hours per week through full dashboard automation
- Identified retention levers in CandyRush that informed the rubber banding product feature
- Provided the first structured view of cross-game user overlap, enabling targeted push campaigns
- Built a reusable BigQuery → Python → Google Sheets pipeline used across multiple reporting tracks
