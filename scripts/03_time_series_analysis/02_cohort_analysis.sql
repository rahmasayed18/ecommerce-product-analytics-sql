/* =============================================================
     COHORT ANALYSIS - First Purchase per Customer
============================================================== */
WITH first_purchase AS (
    SELECT 
        customer_id,
        DATE_FORMAT(MIN(invoice_date), '%Y-%m') AS cohort_month,
        MAX(DATE(invoice_date)) AS last_purchase_date,
        TIMESTAMPDIFF(MONTH, MIN(DATE(invoice_date)), MAX(DATE(invoice_date))) AS months_of_activity,
        COUNT(DISTINCT invoice_no) AS total_invoices,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_spent
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id
)
SELECT
    cohort_month,
    COUNT(DISTINCT customer_id) AS total_users,
    SUM(total_invoices) AS total_invoices,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(total_spent), 2) AS total_spent
FROM first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;
