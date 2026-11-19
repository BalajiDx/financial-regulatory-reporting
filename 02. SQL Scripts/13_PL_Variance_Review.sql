-- 13_PL_Variance_Review.sql
-- Question : Which P&L lines moved more than 15% quarter on quarter (analytical review for the reporting pack)?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH p AS (
    SELECT g.QuarterEnd, c.GLCode, c.GLName, g.Amount,
           LAG(g.Amount) OVER (PARTITION BY c.GLCode ORDER BY g.QuarterEnd) AS prev_amount
    FROM GLBalances g JOIN ChartOfAccounts c ON c.GLCode = g.GLCode WHERE c.Statement = 'PL'
)
SELECT QuarterEnd, GLCode, GLName, ROUND(prev_amount, 1) AS previous_quarter, ROUND(Amount, 1) AS this_quarter,
       ROUND(100.0 * (Amount / prev_amount - 1), 1) AS change_pct
FROM p WHERE prev_amount IS NOT NULL AND ABS(Amount / prev_amount - 1) > 0.15
ORDER BY QuarterEnd, ABS(Amount / prev_amount - 1) DESC;
