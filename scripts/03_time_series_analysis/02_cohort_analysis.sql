-- =============================================================================
-- File: 02_cohort_analysis.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Calculate customer cohort analysis based on first purchase month 
--          to understand retention and customer lifetime value patterns.
-- =============================================================================

-- Cohort Analysis: Customers grouped by their first purchase month
-- Business value: Shows how many customers were acquired each month and their 
--                 overall activity (invoices, quantity, spending). 
--                 Useful for understanding acquisition quality and retention.

WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(invoice_date), '%Y-%m') AS cohort_month,
        COUNT(DISTINCT invoice_no) AS total_invoices,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_spent
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id
)
SELECT 
    cohort_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(total_invoices) AS total_invoices,
    SUM(total_quantity) AS total_units_sold,
    ROUND(SUM(total_spent), 2) AS total_revenue
FROM first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;
