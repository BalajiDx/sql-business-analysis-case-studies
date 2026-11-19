-- 07_Dormant_Accounts.sql
-- Question   : Which open savings/current accounts had no transaction in the last 180 days of 2024?
-- Techniques : LEFT JOIN, MAX date, julianday
-- Note       : Dormant = open account with no transaction in the last 180 days of the data (or none at all).
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH last_txn AS (
    SELECT AccountID, MAX(TxnDate) AS last_date
    FROM Transactions
    GROUP BY AccountID
)
SELECT a.AccountType,
       COUNT(*) AS open_accounts,
       SUM(CASE WHEN l.last_date IS NULL
                  OR julianday('2024-12-31') - julianday(l.last_date) > 180 THEN 1 ELSE 0 END) AS dormant_accounts,
       ROUND(100.0 * SUM(CASE WHEN l.last_date IS NULL
                  OR julianday('2024-12-31') - julianday(l.last_date) > 180 THEN 1 ELSE 0 END) / COUNT(*), 1) AS dormant_pct
FROM Accounts a
LEFT JOIN last_txn l ON l.AccountID = a.AccountID
WHERE a.CloseDate IS NULL AND a.AccountType IN ('Savings', 'Current')
GROUP BY a.AccountType;
