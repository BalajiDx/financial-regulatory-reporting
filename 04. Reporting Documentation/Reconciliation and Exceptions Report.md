# Reconciliation and Exceptions Report

Prepared from the SQL results for the 8 quarters Jun-23 to Mar-25 (synthetic data, INR lakh).

## 1. GL advances vs loan sub-ledger
| Quarter | GL 1210 | Loan sub-ledger | Difference | Status |
|---|---|---|---|---|
| Jun-23 | 134,340.34 | 134,340.34 | 0.00 | Reconciled |
| Sep-23 | 143,699.34 | 143,699.34 | 0.00 | Reconciled |
| Dec-23 | 150,720.78 | 150,308.18 | 412.60 | Break |
| Mar-24 | 159,908.03 | 159,908.03 | 0.00 | Reconciled |
| Jun-24 | 165,031.40 | 165,031.40 | 0.00 | Reconciled |
| Sep-24 | 172,155.26 | 172,442.56 | -287.30 | Break |
| Dec-24 | 178,729.94 | 178,729.94 | 0.00 | Reconciled |
| Mar-25 | 187,055.25 | 186,399.35 | 655.90 | Break |

**Next steps:** for each break, list the loans or journal entries that make up the difference (typical causes: interest accrued in the GL
but not yet in the sub-ledger, loans disbursed after the extract cut-off, manual journals). A break must be cleared or explained before sign-off.

## 2. Asset classification exceptions
| Quarter | Loans 90+ DPD tagged Standard | Outstanding | Provision shortfall |
|---|---|---|---|
| Jun-23 | 4 | 83.0 | 12.1 |
| Sep-23 | 2 | 24.4 | 3.6 |
| Dec-23 | 5 | 46.0 | 6.7 |
| Mar-24 | 5 | 110.9 | 16.2 |
| Jun-24 | 8 | 124.3 | 18.2 |
| Dec-24 | 7 | 195.6 | 28.6 |
| Mar-25 | 2 | 3.7 | 0.5 |

Effect at Mar-25: reported GNPA **7.08%** vs corrected **7.08%**.
**Next steps:** reclassify in the source system, raise the missing provision, and find why the system flag lags (e.g. classification run before the last repayment posting).

## 3. Provision gaps at Mar-25 (held below the illustrative minimum)
| Class | Segment | Loans | Required | Held | Shortfall |
|---|---|---|---|---|---|
| Doubtful | Personal Loan | 26 | 65.1 | 39.1 | -26.0 |

## 4. Large exposures
| Borrower | Loans | Exposure | % of advances | % of Tier 1 | Flag |
|---|---|---|---|---|---|
| GRP08 | 7 | 3,254.0 | 1.75% | 16.40% | Watch (above 5%) |
| GRP10 | 4 | 2,128.3 | 1.14% | 10.72% | Watch (above 5%) |
| GRP05 | 4 | 1,841.3 | 0.99% | 9.28% | Watch (above 5%) |
| GRP09 | 3 | 1,537.3 | 0.82% | 7.75% | Watch (above 5%) |
| GRP02 | 2 | 784.1 | 0.42% | 3.95% | OK |
| GRP04 | 2 | 782.2 | 0.42% | 3.94% | OK |
| GRP07 | 2 | 757.0 | 0.41% | 3.81% | OK |
| GRP01 | 2 | 708.8 | 0.38% | 3.57% | OK |

The 5% of Tier 1 watch level is an illustrative internal limit.
