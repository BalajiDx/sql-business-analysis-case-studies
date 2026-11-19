-- 08_Net_Outflow_Customers_By_Segment.sql
-- Question   : What share of customers in each segment took out more than they put in?
-- Techniques : CTE, HAVING-style filter, AVG of flags
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH flow AS (
    SELECT a.CustomerID,
           SUM(CASE WHEN t.Direction = 'Credit' THEN t.Amount ELSE 0 END) AS credits,
           SUM(CASE WHEN t.Direction = 'Debit'  THEN t.Amount ELSE 0 END) AS debits
    FROM Transactions t
    JOIN Accounts a ON a.AccountID = t.AccountID
    GROUP BY a.CustomerID
)
SELECT c.Segment,
       COUNT(*) AS active_customers,
       SUM(CASE WHEN f.debits > f.credits THEN 1 ELSE 0 END) AS net_outflow_customers,
       ROUND(100.0 * AVG(CASE WHEN f.debits > f.credits THEN 1.0 ELSE 0 END), 1) AS net_outflow_pct,
       ROUND(AVG(f.credits - f.debits), 0) AS avg_net_flow_inr
FROM flow f
JOIN BankCustomers c ON c.CustomerID = f.CustomerID
GROUP BY c.Segment
ORDER BY net_outflow_pct DESC;
