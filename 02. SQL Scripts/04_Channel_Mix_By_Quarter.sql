-- 04_Channel_Mix_By_Quarter.sql
-- Question   : What share of transactions goes through each channel, by quarter?
-- Techniques : CASE quarter, SUM() OVER (PARTITION BY)
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH c AS (
    SELECT substr(TxnDate, 1, 4) || '-Q' || ((CAST(substr(TxnDate, 6, 2) AS INTEGER) + 2) / 3) AS quarter,
           Channel, COUNT(*) AS txns
    FROM Transactions
    GROUP BY 1, 2
)
SELECT quarter, Channel, txns,
       ROUND(100.0 * txns / SUM(txns) OVER (PARTITION BY quarter), 1) AS share_pct
FROM c
ORDER BY quarter, share_pct DESC;
