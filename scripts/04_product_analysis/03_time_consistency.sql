/*=================================================================
Product Consistency Over Time
Question: Are the products contributing to the top 80% of revenue consistent over time?
=================================================================*/

--  A view that ranks monthly product sales and calculates cumulative revenue percentage
DROP VIEW IF EXISTS online_retail_transaction.vw_ranked_monthly_sales;

CREATE VIEW online_retail_transaction.vw_ranked_monthly_sales AS
WITH sales_data AS (
    SELECT
        description AS product,
        DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description, DATE_FORMAT(invoice_date, '%Y-%m')
),

grand_total AS (
    SELECT
        invoice_month,
        SUM(total_sales) AS grand_total_sales
    FROM sales_data
    GROUP BY invoice_month
),

ranked_sales AS (
    SELECT 
        sd.product,
        sd.invoice_month,
        sd.total_quantity,
        sd.total_sales,
        ROUND(sd.total_sales * 100.0 / gt.grand_total_sales, 2) AS sales_percentage,
        ROUND(SUM(sd.total_sales) OVER (PARTITION BY sd.invoice_month ORDER BY sd.total_sales DESC), 2) AS cumulative_sales,
        ROUND(SUM(sd.total_sales) OVER (PARTITION BY sd.invoice_month ORDER BY sd.total_sales DESC) * 100.0 / gt.grand_total_sales, 2) AS cumulative_percentage  
    FROM sales_data sd
    JOIN grand_total gt 
        ON sd.invoice_month = gt.invoice_month
)

SELECT *
FROM ranked_sales
WHERE cumulative_percentage <= 80
ORDER BY invoice_month, total_sales DESC;

--  product performance over time
SELECT
    product,
    COUNT(DISTINCT invoice_month) AS months_in_top_80,
    MIN(invoice_month) AS first_appearance,
    MAX(invoice_month) AS last_appearance,
    CASE
        WHEN COUNT(DISTINCT invoice_month) >= 10 THEN 'Consistent Top Seller'
        WHEN COUNT(DISTINCT invoice_month) BETWEEN 4 AND 9 THEN 'Moderate Performer'
        ELSE 'One-time Spike'
    END AS performance_tier
FROM online_retail_transaction.vw_ranked_monthly_sales
GROUP BY product
ORDER BY months_in_top_80 DESC;
