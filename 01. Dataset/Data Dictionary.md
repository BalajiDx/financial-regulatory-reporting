# Data Dictionary

Synthetic data for a fictional bank, seed 51. 8 quarter-ends, Jun 2023 - Mar 2025 (FY = April to March). Amounts in INR lakh.

## ChartOfAccounts
| Column | Description |
|---|---|
| GLCode (PK) | 4-digit GL code (text) |
| GLName |  |
| Statement | BS (balance sheet) or PL (profit and loss) |
| Class | Assets, Liabilities, Equity, Income, Expense |
| ReportLine | Line in the published statements |

## GLBalances
| Column | Description |
|---|---|
| QuarterEnd | Quarter-end date |
| GLCode (FK) |  |
| Amount | BS: closing balance (provisions negative). PL: amount for the quarter |

## LoanBook
| Column | Description |
|---|---|
| QuarterEnd, LoanID | Key: one row per loan per quarter-end |
| BorrowerID | Customer; GRPxx = a borrower group |
| BranchID (FK) |  |
| Segment | Home Loan, MSME, Gold Loan, Personal Loan, Vehicle Loan, Agriculture |
| SanctionDate, SanctionedAmt |  |
| Outstanding | Principal outstanding |
| DPD | Days past due |
| AssetClass | Classification from the source system (may lag DPD) |
| ProvisionHeld | Provision booked |
| InterestRate | Annual rate |
| DPDBucket | Added in cleaning |

## Deposits
| Column | Description |
|---|---|
| QuarterEnd, BranchID, Product | Product = Savings, Current, Term Deposit |
| Balance |  |

## Branches
| Column | Description |
|---|---|
| BranchID (PK) |  |
| BranchName, Region |  |
