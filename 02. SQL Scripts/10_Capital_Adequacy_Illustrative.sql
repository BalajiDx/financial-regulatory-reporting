-- 10_Capital_Adequacy_Illustrative.sql
-- Question : What is an illustrative capital adequacy ratio (credit risk only) each quarter?
-- Note     : Simplified: Tier 1 = capital + reserves; Tier 2 = standard-asset provisions (cap 1.25% of RWA). RWA = loans x segment risk weight (NPAs 100%) + other investments 100% + fixed and other assets 100%. Market and operational risk are left out. Not a regulatory calculation.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH rw AS (
    SELECT QuarterEnd,
           SUM((Outstanding - ProvisionHeld) * CASE WHEN CASE WHEN DPD <= 90 THEN 'Standard' WHEN DPD <= 455 THEN 'Substandard'
                 WHEN DPD <= 910 THEN 'Doubtful' ELSE 'Loss' END <> 'Standard' THEN 1.0 ELSE
               CASE Segment WHEN 'Home Loan' THEN 0.35 WHEN 'Gold Loan' THEN 0.5 WHEN 'Personal Loan' THEN 1.25
                            WHEN 'Vehicle Loan' THEN 1.0 ELSE 0.75 END END) AS credit_rwa,
           SUM(CASE WHEN CASE WHEN DPD <= 90 THEN 'Standard' WHEN DPD <= 455 THEN 'Substandard'
                 WHEN DPD <= 910 THEN 'Doubtful' ELSE 'Loss' END = 'Standard' THEN ProvisionHeld ELSE 0 END) AS std_prov
    FROM LoanBook GROUP BY QuarterEnd
), g AS (
    SELECT QuarterEnd,
           SUM(CASE WHEN GLCode IN ('2010', '2020') THEN Amount END) AS tier1,
           SUM(CASE WHEN GLCode IN ('1120', '1310', '1410') THEN Amount END) AS other_rwa
    FROM GLBalances GROUP BY QuarterEnd
)
SELECT g.QuarterEnd,
       ROUND(rw.credit_rwa + g.other_rwa, 0) AS rwa,
       ROUND(g.tier1, 0) AS tier1,
       ROUND(MIN(rw.std_prov, 0.0125 * (rw.credit_rwa + g.other_rwa)), 0) AS tier2,
       ROUND(100.0 * g.tier1 / (rw.credit_rwa + g.other_rwa), 2) AS tier1_ratio_pct,
       ROUND(100.0 * (g.tier1 + MIN(rw.std_prov, 0.0125 * (rw.credit_rwa + g.other_rwa))) / (rw.credit_rwa + g.other_rwa), 2) AS crar_pct
FROM g JOIN rw ON rw.QuarterEnd = g.QuarterEnd ORDER BY g.QuarterEnd;
