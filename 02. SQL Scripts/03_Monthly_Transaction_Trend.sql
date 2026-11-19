-- 03_Monthly_Transaction_Trend.sql
-- Question   : How do monthly transaction count and value move through 2024?
-- Techniques : strftime, GROUP BY, LAG
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH m AS (
    SELECT strftime('%Y-%m', TxnDate) AS month,
           COUNT(*)                   AS txns,
           ROUND(SUM(Amount), 0)      AS value_inr
    FROM Transactions
    GROUP BY 1
)
SELECT month, txns, value_inr,
       ROUND(100.0 * (txns - LAG(txns) OVER (ORDER BY month)) / LAG(txns) OVER (ORDER BY month), 1) AS txn_mom_pct
FROM m
ORDER BY month;
