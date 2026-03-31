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

This section is aimed at data and analytics hiring managers who want to see how the work was produced and how to reproduce it.

### How to run and reproduce

Place the Online Retail source files in the **`datasets/`** folder, then load them into a MySQL database (the scripts use schema **`online_retail_transaction`** and raw tables such as `online_retail_aa`, `online_retail_ab`, `online_retail_ba`, `online_retail_bb`, depending on how the extract is split). Run **`scripts/02_create_cleaned_master_table.sql`** to build the unified table **`online_retail_cleaned`** (after aligning table names and imports with your environment). Use **`scripts/01_data_cleaning_and_transformation.sql`** for the same cleansing logic in a “query-only” workflow and for the listed data-quality checks. After the cleaned table exists, run the analysis scripts in **`scripts/`** by theme (exploratory, time trends, product performance, segmentation, retention, reports) as needed. A recent MySQL version with window-function support is assumed.

### SQL scripts layout

- **`scripts/01_…` and `scripts/02_…`** — Cleanse raw rows (valid quantity, price, customer, time rules; normalized text; country aliases) and union sources into **`online_retail_cleaned`** with parsed dates and calendar parts.  
- **`scripts/Exploratory_descriptive_analysis/`** — Core aggregates for customers, sales, products, RFM-style fields, and basket-style exploration.  
- **`scripts/Time_based_trend_analysis/`** — Calendar aggregations and cohort-style views by first purchase month.  
- **`scripts/product_performance/`** (including **`deeper_investigation/`**) — Pareto / long-tail views, consistency, and root-cause style drills.  
- **`scripts/Customer_segmentation/`**, **`scripts/Customer_retention/`**, **`scripts/Reports/`** — Segments, retention/churn, and summary report queries.

### Representative SQL patterns

**1. Unified cleaned table (normalize, derive dates, filter bad rows)**  
Combines sources with consistent column names, parses **`InvoiceDate`**, standardizes a few country labels, and keeps only rows suitable for revenue analysis. Full pipeline: [`scripts/02_create_cleaned_master_table.sql`](scripts/02_create_cleaned_master_table.sql).

```sql
-- One branch of the master table: parse dates, normalize country, enforce row quality
SELECT
    InvoiceNo AS invoice_no,
    StockCode AS stock_code,
    LOWER(TRIM(Description)) AS description,
    Quantity AS quantity,
    STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i') AS invoice_date,
    YEAR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_year,
    UnitPrice AS unit_price,
    CustomerID AS customer_id,
    CASE
        WHEN LOWER(TRIM(Country)) = 'usa' THEN 'united states'
        WHEN LOWER(TRIM(Country)) = 'rsa' THEN 'south africa'
        ELSE LOWER(TRIM(Country))
    END AS country
FROM online_retail_transaction.online_retail_aa
WHERE Quantity > 0
  AND UnitPrice > 0
  AND CustomerId != 0
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24
-- Additional sources are UNION ALL’d in the same script to form online_retail_cleaned.
```

**2. Pareto-style concentration (running share of revenue)**  
Aggregates revenue by product, then uses windowed sums to compute cumulative percentage of total sales—supporting the “how much of revenue sits in the head vs. tail” narrative. Full definition: [`scripts/product_performance/01_pareto_analysis.sql`](scripts/product_performance/01_pareto_analysis.sql).

```sql
WITH sales_data AS (
    SELECT
        description AS product,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description
),
grand_total AS (
    SELECT SUM(total_sales) AS grand_total_sales FROM sales_data
),
ranked_sales AS (
    SELECT
        product,
        total_sales,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 /
              (SELECT grand_total_sales FROM grand_total), 2) AS cumulative_pct
    FROM sales_data
)
SELECT * FROM ranked_sales WHERE cumulative_pct > 80;  -- tail beyond ~80% cumulative revenue
```

**3. Monthly seasonality (volume and revenue by calendar month)**  
Rolls the cleaned fact table to month to expose growth and seasonal peaks (e.g. holiday months) in line with the charts above. Full file: [`scripts/Time_based_trend_analysis/01_sales_by_date.sql`](scripts/Time_based_trend_analysis/01_sales_by_date.sql).

```sql
-- Revenue and order counts by month (2011 in this dataset)
SELECT
    MONTH(invoice_date) AS invoice_month,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS average_unit_price
FROM online_retail_transaction.online_retail_cleaned
GROUP BY MONTH(invoice_date)
ORDER BY invoice_month;
```

**4. Cohort framing (first purchase month per customer)**  
Defines each customer’s cohort from their first invoice month and rolls spend and activity—useful for retention and lifecycle context alongside product and country views. Full query: [`scripts/Time_based_trend_analysis/02_Cohort_analysis.sql`](scripts/Time_based_trend_analysis/02_Cohort_analysis.sql).

```sql
-- Per customer: first purchase month, activity span, spend
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(invoice_date), '%Y-%m') AS cohort_month,
        TIMESTAMPDIFF(MONTH, MIN(DATE(invoice_date)), MAX(DATE(invoice_date))) AS months_of_activity,
        COUNT(DISTINCT invoice_no) AS total_invoices,
        ROUND(SUM(unit_price * quantity), 2) AS total_spent
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id
)
SELECT cohort_month,
       COUNT(DISTINCT customer_id) AS customers,
       ROUND(SUM(total_spent), 2) AS cohort_revenue
FROM first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;
```

---
