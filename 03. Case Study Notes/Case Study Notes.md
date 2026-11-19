# Case Study Notes

One entry per script: the business question, the SQL approach and what the result shows.
All numbers come from `02. SQL Scripts/Query Results/` and describe this **synthetic** dataset only.

## Part A: Banking (scripts 01-12)

### 01. How many customers and accounts does each branch hold?
- **Script:** `01_Branch_Customer_And_Account_Count.sql`  ·  **Result:** `Query Results/01_Branch_Customer_And_Account_Count.csv`
- **Approach:** JOIN, GROUP BY, COUNT DISTINCT
- **Answer:** Puducherry Main is the largest branch (300 customers, 472 accounts). Customers hold 1.52 accounts on average.

### 02. How many products does each customer hold, and how many hold only a savings account?
- **Script:** `02_Product_Holding_Mix.sql`  ·  **Result:** `Query Results/02_Product_Holding_Mix.csv`
- **Approach:** CTE, conditional aggregation
- **Answer:** 53.32% of customers hold only a savings account, a cross-sell opportunity; 5.76% hold three products.

### 03. How do monthly transaction count and value move through 2024?
- **Script:** `03_Monthly_Transaction_Trend.sql`  ·  **Result:** `Query Results/03_Monthly_Transaction_Trend.csv`
- **Approach:** strftime, GROUP BY, LAG
- **Answer:** Volume runs at roughly 2,803-3,655 transactions a month. The sharpest drop is 2024-06 (-23.3% month on month), after about 9% of accounts go quiet from June.

### 04. What share of transactions goes through each channel, by quarter?
- **Script:** `04_Channel_Mix_By_Quarter.sql`  ·  **Result:** `Query Results/04_Channel_Mix_By_Quarter.csv`
- **Approach:** CASE quarter, SUM() OVER (PARTITION BY)
- **Answer:** UPI is the largest channel every quarter at 45.6-46.5% of transactions; branch counters carry about 8%.

### 05. Which 10 customers brought in the most net money (credits minus debits) in 2024?
- **Script:** `05_Top10_Customers_By_Net_Inflow.sql`  ·  **Result:** `Query Results/05_Top10_Customers_By_Net_Inflow.csv`
- **Approach:** JOIN, conditional SUM, RANK
- **Answer:** All of the top 10 are MSME customers; the leader brought in a net ₹5.9 L.

### 06. Within each region, how do branches rank on transaction value?
- **Script:** `06_Branch_Rank_Within_Region.sql`  ·  **Result:** `Query Results/06_Branch_Rank_Within_Region.csv`
- **Approach:** RANK() OVER (PARTITION BY), share of region
- **Answer:** In the seven-branch South-East region, Puducherry Main leads with 19.7% of regional value and Karaikal trails at 10.5%. Single-branch regions rank 1 by definition.

### 07. Which open savings/current accounts had no transaction in the last 180 days of 2024?
- **Script:** `07_Dormant_Accounts.sql`  ·  **Result:** `Query Results/07_Dormant_Accounts.csv`
- **Approach:** LEFT JOIN, MAX date, julianday
- **Answer:** 222 open accounts are dormant: 8.7% of savings and 13.6% of current accounts, a re-activation list.

### 08. What share of customers in each segment took out more than they put in?
- **Script:** `08_Net_Outflow_Customers_By_Segment.sql`  ·  **Result:** `Query Results/08_Net_Outflow_Customers_By_Segment.csv`
- **Approach:** CTE, HAVING-style filter, AVG of flags
- **Answer:** Net outflow is the norm in this data (74.9-83.1% of customers) because ATM withdrawals are debits only; MSME customers have the largest average net outflow (₹2.3 L).

### 09. How often do accounts transact? Median-style view of the gap between transactions by account type.
- **Script:** `09_Days_Between_Transactions.sql`  ·  **Result:** `Query Results/09_Days_Between_Transactions.csv`
- **Approach:** LAG over dates, julianday, bucketing
- **Answer:** Current accounts transact every 8.2 days on average versus 22.2 for savings; 25.2% of savings gaps exceed 30 days.

### 10. For each opening year, how many accounts were opened and what share has since closed?
- **Script:** `10_Account_Opening_Cohorts.sql`  ·  **Result:** `Query Results/10_Account_Opening_Cohorts.csv`
- **Approach:** cohort by year, conditional aggregation
- **Answer:** Older cohorts show 5-8% closure (2018 is highest at 7.5%); recent cohorts look better mainly because they have had less time to close.

### 11. Which transactions are more than 5x the account's own average (possible review cases)?
- **Script:** `11_Unusually_Large_Transactions.sql`  ·  **Result:** `Query Results/11_Unusually_Large_Transactions.csv`
- **Approach:** AVG() OVER (PARTITION BY), ratio filter, ranking
- **Answer:** The query surfaces 25 review cases; the largest is 11.9x the account's own average (₹3.8 L on 2024-07-07).

### 12. How do the customer segments compare on activity, ticket size and digital adoption?
- **Script:** `12_Segment_KPI_Scorecard.sql`  ·  **Result:** `Query Results/12_Segment_KPI_Scorecard.csv`
- **Approach:** multi-table JOIN, KPI ratios
- **Answer:** MSME customers transact twice as often (27.8 per customer) with the biggest tickets (₹31,826); digital share is about 78% in every segment.

## Part B: Retail (scripts 13-25)

### 13. What are monthly net revenue, delivered orders and average order value?
- **Script:** `13_Monthly_Revenue_Orders_AOV.sql`  ·  **Result:** `Query Results/13_Monthly_Revenue_Orders_AOV.csv`
- **Approach:** JOIN, GROUP BY month, derived ratio
- **Answer:** Monthly revenue grows from ₹3.4 L (Jan 2023) to ₹8.4 L (Dec 2024) as the customer base builds up; average order value stays near ₹1,739.

