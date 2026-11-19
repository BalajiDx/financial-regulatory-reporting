-- 06_NPA_By_Segment.sql
-- Question : Which loan segments carry the most NPAs at 31 Mar 2025 (corrected classification)?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH l AS (SELECT *, CASE WHEN DPD <= 90 THEN 'Standard' WHEN DPD <= 455 THEN 'Substandard'
                 WHEN DPD <= 910 THEN 'Doubtful' ELSE 'Loss' END AS RequiredClass FROM LoanBook WHERE QuarterEnd = '2025-03-31')
SELECT Segment, COUNT(*) AS loans,
       ROUND(SUM(Outstanding), 0) AS advances_lakh,
       ROUND(SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding ELSE 0 END), 0) AS gnpa_lakh,
       ROUND(100.0 * SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding ELSE 0 END) / SUM(Outstanding), 2) AS gnpa_pct,
       ROUND(100.0 * SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding ELSE 0 END)
             / SUM(SUM(CASE WHEN RequiredClass <> 'Standard' THEN Outstanding ELSE 0 END)) OVER (), 1) AS share_of_npa_pct
FROM l GROUP BY Segment ORDER BY gnpa_pct DESC;
