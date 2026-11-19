-- 05_Top10_Customers_By_Net_Inflow.sql
-- Question   : Which 10 customers brought in the most net money (credits minus debits) in 2024?
-- Techniques : JOIN, conditional SUM, RANK
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH net AS (
    SELECT a.CustomerID,
           SUM(CASE WHEN t.Direction = 'Credit' THEN t.Amount ELSE -t.Amount END) AS net_inflow,
           COUNT(*) AS txns
    FROM Transactions t
    JOIN Accounts a ON a.AccountID = t.AccountID
    GROUP BY a.CustomerID
)
SELECT RANK() OVER (ORDER BY n.net_inflow DESC) AS rnk, n.CustomerID, c.Segment, b.BranchName,
       ROUND(n.net_inflow, 0) AS net_inflow_inr, n.txns
FROM net n
JOIN BankCustomers c ON c.CustomerID = n.CustomerID
JOIN Branches b ON b.BranchID = c.HomeBranchID
ORDER BY rnk
LIMIT 10;
