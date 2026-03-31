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

- Put the dataset files in **`datasets/`**, then import them into MySQL under schema **`online_retail_transaction`** (raw tables like `online_retail_aa`, `online_retail_ab`, `online_retail_ba`, `online_retail_bb`).  
- Build the analysis-ready fact table by running [`scripts/02_create_cleaned_master_table.sql`](scripts/02_create_cleaned_master_table.sql) to create **`online_retail_cleaned`**.  
- Run analysis scripts from **`scripts/`** by topic (time trends, product performance, segmentation, retention, reports).  
- Assumes a MySQL version that supports **CTEs** and **window functions**.

### SQL scripts layout

- **`scripts/01_…` + `scripts/02_…`** — Data cleaning + creation of **`online_retail_cleaned`** (single source of truth).  
- **`scripts/Exploratory_descriptive_analysis/`** — Baseline KPIs (sales, customers, products, RFM, basket patterns).  
- **`scripts/Time_based_trend_analysis/`** — Seasonality, monthly trends, and cohort-style views.  
- **`scripts/product_performance/`**, **`scripts/Customer_*`**, **`scripts/Reports/`** — Pareto/long-tail deep dives, segmentation & retention, and reporting outputs.

### Representative SQL snippets

**Cleaned master table creation (data quality + derived time fields)**  
Builds a single, analysis-ready fact table by parsing timestamps, standardizing text, and filtering invalid rows. Full script: [`scripts/02_create_cleaned_master_table.sql`](scripts/02_create_cleaned_master_table.sql).

```sql
-- One branch (AA). The full script UNION ALLs AA/AB/BA/BB into online_retail_cleaned.
SELECT
    InvoiceNo AS invoice_no,
    StockCode AS stock_code,
    LOWER(TRIM(Description)) AS description,
    Quantity AS quantity,
    STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i') AS invoice_date,
    MONTH(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_month,
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
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;
```

**Monthly revenue trend with seasonality (revenue + orders + AOV)**  
Summarizes performance by month to expose seasonality and separate **volume** effects (orders/units) from value effects (AOV). Full script: [`scripts/Time_based_trend_analysis/01_sales_by_date.sql`](scripts/Time_based_trend_analysis/01_sales_by_date.sql).

```sql
-- Monthly rollup (seasonality + volume vs value signals)
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT invoice_no) AS orders,
    SUM(quantity) AS units,
    ROUND(SUM(unit_price * quantity), 2) AS revenue,
    ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT invoice_no), 2) AS aov,
    ROUND(SUM(unit_price * quantity) / NULLIF(SUM(quantity), 0), 2) AS avg_selling_price,
    ROUND(AVG(unit_price), 2) AS avg_unit_price,
    ROUND(AVG(quantity), 2) AS avg_units_per_line
FROM online_retail_transaction.online_retail_cleaned
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY year_month;
```

**Product Pareto analysis (concentration + long tail cut)**  
Uses window functions to compute cumulative revenue share by product, quantifying how much of revenue sits in the “head” vs the long tail. Full script: [`scripts/product_performance/01_pareto_analysis.sql`](scripts/product_performance/01_pareto_analysis.sql).

```sql
WITH sales_data AS (
    SELECT
        description AS product,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description
),
totals AS (
    SELECT SUM(total_sales) AS grand_total_sales FROM sales_data
),
ranked AS (
    SELECT
        product,
        total_sales,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC), 2) AS running_sales,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 /
              (SELECT grand_total_sales FROM totals), 2) AS cumulative_pct
    FROM sales_data
)
SELECT product, total_sales, cumulative_pct
FROM ranked
ORDER BY total_sales DESC
LIMIT 15;
```

**Advanced: customer activity tiers (CTEs + window function)**  
Creates a customer-month activity timeline and assigns tiers (new/engaged/loyal) based on distinct active months. Full script: [`scripts/Customer_retention/01_churn_and_actitivity_tiers.sql`](scripts/Customer_retention/01_churn_and_actitivity_tiers.sql).

```sql
WITH months_of_activity AS (
    SELECT
        customer_id,
        DATE_FORMAT(invoice_date, '%Y-%m') AS activity_month,
        DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY invoice_date) AS month_rank
    FROM online_retail_transaction.online_retail_cleaned
),
activity_tiers AS (
    SELECT customer_id, COUNT(DISTINCT activity_month) AS active_months
    FROM months_of_activity
    GROUP BY customer_id
)
SELECT customer_id,
       CASE WHEN active_months BETWEEN 1 AND 2 THEN 'new'
            WHEN active_months BETWEEN 3 AND 5 THEN 'engaged'
            ELSE 'loyal' END AS activity_tier
FROM activity_tiers;
```

### Visualizations

The charts embedded above (monthly revenue trend/seasonality and country concentration) were produced from the same `online_retail_cleaned` fact table and are directly reproducible using the time-trend and country/product scripts in `scripts/`.

---
