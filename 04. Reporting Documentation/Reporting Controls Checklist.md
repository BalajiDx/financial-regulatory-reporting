# Reporting Controls Checklist

Run before the quarterly pack is signed off. Results below are from the SQL scripts on the synthetic data (8 quarters).

| # | Control | How | Result | Status |
|---|---|---|---|---|
| C1 | Source extracts complete | Row counts vs previous quarter; duplicate rows removed (Cleaning Log) | 40 duplicate loan rows removed | Done |
| C2 | Balance sheet balances | 14_Balance_Sheet_Control_Check.sql | 8 of 8 quarters pass | Pass |
| C3 | GL advances = loan sub-ledger | 09_GL_Subledger_Reconciliation.sql | 3 breaks: Dec-23 (+412.6 L), Sep-24 (-287.3 L), Mar-25 (+655.9 L) | Fail - explain |
| C4 | Asset class agrees with DPD | 05_Asset_Classification_Exceptions.sql | 33 loan-quarters misclassified | Fail - reclassify |
| C5 | Provisions at least minimum | 08_Provision_Adequacy.sql | 1 class-segment gaps, total -26.0 L short at Mar-25 | Fail - top up |
| C6 | All GL codes mapped | Cleaning check against ChartOfAccounts | 0 unmapped codes | Pass |
| C7 | Analytical review | 13_PL_Variance_Review.sql (> 15% QoQ) | 12 movements to explain | Explain |
| C8 | Maker-checker | Preparer and checker named on each report | Template field | Process |
| C9 | Version control | Reports and SQL kept in this repo; changes by pull request | Git history | Process |

A **Fail** does not stop the pack automatically: each one needs an owner, a correction or an explanation, and the checker's sign-off.
