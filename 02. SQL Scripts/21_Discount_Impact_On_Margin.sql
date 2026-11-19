-- 21_Discount_Impact_On_Margin.sql
-- Question   : How much margin do discounts cost, and do discounted lines sell more units?
-- Techniques : GROUP BY discount level, margin math
-- Note       : Discounts in this synthetic data are random, so units per line should not move with discount; margin does.
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT CAST(oi.DiscountPct * 100 AS INTEGER) || '%'              AS discount,
       COUNT(*)                                                  AS order_lines,
       ROUND(AVG(oi.Quantity), 2)                                AS avg_units_per_line,
       ROUND(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)), 0)                                     AS revenue_inr,
       ROUND(100.0 * SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) - oi.Quantity * p.UnitCost) / SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)), 1) AS margin_pct
FROM OrderItems oi
JOIN Orders o   ON o.OrderID = oi.OrderID
JOIN Products p ON p.ProductID = oi.ProductID
WHERE o.Status = 'Delivered'
GROUP BY oi.DiscountPct
ORDER BY oi.DiscountPct;
