/*
============================================================
  Project : Customer Revenue Intelligence & Segmentation
  File    : 04_rfm_base.sql
  Purpose : Build rfm_base table calculating recency,
            frequency and monetary values for each
            customer using customer_summary data
  Author  : Aman Panwar
  Date    : March 2026
============================================================
*/
WITH cte_maxdate AS (
    SELECT MAX(order_date) AS max_date
    FROM fact_sales
)

SELECT
    cs.customer_unique_id,
    DATEDIFF(DAY, cs.last_order, md.max_date) AS recency,
    cs.total_orders AS frequency,
    ROUND(cs.total_revenue, 2) AS monetary
INTO rfm_base
FROM customer_summary cs
CROSS JOIN cte_maxdate md;
