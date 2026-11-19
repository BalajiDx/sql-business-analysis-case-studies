-- 01_Branch_Customer_And_Account_Count.sql
-- Question   : How many customers and accounts does each branch hold?
-- Techniques : JOIN, GROUP BY, COUNT DISTINCT
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT b.BranchID, b.BranchName, b.Region,
       COUNT(DISTINCT a.CustomerID)                         AS customers,
       COUNT(a.AccountID)                                   AS accounts,
       SUM(CASE WHEN a.CloseDate IS NULL THEN 1 ELSE 0 END) AS open_accounts,
       ROUND(1.0 * COUNT(a.AccountID) / COUNT(DISTINCT a.CustomerID), 2) AS accounts_per_customer
FROM Branches b
LEFT JOIN Accounts a ON a.BranchID = b.BranchID
GROUP BY b.BranchID, b.BranchName, b.Region
ORDER BY customers DESC;
