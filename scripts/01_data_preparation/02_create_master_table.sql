-- =============================================================================
-- File: 02_create_master_table.sql
-- Author: Rahma Salah
-- Created: 2025
-- Last Updated: 2026-04-02
-- Purpose: Build a single analysis-ready fact table `online_retail_cleaned` 
--          by combining the four raw staging tables (AA, AB, BA, BB).
-- =============================================================================

-- Drop the table if it already exists (so we can rebuild cleanly)
DROP TABLE IF EXISTS online_retail_transaction.online_retail_cleaned;

-- Create the unified cleaned fact table
CREATE TABLE online_retail_transaction.online_retail_cleaned AS
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
WHERE Quantity > 0 
  AND UnitPrice > 0 
  AND CustomerID != 0 
  AND InvoiceDate IS NOT NULL

UNION ALL

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
FROM online_retail_transaction.online_retail_ab
WHERE Quantity > 0 
  AND UnitPrice > 0 
  AND CustomerID != 0 
  AND InvoiceDate IS NOT NULL

UNION ALL

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
FROM online_retail_transaction.online_retail_ba
WHERE Quantity > 0 
  AND UnitPrice > 0 
  AND CustomerID != 0 
  AND InvoiceDate IS NOT NULL

UNION ALL

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
FROM online_retail_transaction.online_retail_bb
WHERE Quantity > 0 
  AND UnitPrice > 0 
  AND CustomerID != 0 
  AND InvoiceDate IS NOT NULL;
