# Data Dictionary

## Overview
This document describes the structure and meaning of the main tables used in the analysis.

## Main Table: `online_retail_cleaned`

This is the single source of truth (fact table) used for all analysis after cleaning.

| Column Name          | Data Type    | Description |
|----------------------|--------------|-----------|
| `invoice_no`         | VARCHAR      | Unique invoice identifier |
| `stock_code`         | VARCHAR      | Product code |
| `description`        | VARCHAR      | Product name/description (cleaned) |
| `quantity`           | INT          | Number of units purchased (positive only) |
| `invoice_date`       | DATETIME     | Date and time of the transaction |
| `invoice_hour`       | INT          | Hour of the day (0-23) |
| `invoice_day_of_week`| INT          | Day of week (1=Sunday, 7=Saturday) |
| `invoice_month`      | INT          | Month number (1-12) |
| `invoice_year`       | INT          | Year (2011) |
| `unit_price`         | DECIMAL      | Price per unit |
| `customer_id`        | INT          | Unique customer identifier |
| `country`            | VARCHAR      | Customer's country (standardized) |

## Raw Staging Tables (Before Cleaning)
- `online_retail_aa`, `online_retail_ab`, `online_retail_ba`, `online_retail_bb`
  - Same structure as above but contain raw, uncleaned data split across files.

## Key Derived Concepts

| Term                    | Definition |
|-------------------------|----------|
| **Revenue**             | `unit_price × quantity` |
| **Order**               | Unique `invoice_no` |
| **Cohort Month**        | First purchase month of a customer |
| **Active Month**        | Any month in which a customer made at least one purchase |
| **RFM**                 | Recency, Frequency, Monetary value used for customer segmentation |
| **Pareto (80/20)**      | Analysis showing how much revenue comes from the top products/customers |

## Notes
- All negative quantities (returns/cancellations) were excluded from the cleaned table.
- Anonymous transactions (`customer_id = 0` or NULL) were removed.
- Country names were standardized (e.g., "USA" → "United States", "RSA" → "South Africa").
- Only positive `quantity` and `unit_price` transactions are included in analysis.

