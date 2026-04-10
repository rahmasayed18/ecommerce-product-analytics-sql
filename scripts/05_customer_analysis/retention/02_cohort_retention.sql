-- =============================================================================
-- File: 02_cohort_retention_analysis.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Calculate monthly cohort retention rates to understand how well 
--          we retain customers over time after their first purchase.
-- =============================================================================

-- Cohort Retention Analysis
-- Business value: Shows retention trends by cohort month. Helps identify 
--                 whether new customers stay active or drop off quickly.

WITH first_purchase AS (
    -- Get the first purchase date for each customer (defines the cohort)
    SELECT 
        customer_id,
        MIN(invoice_date) AS cohort_date
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id
),

invoice_months AS (
    -- All purchase months per customer
    SELECT 
        customer_id,
        DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month,
        invoice_date
    FROM online_retail_transaction.online_retail_cleaned
),

cohort_base AS (
    -- Assign cohort month and calculate month offset from first purchase
    SELECT 
        fp.customer_id,
        DATE_FORMAT(fp.cohort_date, '%Y-%m') AS cohort_month,
        im.invoice_month,
        TIMESTAMPDIFF(MONTH, fp.cohort_date, im.invoice_date) AS month_offset
    FROM first_purchase fp
    JOIN invoice_months im ON fp.customer_id = im.customer_id
),

cohort_size AS (
    -- Number of customers in each cohort (month 0 = first purchase month)
    SELECT 
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_base
    WHERE month_offset = 0
    GROUP BY cohort_month
),

cohort_retention AS (
    -- Count retained customers per cohort and month offset
    SELECT 
        cohort_month,
        month_offset,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM cohort_base
    GROUP BY cohort_month, month_offset
)

-- Final Output: Retention rates by cohort and month
SELECT 
    cr.cohort_month,
    cr.month_offset,
    cs.cohort_size,
    cr.retained_customers,
    ROUND(100.0 * cr.retained_customers / cs.cohort_size, 1) AS retention_rate_pct
FROM cohort_retention cr
JOIN cohort_size cs ON cr.cohort_month = cs.cohort_month
ORDER BY cr.cohort_month, cr.month_offset;
