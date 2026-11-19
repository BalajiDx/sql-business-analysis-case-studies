-- 09_Days_Between_Transactions.sql
-- Question   : How often do accounts transact? Median-style view of the gap between transactions by account type.
-- Techniques : LAG over dates, julianday, bucketing
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH gaps AS (
    SELECT a.AccountType,
           julianday(t.TxnDate) - julianday(LAG(t.TxnDate) OVER (PARTITION BY t.AccountID ORDER BY t.TxnDate, t.TxnID)) AS gap_days
    FROM Transactions t
    JOIN Accounts a ON a.AccountID = t.AccountID
)
SELECT AccountType,
       COUNT(gap_days)                         AS gaps_measured,
       ROUND(AVG(gap_days), 1)                 AS avg_gap_days,
       ROUND(100.0 * AVG(CASE WHEN gap_days <= 7  THEN 1.0 ELSE 0 END), 1) AS within_7_days_pct,
       ROUND(100.0 * AVG(CASE WHEN gap_days > 30 THEN 1.0 ELSE 0 END), 1)  AS over_30_days_pct
FROM gaps
WHERE gap_days IS NOT NULL
GROUP BY AccountType;
