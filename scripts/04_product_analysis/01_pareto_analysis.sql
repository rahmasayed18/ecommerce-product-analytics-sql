/* =============================================================================
   File:       01_pareto_analysis.sql
   Purpose:    Build a view that ranks products by revenue and flags the “tail”
               beyond a cumulative revenue threshold (classic Pareto / 80-20
               style concentration).
   Author:     Rahma Sayed
   Date:       2026-04-02
   Business
   goal:       Show how revenue concentrates across SKUs so leadership can decide
               where to invest (hero products) vs. prune or bundle long-tail
               items that contribute little to total sales.
   Notes:      View name vw_tail_products; filter keeps rows where cumulative
               revenue share *exceeds* 80% (tail slice). DROP targets schema as
               written in legacy script—align with your DB if needed.
   ============================================================================= */


/* -----------------------------------------------------------------------------
   SECTION 1 — Replace view: product-level Pareto / cumulative revenue

   Why it matters:
     • total_sales = SUM(unit_price * quantity) by product description is line
       revenue rolled to product—consistent with other analyses on this dataset.
     • Window SUM(...) OVER (ORDER BY total_sales DESC) builds running totals
       without self-joins; dividing by grand total yields cumulative % of revenue.
     • WHERE cumulative_percentage > 80 isolates the lower-performing tail after
       the top products have already accounted for the first ~80% (definition
       matches existing logic—keep when interpreting charts).

   Technical:
     grand_total CTE is a single scalar for the whole product universe; ranked_sales
     computes per-row share and cumulative metrics.
   ----------------------------------------------------------------------------- */
DROP VIEW IF EXISTS online_retail__transaction.vw_tail_products;
CREATE VIEW online_retail_transaction.vw_tail_products AS
WITH sales_data AS (
    SELECT
        description AS product,
        SUM(quantity) AS total_quantity,
        ROUND(SUM(unit_price * quantity), 2) AS total_sales
    FROM online_retail_transaction.online_retail_cleaned
    GROUP BY description
),
grand_total AS (
    SELECT SUM(total_sales) AS grand_total_sales FROM sales_data
),
ranked_sales AS (
    SELECT
        product,
        total_quantity,
        total_sales,
        ROUND(total_sales * 100.0 / (SELECT grand_total_sales FROM grand_total), 2) AS sales_percentage,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC), 2) AS cumulative_sales,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 /
              (SELECT grand_total_sales FROM grand_total), 2) AS cumulative_percentage
    FROM sales_data
)

SELECT *
FROM ranked_sales
WHERE cumulative_percentage > 80;
