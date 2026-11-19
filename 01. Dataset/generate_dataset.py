"""
Generate the SYNTHETIC raw dataset for the Financial & Regulatory Reporting project.

A small fictional bank ("Sample Co-operative Bank") with 8 quarter-ends from Jun 2023 to Mar 2025 (FY 2023-24 and
FY 2024-25): a loan book at loan level, deposits by branch, a chart of accounts and general-ledger (GL) balances.
All values are randomly generated (seed 51) for learning. No real bank data is used. Amounts in INR lakh.

Run:  python generate_dataset.py
Output: ./Raw Dataset/{ChartOfAccounts,GLBalances,LoanBook,Deposits,Branches}.csv
(The raw files deliberately contain data-quality and classification problems that clean_dataset.py and the SQL checks find.)
"""
import os
import numpy as np
import pandas as pd

rng = np.random.default_rng(51)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Raw Dataset")
os.makedirs(OUT, exist_ok=True)
QE = ["2023-06-30", "2023-09-30", "2023-12-31", "2024-03-31", "2024-06-30", "2024-09-30", "2024-12-31", "2025-03-31"]

branches = pd.DataFrame({"BranchID": [f"BR{i:02d}" for i in range(1, 13)],
                         "BranchName": ["Anna Nagar", "T Nagar", "Adyar", "Tambaram", "Coimbatore RS Puram", "Coimbatore Gandhipuram",
                                        "Madurai Town", "Trichy Cantonment", "Salem", "Vellore", "Puducherry", "Hosur"],
                         "Region": ["Chennai"] * 4 + ["West"] * 2 + ["South"] * 2 + ["North"] * 2 + ["Puducherry", "West"]})

# --------------------------------------------------------------- loan book
seg = {  # segment: (share, avg size lakh, yield, quarterly slip prob, risk weight)
    "Home Loan":        (0.30, 32, 0.088, 0.010, 0.35),
    "MSME":             (0.25, 45, 0.112, 0.030, 0.75),
    "Gold Loan":        (0.15, 4,  0.098, 0.008, 0.50),
    "Personal Loan":    (0.12, 6,  0.145, 0.045, 1.25),
    "Vehicle Loan":     (0.10, 9,  0.105, 0.022, 1.00),
    "Agriculture":      (0.08, 7,  0.090, 0.035, 0.75),
}
loans, lid = {}, 1
def new_loan(q):
    global lid
    s = rng.choice(list(seg), p=[v[0] for v in seg.values()])
    amt = round(float(rng.lognormal(np.log(seg[s][1]), 0.6)), 2)
    l = {"LoanID": f"LN{lid:06d}", "Segment": s, "BranchID": rng.choice(branches.BranchID), "SanctionDate": QE[q] if q >= 0 else "2022-01-15",
         "Sanctioned": amt, "Outstanding": amt * float(rng.uniform(0.6, 1.0)) if q < 0 else amt, "State": 0, "NPAQuarters": 0,
         "Borrower": f"CUST{int(rng.integers(1, 5200)):05d}" if rng.random() < 0.996 else f"GRP{int(rng.integers(1, 12)):02d}"}
    if l["Borrower"].startswith("GRP"):                 # a few large group exposures
        l["Sanctioned"] = l["Outstanding"] = round(float(rng.uniform(300, 800)), 2)
        l["Segment"] = "MSME"
    lid += 1
    return l
for _ in range(5200):
    l = new_loan(-1)
    l["State"] = int(rng.choice([0, 1, 2, 3, 4], p=[0.85, 0.07, 0.03, 0.015, 0.035]))
    l["NPAQuarters"] = int(rng.integers(0, 7)) if l["State"] == 4 else 0
    loans[l["LoanID"]] = l

