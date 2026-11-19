-- 14_Balance_Sheet_Control_Check.sql
-- Question : Do total assets equal total liabilities plus equity in every quarter (control check)?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT g.QuarterEnd,
       ROUND(SUM(CASE WHEN c.Class = 'Assets' THEN g.Amount END), 2) AS total_assets,
       ROUND(SUM(CASE WHEN c.Class IN ('Liabilities', 'Equity') THEN g.Amount END), 2) AS liabilities_and_equity,
       ROUND(SUM(CASE WHEN c.Class = 'Assets' THEN g.Amount END) - SUM(CASE WHEN c.Class IN ('Liabilities', 'Equity') THEN g.Amount END), 2) AS difference,
       CASE WHEN ABS(SUM(CASE WHEN c.Class = 'Assets' THEN g.Amount END)
                   - SUM(CASE WHEN c.Class IN ('Liabilities', 'Equity') THEN g.Amount END)) < 0.5 THEN 'Pass' ELSE 'Fail' END AS result
FROM GLBalances g JOIN ChartOfAccounts c ON c.GLCode = g.GLCode
WHERE c.Statement = 'BS' GROUP BY g.QuarterEnd ORDER BY g.QuarterEnd;
