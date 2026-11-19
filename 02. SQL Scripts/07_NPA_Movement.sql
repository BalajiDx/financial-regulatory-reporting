-- 07_NPA_Movement.sql
-- Question : How did gross NPAs move each quarter (opening, additions, reductions, closing)?
-- Note     : Reductions include upgrades, recoveries and write-offs. Uses the corrected (DPD-based) classification.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH n AS (SELECT QuarterEnd, LoanID, Outstanding FROM LoanBook WHERE DPD > 90),
qs AS (SELECT DISTINCT QuarterEnd FROM LoanBook),
pq AS (SELECT QuarterEnd, LAG(QuarterEnd) OVER (ORDER BY QuarterEnd) AS prev_q FROM qs)
SELECT pq.QuarterEnd,
       ROUND((SELECT SUM(Outstanding) FROM n WHERE n.QuarterEnd = pq.prev_q), 0) AS opening_gnpa,
       ROUND((SELECT SUM(c.Outstanding) FROM n c WHERE c.QuarterEnd = pq.QuarterEnd
              AND c.LoanID NOT IN (SELECT LoanID FROM n p WHERE p.QuarterEnd = pq.prev_q)), 0) AS additions,
       ROUND((SELECT SUM(p.Outstanding) FROM n p WHERE p.QuarterEnd = pq.prev_q
              AND p.LoanID NOT IN (SELECT LoanID FROM n c WHERE c.QuarterEnd = pq.QuarterEnd)), 0) AS reductions,
       ROUND((SELECT SUM(Outstanding) FROM n WHERE n.QuarterEnd = pq.QuarterEnd), 0) AS closing_gnpa
FROM pq WHERE pq.prev_q IS NOT NULL ORDER BY pq.QuarterEnd;
