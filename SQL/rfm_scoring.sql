/*
============================================================
  Project : Customer Revenue Intelligence & Segmentation
  File    : 05_rfm_scoring.sql
  Purpose : Apply NTILE(5) scoring to recency, frequency
            and monetary values to generate R, F and M
            scores for each customer
  Author  : Aman Panwar
  Date    : March 2026
============================================================
*/
WITH cte_scores AS (
    SELECT
        customer_unique_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC)  AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)  AS m_score
    FROM rfm_base
)

SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_score
INTO rfm_scored
FROM cte_scores;

