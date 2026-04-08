-- =============================================================================
-- File: 01_churn_activity_tiers.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Classify customers into activity tiers (new, engaged, loyal) based 
--          on number of active months and identify potential churned users.
-- =============================================================================

-- Customer Activity Tiers & Churn Analysis
-- Business value: Helps marketing and retention teams identify new users who 
--                 need onboarding, engaged users for nurturing, and loyal users 
--                 for VIP treatment.

-- Part 1: Activity Tiers based on number of distinct active months
WITH months_of_activity AS (
    SELECT 
        customer_id,
        DATE_FORMAT(invoice_date, '%Y-%m') AS activity_month
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id, DATE_FORMAT(invoice_date, '%Y-%m')
),
activity_tiers AS (
    SELECT 
        customer_id,
        COUNT(*) AS active_months
    FROM months_of_activity
    GROUP BY customer_id
)
SELECT 
    customer_id,
    active_months,
    CASE 
        WHEN active_months BETWEEN 1 AND 2 THEN 'new'
        WHEN active_months BETWEEN 3 AND 5 THEN 'engaged'
        WHEN active_months >= 6 THEN 'loyal'
        ELSE 'inactive'
    END AS activity_tier
FROM activity_tiers
ORDER BY active_months DESC;

-- Part 2: Churn Status based on purchase lifespan
-- (Simple heuristic: customers who only purchased on a single day)
SELECT 
    customer_id,
    DATE_FORMAT(MIN(invoice_date), '%Y-%m') AS first_purchase_month,
    DATE_FORMAT(MAX(invoice_date), '%Y-%m') AS last_purchase_month,
    TIMESTAMPDIFF(DAY, MIN(invoice_date), MAX(invoice_date)) AS days_active,
    CASE 
        WHEN TIMESTAMPDIFF(DAY, MIN(invoice_date), MAX(invoice_date)) = 0 THEN 'churned_one_day'
        WHEN TIMESTAMPDIFF(DAY, MIN(invoice_date), MAX(invoice_date)) <= 30 THEN 'short_lifespan'
        ELSE 'active_longer_term'
    END AS churn_status
FROM online_retail_transaction.online_retail_cleaned
GROUP BY customer_id
ORDER BY days_active ASC;
