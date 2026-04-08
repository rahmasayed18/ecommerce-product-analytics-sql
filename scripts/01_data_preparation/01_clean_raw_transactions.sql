-- =============================================================================
-- File: 01_clean_raw_transactions.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Clean raw transaction data by removing returns, invalid prices, 
--          and anonymous records before building the master table.
-- =============================================================================

-- Clean SELECT for one staging table (example for online_retail_aa)
-- Apply the same logic to AB, BA, BB
SELECT 
    InvoiceNo AS invoice_no,
    StockCode AS stock_code,
    LOWER(TRIM(Description)) AS description,
    Quantity AS quantity,
    STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i') AS invoice_date,
    HOUR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_hour,
    DAYOFWEEK(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_day_of_week,
    MONTH(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_month,
    YEAR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_year,
    UnitPrice AS unit_price,
    CustomerID AS customer_id,
    CASE 
        WHEN LOWER(TRIM(Country)) = 'usa' THEN 'united states'
        WHEN LOWER(TRIM(Country)) = 'rsa' THEN 'south africa'
        ELSE LOWER(TRIM(Country))
    END AS country
FROM online_retail_transaction.online_retail_aa
WHERE Quantity > 0                    -- Exclude returns and cancellations
  AND UnitPrice > 0                   -- Exclude free or invalid price lines
  AND CustomerID != 0                 -- Exclude anonymous transactions
  AND InvoiceDate IS NOT NULL;
