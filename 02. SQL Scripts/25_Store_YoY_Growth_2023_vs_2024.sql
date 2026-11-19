-- 25_Store_YoY_Growth_2023_vs_2024.sql
-- Question   : How did each store's revenue change from 2023 to 2024?
-- Techniques : pivot with conditional SUM, growth %, NULLIF
-- Note       : Customers' first purchases start in 2023, so 2024 includes repeat buying from the 2023 base and growth is expected.
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT st.StoreName,
       ROUND(SUM(CASE WHEN substr(o.OrderDate, 1, 4) = '2023' THEN oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) ELSE 0 END), 0) AS revenue_2023,
       ROUND(SUM(CASE WHEN substr(o.OrderDate, 1, 4) = '2024' THEN oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) ELSE 0 END), 0) AS revenue_2024,
       ROUND(100.0 * (SUM(CASE WHEN substr(o.OrderDate, 1, 4) = '2024' THEN oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) ELSE 0 END)
                    - SUM(CASE WHEN substr(o.OrderDate, 1, 4) = '2023' THEN oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) ELSE 0 END))
                    / NULLIF(SUM(CASE WHEN substr(o.OrderDate, 1, 4) = '2023' THEN oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct) ELSE 0 END), 0), 1) AS yoy_growth_pct
FROM Orders o
JOIN Stores st     ON st.StoreID = o.StoreID
JOIN OrderItems oi ON oi.OrderID = o.OrderID
WHERE o.Status = 'Delivered'
GROUP BY st.StoreName
ORDER BY yoy_growth_pct DESC;
