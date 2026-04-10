/* =============================================================================
   File: 01_sales_by_date.sql
   Purpose: Monthly time-series analysis showing revenue trends, order volume, 
            and AOV to identify seasonality and volume-driven growth.
   Author: Rahma Sayed
   Date: 2026-04-02
   Business goal: Highlight holiday peaks (Nov–Jan) and demonstrate that revenue 
            growth is primarily driven by order volume rather than price changes.
   Notes: This is the main query used for the monthly revenue chart in the README.
   ============================================================================= */

-- Monthly Revenue Trend with Seasonality and Volume vs Value Analysis
-- This query powers the key insight: growth is volume-driven, not value-driven
SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(quantity) AS total_units_sold,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue,
    ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value,
    ROUND(SUM(unit_price * quantity) / NULLIF(SUM(quantity), 0), 2) AS avg_selling_price_per_unit
FROM online_retail_transaction.online_retail_cleaned
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY year_month;
