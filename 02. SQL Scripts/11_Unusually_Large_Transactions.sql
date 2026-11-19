-- 11_Unusually_Large_Transactions.sql
-- Question   : Which transactions are more than 5x the account's own average (possible review cases)?
-- Techniques : AVG() OVER (PARTITION BY), ratio filter, ranking
-- Note       : Accounts with fewer than 10 transactions are excluded so the average is meaningful.
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH t AS (
    SELECT TxnID, AccountID, TxnDate, Channel, Direction, Amount,
           AVG(Amount) OVER (PARTITION BY AccountID) AS acct_avg,
           COUNT(*)    OVER (PARTITION BY AccountID) AS acct_txns
    FROM Transactions
)
SELECT TxnID, AccountID, TxnDate, Channel, Direction,
       ROUND(Amount, 0) AS amount_inr, ROUND(acct_avg, 0) AS account_avg_inr,
       ROUND(Amount / acct_avg, 1) AS times_avg
FROM t
WHERE acct_txns >= 10 AND Amount > 5 * acct_avg
ORDER BY times_avg DESC
LIMIT 25;
