{\rtf1\ansi\ansicpg1252\cocoartf2908
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 .AppleSystemUIFontMonospaced-Regular;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\fs24 \cf0 -- 04_second_orders.sql: how many new customers order again, and how fast? Overall and by channel.\
\
WITH valid_orders AS (\
  SELECT order_id, user_id, created_at\
  FROM `bigquery-public-data.thelook_ecommerce.orders`\
  WHERE status NOT IN ('Cancelled', 'Returned')\
),\
\
numbered AS (                                   -- number each customer's orders 1, 2, 3\'85\
  SELECT\
    user_id,\
    DATE(created_at) AS order_date,\
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_num\
  FROM valid_orders\
),\
\
first_second AS (                               -- one row per customer: 1st and 2nd order dates\
  SELECT\
    user_id,\
    MIN(IF(order_num = 1, order_date, NULL)) AS first_date,\
    MIN(IF(order_num = 2, order_date, NULL)) AS second_date   -- NULL if they never reordered\
  FROM numbered\
  WHERE order_num <= 2\
  GROUP BY user_id\
)\
\
SELECT\
  COALESCE(u.traffic_source, 'ALL') AS channel,\
  COUNT(*) AS new_customers,\
  ROUND(100 * COUNTIF(DATE_DIFF(second_date, first_date, DAY) <= 14) / COUNT(*), 1) AS pct_2nd_in_14d,\
  ROUND(100 * COUNTIF(DATE_DIFF(second_date, first_date, DAY) <= 30) / COUNT(*), 1) AS pct_2nd_in_30d,\
  ROUND(100 * COUNTIF(DATE_DIFF(second_date, first_date, DAY) <= 90) / COUNT(*), 1) AS pct_2nd_in_90d,\
  APPROX_QUANTILES(DATE_DIFF(second_date, first_date, DAY), 2)[OFFSET(1)] AS median_days_to_2nd\
FROM first_second AS f\
JOIN `bigquery-public-data.thelook_ecommerce.users` AS u\
  ON f.user_id = u.id\
WHERE f.first_date BETWEEN '2025-01-01' AND '2026-07-31'   -- everyone has had at least 90 days to reorder\
GROUP BY ROLLUP(u.traffic_source)                          -- one row per channel, plus a total row\
ORDER BY new_customers DESC;\
}