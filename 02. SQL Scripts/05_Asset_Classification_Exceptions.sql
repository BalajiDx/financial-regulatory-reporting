-- 05_Asset_Classification_Exceptions.sql
-- Question : Which loans are more than 90 days past due but still tagged Standard (exception report)?
-- Note     : These must be reclassified and provided for before the return is filed. Latest quarter shown in full; counts by quarter in the summary.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH l AS (SELECT *, CASE WHEN DPD <= 90 THEN 'Standard' WHEN DPD <= 455 THEN 'Substandard'
                 WHEN DPD <= 910 THEN 'Doubtful' ELSE 'Loss' END AS RequiredClass FROM LoanBook)
SELECT QuarterEnd, COUNT(*) AS loans_misclassified,
       ROUND(SUM(Outstanding), 1) AS outstanding_lakh,
       ROUND(SUM(Outstanding * CASE RequiredClass WHEN 'Standard' THEN 0.004 WHEN 'Substandard' THEN 0.15 WHEN 'Doubtful' THEN 0.40 ELSE 1.0 END - ProvisionHeld), 1) AS provision_shortfall_lakh
FROM l WHERE AssetClass = 'Standard' AND RequiredClass <> 'Standard'
GROUP BY QuarterEnd ORDER BY QuarterEnd;
