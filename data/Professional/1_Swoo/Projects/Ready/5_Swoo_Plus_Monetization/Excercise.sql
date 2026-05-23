SELECT A.USER_ID , A.cash_out, B.winning_amount
from
(
select USER_ID, ROUND(sum (TRANSACTION_AMOUNT ) ,2)as cash_out 
from `your-project-id.wallet_db.WALLET_TRANSACTION` 
where STATUS = "SUCCESS" 
and TRANSACTION_TYPE = "DEBIT"
and date(createDateTime) >= "2019-05-01"
group by 1
) A
LEFT JOIN
(
select USER_ID,ROUND( sum(TRANSACTION_AMOUNT ),2) as winning_amount
from `your-project-id.wallet_db.WALLET_TRANSACTION` 
where STATUS = "SUCCESS" 
and TRANSACTION_TYPE = "CREDIT"
and date(createDateTime) >= "2019-05-01"
group by 1
) B
ON A.USER_ID = B.USER_ID 
group by 1,2,3
order by 2 desc




------------ALL

select F.USER_ID , F.cash_out , F.winning_amount, S.money_spend
from
(
SELECT A.USER_ID , A.cash_out, B.winning_amount
from
(
select USER_ID, ROUND(sum (TRANSACTION_AMOUNT ) ,2)as cash_out 
from `your-project-id.wallet_db.WALLET_TRANSACTION` 
where STATUS = "SUCCESS" 
and TRANSACTION_TYPE = "DEBIT"
and date(createDateTime) >= "2019-05-01"
group by 1
) A
LEFT JOIN
(
select USER_ID,ROUND( sum(TRANSACTION_AMOUNT ),2) as winning_amount
from `your-project-id.wallet_db.WALLET_TRANSACTION` 
where STATUS = "SUCCESS" 
and TRANSACTION_TYPE = "CREDIT"
and date(createDateTime) >= "2019-05-01"
group by 1
) B
ON A.USER_ID = B.USER_ID 
group by 1,2,3
order by 2 desc
) F
LEFT JOIN
(
select A.user_id , SUM (CAST (B.cost_amount AS INT64) )as money_spend
from
(
SELECT cast(user_id as INT64) as user_id,package_id
FROM `your-project-id.app_analytics.ua_processed_db_v3` 
WHERE DATE(occurred) >= '2019-05-01'
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2
) A
LEFT JOIN 
(
SELECT package_id,
REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as cost_type,
REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as cost_amount
FROM `your-project-id.premium_games_db.ripple_packages`
WHERE package_region IN ('IN')
) B
ON A.package_id  = B.package_id
group by 1
order by 2 desc
) S
ON F.USER_ID = S.user_id
order by 2




---------====


select SUM (CAST (REGEXP_REPLACE(winning_amount,'[^0-9]','') AS INT64)) as winning_amount
from `premium_games_db.user_contest_winnings` 
where user_id = 11319979
and winning_amount LIKE '%COINS%'



------------
select A.user_id , SUM(amount_spend_cash)
from
(
SELECT user_id,package_id
FROM `your-project-id.app_analytics.ua_processed_db_v3` 
WHERE DATE(occurred) = '2019-05-07'
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2
) A
LEFT JOIN
(
select package_id, CAST (REGEXP_REPLACE(cost_unit,'[^0-9]','') AS INT64) as amount_spend_cash
from `premium_games_db.ripple_packages`
where cost_unit LIKE '%CASH%'
) B
ON A.package_id = B.package_id
group by 1

------------====


select A.user_id , SUM (CAST (B.cost_amount AS INT64) )as money_spend,
sum(case WHEN items_type = "GEMS" Then B.items_amount end) as No_of_gems,
sum(case WHEN items_type = "COINS" THEN B.items_amount end) as No_of_coins
from
(
SELECT user_id,package_id
FROM `your-project-id.app_analytics.ua_processed_db_v3` 
WHERE DATE(occurred) >= '2019-05-01'
AND body_name = 'p2pmarketplace_marketplacetransactionsuccess'
GROUP BY 1,2
) A
LEFT JOIN 
(
SELECT package_id,
REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as cost_type,
REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(1)],":") [OFFSET(1)],"'","") as cost_amount,
REPLACE(REPLACE(SPLIT(SPLIT(cost_unit,",") [OFFSET(2)],":") [OFFSET(1)],"'",""),"}","") as cost_currency,
REPLACE(SPLIT(SPLIT(items,",") [OFFSET(0)],":") [OFFSET(1)],"'","") as items_type,
CAST (REPLACE(SPLIT(SPLIT(items,",") [OFFSET(1)],":") [OFFSET(1)],"'","")AS INT64) as items_amount
FROM `your-project-id.premium_games_db.ripple_packages`
WHERE package_region IN ('IN')
) B
ON A.package_id  = B.package_id
group by 1
order by 2 desc


---------===

