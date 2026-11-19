-- 12_Segment_KPI_Scorecard.sql
-- Question   : How do the customer segments compare on activity, ticket size and digital adoption?
-- Techniques : multi-table JOIN, KPI ratios
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT c.Segment,
       COUNT(DISTINCT c.CustomerID)                               AS customers,
       ROUND(1.0 * COUNT(t.TxnID) / COUNT(DISTINCT c.CustomerID), 1) AS txns_per_customer,
       ROUND(AVG(t.Amount), 0)                                    AS avg_txn_inr,
       ROUND(100.0 * AVG(CASE WHEN t.Channel IN ('UPI', 'NetBanking', 'POS') THEN 1.0 ELSE 0 END), 1) AS digital_share_pct
FROM BankCustomers c
JOIN Accounts a     ON a.CustomerID = c.CustomerID
JOIN Transactions t ON t.AccountID = a.AccountID
GROUP BY c.Segment
ORDER BY avg_txn_inr DESC;