### 14. Which categories earn the most revenue and gross margin?
- **Script:** `14_Category_Revenue_And_Margin.sql`  ·  **Result:** `Query Results/14_Category_Revenue_And_Margin.csv`
- **Approach:** JOIN, margin calculation, share of total
- **Answer:** Household and Personal Care lead revenue (18.2% and 17.0%); Snacks has the best margin at 26.1%.

### 15. What are the top 3 products by revenue in each category?
- **Script:** `15_Top3_Products_Per_Category.sql`  ·  **Result:** `Query Results/15_Top3_Products_Per_Category.csv`
- **Approach:** ROW_NUMBER() OVER (PARTITION BY ... ORDER BY)
- **Answer:** Returns the top 3 of each of the 8 categories (24 rows); `ROW_NUMBER` keeps exactly three even if revenue ties.

### 16. Which stores beat the company average on revenue per order and margin?
- **Script:** `16_Store_Performance_vs_Average.sql`  ·  **Result:** `Query Results/16_Store_Performance_vs_Average.csv`
- **Approach:** CTE, comparison with AVG() OVER ()
- **Answer:** Chennai Velachery has the highest revenue (₹42.3 L); Chennai Velachery, Bengaluru Whitefield, Chennai OMR, Trichy Cantonment beat the average revenue per order.

### 17. Of customers who first bought in each quarter, what share bought again in the following quarters?
- **Script:** `17_Customer_Cohort_Retention.sql`  ·  **Result:** `Query Results/17_Customer_Cohort_Retention.csv`
- **Approach:** cohort CTEs, quarter index arithmetic, pivot with conditional aggregation
- **Answer:** About 58% of a cohort buys again in the next quarter, falling to about 11% four quarters later; the curve is very similar across cohorts.

### 18. What share of customers order a second time, and how long do they take?
- **Script:** `18_Repeat_Purchase_And_Time_To_Second_Order.sql`  ·  **Result:** `Query Results/18_Repeat_Purchase_And_Time_To_Second_Order.csv`
- **Approach:** ROW_NUMBER, LAG, julianday
- **Answer:** 82.9% of buyers come back for a second order, after 59.7 days on average.

### 19. How do customers split into RFM segments (recency, frequency, monetary)?
- **Script:** `19_RFM_Segmentation.sql`  ·  **Result:** `Query Results/19_RFM_Segmentation.csv`
- **Approach:** NTILE(4), CTEs, CASE segment rules
- **Answer:** Champions (879 customers) bring 37.3% of revenue. The 'At risk' group (971 customers, 37.7% of revenue) used to buy often but has not bought for about 400 days: the first target for a win-back campaign.

### 20. Which stores have the highest return and cancellation rates?
- **Script:** `20_Returns_And_Cancellations_By_Store.sql`  ·  **Result:** `Query Results/20_Returns_And_Cancellations_By_Store.csv`
- **Approach:** conditional aggregation, ratio, ORDER BY
- **Answer:** Return rates sit in a narrow 4.22-5.76% band; Chennai Velachery has the highest combined return + cancellation rate.

### 21. How much margin do discounts cost, and do discounted lines sell more units?
- **Script:** `21_Discount_Impact_On_Margin.sql`  ·  **Result:** `Query Results/21_Discount_Impact_On_Margin.csv`
- **Approach:** GROUP BY discount level, margin math
- **Answer:** Margin falls from 27.8% at no discount to 15.2% at 15%, while units per line stay flat (2.5-2.51): in this data discounts give away margin without lifting volume.

### 22. What share of revenue comes from the top 10%, 20% and 50% of customers?
- **Script:** `22_Pareto_Revenue_Concentration.sql`  ·  **Result:** `Query Results/22_Pareto_Revenue_Concentration.csv`
- **Approach:** cumulative SUM() OVER, ROW_NUMBER, percentile cut-offs
- **Answer:** The top 20% of customers produce 48.5% of revenue (top 10%: 31.4%), close to the classic 80/20 shape but a little flatter.

### 23. Which pairs of categories most often appear in the same basket?
- **Script:** `23_Category_Pairs_Bought_Together.sql`  ·  **Result:** `Query Results/23_Category_Pairs_Bought_Together.csv`
- **Approach:** self-join on OrderID, de-duplicated pairs
- **Answer:** Dairy + Fresh Produce is the most common pair (24.1% of baskets); dairy appears in most top pairs, a candidate for cross-merchandising.

### 24. Do Gold and Silver loyalty members spend and visit more than non-members?
- **Script:** `24_Loyalty_Tier_Comparison.sql`  ·  **Result:** `Query Results/24_Loyalty_Tier_Comparison.csv`
- **Approach:** JOIN, per-customer CTE, averages by tier
- **Answer:** Gold members order 7.56 times on average against 2.35 for non-members and spend 3.2x as much, but their basket size (AOV) is the same: loyalty drives frequency, not basket value.

### 25. How did each store's revenue change from 2023 to 2024?
- **Script:** `25_Store_YoY_Growth_2023_vs_2024.sql`  ·  **Result:** `Query Results/25_Store_YoY_Growth_2023_vs_2024.csv`
- **Approach:** pivot with conditional SUM, growth %, NULLIF
- **Answer:** Every store grew; Bengaluru Whitefield grew fastest (36.9%) and Puducherry Beach Rd slowest (12.3%). Growth is inflated because the customer base was still building in 2023.

