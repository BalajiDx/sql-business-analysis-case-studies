-- 22_Pareto_Revenue_Concentration.sql
-- Question   : What share of revenue comes from the top 10%, 20% and 50% of customers?
-- Techniques : cumulative SUM() OVER, ROW_NUMBER, percentile cut-offs
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH spend AS (
    SELECT o.CustomerID, SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)) AS revenue
    FROM Orders o JOIN OrderItems oi ON oi.OrderID = o.OrderID
    WHERE o.Status = 'Delivered'
    GROUP BY o.CustomerID
),
ranked AS (
    SELECT revenue,
           ROW_NUMBER() OVER (ORDER BY revenue DESC)                     AS rn,
           COUNT(*)     OVER ()                                          AS n,
           SUM(revenue) OVER (ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING) AS cum_rev,
           SUM(revenue) OVER ()                                          AS total
    FROM spend
)
SELECT 'Top 10% of customers' AS customer_group, ROUND(100.0 * MAX(cum_rev) / MAX(total), 1) AS revenue_share_pct FROM ranked WHERE rn <= 0.10 * n
UNION ALL
SELECT 'Top 20% of customers', ROUND(100.0 * MAX(cum_rev) / MAX(total), 1) FROM ranked WHERE rn <= 0.20 * n
UNION ALL
SELECT 'Top 50% of customers', ROUND(100.0 * MAX(cum_rev) / MAX(total), 1) FROM ranked WHERE rn <= 0.50 * n;
