# Report Specification

One line per report in the quarterly reporting pack of the fictional bank. Regulatory names and thresholds are **illustrative**; a real return follows the regulator's current format and instructions.

| ID | Report | Source | Logic (SQL script) | Frequency / deadline | Owner |
|---|---|---|---|---|---|
| RPT-01 | Balance sheet (quarterly) | GLBalances + ChartOfAccounts | Sum GL balances by ReportLine at quarter-end | Quarterly, T+10 days | Finance |
| RPT-02 | Profit and loss (FY comparison) | GLBalances + ChartOfAccounts | Sum P&L GLs over Apr-Mar; PAT = income - expenses | Quarterly / annual | Finance |
| RPT-03 | Key ratios (NIM, cost-to-income, ROA, CASA, CD ratio) | GLBalances | See 03_Key_Financial_Ratios.sql; quarterly x 4 to annualise | Quarterly | Finance |
| RPT-04 | Asset quality return (GNPA, NNPA, PCR, SMA) | LoanBook | Classify by DPD (90+ = NPA); see 04_Asset_Quality_Summary.sql | Quarterly | Credit / Risk |
| RPT-05 | Asset classification exception report | LoanBook | Loans 90+ DPD tagged Standard (05) | Monthly before close | Credit operations |
| RPT-06 | Provision adequacy | LoanBook | Required vs held provision by class and segment (08) | Quarterly | Finance / Risk |
| RPT-07 | Capital adequacy (illustrative) | LoanBook + GLBalances | Credit-risk RWA by segment weight; Tier 1 + Tier 2 / RWA (10) | Quarterly | Risk |
| RPT-08 | Large exposures | LoanBook + GLBalances | Borrower exposure vs Tier 1 (12) | Quarterly | Risk |
| RPT-09 | GL to sub-ledger reconciliation | GLBalances + LoanBook | GL 1210 vs sum of loan outstanding, tolerance ₹1 lakh (09) | Every quarter-end, before sign-off | Finance operations |

## Definitions
| Term | Definition used in this repo |
|---|---|
| DPD | Days past due on the loan at quarter-end |
| NPA | Loan more than 90 days past due |
| Substandard / Doubtful / Loss | NPA up to 12 months (DPD ≤ 455) / over 12 months (DPD 456-910) / DPD above 910 (illustrative cut-off) |
| GNPA % | Outstanding of NPAs / gross advances |
| NNPA % | (Gross NPA - NPA provisions) / (gross advances - NPA provisions) |
| PCR % | NPA provisions / gross NPA |
| SMA | Special mention accounts, 1-90 DPD (SMA-0 1-30, SMA-1 31-60, SMA-2 61-90) |
| CASA % | (Savings + current deposits) / total deposits |
| NIM % | (Interest earned - interest expended) x 4 / (advances + investments) |
| CRAR % | (Tier 1 + Tier 2) / risk-weighted assets; credit risk only in this repo |

## Report layout rules
- Amounts in INR lakh with no decimals in summaries; ratios to 2 decimals.
- Every report shows the quarter-end date, the source extract date and the preparer / checker.
- Comparatives: the same quarter last year for P&L items, the last financial year-end for balance-sheet items.
- A paginated (print-ready) version of RPT-01 to RPT-04 can be built in Power BI Report Builder from the same SQL.
