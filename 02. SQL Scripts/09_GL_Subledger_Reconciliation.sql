-- 09_GL_Subledger_Reconciliation.sql
-- Question : Does the GL advances balance (GL 1210) agree with the loan sub-ledger each quarter?
-- Note     : Tolerance: INR 1 lakh. Breaks must be explained before sign-off.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT g.QuarterEnd,
       ROUND(g.Amount, 2) AS gl_advances,
       ROUND(l.subledger, 2) AS loan_subledger,
       ROUND(g.Amount - l.subledger, 2) AS difference,
       CASE WHEN ABS(g.Amount - l.subledger) <= 1 THEN 'Reconciled' ELSE 'Break' END AS status
FROM GLBalances g
JOIN (SELECT QuarterEnd, SUM(Outstanding) AS subledger FROM LoanBook GROUP BY QuarterEnd) l ON l.QuarterEnd = g.QuarterEnd
WHERE g.GLCode = '1210' ORDER BY g.QuarterEnd;
