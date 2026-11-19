-- 04_Asset_Quality_Summary.sql
-- Question : What are gross NPA, net NPA and the provision coverage ratio each quarter, as reported and as corrected?
-- Note     : Reported = source-system AssetClass. Corrected = class required by days past due (90+ DPD = NPA).
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH l AS (SELECT *, CASE WHEN DPD <= 90 THEN 'Standard' WHEN DPD <= 455 THEN 'Substandard'
                 WHEN DPD <= 910 THEN 'Doubtful' ELSE 'Loss' END AS RequiredClass FROM LoanBook)
SELECT QuarterEnd,
       ROUND(SUM(Outstanding), 0) AS gross_advances,
       ROUND(100.0 * SUM(CASE WHEN AssetClass <> 'Standard' THEN Outstanding ELSE 0 END) / SUM(Outstanding), 2) AS gnpa_reported_pct,
       ROUND(100.0 * SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding ELSE 0 END) / SUM(Outstanding), 2) AS gnpa_corrected_pct,
       ROUND(100.0 * (SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding - ProvisionHeld ELSE 0 END))
             / (SUM(Outstanding) - SUM(CASE WHEN RequiredClass <> 'Standard' THEN ProvisionHeld ELSE 0 END)), 2) AS nnpa_corrected_pct,
       ROUND(100.0 * SUM(CASE WHEN RequiredClass <> 'Standard' THEN ProvisionHeld ELSE 0 END)
             / SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding ELSE 0 END), 1) AS pcr_pct,
       ROUND(100.0 * SUM(CASE WHEN DPD BETWEEN 1 AND 90 THEN Outstanding ELSE 0 END) / SUM(Outstanding), 2) AS sma_pct
FROM l GROUP BY QuarterEnd ORDER BY QuarterEnd;
