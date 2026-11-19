-- 00_Create_Tables_And_Load.sql
-- Purpose : Create the 5 reporting tables and load the cleaned CSVs
-- Dialect : SQLite 3.32+ (run from the repo root:  sqlite3 project.db < "02. SQL Scripts/00_Create_Tables_And_Load.sql")
-- Data    : Synthetic data (generate_dataset.py, seed 51), cleaned by clean_dataset.py. Amounts in INR lakh

DROP TABLE IF EXISTS ChartOfAccounts;
DROP TABLE IF EXISTS GLBalances;
DROP TABLE IF EXISTS LoanBook;
DROP TABLE IF EXISTS Deposits;
DROP TABLE IF EXISTS Branches;

CREATE TABLE ChartOfAccounts (
    GLCode TEXT PRIMARY KEY,
    GLName TEXT,
    Statement TEXT,
    Class TEXT,
    ReportLine TEXT
);
CREATE TABLE GLBalances (
    QuarterEnd TEXT,
    GLCode TEXT REFERENCES ChartOfAccounts(GLCode),
    Amount REAL,
    PRIMARY KEY (QuarterEnd,
    GLCode)
);
CREATE TABLE LoanBook (
    QuarterEnd TEXT,
    LoanID TEXT,
    BorrowerID TEXT,
    BranchID TEXT REFERENCES Branches(BranchID),
    Segment TEXT,
    SanctionDate TEXT,
    SanctionedAmt REAL,
    Outstanding REAL,
    DPD INTEGER,
    AssetClass TEXT,
    ProvisionHeld REAL,
    InterestRate REAL,
    DPDBucket TEXT,
    PRIMARY KEY (QuarterEnd,
    LoanID)
);
CREATE TABLE Deposits (
    QuarterEnd TEXT,
    BranchID TEXT REFERENCES Branches(BranchID),
    Product TEXT,
    Balance REAL
);
CREATE TABLE Branches (
    BranchID TEXT PRIMARY KEY,
    BranchName TEXT,
    Region TEXT
);

.mode csv
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_ChartOfAccounts.csv" ChartOfAccounts
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_GLBalances.csv" GLBalances
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_LoanBook.csv" LoanBook
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_Deposits.csv" Deposits
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_Branches.csv" Branches

-- SQL Server: load with BULK INSERT / the Import Flat File wizard; MySQL: LOAD DATA INFILE.
-- Date functions differ: strftime('%Y-%m', d) -> FORMAT(d,'yyyy-MM') (SQL Server) / DATE_FORMAT(d,'%Y-%m') (MySQL);
-- julianday(a) - julianday(b) -> DATEDIFF(day, b, a) / DATEDIFF(a, b).
