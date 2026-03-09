# Customer Revenue Intelligence & Segmentation System

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)

A complete end-to-end data analytics project analyzing customer purchasing behavior and revenue distribution across ~95,000 customers and ~100,000 orders from the Brazilian Olist e-commerce platform — culminating in RFM-based customer segmentation and a 3-page interactive Power BI dashboard.

---

## Table of Contents
- [Problem Statement](#problem-statement)
- [Dataset](#dataset)
- [Project Workflow](#project-workflow)
- [Data Modeling](#data-modeling)
- [RFM Segmentation Methodology](#rfm-segmentation-methodology)
- [Business Analysis Performed](#business-analysis-performed)
- [Dashboard Overview](#dashboard-overview)
- [Key Business Insights](#key-business-insights)
- [Business Recommendations](#business-recommendations)
- [Repository Structure](#repository-structure)
- [How to Run](#how-to-run)
- [Resume and LinkedIn Description](#resume-and-linkedin-description)

---

## Problem Statement

E-commerce businesses accumulate large volumes of transaction data but often lack a structured framework to answer critical commercial questions:

- Which customers are most valuable to the business?
- Which customers are at risk of churning?
- Where should retention and reactivation efforts be focused?
- How is revenue distributed across the customer base?

This project builds a complete customer intelligence system to answer these questions using SQL Server for data preparation and RFM segmentation, and Power BI for business visualization.

---

## Dataset

| Attribute | Detail |
|-----------|--------|
| **Name** | Brazilian E-Commerce Public Dataset by Olist |
| **Source** | [Kaggle — Olist Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |
| **Orders** | ~100,000 |
| **Customers** | ~95,000 unique customers |
| **Period** | 2016 – 2018 |
| **Key Tables Used** | olist_orders, olist_order_items, olist_customers, olist_order_payments |

> **Note:** Raw CSV files are not included in this repository due to file size. Download the dataset directly from the Kaggle link above and follow the setup instructions below.

---

## Project Workflow

```
Raw CSV Files (Kaggle)
        |
SQL Server — Data Import and Cleaning
        |
Fact Table Construction (fact_sales)
        |
Customer-Level Aggregation (customer_summary)
        |
RFM Scoring (rfm_base to rfm_scored)
        |
Customer Segmentation (rfm_segmented_table)
        |
Business Analysis Queries
        |
Power BI Dashboard (3 Pages)
```

---
## Data Preparation & Validation

During the SQL phase, the Olist dataset was imported into SQL Server 
and validated before building the analytical model.

| Step | What Was Done |
|------|--------------|
| Data Type Verification | Ensured price and payment columns were stored as DECIMAL, date fields as DATE/DATETIME |
| Row Count Validation | Verified row counts post-import and cross-checked across related tables |
| Duplicate Detection | Checked for duplicate order_id + order_item_id combinations using GROUP BY HAVING COUNT(*) > 1 |
| Grain Definition | Defined fact table grain as one row per order_id + order_item_id |
| Revenue Validation | Verified item-level revenue matched customer-level aggregations |
| Fan-out Detection | Identified and resolved duplication caused by joining payment table with item-level table |
| Segmentation Check | Confirmed each customer appears exactly once in the final RFM output |

**Result:** Three core analytical tables produced — fact_sales, customer_summary, rfm_segmented_table

## Data Modeling

### Fact Table — fact_sales
**Grain:** One row per order_id + order_item_id

Built by joining:
- olist_orders — order dates, customer IDs, order status
- olist_order_items — product-level revenue (price, freight)
- olist_customers — customer unique ID and location
- olist_order_payments — payment values per order

Revenue integrity was validated by confirming SUM(price) matched aggregated customer revenue across all joins.

### Customer Summary Table — customer_summary
Aggregated to one row per customer containing:
- total_orders — count of distinct orders placed
- total_revenue — lifetime spend in BRL
- first_order — date of first purchase
- last_order — date of most recent purchase

This table formed the base for all RFM calculations.

---

## RFM Segmentation Methodology

RFM scores each customer on three behavioral dimensions:

| Dimension | Definition | Direction |
|-----------|-----------|-----------|
| **Recency (R)** | Days since last purchase (from dataset max date) | Lower = better |
| **Frequency (F)** | Total number of orders placed | Higher = better |
| **Monetary (M)** | Total lifetime spend in BRL | Higher = better |

### Scoring Approach
NTILE(5) was used to divide customers into 5 equal buckets per dimension, producing scores from 1 (lowest) to 5 (highest). Recency scores were inverted so that more recent customers receive higher scores.

### Segment Definitions

| Segment | Behavioral Profile |
|---------|-------------------|
| **Champions** | High recency, high frequency, high spend |
| **Loyal Customers** | High frequency, consistent spend |
| **Big Spenders** | High monetary value, lower frequency — dormant high-value |
| **Regular Customers** | Moderate across all three dimensions |
| **At Risk** | Previously active, now lapsing — low recency score |

---

## Business Analysis Performed

| Analysis | Description |
|----------|-------------|
| Average Order Value (AOV) | Total revenue divided by total orders = $137.75 |
| Top 10% Revenue Contribution | Revenue share driven by highest-value customers |
| Revenue Concentration | Pareto-style analysis of top 20% customers |
| Recency Bucket Distribution | Customers grouped into 0-30, 31-90, 91-180, 180+ day buckets |
| Repeat Purchase Rate | Percentage of customers with more than one order |
| Customer Lifecycle Analysis | Duration from first order to last order per customer |
| Revenue Validation | Cross-validated SUM(price) against aggregated revenue figures |

---

## Dashboard Overview

### Page 1 — Business Overview
<img width="1390" height="784" alt="business_overview_dashboard" src="https://github.com/user-attachments/assets/22353b3e-f26b-4eac-8879-20c679027dd5" />
High-level executive summary of overall business performance.

- KPI Cards: Total Revenue ($13.6M), Total Orders (99K), Total Customers (95K), AOV ($137.75)
- Revenue contribution by customer segment
- Customer count distribution by segment
- Customer recency bucket distribution
- Business analyst insight text panel

### Page 2 — Customer Segmentation Analysis
<img width="1388" height="783" alt="segmentation_analysis_dashboard" src="https://github.com/user-attachments/assets/fc237749-68af-4c3a-aa5e-8f87d4c636c7" />

Deep dive into RFM segment behavior and value comparison.

- Average days since last purchase by segment
- Purchase frequency comparison by segment
- Average lifetime spend by segment
- Revenue share donut chart by segment
- RFM Behavior Map: bubble chart plotting frequency vs spend per segment

### Page 3 — Revenue Intelligence
<img width="1382" height="778" alt="revenue_intelligence_dashboard" src="https://github.com/user-attachments/assets/9b830434-5768-4cfc-8f1f-8bddcfa8b81f" />

Revenue trend analysis and customer value mapping.

- Monthly revenue trend across 2016–2018
- Customer revenue distribution by spend bucket
- Customer Value Map: scatter plot of orders vs revenue per customer
- Top 10 customers by total revenue
- Monthly order volume trend

---

## Key Business Insights

1. **Revenue is highly concentrated** — Champions and Big Spenders together drive over 50% of $13.6M total revenue despite being a small share of the customer base
2. **High churn risk** — 35%+ of customers fall in the 180+ day recency bucket indicating widespread disengagement
3. **Low repeat purchase rate** — Most customers place only one order; increasing repeat purchases is the primary growth lever
4. **Big Spenders are dormant** — Highest average spend but worst recency score — strong reactivation potential
5. **Revenue peaked May 2018** at approximately $980K before declining through August 2018
6. **Volume-driven business model** — Majority of customers spend under $100 lifetime confirming that frequency, not AOV, is the key metric to grow

---

## Business Recommendations

| Priority | Segment | Recommendation |
|----------|---------|----------------|
| High | Champions | Launch VIP loyalty program to prevent churn — highest ROI segment |
| High | Big Spenders | Personalized reactivation campaign — high value, currently dormant |
| Medium | At Risk | Time-limited win-back offer — moderate historical spend, recoverable |
| Medium | Single-order customers | Post-purchase follow-up sequence to drive second order |
| Growth | Regular Customers | Upsell and cross-sell campaigns to migrate toward Loyal tier |

---

## Repository Structure

```
customer-revenue-intelligence/
|
|-- README.md
|
|-- SQL/
|   |-- 01_fact_table.sql
|   |-- 02_customer_summary.sql
|   |-- 03_rfm_base.sql
|   |-- 04_rfm_scoring.sql
|   |-- 05_segmentation.sql
|   |-- 06_business_analysis.sql
|
|-- PowerBI/
|   |-- Customer_Revenue_Intelligence.pbix
|
|-- Documentation/
|   |-- rfm_segmentation_logic.md
|   |-- dashboard_screenshots/
|       |-- page1_business_overview.png
|       |-- page2_segmentation_analysis.png
|       |-- page3_revenue_intelligence.png
|
|-- Dataset/
    |-- README.md
```

---

## How to Run

### Prerequisites
- SQL Server (any edition including the free Express edition)
- SQL Server Management Studio (SSMS) — free download from Microsoft
- Power BI Desktop — free download from Microsoft

### Steps

**Step 1 — Get the Dataset**
- Go to [Kaggle — Olist Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- Download and extract all CSV files

**Step 2 — Run SQL Scripts in Order**
Open SSMS, connect to your SQL Server instance, and run the scripts in this order:
```
01_fact_table.sql           — Build the fact_sales table
02_customer_summary.sql     — Build the customer_summary table
03_rfm_base.sql             — Build RFM base table
04_rfm_scoring.sql          — Calculate RFM scores using NTILE(5)
05_segmentation.sql         — Assign customer segments
06_business_analysis.sql    — Run business analysis queries
```

**Step 3 — Open Power BI Dashboard**
- Open Customer_Revenue_Intelligence.pbix in Power BI Desktop
- Go to Home > Transform data > Data source settings
- Update the SQL Server connection to point to your local instance
- Click Close and Refresh

---

## Resume and LinkedIn Description

### Resume — Project Section
Built an end-to-end Customer Revenue Intelligence system on the Olist Brazilian E-Commerce dataset (~95K customers, ~100K orders) using SQL Server for data modeling, RFM scoring, and customer segmentation, and Power BI for a 3-page interactive dashboard tracking $13.6M in revenue across 5 behavioral customer segments.

### LinkedIn — Project Description
**Customer Revenue Intelligence and Segmentation System**

Built a full end-to-end data analytics project analyzing ~95,000 customers and ~100,000 orders from the Brazilian Olist e-commerce platform.

Used SQL Server to clean raw data, build a fact table, calculate RFM scores using NTILE(5), and segment customers into 5 behavioral profiles. Delivered a 3-page Power BI dashboard covering business KPIs ($13.6M revenue, $137.75 AOV), segment behavior analysis, and revenue intelligence with actionable retention and reactivation recommendations.

Tech: SQL Server | Power BI | DAX | RFM Modeling
Dataset: Brazilian E-Commerce Public Dataset (Olist) via Kaggle
