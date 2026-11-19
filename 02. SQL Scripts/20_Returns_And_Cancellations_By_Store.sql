-- 20_Returns_And_Cancellations_By_Store.sql
-- Question   : Which stores have the highest return and cancellation rates?
-- Techniques : conditional aggregation, ratio, ORDER BY
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT st.StoreName, st.Format,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(CASE WHEN o.Status = 'Returned'  THEN 1.0 ELSE 0 END), 2) AS return_rate_pct,
       ROUND(100.0 * AVG(CASE WHEN o.Status = 'Cancelled' THEN 1.0 ELSE 0 END), 2) AS cancel_rate_pct
FROM Orders o
JOIN Stores st ON st.StoreID = o.StoreID
GROUP BY st.StoreName, st.Format
ORDER BY return_rate_pct + cancel_rate_pct DESC;
