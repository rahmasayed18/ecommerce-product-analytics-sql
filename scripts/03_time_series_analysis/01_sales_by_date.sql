/* =============================================================================
   File:       01_sales_by_date.sql
   Purpose:    Time-based rollups of orders, quantity, and revenue from
               online_retail_cleaned at multiple grains (year, month, DOW, hour,
               quarter) for trend and seasonality analysis.
   Author:     Rahma Sayed
   Date:       2026-04-02
   Business
   goal:       Quantify when demand concentrates (e.g. holiday peaks, weekday
               patterns) and whether growth is driven by order volume vs. price
               or basket size—supporting planning, staffing, and campaign timing.
   Notes:      All queries read the cleaned fact table only. Revenue uses
               unit_price * quantity (line revenue). Averages are simple AVG of
               line-level unit_price / quantity unless you scope otherwise.
   ============================================================================= */


/* -----------------------------------------------------------------------------
   SECTION 1 — Yearly sales

   Why it matters:
     Anchors total scale by calendar year and separates multi-year views if the
     dataset expands; order and quantity totals show throughput vs. revenue.
   ----------------------------------------------------------------------------- */
SELECT
    YEAR(invoice_date) AS invoice_year,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS average_unit_price,
    ROUND(AVG(quantity), 2) AS average_quantity
FROM online_retail_transaction.online_retail_cleaned
GROUP BY YEAR(invoice_date)
ORDER BY invoice_year;


/* -----------------------------------------------------------------------------
   SECTION 2 — Monthly sales

   Why it matters:
     Primary view for seasonality (e.g. Q4 uplift): same KPIs as yearly but by
     month number (1–12) within the dataset window—useful for month-over-month
     storytelling and aligning with fiscal calendars.
   ----------------------------------------------------------------------------- */
SELECT
    MONTH(invoice_date) AS invoice_month,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS average_unit_price,
    ROUND(AVG(quantity), 2) AS average_quantity
FROM online_retail_transaction.online_retail_cleaned
GROUP BY MONTH(invoice_date)
ORDER BY invoice_month;


/* -----------------------------------------------------------------------------
   SECTION 3 — Sales by day of week

   Why it matters:
     Reveals intra-week rhythm (e.g. B2B vs. consumer patterns). ORDER BY
     total_sales DESC surfaces which weekdays drive the most revenue first.
   ----------------------------------------------------------------------------- */
SELECT
    DAYOFWEEK(invoice_date) AS invoice_day_of_week,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS average_unit_price,
    ROUND(AVG(quantity), 2) AS average_quantity
FROM online_retail_transaction.online_retail_cleaned
GROUP BY DAYOFWEEK(invoice_date)
ORDER BY total_sales DESC;


/* -----------------------------------------------------------------------------
   SECTION 4 — Hourly sales

   Why it matters:
     Uses invoice_hour from data prep to see concentration of activity by clock
     hour (ops, same-day delivery windows). Ensure upstream extraction populated
     invoice_hour consistently.
   ----------------------------------------------------------------------------- */
SELECT
    invoice_hour,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS average_unit_price,
    ROUND(AVG(quantity), 2) AS average_quantity
FROM online_retail_transaction.online_retail_cleaned
GROUP BY invoice_hour
ORDER BY total_sales DESC;


/* -----------------------------------------------------------------------------
   SECTION 5 — Quarterly sales

   Why it matters:
     Coarser seasonal lens than month—helpful for executive summaries and
     comparing Q1–Q4 performance when monthly noise is too granular.
   ----------------------------------------------------------------------------- */
SELECT
    QUARTER(invoice_date) AS invoice_quarter,
    COUNT(DISTINCT invoice_no) AS total_invoices,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(unit_price * quantity), 2) AS total_sales,
    ROUND(AVG(unit_price), 2) AS average_unit_price,
    ROUND(AVG(quantity), 2) AS average_quantity
FROM online_retail_transaction.online_retail_cleaned
GROUP BY QUARTER(invoice_date)
ORDER BY total_sales DESC;
