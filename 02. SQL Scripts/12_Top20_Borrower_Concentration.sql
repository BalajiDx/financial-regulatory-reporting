-- 12_Top20_Borrower_Concentration.sql
-- Question : How concentrated is lending: top 20 borrowers as a share of advances and of Tier 1 capital (31 Mar 2025)?
-- Note     : Regulatory exposure limits differ by bank type; the 5% of Tier 1 'Watch' flag here is an illustrative internal limit.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH b AS (
    SELECT BorrowerID, COUNT(*) AS loans, SUM(Outstanding) AS exposure
    FROM LoanBook WHERE QuarterEnd = '2025-03-31' GROUP BY BorrowerID
), t1 AS (SELECT SUM(Amount) AS tier1 FROM GLBalances WHERE QuarterEnd = '2025-03-31' AND GLCode IN ('2010', '2020'))
SELECT BorrowerID, loans, ROUND(exposure, 1) AS exposure_lakh,
       ROUND(100.0 * exposure / (SELECT SUM(Outstanding) FROM LoanBook WHERE QuarterEnd = '2025-03-31'), 2) AS pct_of_advances,
       ROUND(100.0 * exposure / (SELECT tier1 FROM t1), 2) AS pct_of_tier1,
       CASE WHEN exposure > 0.05 * (SELECT tier1 FROM t1) THEN 'Watch (above 5%)' ELSE 'OK' END AS flag
FROM b ORDER BY exposure DESC LIMIT 20;
