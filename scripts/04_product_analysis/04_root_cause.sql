-- =============================================================================
-- File: 04_product_root_cause_analysis.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Investigate potential root causes for product performance — 
--          seasonality patterns and price stability for top products.
-- =============================================================================

-- Root Cause Analysis for Top Products
-- 1. Seasonality: Do top products sell more in specific months?
-- 2. Price Stability: Do top products have more stable pricing?

-- Part 1: Seasonality of Top Products (Products in top 80% revenue)
WITH top_products AS (
    SELECT DISTINCT product 
    FROM online_retail_transaction.vw_pareto_analysis   -- or use your ranked sales logic
),
monthly_sales AS (
    SELECT 
        p.product,
        DATE_FORMAT(c.invoice_date, '%Y-%m') AS invoice_month,
        ROUND(SUM(c.unit_price * c.quantity), 2) AS monthly_sales
    FROM online_retail_transaction.online_retail_cleaned c
    JOIN top_products p ON c.description = p.product
    GROUP BY p.product, DATE_FORMAT(c.invoice_date, '%Y-%m')
)
SELECT 
    product,
    invoice_month,
    monthly_sales,
    ROUND(monthly_sales * 100.0 / SUM(monthly_sales) OVER (PARTITION BY product), 2) AS percent_of_product_total
FROM monthly_sales
ORDER BY product, invoice_month;
