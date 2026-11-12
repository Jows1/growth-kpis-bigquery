-- 03_acquisition.sql
-- New customers by traffic source, last 12 complete months (Nov 2025 - Oct 2026).

WITH valid_orders AS (
  SELECT order_id, user_id, created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
),

first_orders AS (                   -- each customer's first valid order date
  SELECT user_id, MIN(DATE(created_at)) AS first_order_date
  FROM valid_orders
  GROUP BY user_id
)

SELECT
  u.traffic_source,
  COUNT(*) AS new_customers,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_new_customers
FROM first_orders AS f
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u
  ON f.user_id = u.id
WHERE f.first_order_date >= '2025-11-01'
  AND f.first_order_date <  '2026-11-01'
GROUP BY u.traffic_source
ORDER BY new_customers DESC;
