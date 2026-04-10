# Project Methodology

## Overview
This project analyzes the Online Retail dataset (2011 transactions) to understand revenue trends, customer behavior, product performance, and geographic distribution. The goal is to provide actionable business insights for growth and retention strategies.

## Data Source
- **Dataset**: Online Retail (UCI Machine Learning Repository)
- **Time Period**: January to December 2011
- **Scope**: 37 countries, thousands of products, and hundreds of thousands of transactions

## Approach & Process

### 1. Data Preparation
- Loaded raw data from split staging tables (AA, AB, BA, BB)
- Applied rigorous cleaning:
  - Removed canceled orders (`Quantity <= 0`)
  - Removed invalid prices (`UnitPrice <= 0`)
  - Removed anonymous transactions (`CustomerID = 0` or NULL)
  - Standardized text (lowercase + trim)
  - Parsed dates and extracted calendar components
  - Normalized country names (USA → United States, RSA → South Africa)

### 2. Exploratory Analysis
- Calculated overall KPIs (total revenue, orders, customers, products)
- Identified top countries, top products, and basic distributions

### 3. Core Analysis
- **Time Series**: Monthly revenue trends and seasonality
- **Product Analysis**: Pareto (80/20), long tail, and time consistency
- **Customer Analysis**: RFM segmentation, activity tiers, cohort retention
- **Value Segmentation**: High vs Low value customers by spending

### 4. Reporting
- Built summary tables for customer and product performance

## Tools & Technologies
- **SQL** (MySQL) – Main analysis language
- **Git + GitHub** – Version control and portfolio hosting

## Key Assumptions
- Cancelled orders (`InvoiceNo` starting with 'C') are excluded from revenue analysis
- Revenue is calculated as `UnitPrice × Quantity`
- One row represents one product line in a transaction

## Limitations
- No customer demographic data beyond country
- No returns processing cost or profit margin data
- Dataset ends in December 2011 (no 2012 data for full year-over-year comparison)
