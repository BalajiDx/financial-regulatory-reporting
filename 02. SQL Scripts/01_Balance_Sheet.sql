-- 01_Balance_Sheet.sql
-- Question : What does the balance sheet look like at 31 Mar 2024 and 31 Mar 2025 (by report line)?
-- Note     : Report lines come from the chart of accounts mapping. Amounts in INR lakh; provisions are shown net within Advances.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT c.Class, c.ReportLine,
       ROUND(SUM(CASE WHEN g.QuarterEnd = '2024-03-31' THEN g.Amount END), 0) AS mar_2024,
       ROUND(SUM(CASE WHEN g.QuarterEnd = '2025-03-31' THEN g.Amount END), 0) AS mar_2025,
       ROUND(100.0 * (SUM(CASE WHEN g.QuarterEnd = '2025-03-31' THEN g.Amount END)
                    / SUM(CASE WHEN g.QuarterEnd = '2024-03-31' THEN g.Amount END) - 1), 1) AS change_pct
FROM GLBalances g JOIN ChartOfAccounts c ON c.GLCode = g.GLCode
WHERE c.Statement = 'BS'
GROUP BY c.Class, c.ReportLine
ORDER BY CASE c.Class WHEN 'Assets' THEN 1 WHEN 'Liabilities' THEN 2 ELSE 3 END, mar_2025 DESC;
