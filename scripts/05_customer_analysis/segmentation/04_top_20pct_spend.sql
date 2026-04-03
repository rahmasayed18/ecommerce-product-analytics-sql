/* =============================================================
     customer segmentation
     4- Top 20% by Spending (Percentiles)
==============================================================*/

WITH customer_spending AS (
    SELECT
        customer_id,
        country,
        COUNT(invoice_no) AS total_invoices,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_spent,
        ROUND(SUM(unit_price * quantity) / COUNT(invoice_no), 2) AS average_order_value
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id, country
),
percentiles AS (
    SELECT
        customer_id,
        country,
        total_invoices,
        total_quantity,
        total_spent,
        average_order_value,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS percentile_rank
    FROM customer_spending
)
SELECT
    country,
    COUNT(customer_id) AS total_customers,
    SUM(total_invoices) AS total_invoices,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(total_spent), 2) AS total_spent,
    ROUND(SUM(total_spent) / COUNT(customer_id), 2) AS average_spent_per_customer,
    ROUND(SUM(total_invoices) / COUNT(customer_id), 2) AS average_orders_per_customer,
    ROUND(SUM(total_quantity) / COUNT(customer_id), 2) AS average_quantity_per_customer
FROM percentiles
WHERE percentile_rank = 1
GROUP BY country
ORDER BY total_spent DESC;
