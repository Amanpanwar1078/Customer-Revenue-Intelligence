/*
============================================================
  Project : Customer Revenue Intelligence & Segmentation
  File    : 06_segmentation.sql
  Purpose : Assign customer segment labels using CASE WHEN
            logic on RFM scores — Champions, Loyal,
            Big Spenders, Regular, At Risk
  Author  : Aman Panwar
  Date    : March 2026
============================================================
*/
SELECT
customer_unique_id,
recency,
frequency,
monetary,
CASE
WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'

WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Loyal Customers'

WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'

WHEN f_score <= 2 AND m_score >= 4 THEN 'Big Spenders'

ELSE 'Regular Customers'

END Customer_Segmentation
INTO rfm_segmented_table
FROM rfm_scored;
