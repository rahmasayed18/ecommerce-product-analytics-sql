/* =============================================================================
   File:       01_clean_raw_transactions.sql
   Purpose:    Reusable cleaning SELECTs plus QA queries for split raw staging
               tables (AA, AB, BA, BB) ahead of building online_retail_cleaned.
   Author:     Rahma Sayed
   Date:       2026-04-01
   Business
   goal:       Produce trustworthy transaction-level inputs for revenue, product,
               and market analysis by excluding cancellations/returns, bad
               prices, unknown customers, and timestamps that would break parsing.
   Notes:      Run cleaning blocks as needed, or use 02_create_master_table.sql to
               materialize the unified fact table. QA queries validate row-level
               issues before reporting.
   ============================================================================= */


/* -----------------------------------------------------------------------------
   SECTION 1 — Staging table: ONLINE_RETAIL_AA (clean SELECT)

   What this does (business):
     Picks valid sale lines only so downstream revenue matches “money in,” not
     credits or data-entry errors.

   Logic (unchanged):
     • Quantity > 0        → drop returns/cancellations (negative qty) and
                             zero-qty noise; we only want positive sales volume.
     • UnitPrice > 0       → drop free or invalid price lines that would distort
                             AOV and revenue.
     • CustomerID != 0     → drop anonymous rows; we cannot attribute revenue
                             or build customer metrics without an ID.
     • Hour < 24 check     → guards STR_TO_DATE / calendar fields from bad
                             time strings in raw InvoiceDate.

     LOWER(TRIM(Description|Country)) → consistent text for joins/labels and
     fewer duplicate product or country names due to spacing/case.
   ----------------------------------------------------------------------------- */
