# Project: Geo & DAU Engagement Analytics

## Problem Statement
Swoo operated across India and the UAE, with a diverse player base spread across different timezones and device types. The growth team needed a clear picture of where players were coming from, which games were driving DAU, and how Trivia vs. PollMania (same 4PM slot, differentiated by start minute) were performing against each other.

## Objective
Map game participation by country and timezone, track DAU trends for Trivia and PollMania separately, and provide the team with geo-intelligence to prioritize market-specific game scheduling and content strategies.

## Approach
- Parsed raw Urban Airship event data to extract country code, device model, carrier, and timezone per user
- Segmented game starts by timezone to understand regional peak-play windows
- Separated Trivia (minute 0) and PollMania (minute 30) from the shared 4PM Trivia slot using start-minute logic
- Tracked distinct daily users per game type to compare engagement trends over time

## Key Insights
- India (IST) accounted for the majority of game starts; UAE (GST) showed strong evening engagement
- Trivia DAU consistently outperformed PollMania DAU in the shared 4PM slot
- Device diversity was high — feature-phone optimizations were critical for Tier-2/3 cities

## Files
- `Players_By_Country.sql` — Game starts segmented by country code, timezone, device model, and carrier
- `Trivia and Pollmania DAU.sql` — DAU comparison between Trivia and PollMania from the shared game slot

## Tech Stack
BigQuery · SQL · Urban Airship Event Data
