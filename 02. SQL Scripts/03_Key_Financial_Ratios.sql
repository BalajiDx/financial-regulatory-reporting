-- 03_Key_Financial_Ratios.sql
-- Question : How did NIM, cost-to-income, ROA and CASA move each quarter?
-- Note     : Annualised = quarter x 4. NIM on quarter-end advances + investments. CASA = (savings + current) / total deposits.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH q AS (
    SELECT g.QuarterEnd,
           SUM(CASE WHEN c.ReportLine = 'Interest earned' THEN g.Amount END) AS int_earned,
           SUM(CASE WHEN c.ReportLine = 'Interest expended' THEN g.Amount END) AS int_exp,
           SUM(CASE WHEN c.ReportLine = 'Other income' THEN g.Amount END) AS other_inc,
           SUM(CASE WHEN c.ReportLine = 'Operating expenses' THEN g.Amount END) AS opex,
           SUM(CASE WHEN c.Statement = 'PL' THEN CASE WHEN c.Class = 'Income' THEN g.Amount ELSE -g.Amount END END) AS pat,
           SUM(CASE WHEN c.Class = 'Assets' THEN g.Amount END) AS total_assets,
           SUM(CASE WHEN g.GLCode IN ('1210', '1110', '1120') THEN g.Amount END) AS earning_assets,
           SUM(CASE WHEN g.GLCode IN ('2110', '2120') THEN g.Amount END) AS casa,
           SUM(CASE WHEN c.ReportLine = 'Deposits' THEN g.Amount END) AS deposits,
           SUM(CASE WHEN g.GLCode = '1210' THEN g.Amount END) AS advances
    FROM GLBalances g JOIN ChartOfAccounts c ON c.GLCode = g.GLCode GROUP BY g.QuarterEnd
)
SELECT QuarterEnd,
       ROUND(100.0 * 4 * (int_earned - int_exp) / earning_assets, 2) AS nim_pct,
       ROUND(100.0 * opex / (int_earned - int_exp + other_inc), 1) AS cost_to_income_pct,
       ROUND(100.0 * 4 * pat / total_assets, 2) AS roa_pct,
       ROUND(100.0 * casa / deposits, 1) AS casa_pct,
       ROUND(100.0 * advances / deposits, 1) AS credit_deposit_pct
FROM q ORDER BY QuarterEnd;
