-- 02_Profit_And_Loss.sql
-- Question : What is the profit and loss for FY 2023-24 and FY 2024-25 (by report line)?
-- Note     : FY = April to March, so FY 2024-25 = quarters ending Jun 2024 to Mar 2025.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH p AS (
    SELECT c.Class, c.ReportLine,
           CASE WHEN g.QuarterEnd <= '2024-03-31' THEN 'FY24' ELSE 'FY25' END AS fy, g.Amount
    FROM GLBalances g JOIN ChartOfAccounts c ON c.GLCode = g.GLCode WHERE c.Statement = 'PL'
), lines AS (
    SELECT Class, ReportLine, ROUND(SUM(CASE WHEN fy = 'FY24' THEN Amount END), 0) AS fy_2023_24,
           ROUND(SUM(CASE WHEN fy = 'FY25' THEN Amount END), 0) AS fy_2024_25
    FROM p GROUP BY Class, ReportLine
)
SELECT ReportLine, fy_2023_24, fy_2024_25, ROUND(100.0 * (fy_2024_25 / fy_2023_24 - 1), 1) AS change_pct FROM lines
UNION ALL
SELECT 'Net profit (PAT)',
       SUM(CASE WHEN Class = 'Income' THEN fy_2023_24 ELSE -fy_2023_24 END),
       SUM(CASE WHEN Class = 'Income' THEN fy_2024_25 ELSE -fy_2024_25 END),
       ROUND(100.0 * (SUM(CASE WHEN Class = 'Income' THEN fy_2024_25 ELSE -fy_2024_25 END)
                    / SUM(CASE WHEN Class = 'Income' THEN fy_2023_24 ELSE -fy_2023_24 END) - 1), 1)
FROM lines;
