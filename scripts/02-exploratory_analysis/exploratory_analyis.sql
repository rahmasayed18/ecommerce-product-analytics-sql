-- =============================================================================
-- File: 01_exploratory_analysis.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Provide key descriptive statistics and initial insights about the 
--          dataset to understand overall business performance before deep analysis.
-- =============================================================================

-- =============================================
-- 1. Overall Dataset Summary
-- =============================================
SELECT 
    COUNT(DISTINCT invoice_no) AS total_invoices,
    COUNT(DISTINCT stock_code) AS total_products,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT country) AS total_countries,
    MIN(invoice_date) AS first_transaction_date,
    MAX(invoice_date) AS last_transaction_date,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue,
    ROUND(AVG(unit_price * quantity), 2) AS avg_order_value
FROM online_retail_transaction.online_retail_cleaned;

-- =============================================
-- 2. Top 10 Countries by Revenue
-- =============================================
SELECT 
    country,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue,
    ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value
FROM online_retail_transaction.online_retail_cleaned
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 10;

-- =============================================
-- 3. Top 10 Products by Revenue
-- =============================================
SELECT 
    description AS product,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM online_retail_transaction.online_retail_cleaned
GROUP BY description
ORDER BY total_revenue DESC
LIMIT 10;

-- =============================================
-- 4. Monthly Revenue Trend (Basic Overview)
-- =============================================
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM online_retail_transaction.online_retail_cleaned
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY year_month;

-- =============================================
-- 5. Basic Customer Behavior
-- =============================================
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(AVG(quantity), 2) AS avg_items_per_line,
    ROUND(AVG(unit_price), 2) AS avg_unit_price,
    ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT customer_id), 2) AS avg_revenue_per_customer
FROM online_retail_transaction.online_retail_cleaned;
