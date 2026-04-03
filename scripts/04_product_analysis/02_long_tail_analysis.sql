/*===============================================================================
  Long Tail Product Analysis | E-Commerce Dataset

  Goal: Investigate the tail-end product performance beyond Pareto 80/20,
          segmenting low performers based on frequency and stability to support
          stock prioritization and product strategy decisions.
================================================================================*/

/*-----------------------------------------------------------------------------
  Question 1: Do 20% of products generate 80% of total sales?
-----------------------------------------------------------------------------*/

WITH total_products_number AS (
    SELECT COUNT(DISTINCT description) AS total_products
    FROM online_retail_transaction.online_retail_cleaned
),
total_80_percent_number AS (
    SELECT COUNT(DISTINCT product) AS total_80_percent_product_number
    FROM online_retail_transaction.vw_pareto_analysis
)

SELECT
    t80.total_80_percent_product_number,
    tp.total_products,
    CONCAT(ROUND(t80.total_80_percent_product_number * 100.0 / tp.total_products, 2), ' %') AS product_percent
FROM total_80_percent_number t80
JOIN total_products_number tp ON 1 = 1;

/*--------------------------------------------------------------------------------
  Question 2: Long Tail Analysis — Products in the bottom 20% of revenue
--------------------------------------------------------------------------------*/

DROP VIEW IF EXISTS online_retail_transaction.vw_tail_products;
CREATE VIEW online_retail_transaction.vw_tail_products AS
WITH sales_data AS (
    SELECT
        description AS product,
        COUNT(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales,
        DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description, DATE_FORMAT(invoice_date, '%Y-%m')
),
grand_total AS (
    SELECT SUM(total_sales) AS grand_total_sales FROM sales_data
),
ranked_sales AS (
    SELECT 
        product,
        total_quantity,
        total_sales,
        invoice_month,
        CONCAT(ROUND(total_sales * 100.0 / (SELECT grand_total_sales FROM grand_total), 2), ' %') AS sales_percentage,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC), 2) AS cumulative_sales,
        CONCAT(ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 / 
        (SELECT grand_total_sales FROM grand_total), 2), ' %') AS cumulative_percentage  
    FROM sales_data
)

SELECT *
FROM ranked_sales
WHERE CAST(REPLACE(cumulative_percentage, ' %', '') AS DECIMAL) BETWEEN 80 AND 100
ORDER BY total_sales DESC;

--checking the count of the tail products

WITH total_products_number AS (
    SELECT COUNT(DISTINCT description) AS total_products
    FROM online_retail_transaction.online_retail_cleaned
),
tail_products_number AS (
    SELECT COUNT(DISTINCT product) AS tail_count
    FROM tail_products
)

SELECT
    t.tail_count,
    tp.total_products,
    CONCAT(ROUND(t.tail_count * 100.0 / tp.total_products, 2), ' %') AS tail_percent
FROM 
    tail_products_number t
JOIN 
    total_products_number tp ON 1=1;

/*--------------------------------------------------------------------------------
-- Sub-Segmenting Long Tail Products: Frequency and Stability Patterns
--------------------------------------------------------------------------------*/

-- Identify “risky” top earners: Sold big but in only 1–2 months
WITH risky_top_earner_products AS (
    SELECT 
        product,
        COUNT(DISTINCT invoice_month) AS active_months,
        SUM(total_quantity) AS total_units_sold,
        ROUND(SUM(total_sales), 2) AS total_revenue,
        CASE
            WHEN SUM(total_sales) >= 500 AND COUNT(DISTINCT invoice_month) <= 2 THEN 'risky_product'
            ELSE 'stable_product'
        END AS product_stability
    FROM online_retail_transaction.vw_tail_products
    GROUP BY product
)
SELECT *
FROM risky_top_earner_products
WHERE product_stability = 'risky_product'
ORDER BY total_revenue DESC;

-- Identify “reliable low-volume performers”: Sold consistently across 6–12 months
WITH reliable_best_sellers AS (
    SELECT 
        product,
        COUNT(DISTINCT invoice_month) AS active_months,
        SUM(total_quantity) AS total_units_sold,
        ROUND(SUM(total_sales), 2) AS total_revenue,
        CASE
            WHEN SUM(total_sales) >= 500 AND COUNT(DISTINCT invoice_month) BETWEEN 6 AND 12 THEN 'reliable_best_seller'
            ELSE 'low_volume_product'
        END AS product_stability
    FROM online_retail_transaction.vw_tail_products
    GROUP BY product
)
SELECT *
FROM reliable_best_sellers
WHERE product_stability = 'reliable_best_seller'
ORDER BY total_revenue DESC;

-- Identify “consistent underperformers”: Low revenue but sold for 6+ months
WITH consistent_low_revenue_products AS (
    SELECT 
        product,
        COUNT(DISTINCT invoice_month) AS active_months,
        SUM(total_quantity) AS total_units_sold,
        ROUND(SUM(total_sales), 2) AS total_revenue,
        CASE
            WHEN SUM(total_sales) <= 500 AND COUNT(DISTINCT invoice_month) BETWEEN 6 AND 12 THEN 'consistent_low_revenue'
            ELSE '------------'
        END AS product_stability
    FROM online_retail_transaction.vw_tail_products
    GROUP BY product
)
SELECT *
FROM consistent_low_revenue_products
WHERE product_stability = 'consistent_low_revenue'
ORDER BY total_revenue DESC;


-- This query analyzes the price stability of tail products by calculating


WITH price_analysis AS (
    SELECT
        description AS product,
        ROUND(AVG(unit_price), 2) AS avg_price,
        ROUND(STD(unit_price), 2) AS price_std_dev,
        ROUND(STD(unit_price) / AVG(unit_price), 2) AS relative_std_dev,
        CASE 
            WHEN ROUND(STD(unit_price) / AVG(unit_price), 2) < 0.1 THEN 'Stable Price'
            WHEN ROUND(STD(unit_price) / AVG(unit_price), 2) BETWEEN 0.1 AND 0.3 THEN 'Moderately Stable Price'
            ELSE 'Volatile Price'
        END AS price_stability
    FROM online_retail__transaction.online_retail_cleaned
    WHERE description IN (
        SELECT DISTINCT product
        FROM online_retail__transaction.vw_tail_products
    )
    GROUP BY description
)

SELECT 
    price_stability,
    COUNT(DISTINCT product) AS total_products
FROM price_analysis
GROUP BY price_stability
ORDER BY total_products DESC;


