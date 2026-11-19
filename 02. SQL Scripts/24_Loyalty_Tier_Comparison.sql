-- 24_Loyalty_Tier_Comparison.sql
-- Question   : Do Gold and Silver loyalty members spend and visit more than non-members?
-- Techniques : JOIN, per-customer CTE, averages by tier
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH c AS (
    SELECT o.CustomerID, COUNT(DISTINCT o.OrderID) AS orders, SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)) AS spend
    FROM Orders o JOIN OrderItems oi ON oi.OrderID = o.OrderID
    WHERE o.Status = 'Delivered'
    GROUP BY o.CustomerID
)
SELECT r.LoyaltyTier,
       COUNT(*)                         AS buyers,
       ROUND(AVG(c.orders), 2)          AS avg_orders,
       ROUND(AVG(c.spend), 0)           AS avg_spend_inr,
       ROUND(SUM(c.spend) / SUM(c.orders), 0) AS aov_inr
FROM c JOIN RetailCustomers r ON r.CustomerID = c.CustomerID
GROUP BY r.LoyaltyTier
ORDER BY avg_spend_inr DESC;
