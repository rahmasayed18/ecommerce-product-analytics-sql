
-- =============================================================================
-- File: 02_customer_value_segmentation.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Segment customers by spending value (High Value vs Low Value) and 
--          analyze their contribution by country to support retention and 
--          targeting strategies.
-- =============================================================================

WITH customer_spending AS (
    -- Calculate key metrics per customer
    SELECT
        customer_id,
        country,
        COUNT(DISTINCT invoice_no) AS total_invoices,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_spent,
        ROUND(SUM(unit_price * quantity) / COUNT(DISTINCT invoice_no), 2) AS avg_order_value
    FROM online_retail_transaction.online_retail_cleaned
    WHERE invoice_no NOT LIKE 'C%'
    GROUP BY customer_id, country
),

customer_value AS (
    -- Assign High / Low Value based on total spending
    SELECT
        customer_id,
        country,
        total_invoices,
        total_quantity,
        total_spent,
        avg_order_value,
        CASE 
            WHEN total_spent >= 1000 THEN 'High Value Customer'
            ELSE 'Low Value Customer'
        END AS customer_segment
    FROM customer_spending
)

-- Final aggregated view by country and segment
SELECT 
    country,
    customer_segment,
    COUNT(customer_id) AS number_of_customers,
    SUM(total_invoices) AS total_invoices,
    SUM(total_quantity) AS total_units_sold,
    ROUND(SUM(total_spent), 2) AS total_revenue,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(100.0 * COUNT(customer_id) / SUM(COUNT(customer_id)) OVER (PARTITION BY country), 2) AS segment_percentage_in_country
FROM customer_value
GROUP BY country, customer_segment
ORDER BY country, total_revenue DESC;
