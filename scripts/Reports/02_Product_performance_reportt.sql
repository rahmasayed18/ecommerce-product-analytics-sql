-- =============================================================================
-- File: 02_product_performance_report.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Create a product-level performance summary with key metrics 
--          (sales, quantity, recency, returns) to support inventory and 
--          product strategy decisions.
-- =============================================================================

-- Product Performance Report
-- Business value: Helps identify high-performing products, slow movers, 
--                 at-risk products, and return issues.

DROP TABLE IF EXISTS online_retail_transaction.product_performance_report;

CREATE TABLE online_retail_transaction.product_performance_report AS
SELECT
    stock_code,
    description AS product,
    country,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS avg_unit_price,
    ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value,
    DATE_FORMAT(MAX(invoice_date), '%Y-%m') AS last_sale_month,
    TIMESTAMPDIFF(MONTH, MAX(invoice_date), NOW()) AS recency_months,
    ROUND(
        (SUM(CASE WHEN quantity < 0 THEN ABS(quantity) ELSE 0 END) /
         NULLIF(SUM(CASE WHEN quantity > 0 THEN quantity ELSE 0 END), 0)) * 100, 2
    ) AS return_rate_percent,
    CASE 
        WHEN SUM(unit_price * quantity) >= 1000 THEN 'High Value Product'
        WHEN SUM(unit_price * quantity) >= 500 THEN 'Medium Value Product'
        ELSE 'Low Value Product'
    END AS value_category,
    CASE 
        WHEN TIMESTAMPDIFF(MONTH, MAX(invoice_date), NOW()) > 6 THEN 'At Risk'
        ELSE 'Active'
    END AS status
FROM online_retail_transaction.online_retail_cleaned
GROUP BY stock_code, description, country
ORDER BY total_sales DESC;
