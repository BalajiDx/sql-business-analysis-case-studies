-- 15_Top3_Products_Per_Category.sql
-- Question   : What are the top 3 products by revenue in each category?
-- Techniques : ROW_NUMBER() OVER (PARTITION BY ... ORDER BY)
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH pr AS (
    SELECT p.Category, p.ProductID, p.ProductName, p.Brand,
           ROUND(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)), 0) AS revenue_inr,
           ROW_NUMBER() OVER (PARTITION BY p.Category ORDER BY SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)) DESC) AS rn
    FROM OrderItems oi
    JOIN Orders o   ON o.OrderID = oi.OrderID
    JOIN Products p ON p.ProductID = oi.ProductID
    WHERE o.Status = 'Delivered'
    GROUP BY p.Category, p.ProductID, p.ProductName, p.Brand
)
SELECT Category, rn AS rank_in_category, ProductID, ProductName, Brand, revenue_inr
FROM pr
WHERE rn <= 3
ORDER BY Category, rn;
