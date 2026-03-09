/*
============================================================
  Project : Customer Revenue Intelligence & Segmentation
  File    : 03_customer_summary.sql
  Purpose : Build customer_summary table aggregating
            total orders, total revenue, first order
            and last order per customer
  Author  : Aman Panwar
  Date    : March 2026
============================================================
*/
SELECT
    customer_unique_id,
    SUM(price) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order
INTO customer_summary
FROM fact_sales
GROUP BY customer_unique_id;
