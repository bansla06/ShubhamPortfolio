# Project: Swoo Plus Monetization & Wallet Analytics

## Problem Statement
Swoo Plus was a paid contest feature where users could spend in-app currency (Ripples) to enter Pay2Play games and win real money. The monetization team needed to understand who was spending, how often they were repeating transactions, whether high spenders were also high winners, and how wallet cash-out behavior differed from winnings.

## Objective
Analyze Swoo Plus user spending behavior, identify power users and repeat transactors, profile demographics of paying players, and measure the relationship between money spent, winnings, and cash-out amounts.

## Approach
- Segmented users by transaction repetition (1x, 2x, 3x, 4x, 5x+ purchases) and total spend
- Profiled contest players by age, city, and gender to understand paying demographics
- Identified users who played but never converted to paid contests
- Cross-joined wallet DEBIT (cash-out), CREDIT (winnings), and in-app purchase data to get a holistic view of each user's financial journey on the platform

## Key Insights
- Majority of Swoo Plus users were one-time transactors — repeat purchase rate was low
- High cash-out users were not always high winners — indicating some users were gaming the system
- Male users from Tier-1 cities dominated paying demographics

## Files
- `Swoo Plus Analysis Queris.sql` — Contest player demographics, repeat transactions, package details
- `Excercise.sql` — Wallet debit/credit analysis and P2P marketplace spend tracking

## Tech Stack
BigQuery · SQL · Python
