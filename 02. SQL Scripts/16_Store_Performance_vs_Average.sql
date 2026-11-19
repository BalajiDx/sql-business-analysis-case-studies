-- 16_Store_Performance_vs_Average.sql
-- Question   : Which stores beat the company average on revenue per order and margin?
-- Techniques : CTE, comparison with AVG() OVER ()
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH s AS (
    SELECT st.StoreName, st.Format,
           COUNT(DISTINCT o.OrderID)                         AS orders,
           SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct))                                       AS revenue,
           SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) - oi.Quantity * p.UnitCost)            AS margin
    FROM Orders o
    JOIN Stores st     ON st.StoreID = o.StoreID
    JOIN OrderItems oi ON oi.OrderID = o.OrderID
    JOIN Products p    ON p.ProductID = oi.ProductID
    WHERE o.Status = 'Delivered'
    GROUP BY st.StoreName, st.Format
)
SELECT StoreName, Format, orders, ROUND(revenue, 0) AS revenue_inr,
       ROUND(revenue / orders, 0)                                   AS revenue_per_order,
       ROUND(100.0 * margin / revenue, 1)                           AS margin_pct,
       ROUND(revenue / orders - AVG(revenue / orders) OVER (), 0)   AS rpo_vs_avg,
       CASE WHEN revenue / orders >= AVG(revenue / orders) OVER () THEN 'Above' ELSE 'Below' END AS vs_average
FROM s
ORDER BY revenue_inr DESC;
