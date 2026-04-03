/* =============================================================
     Cohort Retention Analysis
==============================================================*/

/* 1. Identify First Purchase (Cohort) */
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS cohort_date
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY customer_id
),

/* 2. All Invoice Dates per Customer */
invoice_months AS (
    SELECT
        customer_id,
        invoice_date,
        DATE_FORMAT(invoice_date, '%Y-%m') AS invoice_month
    FROM online_retail_transaction.online_retail_cleaned
),

/* 3. Cohort Assignment + Month Offset */
cohort_base AS (
    SELECT
        fp.customer_id,
        DATE_FORMAT(fp.cohort_date, '%Y-%m') AS cohort_month,
        im.invoice_month,
        TIMESTAMPDIFF(MONTH, fp.cohort_date, im.invoice_date) AS month_offset
    FROM first_purchase fp
    JOIN invoice_months im ON fp.customer_id = im.customer_id
),

/* 4. Cohort Sizes (Month 0 only) */
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM cohort_base
    WHERE month_offset = 0
    GROUP BY cohort_month
),

/* 5. Monthly Retention Count */
cohort_retention AS (
    SELECT
        cohort_month,
        month_offset,
        COUNT(DISTINCT customer_id) AS retained_customers
    FROM cohort_base
    GROUP BY cohort_month, month_offset
)

/* 6. Final Retention Table with Rates */
SELECT
    cr.cohort_month,
    cr.month_offset,
    cs.cohort_size,
    cr.retained_customers,
    CONCAT(ROUND(100.0 * cr.retained_customers / cs.cohort_size, 1), ' %') AS retention_rate
FROM cohort_retention cr
JOIN cohort_size cs ON cr.cohort_month = cs.cohort_month
ORDER BY cr.cohort_month, cr.month_offset;
