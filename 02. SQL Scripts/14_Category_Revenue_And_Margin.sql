-- 14_Category_Revenue_And_Margin.sql
-- Question   : Which categories earn the most revenue and gross margin?
-- Techniques : JOIN, margin calculation, share of total
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT p.Category,
       ROUND(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)), 0)                                    AS revenue_inr,
       ROUND(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) - oi.Quantity * p.UnitCost), 0)         AS gross_margin_inr,
       ROUND(100.0 * SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) - oi.Quantity * p.UnitCost) / SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)), 1) AS margin_pct,
       ROUND(100.0 * SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)) / SUM(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct))) OVER (), 1) AS revenue_share_pct
FROM OrderItems oi
JOIN Orders o   ON o.OrderID = oi.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
WHERE o.Status = 'Delivered'
GROUP BY p.Category
ORDER BY revenue_inr DESC;
