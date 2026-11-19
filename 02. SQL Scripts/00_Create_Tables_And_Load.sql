-- 00_Create_Tables_And_Load.sql
-- Purpose : create the nine tables used by scripts 01-25 and load the CSVs from 01. Dataset/.
-- Dialect : SQLite 3.25+ (window functions). Run in the sqlite3 shell from the repo root:
--             sqlite3 case_studies.db < "02. SQL Scripts/00_Create_Tables_And_Load.sql"
-- Data    : SYNTHETIC (seed 7). Amounts in INR. Banking transactions cover 2024; retail orders 2023-2024.
-- Note    : banking and retail customers live in separate tables (BankCustomers, RetailCustomers).

DROP TABLE IF EXISTS Branches;      DROP TABLE IF EXISTS BankCustomers;
DROP TABLE IF EXISTS Accounts;      DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Stores;        DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS RetailCustomers; DROP TABLE IF EXISTS Orders; DROP TABLE IF EXISTS OrderItems;

CREATE TABLE Branches      (BranchID TEXT PRIMARY KEY, BranchName TEXT, City TEXT, Region TEXT, OpenedYear INTEGER);
CREATE TABLE BankCustomers (CustomerID TEXT PRIMARY KEY, Gender TEXT, Age INTEGER, Segment TEXT,
                            HomeBranchID TEXT REFERENCES Branches(BranchID), JoinDate TEXT);
CREATE TABLE Accounts      (AccountID TEXT PRIMARY KEY, CustomerID TEXT REFERENCES BankCustomers(CustomerID),
                            AccountType TEXT, OpenDate TEXT, CloseDate TEXT, BranchID TEXT REFERENCES Branches(BranchID));
CREATE TABLE Transactions  (TxnID TEXT PRIMARY KEY, AccountID TEXT REFERENCES Accounts(AccountID), TxnDate TEXT,
                            Channel TEXT, Direction TEXT, Amount REAL);
CREATE TABLE Stores        (StoreID TEXT PRIMARY KEY, StoreName TEXT, Format TEXT, OpenDate TEXT);
CREATE TABLE Products      (ProductID TEXT PRIMARY KEY, ProductName TEXT, Category TEXT, Brand TEXT,
                            ListPrice REAL, UnitCost REAL);
CREATE TABLE RetailCustomers (CustomerID TEXT PRIMARY KEY, City TEXT, LoyaltyTier TEXT, FirstPurchaseDate TEXT);
CREATE TABLE Orders        (OrderID TEXT PRIMARY KEY, CustomerID TEXT REFERENCES RetailCustomers(CustomerID),
                            StoreID TEXT REFERENCES Stores(StoreID), OrderDate TEXT, Status TEXT, PaymentMode TEXT);
CREATE TABLE OrderItems    (OrderItemID TEXT PRIMARY KEY, OrderID TEXT REFERENCES Orders(OrderID),
                            ProductID TEXT REFERENCES Products(ProductID), Quantity INTEGER, UnitPrice REAL, DiscountPct REAL);

.mode csv
.import --skip 1 "01. Dataset/Banking/Branches.csv"     Branches
.import --skip 1 "01. Dataset/Banking/Customers.csv"    BankCustomers
.import --skip 1 "01. Dataset/Banking/Accounts.csv"     Accounts
.import --skip 1 "01. Dataset/Banking/Transactions.csv" Transactions
.import --skip 1 "01. Dataset/Retail/Stores.csv"        Stores
.import --skip 1 "01. Dataset/Retail/Products.csv"      Products
.import --skip 1 "01. Dataset/Retail/Customers.csv"     RetailCustomers
.import --skip 1 "01. Dataset/Retail/Orders.csv"        Orders
.import --skip 1 "01. Dataset/Retail/OrderItems.csv"    OrderItems
UPDATE Accounts SET CloseDate = NULL WHERE CloseDate = '';

-- SQL Server / MySQL: replace .import with BULK INSERT / LOAD DATA INFILE, and
--   strftime('%Y-%m', d)  -> FORMAT(d,'yyyy-MM')  /  DATE_FORMAT(d,'%Y-%m')
--   julianday(a) - julianday(b) -> DATEDIFF(day, b, a)  /  DATEDIFF(a, b)
