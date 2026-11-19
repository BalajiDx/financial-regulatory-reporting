-- 08_Provision_Adequacy.sql
-- Question : Is the provision held enough for each asset class at 31 Mar 2025 (illustrative rates)?
-- Note     : Required rates (illustrative): Standard 0.4%, Substandard 15%, Doubtful 40%, Loss 100%, applied to the DPD-based class.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH l AS (SELECT *, CASE WHEN DPD <= 90 THEN 'Standard' WHEN DPD <= 455 THEN 'Substandard'
                 WHEN DPD <= 910 THEN 'Doubtful' ELSE 'Loss' END AS RequiredClass FROM LoanBook WHERE QuarterEnd = '2025-03-31')
SELECT RequiredClass AS asset_class, Segment,
       COUNT(*) AS loans,
       ROUND(SUM(Outstanding), 0) AS outstanding_lakh,
       ROUND(SUM(Outstanding * CASE RequiredClass WHEN 'Standard' THEN 0.004 WHEN 'Substandard' THEN 0.15 WHEN 'Doubtful' THEN 0.40 ELSE 1.0 END), 1) AS required_provision,
       ROUND(SUM(ProvisionHeld), 1) AS provision_held,
       ROUND(SUM(ProvisionHeld) - SUM(Outstanding * CASE RequiredClass WHEN 'Standard' THEN 0.004 WHEN 'Substandard' THEN 0.15 WHEN 'Doubtful' THEN 0.40 ELSE 1.0 END), 1) AS surplus_shortfall
FROM l WHERE RequiredClass <> 'Standard'
GROUP BY RequiredClass, Segment
HAVING ABS(SUM(ProvisionHeld) - SUM(Outstanding * CASE RequiredClass WHEN 'Standard' THEN 0.004 WHEN 'Substandard' THEN 0.15 WHEN 'Doubtful' THEN 0.40 ELSE 1.0 END)) > 1
ORDER BY surplus_shortfall;
