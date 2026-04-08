-- =============================================================================
-- File: 01_pareto_analysis.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Analyze product revenue concentration using Pareto principle 
--          (80/20 rule) to show how much revenue comes from top products vs long tail.
-- =============================================================================

-- Product Pareto Analysis - Revenue Concentration (Head vs Long Tail)
-- Business insight: Shows that ~80% of revenue comes from ~50% of products.
--                   Helps identify "hero" products vs low-contribution items.

WITH sales_data AS (
    SELECT 
        description AS product,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description
),
grand_total AS (
    SELECT SUM(total_sales) AS grand_total_sales 
    FROM sales_data
)
SELECT 
    product,
    total_sales,
    ROUND(total_sales * 100.0 / (SELECT grand_total_sales FROM grand_total), 2) AS sales_percentage,
    ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 / 
          (SELECT grand_total_sales FROM grand_total), 2) AS cumulative_percentage
FROM sales_data
ORDER BY total_sales DESC
LIMIT 20;   -- Show top 20 products for readability
