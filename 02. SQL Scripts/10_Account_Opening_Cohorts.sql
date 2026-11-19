-- 10_Account_Opening_Cohorts.sql
-- Question   : For each opening year, how many accounts were opened and what share has since closed?
-- Techniques : cohort by year, conditional aggregation
-- Dialect    : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT substr(OpenDate, 1, 4) AS open_year,
       COUNT(*) AS opened,
       SUM(CASE WHEN CloseDate IS NOT NULL THEN 1 ELSE 0 END) AS closed,
       ROUND(100.0 * SUM(CASE WHEN CloseDate IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 1) AS closed_pct,
       ROUND(AVG(CASE WHEN CloseDate IS NOT NULL THEN julianday(CloseDate) - julianday(OpenDate) END) / 365.25, 1) AS avg_years_to_close
FROM Accounts
GROUP BY 1
ORDER BY 1;
