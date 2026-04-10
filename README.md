# Project Background  
This project analyzes the Online Retail dataset with a focus on **monthly revenue growth** and identifying the key drivers behind sales fluctuations. The dataset covers all of 2011, with transactions across 37 countries. The main objective is to understand revenue trends, country performance, product dynamics, and purchasing behavior to inform business decisions and growth strategies.  

The analysis followed a structured process: cleaning and preparing the dataset, building a technical understanding of its structure, analyzing monthly growth patterns, and presenting insights in a business-oriented format.  

---

# Data Structure & Initial Checks  
- The dataset is organized at the transaction level, including **InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, and Country**.  
- Initial cleaning involved handling missing values, canceled orders, and duplicate entries.  
- After preparation, data were aggregated into **monthly revenue, order volume, and customer activity** to enable growth and trend analysis.  
- Exploratory checks confirmed that the data spans **2011**, with transactions distributed across **37 countries**.  

---

# Executive Summary  
The company’s performance is mainly driven by its **top six countries**, which dominate overall results. Smaller markets contribute minimal growth and show flat patterns, making them less relevant for near-term performance.  

From a product perspective, there is no single breakout product. Instead, about **80% of revenue comes from nearly 50% of the product portfolio**, reflecting broad adoption but no clear hero items. Interestingly, some high-performing products are sold only once, which raises concerns about missed opportunities for repeat purchases.  

The **UK is the dominant market**, generating roughly **£4.5M out of £8.5M total revenue**. While the UK is crucial, the remaining ~£4M is spread across **36 other countries**, which, though smaller individually, collectively provide stable contributions.  

The UK’s **Average Order Value (AOV)** remains very stable, meaning revenue fluctuations are almost entirely due to **changes in order volume**, not pricing. This makes driving more orders the key to UK growth.  

Finally, there is clear **seasonality**, with strong peaks in **November, December, and January**, highlighting the impact of holiday-driven demand.  




<img width="1479" height="834" alt="Screenshot 2025-12-30 194707" src="https://github.com/user-attachments/assets/036f170a-2c45-4e3c-b3c8-177867fa987c" />




---

# Insights Deep Dive  

## Revenue & Order Trends  
- December revenue reached ~**£700K from 2,178 orders**, the highest point of the year.  
- Between **February and July**, sales were stable, fluctuating between **£400K and £600K**.  
- From **August onward**, revenue began to rise gradually, eventually crossing **£1M by December**.  
- Revenue patterns confirm that growth is **volume-driven, not value-driven**, since AOV stayed consistent throughout.  


<img width="1354" height="406" alt="Screenshot 2025-10-12 211853" src="https://github.com/user-attachments/assets/461f8cce-a385-438f-9ec9-31a2d64ece64" />


---

## Country Performance  
- The **UK dominates with ~£4.5M**, accounting for more than half of total sales.  
- Despite this, the remaining ~**£4M comes from 36 other countries**, each small on its own but together forming a **stable backbone of the business**.  
- This dual structure (one dominant market + many stable minor contributors) shows both **strength and risk**: heavy reliance on the UK, but also hidden resilience from broad geographic spread.  

<img width="1494" height="343" alt="Screenshot 2025-10-12 210220" src="https://github.com/user-attachments/assets/acdebbfb-ffd3-408f-b589-d9182c91ea34" />


---

## Customer Purchasing Behavior  
- **80% of revenue** is spread across ~**50% of the product catalog**, meaning there’s no single “hero product.”  
- The highest purchased product was **Paper Craft Little Birdie**, which generated ~**£170K in December alone**, but was sold only once. This suggests issues like **one-off bulk purchases or missed retention opportunities.**
- **AOV remained stable** across time and markets, showing consistent customer spending patterns. Growth opportunities, therefore lie in **increasing purchase frequency rather than pricing adjustments**.  




---

# Recommendations  
1. **Prioritize the top six countries.** These drive the majority of sales and should be the focus for tailored campaigns and strategies.  
2. **Boost UK order volume.** Since AOV is stable, growth depends on increasing the number of transactions. Tactics like loyalty programs, targeted promotions, or bundling could help.  
3. **Investigate one-time product sales.** Products like *Paper Craft Little Birdie*, which generate huge revenue but are only sold once, represent missed opportunities. **Ensuring availability, promoting repeat buys, and addressing supply issues could unlock more growth.**
4. **Leverage seasonality.** Strengthen promotional activity in November–January to capitalize on natural demand spikes during the holiday season.
5. **Balance dependence on the UK.** While the UK is the main driver, diversifying growth across other stable countries can reduce vulnerability and ensure longer-term resilience.  

