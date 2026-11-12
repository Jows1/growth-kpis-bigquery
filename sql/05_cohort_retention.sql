-- 05_cohort_retention.sql
-- Of each month's new customers, what % ordered again 1, 2 and 3 months later?

WITH valid_orders AS (
  SELECT order_id, user_id, created_at
  FROM `bigquery-public-data.thelook_ecommerce.orders`
  WHERE status NOT IN ('Cancelled', 'Returned')
),

customer_months AS (                -- which months each customer ordered in
  SELECT DISTINCT
    user_id,
    DATE_TRUNC(DATE(created_at), MONTH) AS order_month
  FROM valid_orders
  WHERE DATE(created_at) < '2026-11-01'
),

cohorts AS (                        -- each customer's first month = their cohort
  SELECT user_id, MIN(order_month) AS cohort_month
  FROM customer_months
  GROUP BY user_id
),

activity AS (                       -- months between joining and each active month
  SELECT
    c.cohort_month,
    c.user_id,
    DATE_DIFF(m.order_month, c.cohort_month, MONTH) AS months_since_first
  FROM cohorts AS c
  JOIN customer_months AS m USING (user_id)
)

SELECT
  cohort_month,
  COUNT(DISTINCT IF(months_since_first = 0, user_id, NULL)) AS cohort_size,
  ROUND(100 * COUNT(DISTINCT IF(months_since_first = 1, user_id, NULL))
            / COUNT(DISTINCT IF(months_since_first = 0, user_id, NULL)), 1) AS m1_pct,
  ROUND(100 * COUNT(DISTINCT IF(months_since_first = 2, user_id, NULL))
            / COUNT(DISTINCT IF(months_since_first = 0, user_id, NULL)), 1) AS m2_pct,
  ROUND(100 * COUNT(DISTINCT IF(months_since_first = 3, user_id, NULL))
            / COUNT(DISTINCT IF(months_since_first = 0, user_id, NULL)), 1) AS m3_pct
FROM activity
WHERE cohort_month BETWEEN '2025-11-01' AND '2026-07-01'   -- cohorts with 3 full months observed
GROUP BY cohort_month
ORDER BY cohort_month;