rows = []
for qi, qe in enumerate(QE):
    for _ in range(int(rng.integers(380, 520))):
        l = new_loan(qi)
        loans[l["LoanID"]] = l
    closed = []
    for l in loans.values():
        p = seg[l["Segment"]][3] * (1.25 if qi >= 5 and l["Segment"] in ("Personal Loan", "MSME") else 1)
        st = l["State"]
        if st == 0:
            l["State"] = 1 if rng.random() < p * 2 else 0
        elif st < 4:
            r = rng.random()
            l["State"] = st + 1 if r < 0.30 + 0.1 * st else (0 if r < 0.75 else st)
        else:
            l["State"] = 0 if rng.random() < 0.07 else 4
        l["NPAQuarters"] = l["NPAQuarters"] + 1 if l["State"] == 4 else 0
        l["Outstanding"] = round(l["Outstanding"] * (0.955 if l["State"] == 0 else 1.0), 2)
        if l["Outstanding"] < 0.3 * l["Sanctioned"] and l["State"] == 0 and rng.random() < 0.5:
            closed.append(l["LoanID"])
            continue
        if l["NPAQuarters"] > 10:                      # written off
            closed.append(l["LoanID"])
            continue
        dpd = {0: 0, 1: int(rng.integers(1, 31)), 2: int(rng.integers(31, 61)), 3: int(rng.integers(61, 91))}.get(l["State"], 90 + 91 * l["NPAQuarters"] - int(rng.integers(0, 60)))
        if l["State"] < 4:
            ac = "Standard"
        else:
            ac = "Substandard" if l["NPAQuarters"] <= 4 else ("Doubtful" if l["NPAQuarters"] <= 9 else "Loss")
        rate = {"Standard": 0.004, "Substandard": 0.15, "Doubtful": 0.40, "Loss": 1.0}[ac]
        prudence = 1.0 if ac in ("Standard", "Loss") else float(rng.uniform(1.2, 1.8))   # most NPAs provided above the minimum
        booked = rate * (0.6 if (ac == "Doubtful" and l["Segment"] == "Personal Loan") else prudence)
        booked = min(booked, 1.0)
        rows.append({"QuarterEnd": qe, "LoanID": l["LoanID"], "BorrowerID": l["Borrower"], "BranchID": l["BranchID"], "Segment": l["Segment"],
                     "SanctionDate": l["SanctionDate"], "SanctionedAmt": l["Sanctioned"], "Outstanding": round(l["Outstanding"], 2),
                     "DPD": dpd, "AssetClass": ac, "ProvisionHeld": round(l["Outstanding"] * booked, 2),
                     "InterestRate": round(seg[l["Segment"]][2] + float(rng.normal(0, 0.006)), 4)})
    for c in closed:
        del loans[c]
lb = pd.DataFrame(rows)
# classification lag: some loans past 90 DPD still tagged Standard by the source system
lag = lb[(lb.AssetClass == "Substandard") & (lb.DPD < 200)].sample(frac=0.06, random_state=4).index
lb.loc[lag, "AssetClass"] = "Standard"
lb.loc[lag, "ProvisionHeld"] = (lb.loc[lag, "Outstanding"] * 0.004).round(2)

# ----------------------------------------------------------------- deposits
dep = []
bases = {b.BranchID: rng.uniform(140, 380) * 4.3 * (1.35 if b.Region == "Chennai" else 1) for b in branches.itertuples()}
for qi, qe in enumerate(QE):
    for b in branches.itertuples():
        base = bases[b.BranchID] * rng.uniform(0.98, 1.02)
        g = (1 + 0.035) ** qi
        casa_mix = 0.40 - 0.012 * qi + rng.normal(0, 0.015)       # CASA share drifting down as term deposits pay more
        tot = base * 10 * g
        dep += [{"QuarterEnd": qe, "BranchID": b.BranchID, "Product": "Savings", "Balance": round(tot * casa_mix * 0.78, 2)},
                {"QuarterEnd": qe, "BranchID": b.BranchID, "Product": "Current", "Balance": round(tot * casa_mix * 0.22, 2)},
                {"QuarterEnd": qe, "BranchID": b.BranchID, "Product": "Term Deposit", "Balance": round(tot * (1 - casa_mix), 2)}]
dp = pd.DataFrame(dep)

# --------------------------------------------------------- chart of accounts
coa = pd.DataFrame([
    ("1010", "Cash in hand", "BS", "Assets", "Cash & balances with RBI"), ("1020", "Balance with RBI", "BS", "Assets", "Cash & balances with RBI"),
    ("1030", "Balances with banks", "BS", "Assets", "Balances with banks"), ("1110", "Government securities (SLR)", "BS", "Assets", "Investments"),
    ("1120", "Other investments", "BS", "Assets", "Investments"), ("1210", "Loans and advances - gross", "BS", "Assets", "Advances"),
    ("1290", "Provisions on advances", "BS", "Assets", "Advances"), ("1310", "Fixed assets", "BS", "Assets", "Fixed assets"),
    ("1410", "Other assets", "BS", "Assets", "Other assets"), ("2010", "Share capital", "BS", "Equity", "Capital & reserves"),
    ("2020", "Reserves and surplus", "BS", "Equity", "Capital & reserves"), ("2110", "Savings deposits", "BS", "Liabilities", "Deposits"),
    ("2120", "Current deposits", "BS", "Liabilities", "Deposits"), ("2130", "Term deposits", "BS", "Liabilities", "Deposits"),
    ("2210", "Borrowings", "BS", "Liabilities", "Borrowings"), ("2310", "Other liabilities", "BS", "Liabilities", "Other liabilities & provisions"),
    ("4010", "Interest on advances", "PL", "Income", "Interest earned"), ("4020", "Interest on investments", "PL", "Income", "Interest earned"),
    ("4110", "Fee and commission income", "PL", "Income", "Other income"), ("5010", "Interest on deposits", "PL", "Expense", "Interest expended"),
    ("5020", "Interest on borrowings", "PL", "Expense", "Interest expended"), ("5110", "Staff costs", "PL", "Expense", "Operating expenses"),
    ("5120", "Other operating expenses", "PL", "Expense", "Operating expenses"), ("5210", "Provisions and contingencies", "PL", "Expense", "Provisions"),
    ("5310", "Income tax", "PL", "Expense", "Tax"),
], columns=["GLCode", "GLName", "Statement", "Class", "ReportLine"])

