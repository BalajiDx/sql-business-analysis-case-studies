-- 13_Monthly_Revenue_Orders_AOV.sql
-- Question   : What are monthly net revenue, delivered orders and average order value?
-- Techniques : JOIN, GROUP BY month, derived ratio
-- Note       : Revenue = quantity x unit price x (1 - discount), delivered orders only.
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT strftime('%Y-%m', o.OrderDate) AS month,
       COUNT(DISTINCT o.OrderID)      AS delivered_orders,
       ROUND(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)), 0)          AS revenue_inr,
       ROUND(SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct)) / COUNT(DISTINCT o.OrderID), 0) AS aov_inr
FROM Orders o
JOIN OrderItems oi ON oi.OrderID = o.OrderID
WHERE o.Status = 'Delivered'
GROUP BY 1
ORDER BY 1;
