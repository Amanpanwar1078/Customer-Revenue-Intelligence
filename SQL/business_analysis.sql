/*
============================================================
  Project : Customer Revenue Intelligence & Segmentation
  File    : 07_business_analysis.sql
  Purpose : Business analysis queries covering segment
            revenue, AOV, revenue concentration, recency
            buckets, repeat purchase rate and lifecycle
  Author  : Aman Panwar
  Date    : March 2026
============================================================
*/


-- ============================================================
-- 1. SEGMENT REVENUE & CUSTOMER DISTRIBUTION
-- Revenue contribution and customer share per RFM segment
-- ============================================================
SELECT 
    Customer_Segmentation,
    COUNT(*)                                                        AS segment_customers,
    ROUND(SUM(monetary), 2)                                         AS segment_revenue,
    ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER(), 2)    AS revenue_percentage,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)              AS customer_percentage
FROM rfm_segmented_table
GROUP BY Customer_Segmentation
ORDER BY segment_revenue DESC;


-- ============================================================
-- 2. SEGMENT AVERAGE ORDER VALUE (AOV)
-- Identifies which segments have the highest spend per order
-- ============================================================
SELECT
    Customer_Segmentation,
    ROUND(SUM(monetary), 2)                                             AS segment_revenue,
    SUM(frequency)                                                      AS segment_orders,
    ROUND(SUM(monetary) * 1.0 / NULLIF(SUM(frequency), 0), 2)          AS segment_AOV
FROM rfm_segmented_table
GROUP BY Customer_Segmentation
ORDER BY segment_AOV DESC;


-- ============================================================
-- 3. REVENUE PER CUSTOMER BY SEGMENT
-- Average lifetime value per customer within each segment
-- ============================================================
SELECT
    Customer_Segmentation,
    ROUND(SUM(monetary), 2)                             AS segment_revenue,
    COUNT(*)                                            AS total_customers,
    ROUND(SUM(monetary) * 1.0 / COUNT(*), 2)           AS revenue_per_customer
FROM rfm_segmented_table
GROUP BY Customer_Segmentation
ORDER BY revenue_per_customer DESC;


-- ============================================================
-- 4. TOP 10% CUSTOMERS — REVENUE SHARE
-- Pareto analysis: how much revenue comes from top 10%
-- ============================================================
WITH ranked_customers AS (
    SELECT
        customer_unique_id,
        monetary,
        NTILE(10) OVER (ORDER BY monetary DESC) AS revenue_decile
    FROM rfm_segmented_table
)
SELECT
    ROUND(
        SUM(CASE WHEN revenue_decile = 1 THEN monetary END) * 100.0
        / SUM(monetary),
        2
    ) AS top_10_percent_revenue_share
FROM ranked_customers;


-- ============================================================
-- 5. TOP 20% CUSTOMERS — REVENUE SHARE
-- Extended Pareto: revenue contribution of top 20%
-- ============================================================
WITH ranked_customers AS (
    SELECT
        customer_unique_id,
        monetary,
        NTILE(10) OVER (ORDER BY monetary DESC) AS revenue_decile
    FROM rfm_segmented_table
)
SELECT
    ROUND(
        SUM(CASE WHEN revenue_decile IN (1, 2) THEN monetary END) * 100.0
        / SUM(monetary),
        2
    ) AS top_20_percent_revenue_share
FROM ranked_customers;


-- ============================================================
-- 6. CUMULATIVE REVENUE SHARE BY DECILE
-- Shows revenue concentration across all 10 customer deciles
-- ============================================================
WITH ranked_customers AS (
    SELECT
        customer_unique_id,
        monetary,
        NTILE(10) OVER (ORDER BY monetary DESC) AS revenue_decile
    FROM rfm_segmented_table
),
decile_revenue AS (
    SELECT
        revenue_decile,
        ROUND(SUM(monetary), 2) AS decile_revenue
    FROM ranked_customers
    GROUP BY revenue_decile
)
SELECT
    revenue_decile,
    decile_revenue,
    ROUND(
        SUM(decile_revenue) OVER (ORDER BY revenue_decile)
        * 100.0 / SUM(decile_revenue) OVER (),
        2
    ) AS cumulative_revenue_percentage
FROM decile_revenue
ORDER BY revenue_decile;


-- ============================================================
-- 7. RECENCY BUCKET DISTRIBUTION
-- Groups customers by days since last purchase
-- ============================================================
WITH recency_buckets AS (
    SELECT 
        customer_unique_id,
        CASE 
            WHEN recency BETWEEN 0  AND 30  THEN '0-30 Days'
            WHEN recency BETWEEN 31 AND 90  THEN '31-90 Days'
            WHEN recency BETWEEN 91 AND 180 THEN '91-180 Days'
            ELSE '180+ Days'
        END AS recency_bucket
    FROM rfm_base
)
SELECT 
    recency_bucket,
    COUNT(*)                                                        AS customers_in_bucket,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)             AS customer_percentage
FROM recency_buckets
GROUP BY recency_bucket
ORDER BY customers_in_bucket DESC;


-- ============================================================
-- 8. REPEAT PURCHASE RATE
-- Percentage of customers who placed more than one order
-- ============================================================
SELECT 
    ROUND(
        SUM(CASE WHEN frequency > 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS repeat_purchase_rate_percentage
FROM rfm_base;


-- ============================================================
-- 9. AVERAGE RECENCY BY SEGMENT
-- Identifies which segments are most vs least recently active
-- ============================================================
SELECT 
    Customer_Segmentation,
    ROUND(AVG(recency), 2) AS avg_recency_days
FROM rfm_segmented_table
GROUP BY Customer_Segmentation
ORDER BY avg_recency_days ASC;


-- ============================================================
-- 10. CUSTOMER LIFECYCLE WINDOW BY SEGMENT
-- Average days between first and last purchase per segment
-- ============================================================
SELECT 
    rst.Customer_Segmentation,
    ROUND(
        AVG(DATEDIFF(DAY, cs.first_order, cs.last_order)),
        2
    ) AS avg_customer_lifecycle_days
FROM customer_summary cs
JOIN rfm_segmented_table rst
    ON cs.customer_unique_id = rst.customer_unique_id
GROUP BY rst.Customer_Segmentation
ORDER BY avg_customer_lifecycle_days DESC;


-- ============================================================
-- 11. CHURN RISK PERCENTAGE
-- Customers with recency > 180 days considered at churn risk
-- ============================================================
SELECT 
    ROUND(
        SUM(CASE WHEN recency > 180 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS churn_risk_percentage
FROM rfm_base;


-- ============================================================
-- 12. REVENUE VALIDATION
-- Verifies fact table revenue matches customer summary totals
-- ============================================================
SELECT 
    SUM(total_payment)  AS fact_revenue_by_payment,
    SUM(price)          AS fact_revenue_by_price
FROM fact_sales;

SELECT 
    SUM(total_revenue)  AS customer_summary_revenue
FROM customer_summary;


-- ============================================================
-- 13. DUPLICATE GRAIN CHECK
-- Confirms no duplicate order_id + order_item_id in fact table
-- ============================================================
SELECT 
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM fact_sales
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 14. SEGMENTATION INTEGRITY CHECK
-- Confirms each customer appears exactly once in RFM output
-- ============================================================
SELECT 
    customer_unique_id,
    COUNT(*) AS occurrence_count
FROM rfm_segmented_table
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;
