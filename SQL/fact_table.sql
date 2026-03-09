/*
============================================================
  Project : Customer Revenue Intelligence & Segmentation
  File    : 02_fact_table.sql
  Purpose : Build the fact_sales table by joining orders,
            order items, customers and payments at the
            grain of order_id + order_item_id
  Author  : Aman Panwar
  Date    : March 2026
============================================================
*/
--Layer 1: Fact Table(Order-Item Level)

    select
    oi.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp AS order_date,
    oi.order_item_id,
    oi.product_id,
    oi.price,
    oi.freight_value,
    p.total_payment
INTO fact_sales
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN (
    SELECT order_id,
           SUM(payment_value) AS total_payment
    FROM order_payments_dataset
    GROUP BY order_id
) p
    ON oi.order_id = p.order_id
    left join customers_dataset c
    on c.customer_id=o.customer_id
;
