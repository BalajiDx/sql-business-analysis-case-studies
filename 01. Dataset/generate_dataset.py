"""
Generate the SYNTHETIC datasets for the SQL Business Analysis Case Studies.

Two small schemas are created, one for banking and one for retail. Everything is random
(seed 7); no real bank, retailer or customer data is used.

Run:  python generate_dataset.py
Output: ./Banking/*.csv and ./Retail/*.csv
"""
import os
import numpy as np
import pandas as pd

rng = np.random.default_rng(7)
HERE = os.path.dirname(os.path.abspath(__file__))
for d in ("Banking", "Retail"):
    os.makedirs(os.path.join(HERE, d), exist_ok=True)

# ===================================================================== BANKING
branches = pd.DataFrame({
    "BranchID": [f"BR{i:02d}" for i in range(1, 13)],
    "BranchName": ["Puducherry Main", "Lawspet", "Villianur", "Karaikal", "Chennai T Nagar", "Chennai Anna Nagar",
                   "Cuddalore", "Villupuram", "Tindivanam", "Bengaluru MG Road", "Coimbatore RS Puram", "Madurai Town"],
    "City": ["Puducherry", "Puducherry", "Puducherry", "Karaikal", "Chennai", "Chennai",
             "Cuddalore", "Villupuram", "Tindivanam", "Bengaluru", "Coimbatore", "Madurai"],
    "Region": ["South-East", "South-East", "South-East", "South-East", "Chennai", "Chennai",
               "South-East", "South-East", "South-East", "Karnataka", "Western TN", "Southern TN"],
    "OpenedYear": [1998, 2006, 2011, 2003, 2001, 2008, 2009, 2014, 2017, 2012, 2010, 2005],
})
N_C = 2500
cust = pd.DataFrame({
    "CustomerID": [f"BC{i:05d}" for i in range(1, N_C + 1)],
    "Gender": rng.choice(["F", "M"], N_C),
    "Age": rng.integers(19, 76, N_C),
    "Segment": rng.choice(["Mass", "Mass Affluent", "Affluent", "MSME"], N_C, p=[0.55, 0.25, 0.08, 0.12]),
    "HomeBranchID": rng.choice(branches["BranchID"], N_C, p=np.r_[[0.12, 0.08, 0.06, 0.07, 0.12, 0.10], [0.06, 0.07, 0.05, 0.10, 0.09, 0.08]] / 1.0),
})
cust["JoinDate"] = (pd.Timestamp("2016-01-01") + pd.to_timedelta(rng.integers(0, 365 * 8, N_C), unit="D")).strftime("%Y-%m-%d")

acc_rows = []
aid = 1
for _, c in cust.iterrows():
    kinds = ["Savings"]
    if rng.random() < 0.35:
        kinds.append("Current" if c["Segment"] == "MSME" else "Fixed Deposit")
    if rng.random() < 0.18:
        kinds.append("Recurring Deposit")
    for k in kinds:
        opened = min(pd.Timestamp(c["JoinDate"]) + pd.Timedelta(days=int(rng.integers(0, 400))),
                     pd.Timestamp("2024-12-31"))
        closed = ""
        if rng.random() < 0.07:
            closed = (opened + pd.Timedelta(days=int(rng.integers(200, 2000)))).strftime("%Y-%m-%d")
            if closed > "2024-12-31":
                closed = ""
        acc_rows.append({"AccountID": f"A{aid:06d}", "CustomerID": c["CustomerID"], "AccountType": k,
                         "OpenDate": opened.strftime("%Y-%m-%d"), "CloseDate": closed,
                         "BranchID": c["HomeBranchID"]})
        aid += 1
acc = pd.DataFrame(acc_rows)

tx_rows = []
tid = 1
channels = ["UPI", "ATM", "Branch", "NetBanking", "POS"]
active = acc[acc["AccountType"].isin(["Savings", "Current"])]
for _, a in active.iterrows():
    seg = cust.loc[cust["CustomerID"] == a["CustomerID"], "Segment"].iloc[0]
    scale = {"Mass": 1.0, "Mass Affluent": 2.5, "Affluent": 6.0, "MSME": 8.0}[seg]
    n = int(rng.poisson(14 if a["AccountType"] == "Savings" else 40))
    start = max(pd.Timestamp(a["OpenDate"]), pd.Timestamp("2024-01-01"))
    end = pd.Timestamp(a["CloseDate"]) if a["CloseDate"] else pd.Timestamp("2024-12-31")
    if rng.random() < 0.09:                       # ~9% of accounts go quiet part-way through the year
        end = min(end, pd.Timestamp("2024-05-31"))
    if end <= start:
        continue
    days = (end - start).days
    for _ in range(n):
        ch = rng.choice(channels, p=[0.46, 0.14, 0.08, 0.17, 0.15])
        dc = "Credit" if rng.random() < 0.42 else "Debit"
        amt = float(np.round(rng.lognormal(np.log(2500 * scale), 1.0), 2))
        if ch == "ATM":                       # cash withdrawals are capped
            dc, amt = "Debit", float(min(round(amt, -2) or 100, 40000))
        tx_rows.append({"TxnID": f"T{tid:07d}", "AccountID": a["AccountID"],
                        "TxnDate": (start + pd.Timedelta(days=int(rng.integers(0, days)))).strftime("%Y-%m-%d"),
                        "Channel": ch, "Direction": dc, "Amount": amt})
        tid += 1
tx = pd.DataFrame(tx_rows).sort_values(["TxnDate", "TxnID"])

branches.to_csv(os.path.join(HERE, "Banking", "Branches.csv"), index=False)
cust.to_csv(os.path.join(HERE, "Banking", "Customers.csv"), index=False)
acc.to_csv(os.path.join(HERE, "Banking", "Accounts.csv"), index=False)
tx.to_csv(os.path.join(HERE, "Banking", "Transactions.csv"), index=False)