---

## Technical Implementation

Short technical tour for data analysts and hiring managers.

### How to Run and Reproduce

- Place the raw file in `data/raw/online_retail_raw.xlsx`.
- Load the data into MySQL schema `online_retail_transaction`.
- Run [`scripts/01_data_preparation/02_create_master_table.sql`](scripts/01_data_preparation/02_create_master_table.sql) to build the cleaned fact table `online_retail_cleaned`.
- Execute scripts in numbered order (`02_exploratory_analysis/` → `06_reporting/`).
- Requires MySQL with support for **CTEs** and **window functions**.

### SQL Scripts Layout

| Folder | Purpose |
| --- | --- |
| `01_data_preparation/` | Data cleaning and creation of unified `online_retail_cleaned` table |
| `02_exploratory_analysis/` | Core KPIs, RFM, basket analysis |
| `03_time_series_analysis/` | Seasonality, monthly trends, cohort views |
| `04_product_analysis/` | Pareto analysis, long tail, consistency checks |
| `05_customer_analysis/` | Segmentation and retention (churn & activity tiers) |
| `06_reporting/` | Summary reports |

### Representative SQL Snippets

**1. Master Table Creation**  
Builds a clean, analysis-ready fact table from raw feeds.  
Full script: [`scripts/01_data_preparation/02_create_master_table.sql`](scripts/01_data_preparation/02_create_master_table.sql)

```sql
SELECT 
    InvoiceNo AS invoice_no,
    StockCode AS stock_code,
    STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i') AS invoice_date,
    Quantity AS quantity,
    UnitPrice AS unit_price,
    CustomerID AS customer_id,
    LOWER(TRIM(Country)) AS country
FROM online_retail_transaction.online_retail_aa
WHERE Quantity > 0 
  AND UnitPrice > 0 
  AND CustomerID != 0;
```

**2. Monthly Revenue & Seasonality**  
Calculates orders, revenue, and AOV by month.  
Full script: [`scripts/03_time_series_analysis/01_sales_by_date.sql`](scripts/03_time_series_analysis/01_sales_by_date.sql)

```sql
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT invoice_no) AS orders,
    ROUND(SUM(unit_price * quantity), 2) AS revenue,
    ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT invoice_no), 2) AS aov
FROM online_retail_transaction.online_retail_cleaned
GROUP BY 1 
ORDER BY 1;
```

**3. Product Pareto Analysis**  
Shows revenue concentration (head vs long tail).  
Full script: [`scripts/04_product_analysis/01_pareto_analysis.sql`](scripts/04_product_analysis/01_pareto_analysis.sql)

```sql
WITH p AS (
    SELECT description AS product, 
           ROUND(SUM(unit_price * quantity), 2) AS sales
    FROM online_retail_transaction.online_retail_cleaned 
    GROUP BY description
),
t AS (SELECT SUM(sales) AS tot FROM p)
SELECT product, sales,
       ROUND(SUM(sales) OVER (ORDER BY sales DESC) * 100.0 / (SELECT tot FROM t), 2) AS cum_pct
FROM p 
ORDER BY sales DESC 
LIMIT 15;
```

**4. Customer Activity Tiers**  
Assigns new / engaged / loyal tiers based on active months.  
Full script: [`scripts/05_customer_analysis/retention/01_churn_activity_tiers.sql`](scripts/05_customer_analysis/retention/01_churn_activity_tiers.sql)

```sql
WITH m AS (
    SELECT customer_id, DATE_FORMAT(invoice_date, '%Y-%m') AS ym
    FROM online_retail_transaction.online_retail_cleaned
),
s AS (
    SELECT customer_id, COUNT(DISTINCT ym) AS mo 
    FROM m GROUP BY customer_id
)
SELECT customer_id,
       CASE 
           WHEN mo <= 2 THEN 'new'
           WHEN mo <= 5 THEN 'engaged' 
           ELSE 'loyal' 
       END AS tier
FROM s;
```

---