SELECT
    InvoiceNo AS invoice_no,
    StockCode,
    LOWER(TRIM(Description)) AS Description,
    Quantity,
    InvoiceDate,
    HOUR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_hour,
    DAYOFWEEK(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_day_of_week,
    MONTH(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_month,
    YEAR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_year,
    UnitPrice,
    CustomerID,
    LOWER(TRIM(Country)) AS Country
FROM online_retail_transaction.online_retail_aa
WHERE
    Quantity > 0
    AND UnitPrice > 0
    AND CustomerID != 0
    AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;


/* -----------------------------------------------------------------------------
   SECTION 2 — QA for ONLINE_RETAIL_AA

   Use these to spot bad rows before they enter the cleaned fact table: null IDs,
   invalid stock codes, returns, impossible dates/prices, missing country, and
   invoice cancellation pattern (prefix 'C%' per dataset convention).
   ----------------------------------------------------------------------------- */
-- Null or invalid values check by column
SELECT CustomerID FROM online_retail_transaction.online_retail_aa WHERE CustomerID IS NULL OR CustomerID = 0;
SELECT StockCode FROM online_retail_transaction.online_retail_aa WHERE StockCode IS NULL OR StockCode = '';
SELECT Quantity FROM online_retail_transaction.online_retail_aa WHERE Quantity < 0;
SELECT InvoiceDate FROM online_retail_transaction.online_retail_aa WHERE InvoiceDate = 0 OR InvoiceDate IS NULL;
SELECT UnitPrice FROM online_retail_transaction.online_retail_aa WHERE UnitPrice < 0;
SELECT Country FROM online_retail_transaction.online_retail_aa WHERE Country IS NULL OR Country = '';
SELECT InvoiceNo FROM online_retail_transaction.online_retail_aa WHERE InvoiceNo IS NULL OR InvoiceNo LIKE 'C%';

-- Check valid time extraction
SELECT * FROM online_retail_transaction.online_retail_aa
WHERE CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;
SELECT InvoiceDate FROM online_retail_transaction.online_retail_aa WHERE InvoiceDate IS NOT NULL LIMIT 10;


/* -----------------------------------------------------------------------------
   SECTION 3 — Staging table: ONLINE_RETAIL_AB (clean SELECT + QA)

   Same business rules as Section 1; duplicated per physical table so each
   ingest chunk can be validated the same way before UNION.
   ----------------------------------------------------------------------------- */
/* === Clean: online_retail_ab === */
SELECT
    InvoiceNo AS invoice_no,
    StockCode,
    LOWER(TRIM(Description)) AS Description,
    Quantity,
    InvoiceDate,
    HOUR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_hour,
    DAYOFWEEK(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_day_of_week,
    MONTH(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_month,
    YEAR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_year,
    UnitPrice,
    CustomerID,
    LOWER(TRIM(Country)) AS Country
FROM online_retail_transaction.online_retail_ab
WHERE
    Quantity > 0
    AND UnitPrice > 0
    AND CustomerID != 0
    AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;

/* === QA: online_retail_ab Quality Checks === */
SELECT CustomerID FROM online_retail_transaction.online_retail_ab WHERE CustomerID IS NULL OR CustomerID = 0;
SELECT StockCode FROM online_retail_transaction.online_retail_ab WHERE StockCode IS NULL OR StockCode = '';
SELECT Quantity FROM online_retail_transaction.online_retail_ab WHERE Quantity < 0;
SELECT InvoiceDate FROM online_retail_transaction.online_retail_ab WHERE InvoiceDate = 0 OR InvoiceDate IS NULL;
SELECT UnitPrice FROM online_retail_transaction.online_retail_ab WHERE UnitPrice < 0;
SELECT Country FROM online_retail_transaction.online_retail_ab WHERE Country IS NULL OR Country = '';
SELECT InvoiceNo FROM online_retail_transaction.online_retail_ab WHERE InvoiceNo IS NULL OR InvoiceNo LIKE 'C%';

-- Time sanity check
SELECT * FROM online_retail_transaction.online_retail_ab
WHERE CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;
SELECT InvoiceDate FROM online_retail_transaction.online_retail_ab WHERE InvoiceDate IS NOT NULL LIMIT 10;


/* -----------------------------------------------------------------------------
   SECTION 4 — Staging table: ONLINE_RETAIL_BA (clean SELECT)

   Extra step on Country: map common abbreviations (USA, RSA) to full names so
   country-level revenue matches executive reporting (“United Kingdom” vs mixed
   spellings), same as in the master table script.
   ----------------------------------------------------------------------------- */
/* === Clean: online_retail_ba === */
SELECT
    InvoiceNo AS invoice_no,
    StockCode,
    LOWER(TRIM(Description)) AS Description,
    Quantity,
    InvoiceDate,
    HOUR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_hour,
    DAYOFWEEK(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_day_of_week,
    MONTH(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_month,
    YEAR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_year,
    UnitPrice,
    CustomerID,
    CASE
        WHEN LOWER(TRIM(Country)) = 'usa' THEN 'united states'
        WHEN LOWER(TRIM(Country)) = 'rsa' THEN 'south africa'
        ELSE LOWER(TRIM(Country))
    END AS Country
FROM online_retail_transaction.online_retail_ba
WHERE
    Quantity > 0
    AND UnitPrice > 0
    AND CustomerID != 0
    AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;


/* -----------------------------------------------------------------------------
   SECTION 5 — Staging table: ONLINE_RETAIL_BB (clean SELECT)

   Mirrors Section 4 for the last split file; identical country normalization so
   all four chunks roll up to one consistent geography dimension.
   ----------------------------------------------------------------------------- */
/* === Clean: online_retail_bb === */
SELECT
    InvoiceNo AS invoice_no,
    StockCode,
    LOWER(TRIM(Description)) AS Description,
    Quantity,
    InvoiceDate,
    HOUR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_hour,
    DAYOFWEEK(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_day_of_week,
    MONTH(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_month,
    YEAR(STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i')) AS invoice_year,
    UnitPrice,
    CustomerID,
    CASE
        WHEN LOWER(TRIM(Country)) = 'usa' THEN 'united states'
        WHEN LOWER(TRIM(Country)) = 'rsa' THEN 'south africa'
        ELSE LOWER(TRIM(Country))
    END AS Country
FROM online_retail_transaction.online_retail_bb
WHERE
    Quantity > 0
    AND UnitPrice > 0
    AND CustomerID != 0
    AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(InvoiceDate, ' ', -1), ':', 1) AS UNSIGNED) < 24;
