-- 18_Repeat_Purchase_And_Time_To_Second_Order.sql
-- Question   : What share of customers order a second time, and how long do they take?
-- Techniques : ROW_NUMBER, LAG, julianday
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH o AS (
    SELECT CustomerID, OrderDate,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) AS n,
           LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate, OrderID) AS prev_date
    FROM Orders WHERE Status = 'Delivered'
)
SELECT COUNT(DISTINCT CustomerID)                                         AS buyers,
       COUNT(DISTINCT CASE WHEN n = 2 THEN CustomerID END)                AS repeat_buyers,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN n = 2 THEN CustomerID END) / COUNT(DISTINCT CustomerID), 1) AS repeat_rate_pct,
       ROUND(AVG(CASE WHEN n = 2 THEN julianday(OrderDate) - julianday(prev_date) END), 1) AS avg_days_to_2nd_order
FROM o;
