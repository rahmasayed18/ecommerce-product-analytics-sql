/* =============================================================================
   File:       01_churn_activity_tiers.sql
   Purpose:    Classify customers by how many distinct calendar months they
               purchased in, then flag simple churn vs. active using first/last
               purchase dates.
   Author:     Rahma Sayed
   Date:       2026-04-02
   Business
   goal:       Segment the base for CRM and retention (who is new, engaged, or
               loyal; who looks churned) so marketing and product can target
               reactivation vs. growth plays with evidence from behavior.
   Notes:      Activity tiers use COUNT(*) on the month-level CTE (one row per
               customer-month after DISTINCT). Churn query uses same-day min/max
               date as “churned_user” per original rule.
   ============================================================================= */


/* -----------------------------------------------------------------------------
   SECTION 1 — Activity tiers (month coverage + DENSE_RANK)

   Why it matters:
     • DISTINCT customer_id + DATE_FORMAT(invoice_date, '%Y-%m') collapses lines
       to one row per shopper per month—COUNT of those rows ≈ “how many months
       active,” which maps to engagement depth for loyalty programs.
     • DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY invoice_date) is
       carried in the inner set for ordering within customer history (logic
       unchanged from source).

   Tier labels (business):
     inactive / new / engaged / loyal reflect how many month-buckets appear—
     useful for prioritizing onboarding vs. nurture vs. VIP treatment.

   Note:
     activity_months = 0 is labeled inactive; in practice rows come from
     customers with at least one invoice, so interpret alongside data coverage.
   ----------------------------------------------------------------------------- */
WITH months_of_activity AS (
    SELECT DISTINCT
        customer_id,
        DATE_FORMAT(invoice_date, '%Y-%m') AS activity_month,
        DENSE_RANK() OVER (
            PARTITION BY customer_id
            ORDER BY invoice_date
        ) AS activity_month_rank
    FROM online_retail_transaction.online_retail_cleaned
),

activity_tiers AS (
    SELECT
        customer_id,
        COUNT(*) AS activity_months
    FROM months_of_activity
    GROUP BY customer_id
)

/* 2. Classify Customers into Activity Tiers */
SELECT
    customer_id,
    CASE
        WHEN activity_months = 0 THEN 'inactive'
        WHEN activity_months BETWEEN 1 AND 2 THEN 'new'
        WHEN activity_months BETWEEN 3 AND 5 THEN 'engaged'
        ELSE 'loyal'
    END AS activity_period
FROM activity_tiers
ORDER BY customer_id;


/* -----------------------------------------------------------------------------
   SECTION 2 — Churned vs active (single-day lifespan heuristic)

   Why it matters:
     • sign_up_date / last_purchase_date frame the customer lifecycle in months
       for reporting and cohort slides.
     • days_of_activity = 0 when MIN(invoice_date) = MAX(invoice_date) flags
       one-day-only purchasers—labeled churned_user here to surface “hit and quit”
       accounts for win-back tests (definition is strict; validate for your use
       case).

   Logic unchanged:
     ORDER BY sign_up_date lists customers roughly by cohort of first purchase.
   ----------------------------------------------------------------------------- */
SELECT
    customer_id,
    DATE_FORMAT(MIN(invoice_date), '%Y-%m') AS sign_up_date,
    DATE_FORMAT(MAX(invoice_date), '%Y-%m') AS last_purchase_date,
    TIMESTAMPDIFF(DAY, MIN(invoice_date), MAX(invoice_date)) AS days_of_activity,
    CASE
        WHEN TIMESTAMPDIFF(DAY, MIN(invoice_date), MAX(invoice_date)) = 0 THEN 'churned_user'
        ELSE 'active'
    END AS churn_status
FROM online_retail_transaction.online_retail_cleaned
GROUP BY customer_id
ORDER BY sign_up_date;