# ====================================================================== RETAIL
stores = pd.DataFrame({
    "StoreID": [f"S{i:02d}" for i in range(1, 9)],
    "StoreName": ["Puducherry Beach Rd", "Chennai Velachery", "Chennai OMR", "Bengaluru Whitefield",
                  "Coimbatore Gandhipuram", "Madurai Anna Nagar", "Trichy Cantonment", "Online"],
    "Format": ["Supermarket", "Hypermarket", "Supermarket", "Hypermarket", "Supermarket", "Supermarket", "Express", "Online"],
    "OpenDate": ["2015-04-01", "2017-08-15", "2019-02-01", "2018-11-10", "2016-06-01", "2020-01-20", "2021-07-01", "2019-09-01"],
})
cats = {"Staples": (40, 450), "Dairy": (25, 180), "Personal Care": (60, 650), "Household": (50, 900),
        "Beverages": (20, 320), "Snacks": (10, 250), "Fresh Produce": (15, 220), "Home Appliances": (900, 12000)}
prod_rows = []
pid = 1
for cat, (lo, hi) in cats.items():
    for j in range(int(rng.integers(14, 24))):
        price = float(np.round(rng.uniform(lo, hi), 0))
        prod_rows.append({"ProductID": f"P{pid:04d}", "ProductName": f"{cat} item {j + 1:02d}", "Category": cat,
                          "Brand": rng.choice(["Own Label", "Brand A", "Brand B", "Brand C", "Brand D"],
                                              p=[0.25, 0.25, 0.2, 0.15, 0.15]),
                          "ListPrice": price, "UnitCost": float(np.round(price * rng.uniform(0.62, 0.82), 2))})
        pid += 1
prod = pd.DataFrame(prod_rows)
# appliances are bought far less often than groceries
cat_weight = {"Staples": 1.4, "Dairy": 1.5, "Personal Care": 1.0, "Household": 0.9, "Beverages": 1.1,
              "Snacks": 1.3, "Fresh Produce": 1.4, "Home Appliances": 0.035}
prod_p = prod["Category"].map(cat_weight).to_numpy()
prod_p = prod_p / prod_p.sum()

N_RC = 4000
rcust = pd.DataFrame({
    "CustomerID": [f"RC{i:05d}" for i in range(1, N_RC + 1)],
    "City": rng.choice(["Puducherry", "Chennai", "Bengaluru", "Coimbatore", "Madurai", "Trichy"], N_RC,
                       p=[0.15, 0.34, 0.2, 0.12, 0.11, 0.08]),
    "LoyaltyTier": rng.choice(["None", "Silver", "Gold"], N_RC, p=[0.6, 0.3, 0.1]),
})
first = pd.Timestamp("2023-01-01") + pd.to_timedelta(rng.integers(0, 700, N_RC), unit="D")
rcust["FirstPurchaseDate"] = first.strftime("%Y-%m-%d")

ord_rows, item_rows = [], []
oid = 1
iid = 1
store_p = np.array([0.12, 0.17, 0.12, 0.16, 0.11, 0.1, 0.07, 0.15])
for i, c in rcust.iterrows():
    loyal = {"None": 0.6, "Silver": 1.4, "Gold": 2.6}[c["LoyaltyTier"]]
    t = first[i]
    n_orders = 1 + int(rng.poisson(3.2 * loyal))
    for k in range(n_orders):
        if t > pd.Timestamp("2024-12-31"):
            break
        st = rng.choice(stores["StoreID"], p=store_p)
        status = rng.choice(["Delivered", "Returned", "Cancelled"], p=[0.92, 0.05, 0.03])
        ord_rows.append({"OrderID": f"O{oid:06d}", "CustomerID": c["CustomerID"], "StoreID": st,
                         "OrderDate": t.strftime("%Y-%m-%d"), "Status": status,
                         "PaymentMode": rng.choice(["UPI", "Card", "Cash", "Wallet"], p=[0.44, 0.27, 0.21, 0.08])})
        for _ in range(int(rng.integers(1, 7))):
            p = prod.iloc[int(rng.choice(len(prod), p=prod_p))]
            disc = float(rng.choice([0, 0, 0, 0.05, 0.1, 0.15]))
            item_rows.append({"OrderItemID": f"OI{iid:07d}", "OrderID": f"O{oid:06d}", "ProductID": p["ProductID"],
                              "Quantity": int(rng.integers(1, 5)), "UnitPrice": p["ListPrice"], "DiscountPct": disc})
            iid += 1
        oid += 1
        t = t + pd.Timedelta(days=int(rng.exponential(55 / loyal)) + 1)
orders = pd.DataFrame(ord_rows)
items = pd.DataFrame(item_rows)

stores.to_csv(os.path.join(HERE, "Retail", "Stores.csv"), index=False)
prod.to_csv(os.path.join(HERE, "Retail", "Products.csv"), index=False)
rcust.to_csv(os.path.join(HERE, "Retail", "Customers.csv"), index=False)
orders.to_csv(os.path.join(HERE, "Retail", "Orders.csv"), index=False)
items.to_csv(os.path.join(HERE, "Retail", "OrderItems.csv"), index=False)
for n, df in [("Banking/Branches", branches), ("Banking/Customers", cust), ("Banking/Accounts", acc),
              ("Banking/Transactions", tx), ("Retail/Stores", stores), ("Retail/Products", prod),
              ("Retail/Customers", rcust), ("Retail/Orders", orders), ("Retail/OrderItems", items)]:
    print(f"{n:<22}{len(df):>8,} rows")
