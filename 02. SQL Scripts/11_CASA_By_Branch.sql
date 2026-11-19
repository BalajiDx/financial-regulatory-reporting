-- 11_CASA_By_Branch.sql
-- Question : What is the CASA ratio by branch at 31 Mar 2025, and how did it change from 31 Mar 2024?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT b.BranchName, b.Region,
       ROUND(SUM(CASE WHEN d.QuarterEnd = '2025-03-31' THEN d.Balance END), 0) AS deposits_mar_2025,
       ROUND(100.0 * SUM(CASE WHEN d.QuarterEnd = '2024-03-31' AND d.Product <> 'Term Deposit' THEN d.Balance END)
                    / SUM(CASE WHEN d.QuarterEnd = '2024-03-31' THEN d.Balance END), 1) AS casa_mar_2024_pct,
       ROUND(100.0 * SUM(CASE WHEN d.QuarterEnd = '2025-03-31' AND d.Product <> 'Term Deposit' THEN d.Balance END)
                    / SUM(CASE WHEN d.QuarterEnd = '2025-03-31' THEN d.Balance END), 1) AS casa_mar_2025_pct
FROM Deposits d JOIN Branches b ON b.BranchID = d.BranchID
GROUP BY b.BranchID ORDER BY casa_mar_2025_pct;
