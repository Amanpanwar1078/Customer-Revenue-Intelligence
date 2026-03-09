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
