-- 02_Product_Holding_Mix.sql
-- Question   : How many products does each customer hold, and how many hold only a savings account?
-- Techniques : CTE, conditional aggregation
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH holding AS (
    SELECT CustomerID,
           COUNT(DISTINCT AccountType)                                 AS products,
           MAX(CASE WHEN AccountType <> 'Savings' THEN 1 ELSE 0 END)   AS has_non_savings
    FROM Accounts
    GROUP BY CustomerID
)
SELECT products                                    AS products_held,
       COUNT(*)                                    AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers,
       SUM(CASE WHEN has_non_savings = 0 THEN 1 ELSE 0 END) AS savings_only
FROM holding
GROUP BY products
ORDER BY products;
