/* =============================================================================
   File:       02_create_master_table.sql
   Purpose:    Build a single analysis-ready fact table online_retail_cleaned by
               stacking and harmonizing raw splits (AA, AB, BA, BB).
   Author:     Rahma Sayed
   Date:       2026-04-01
   Business
   goal:       One consistent “source of truth” for KPIs, Pareto, seasonality, and
               customer views—so every downstream script reads the same cleansed
               transactions with parsed dates and stable geography labels.
   Output:     Table online_retail_transaction.online_retail_cleaned
   Notes:      DROP + CREATE AS is destructive; rerun only when rebuilding from
               raw staging. CustomerId casing in WHERE matches existing schema.
   ============================================================================= */


/* -----------------------------------------------------------------------------
   SECTION 1 — Reset target table

   Drops the prior cleaned table so this script can rebuild it from scratch.
   Use with care in shared environments (data loss for that table only).
   ----------------------------------------------------------------------------- */
DROP TABLE IF EXISTS online_retail_transaction.online_retail_cleaned;


/* -----------------------------------------------------------------------------
   SECTION 2 — CREATE TABLE AS … UNION ALL (four raw feeds)

   Business intent:
     • Same row-level filters as 01_clean_raw_transactions.sql — only positive
       quantity and price, identifiable customers, and parseable timestamps —
       so revenue and order counts reflect real sales, not reversals or junk.
     • STR_TO_DATE on InvoiceDate stores a true datetime for time-series and
       cohort work (monthly revenue, seasonality, AOV trends).
     • Calendar parts (hour, DOW, month, year) avoid repeating parsing logic in
       every downstream query.
     • CASE on Country aligns USA/RSA to canonical names for clean country
       rollups (e.g. UK dominance in exec summaries).

   Technical:
     UNION ALL preserves all four ingest parts without deduplicating (same as
     original logic); duplicates, if any, must be handled in a separate rule.

   Branch AA — first UNION leg (identical pattern to AB/BA/BB below).
   ----------------------------------------------------------------------------- */
CREATE TABLE online_retail_transaction.online_retail_cleaned AS

-- ============================
-- Cleaned Data from table: AA
-- ============================
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
  AND CustomerId != 0
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24

UNION ALL

-- ============================
-- Cleaned Data from table: AB
-- ============================
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
  AND CustomerId != 0
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24

UNION ALL

-- ============================
-- Cleaned Data from table: BA
-- ============================
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
  AND CustomerId != 0
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24

UNION ALL

-- ============================
-- Cleaned Data from table: BB
-- ============================
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
  AND CustomerId != 0
  AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;