# ----------------------------------------------------------------- GL balances
gl, prev_loans, prev_prov, reserves = [], None, None, 13500.0
for qi, qe in enumerate(QE):
    q = lb[lb.QuarterEnd == qe]
    loans_gross = q.Outstanding.sum()
    prov = q.ProvisionHeld.sum()
    recon = {2: 412.6, 5: -287.3, 7: 655.9}.get(qi, 0.0)          # unreconciled GL vs loan sub-ledger differences
    d = dp[dp.QuarterEnd == qe].groupby("Product").Balance.sum()
    avg_loans = loans_gross if prev_loans is None else (loans_gross + prev_loans) / 2
    inv_slr = d.sum() * 0.20 * rng.uniform(1.0, 1.06)
    int_adv = (q.Outstanding * q.InterestRate).sum() / 4 * 0.97 * (avg_loans / loans_gross)
    int_inv = inv_slr * 1.15 * 0.071 / 4
    int_dep = (d["Savings"] * 0.030 + d["Term Deposit"] * (0.066 + 0.002 * qi)) / 4
    fee = loans_gross * 0.0022 * rng.uniform(0.9, 1.1)
    staff, other = 830 * (1.015 ** qi) * rng.uniform(0.97, 1.03), 500 * (1.02 ** qi) * rng.uniform(0.9, 1.15)
    prov_exp = max(prov - (prev_prov if prev_prov is not None else prov * 0.94), 0) + loans_gross * 0.0004
    borrow = 9000 + 700 * qi
    int_bor = borrow * 0.072 / 4
    pbt = int_adv + int_inv + fee - int_dep - int_bor - staff - other - prov_exp
    tax = max(pbt, 0) * 0.252
    reserves += pbt - tax
    assets = {"1010": d.sum() * 0.012, "1020": d.sum() * 0.045, "1030": d.sum() * 0.03, "1110": inv_slr, "1120": inv_slr * 0.15,
              "1210": loans_gross + recon, "1290": -prov, "1310": 1450 + 12 * qi, "1410": loans_gross * 0.015}
    liab = {"2010": 4500.0, "2020": reserves, "2110": d["Savings"], "2120": d["Current"], "2130": d["Term Deposit"], "2210": borrow}
    liab["2310"] = sum(assets.values()) - sum(liab.values())
    pl = {"4010": int_adv, "4020": int_inv, "4110": fee, "5010": int_dep, "5020": int_bor, "5110": staff, "5120": other, "5210": prov_exp, "5310": tax}
    for k, v in {**assets, **liab, **pl}.items():
        gl.append({"QuarterEnd": qe, "GLCode": k, "Amount": round(v, 2)})
    prev_loans, prev_prov = loans_gross, prov
gl = pd.DataFrame(gl)

# -------------------------------------------- deliberate data-quality issues
lb = pd.concat([lb, lb[lb.QuarterEnd == "2024-12-31"].sample(40, random_state=5)], ignore_index=True)    # duplicate extract rows
i = rng.choice(len(lb), 60, replace=False)
lb.loc[i, "Segment"] = lb.loc[i, "Segment"].str.upper()
gl["GLCode"] = gl.GLCode.astype(str)
gl["Amount"] = gl.Amount.astype(object)
t = gl.sample(6, random_state=6).index
gl.loc[t, "Amount"] = gl.loc[t, "Amount"].map(lambda v: f"{v:,.2f}")                       # amounts exported as text with commas

coa.to_csv(os.path.join(OUT, "ChartOfAccounts.csv"), index=False)
gl.to_csv(os.path.join(OUT, "GLBalances.csv"), index=False)
lb.to_csv(os.path.join(OUT, "LoanBook.csv"), index=False)
dp.to_csv(os.path.join(OUT, "Deposits.csv"), index=False)
branches.to_csv(os.path.join(OUT, "Branches.csv"), index=False)
print(f"loan-quarter rows {len(lb):,}  GL rows {len(gl)}  deposit rows {len(dp)}")
