{\rtf1\ansi\ansicpg1252\cocoartf2908
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 .AppleSystemUIFontMonospaced-Regular;\f1\fnil\fcharset0 HelveticaNeue;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\fs24 \cf0 WITH valid_orders AS (              \
  SELECT order_id, user_id, created_at\
  FROM `bigquery-public-data.thelook_ecommerce.orders`\
  WHERE status NOT IN ('Cancelled', 'Returned')\
),\
\
order_revenue AS (                  \
  SELECT order_id, SUM(sale_price) AS revenue\
  FROM `bigquery-public-data.thelook_ecommerce.order_items`\
  GROUP BY order_id\
)\
\
SELECT\
  DATE_TRUNC(DATE(o.created_at), MONTH)        AS month,            \
  COUNT(DISTINCT o.order_id)                   AS orders,\
  COUNT(DISTINCT o.user_id)                    AS active_customers, \
  ROUND(SUM(r.revenue), 0)                     AS revenue,\
  ROUND(SAFE_DIVIDE(SUM(r.revenue),\
        COUNT(DISTINCT o.order_id)), 2)        AS revenue_per_order \
FROM valid_orders AS o\
JOIN order_revenue AS r USING (order_id)        \
WHERE DATE(o.created_at) < DATE_TRUNC(CURRENT_DATE(), MONTH)  \
GROUP BY month\
ORDER BY month;
\f1\fs26 \
}