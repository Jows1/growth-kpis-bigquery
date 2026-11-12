-- 02_monthly_kpis.sql
-- Orders, active customers, revenue and revenue per order by month.

WITH valid_orders AS (              -- keep only real orders (see decisions log)
  SELECT order_id, user_id, created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
),

order_revenue AS (                  -- one revenue figure per order (sum of its items)
  SELECT order_id, SUM(sale_price) AS revenue
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  GROUP BY order_id
)

SELECT
  DATE_TRUNC(DATE(o.created_at), MONTH)                         AS month,
  COUNT(DISTINCT o.order_id)                                    AS orders,
  COUNT(DISTINCT o.user_id)                                     AS active_customers,
  ROUND(SUM(r.revenue), 0)                                      AS revenue,
  ROUND(SAFE_DIVIDE(SUM(r.revenue), COUNT(DISTINCT o.order_id)), 2) AS revenue_per_order
FROM valid_orders AS o
JOIN order_revenue AS r USING (order_id)
WHERE DATE(o.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)    -- drop the incomplete current month
GROUP BY month
ORDER BY month;
