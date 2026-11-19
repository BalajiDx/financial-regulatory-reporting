# Data Lineage

How each reported number travels from the source systems to the report. (Mermaid diagram: renders on GitHub.)

```mermaid
flowchart LR
    CBS[(Core banking system<br/>loan accounts)] -->|daily extract| LB[LoanBook<br/>loan-level, quarter-end]
    CBS -->|deposit balances| DP[Deposits<br/>branch x product]
    GLS[(General ledger)] -->|trial balance| GL[GLBalances]
    COA[ChartOfAccounts<br/>GL -> report line] --> GL
    LB -->|clean_dataset.py| CL[Cleaned Dataset]
    DP --> CL
    GL --> CL
    CL -->|SQL 01-03| FIN[Financial statements<br/>and ratios]
    CL -->|SQL 04-08| AQ[Asset quality, exceptions,<br/>provisions]
    CL -->|SQL 10, 12| REG[Capital and<br/>large exposures]
    CL -->|SQL 09, 14| CTRL[Reconciliations and<br/>control checks]
    CTRL -->|must pass or be explained| SIGN{Checker sign-off}
    FIN --> SIGN
    AQ --> SIGN
    REG --> SIGN
    SIGN --> PACK[Quarterly reporting pack<br/>and Power BI report]
```

## Field-level lineage (examples)
| Reported item | Source field | Transformation |
|---|---|---|
| Gross advances | LoanBook.Outstanding | Sum at quarter-end; must agree with GL 1210 |
| Gross NPA | LoanBook.Outstanding, LoanBook.DPD | Sum where DPD > 90 (not the source AssetClass tag) |
| NPA provisions | LoanBook.ProvisionHeld | Sum where DPD > 90 |
| CASA % | GLBalances 2110, 2120, 2130 | (2110 + 2120) / (2110 + 2120 + 2130) |
| Net profit | GLBalances 4xxx, 5xxx | Income GLs - expense GLs over the financial year |
| Tier 1 | GLBalances 2010, 2020 | Share capital + reserves |
