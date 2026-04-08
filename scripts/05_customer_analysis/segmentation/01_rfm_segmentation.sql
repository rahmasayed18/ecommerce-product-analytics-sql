-- =============================================================================
-- File: 01_rfm_segmentation.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Segment customers using RFM (Recency, Frequency, Monetary) model 
--          to identify Champions, Loyal Customers, Potential Loyalists, and At Risk customers.
-- =============================================================================

WITH rfm AS (
    SELECT
        customer_id,
        MAX(invoice_date) AS last_purchase_date,
        MIN(invoice_date) AS first_purchase_date,
        TIMESTAMPDIFF(MONTH, MAX(invoice_date), '2012-01-01') AS recency_months,
        COUNT(DISTINCT invoice_no) AS frequency,
        ROUND(SUM(unit_price * quantity), 2) AS monetary_value
    FROM online_retail_transaction.online_retail_cleaned
    WHERE invoice_no NOT LIKE 'C%'
    GROUP BY customer_id
)
SELECT
    customer_id,
    last_purchase_date,
    first_purchase_date,
    recency_months,
    frequency,
    monetary_value,
    CASE
        WHEN recency_months <= 1 AND frequency >= 5 AND monetary_value >= 100 THEN 'Champions'
        WHEN recency_months <= 3 AND frequency >= 3 AND monetary_value >= 50 THEN 'Loyal Customers'
        WHEN recency_months <= 6 AND frequency >= 2 AND monetary_value >= 20 THEN 'Potential Loyalists'
        WHEN recency_months > 6 AND frequency < 2 AND monetary_value < 20 THEN 'At Risk'
        ELSE 'Others'
    END AS rfm_segment
FROM rfm
ORDER BY monetary_value DESC;
