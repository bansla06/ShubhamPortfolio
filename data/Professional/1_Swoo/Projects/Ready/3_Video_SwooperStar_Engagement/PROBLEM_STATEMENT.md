# Project: Video Tab & SwooperStar Engagement Analysis

## Problem Statement
Swoo's video tab hosted live broadcaster content alongside the SwooperStar live talent show game. The product team lacked visibility into how users were engaging with the video tab — how long they stayed, how many videos they watched, and whether SwooperStar drives incremental viewing time or just cannibalizes other sessions.

## Objective
Measure time spent on the video tab, video watch counts per user, hourly engagement patterns, and the effectiveness of push notifications in driving users back to live video content.

## Approach
- Used session-level event data (`videoplayer_open` / `videoplayer_exit`) to compute time spent per user per day using LEAD window functions
- Broke down time spent and videos watched by hour to identify peak engagement windows
- Analyzed DAU for the video tab vs. videos actually played (open vs. watch funnel)
- Tracked automated UA notifications to measure notification-driven re-engagement

## Key Insights
- Evening hours (12–19) accounted for the majority of SwooperStar viewing time
- Significant drop-off between users who opened the video tab vs. those who watched a full video
- Push notifications showed measurable impact on re-opening rates

## Files
- `Video_Tab.sql` — Time spent on video tab, videos watched per hour, DAU for video features
- `Automated_ua_notifcation.ipynb` — UA push notification automation for live video events

## Tech Stack
BigQuery · SQL (Window Functions) · Urban Airship · Python
