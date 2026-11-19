-- 06_Branch_Rank_Within_Region.sql
-- Question   : Within each region, how do branches rank on transaction value?
-- Techniques : RANK() OVER (PARTITION BY), share of region
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH v AS (
    SELECT b.Region, b.BranchName, ROUND(SUM(t.Amount), 0) AS value_inr
    FROM Transactions t
    JOIN Accounts a  ON a.AccountID = t.AccountID
    JOIN Branches b  ON b.BranchID = a.BranchID
    GROUP BY b.Region, b.BranchName
)
SELECT Region, BranchName, value_inr,
       RANK() OVER (PARTITION BY Region ORDER BY value_inr DESC)              AS rank_in_region,
       ROUND(100.0 * value_inr / SUM(value_inr) OVER (PARTITION BY Region), 1) AS share_of_region_pct
FROM v
ORDER BY Region, rank_in_region;
