-- 01_data_check.sql
-- Part A: how big is the data and what dates does it cover?
SELECT
  COUNT(*)                 AS total_orders,
  COUNT(DISTINCT user_id)  AS total_customers,
  MIN(DATE(created_at))    AS first_order_date,
  MAX(DATE(created_at))    AS last_order_date
FROM `bigquery-public-data.thelook_ecommerce.orders`;

-- Part B: what order statuses exist, and how common is each?
SELECT
  status,
  COUNT(*) AS orders,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders
FROM `bigquery-public-data.thelook_ecommerce.orders`
GROUP BY status
ORDER BY orders DESC;
