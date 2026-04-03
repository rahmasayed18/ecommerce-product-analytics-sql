/*=================================================================
Root Cause 01: Seasonality
Hypothesis: Top products perform better in certain months
=================================================================*/

SELECT 
    product,
    invoice_month,
    SUM(total_sales) AS monthly_sales
FROM online_retail_transaction.vw_ranked_monthly_sales
WHERE product IN (
    SELECT DISTINCT product 
    FROM online_retail_transaction.vw_pareto_analysis
)
GROUP BY product, invoice_month
ORDER BY product, invoice_month;


/*=================================================================
Root Cause 02: Price Sensitivity
Hypothesis: Top sellers have better pricing (lower or more stable price)
=================================================================*/

DROP VIEW IF EXISTS online_retail_transaction.vw_top_80_price_analysis;
CREATE VIEW online_retail_transaction.vw_top_80_price_analysis AS  
WITH price_analysis AS (
    SELECT
        description AS product,
        ROUND(AVG(unit_price), 2) AS avg_price,
        ROUND(STD(unit_price), 2) AS price_std_dev,
        ROUND(STD(unit_price) / AVG(unit_price), 2) AS relative_std_dev,
        CASE 
            WHEN ROUND(STD(unit_price) / AVG(unit_price), 2) < 0.1 THEN 'Stable Price'
            WHEN ROUND(STD(unit_price) / AVG(unit_price), 2) BETWEEN 0.1 AND 0.3 THEN 'Moderately Stable Price'
            ELSE 'Volatile Price'
        END AS price_stability
    FROM online_retail_transaction.online_retail_cleaned
    WHERE description IN (
        SELECT DISTINCT product
        FROM online_retail_transaction.vw_pareto_analysis
    )
    GROUP BY description
)

SELECT 
    price_stability,
    COUNT(product) AS total_products
FROM price_analysis
GROUP BY price_stability
ORDER BY total_products DESC;
