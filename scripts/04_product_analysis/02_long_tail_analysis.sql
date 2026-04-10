-- =============================================================================
-- File: 02_long_tail_analysis.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Analyze the long tail products (bottom ~20% of revenue) to understand 
--          their contribution, frequency, and potential risks or opportunities.
-- =============================================================================

-- Long Tail Product Analysis (Products contributing to the bottom ~20% of revenue)
-- Business value: Helps decide whether to keep, bundle, or discontinue low-performing products.

WITH sales_data AS (
    SELECT 
        description AS product,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales,
        COUNT(DISTINCT invoice_no) AS total_orders,
        COUNT(DISTINCT DATE_FORMAT(invoice_date, '%Y-%m')) AS active_months
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description
),
grand_total AS (
    SELECT SUM(total_sales) AS grand_total_sales 
    FROM sales_data
),
ranked_products AS (
    SELECT 
        product,
        total_sales,
        total_orders,
        active_months,
        ROUND(total_sales * 100.0 / (SELECT grand_total_sales FROM grand_total), 2) AS sales_percentage,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 / 
              (SELECT grand_total_sales FROM grand_total), 2) AS cumulative_percentage
    FROM sales_data
)
-- Select only the long tail products (cumulative > 80%)
SELECT 
    product,
    total_sales,
    total_orders,
    active_months,
    sales_percentage,
    cumulative_percentage,
    CASE 
        WHEN active_months = 1 THEN 'One-time bulk purchase'
        WHEN active_months BETWEEN 2 AND 3 THEN 'Low frequency'
        WHEN active_months >= 6 THEN 'Consistent low performer'
        ELSE 'Moderate frequency'
    END AS tail_segment
FROM ranked_products
WHERE cumulative_percentage > 80
ORDER BY total_sales DESC;
