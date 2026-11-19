-- 17_Customer_Cohort_Retention.sql
-- Question   : Of customers who first bought in each quarter, what share bought again in the following quarters?
-- Techniques : cohort CTEs, quarter index arithmetic, pivot with conditional aggregation
-- Note       : Cells are left empty (NULL) where a cohort has not yet reached that quarter (data ends 2024-Q4).
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH firsts AS (
    SELECT CustomerID, MIN(OrderDate) AS first_date FROM Orders WHERE Status = 'Delivered' GROUP BY CustomerID
),
qidx AS (
    SELECT o.CustomerID,
           (CAST(substr(f.first_date, 1, 4) AS INTEGER) * 4 + (CAST(substr(f.first_date, 6, 2) AS INTEGER) - 1) / 3) AS cohort_q,
           (CAST(substr(o.OrderDate, 1, 4) AS INTEGER) * 4 + (CAST(substr(o.OrderDate, 6, 2) AS INTEGER) - 1) / 3) AS order_q
    FROM Orders o JOIN firsts f ON f.CustomerID = o.CustomerID
    WHERE o.Status = 'Delivered'
),
c AS (
    SELECT CustomerID, cohort_q, order_q - cohort_q AS q_since FROM qidx GROUP BY CustomerID, cohort_q, order_q
)
SELECT (cohort_q / 4) || '-Q' || (cohort_q % 4 + 1) AS cohort,
       COUNT(DISTINCT CASE WHEN q_since = 0 THEN CustomerID END) AS cohort_size,
       CASE WHEN cohort_q + 1 <= 2024 * 4 + 3 THEN ROUND(100.0 * COUNT(DISTINCT CASE WHEN q_since = 1 THEN CustomerID END) / COUNT(DISTINCT CASE WHEN q_since = 0 THEN CustomerID END), 1) END AS q1_pct,
       CASE WHEN cohort_q + 2 <= 2024 * 4 + 3 THEN ROUND(100.0 * COUNT(DISTINCT CASE WHEN q_since = 2 THEN CustomerID END) / COUNT(DISTINCT CASE WHEN q_since = 0 THEN CustomerID END), 1) END AS q2_pct,
       CASE WHEN cohort_q + 3 <= 2024 * 4 + 3 THEN ROUND(100.0 * COUNT(DISTINCT CASE WHEN q_since = 3 THEN CustomerID END) / COUNT(DISTINCT CASE WHEN q_since = 0 THEN CustomerID END), 1) END AS q3_pct,
       CASE WHEN cohort_q + 4 <= 2024 * 4 + 3 THEN ROUND(100.0 * COUNT(DISTINCT CASE WHEN q_since = 4 THEN CustomerID END) / COUNT(DISTINCT CASE WHEN q_since = 0 THEN CustomerID END), 1) END AS q4_pct
FROM c
GROUP BY cohort_q
ORDER BY cohort_q;
