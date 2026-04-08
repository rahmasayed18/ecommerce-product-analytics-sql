-- =============================================================================
-- File: 03_product_time_consistency.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Analyze how consistent products are in contributing to the top 80% 
--          of monthly revenue (product stability over time).
-- =============================================================================

-- Product Time Consistency Analysis
-- Business value: Identifies "reliable" top products vs one-time spikes.
--                  Helps with inventory planning and product strategy.

WITH monthly_sales AS (
    SELECT 
        description AS product,
        DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description, DATE_FORMAT(invoice_date, '%Y-%m')
),
monthly_ranked AS (
    SELECT 
        product,
        invoice_month,
        total_sales,
        ROUND(total_sales * 100.0 / SUM(total_sales) OVER (PARTITION BY invoice_month), 2) AS sales_percentage,
        ROUND(SUM(total_sales) OVER (PARTITION BY invoice_month ORDER BY total_sales DESC) * 100.0 
              / SUM(total_sales) OVER (PARTITION BY invoice_month), 2) AS cumulative_percentage
    FROM monthly_sales
),
top_80_products_per_month AS (
    SELECT 
        product,
        invoice_month
    FROM monthly_ranked
    WHERE cumulative_percentage <= 80
)
SELECT 
    product,
    COUNT(DISTINCT invoice_month) AS months_in_top_80,
    MIN(invoice_month) AS first_appearance,
    MAX(invoice_month) AS last_appearance,
    CASE 
        WHEN COUNT(DISTINCT invoice_month) >= 10 THEN 'Consistent Top Seller'
        WHEN COUNT(DISTINCT invoice_month) BETWEEN 4 AND 9 THEN 'Moderate Performer'
        ELSE 'One-time or Rare Performer'
    END AS performance_tier
FROM top_80_products_per_month
GROUP BY product
ORDER BY months_in_top_80 DESC;
