# Power BI Build Guide

Steps to rebuild the report in Power BI Desktop from this repo. The `.pbix` itself is not included; save yours as
`03. Power BI/File/Financial_Regulatory_Reporting.pbix` once built. The images in `Dashboard Images/` show the target layout.

## 1. Load the data
1. **Home > Get data > Text/CSV**, and load these files from `01. Dataset/Cleaned Dataset/`:
   - `Clean_ChartOfAccounts.csv` -> rename the query to `ChartOfAccounts`
   - `Clean_GLBalances.csv` -> rename the query to `GLBalances`
   - `Clean_LoanBook.csv` -> rename the query to `LoanBook`
   - `Clean_Deposits.csv` -> rename the query to `Deposits`
   - `Clean_Branches.csv` -> rename the query to `Branches`
2. In Power Query set types: dates to **Date**, money and rates to **Decimal number**, counts to **Whole number**, IDs to **Text**.
3. Keep `GLCode` as **Text** (leading zeros and codes like 1010 must not be summed).
4. Create the `Quarters` table from `DAX/Measures.dax` (it replaces a daily Calendar: all data is at quarter-end).
5. Balance-sheet measures are point-in-time. Use `Closing Balance` in visuals that span several quarters; never sum balances across quarters.

## 2. Model
Create these relationships (single direction, filter flows from the "1" side):

| From (1) | To (*) |
|---|---|
| ChartOfAccounts[GLCode] | GLBalances[GLCode] |
| Quarters[QuarterEnd] | GLBalances[QuarterEnd] |
| Quarters[QuarterEnd] | LoanBook[QuarterEnd] |
| Quarters[QuarterEnd] | Deposits[QuarterEnd] |
| Branches[BranchID] | LoanBook[BranchID] |
| Branches[BranchID] | Deposits[BranchID] |

Mark `Calendar` as the date table.

## 3. Add DAX
From `DAX/Measures.dax`, in order: the `Calendar` table, calculated columns (set **Sort by column** on band columns),
then measures in a dedicated `_Measures` table with display folders (Financials, Ratios, Asset Quality, Controls).

## 4. Pages
| Page | Image | Visuals |
|---|---|---|
| 1. Financial Performance | `1.Financial_Performance.png` | KPI cards, NIM and CASA lines, P&L table, cost-to-income columns |
| 2. Asset Quality | `2.Asset_Quality.png` | GNPA reported vs corrected line, NPA by segment, NPA movement table, exceptions table |
| 3. Regulatory Ratios & Controls | `3.Regulatory_Ratios_Controls.png` | CRAR line, CASA by branch, reconciliation table, control checks |
| Model | `4.Data_Model.png` | Relationships to build in Model view |

## 5. Check your numbers
With no slicers applied the report should show:
- GNPA % at Mar-25 ≈ 7.08% (reported 7.08%)
- CASA % at Mar-25 ≈ 31.3%; NIM % ≈ 3.34%
- Advances Recon Status shows Break for Dec-23, Sep-24, Mar-25

The full set of reference results is in `02. SQL Scripts/Query Results/`. Anything different means a relationship or a data type is wrong.

## 6. Optional: Power BI Service
Publish to a workspace, set **scheduled refresh** (a gateway is needed for on-premises sources), add **row-level security**
under Modeling > Manage roles, and use a **deployment pipeline** to move the report from Development to Test to Production.
