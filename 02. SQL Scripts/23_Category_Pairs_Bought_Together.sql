-- 23_Category_Pairs_Bought_Together.sql
-- Question   : Which pairs of categories most often appear in the same basket?
-- Techniques : self-join on OrderID, de-duplicated pairs
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH cat AS (
    SELECT DISTINCT oi.OrderID, p.Category
    FROM OrderItems oi JOIN Products p ON p.ProductID = oi.ProductID
    JOIN Orders o ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Delivered'
)
SELECT a.Category AS category_a, b.Category AS category_b,
       COUNT(*)   AS baskets_together,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT OrderID) FROM cat), 1) AS pct_of_baskets
FROM cat a
JOIN cat b ON a.OrderID = b.OrderID AND a.Category < b.Category
GROUP BY a.Category, b.Category
ORDER BY baskets_together DESC
LIMIT 10;
