-- 19_RFM_Segmentation.sql
-- Question   : How do customers split into RFM segments (recency, frequency, monetary)?
-- Techniques : NTILE(4), CTEs, CASE segment rules
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

WITH base AS (
    SELECT o.CustomerID,
           julianday('2024-12-31') - julianday(MAX(o.OrderDate)) AS recency_days,
           COUNT(DISTINCT o.OrderID)                             AS frequency,
           SUM(oi.Quantity * oi.UnitPrice * (1 - oi.DiscountPct))                                           AS monetary
    FROM Orders o JOIN OrderItems oi ON oi.OrderID = o.OrderID
    WHERE o.Status = 'Delivered'
    GROUP BY o.CustomerID
),
scored AS (
    SELECT *, NTILE(4) OVER (ORDER BY recency_days DESC) AS r,
              NTILE(4) OVER (ORDER BY frequency)        AS f,
              NTILE(4) OVER (ORDER BY monetary)         AS m
    FROM base
)
SELECT CASE WHEN r >= 3 AND f >= 3 AND m >= 3 THEN '1. Champions'
            WHEN r >= 3 AND f >= 2                THEN '2. Loyal / Potential'
            WHEN r <= 2 AND f >= 3                THEN '3. At risk (were frequent)'
            WHEN r = 1                            THEN '5. Lapsed'
            ELSE '4. Occasional' END              AS rfm_segment,
       COUNT(*)                                   AS customers,
       ROUND(AVG(recency_days), 0)                AS avg_recency_days,
       ROUND(AVG(frequency), 1)                   AS avg_orders,
       ROUND(AVG(monetary), 0)                    AS avg_spend_inr,
       ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS revenue_share_pct
FROM scored
GROUP BY 1
ORDER BY 1;
