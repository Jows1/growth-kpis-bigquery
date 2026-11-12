{\rtf1\ansi\ansicpg1252\cocoartf2908
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 HelveticaNeue;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\fs26 \cf0 SELECT\
  COUNT(*)                 AS total_orders,     \
  COUNT(DISTINCT user_id)  AS total_customers,  \
  MIN(DATE(created_at))    AS first_order_date, \
  MAX(DATE(created_at))    AS last_order_date   \
FROM `bigquery-public-data.thelook_ecommerce.orders`;\
\
-- Part B: what order statuses exist, and how common is each?\
SELECT\
  status,\
  COUNT(*) AS orders,\
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_orders\
FROM `bigquery-public-data.thelook_ecommerce.orders`\
GROUP BY status\
ORDER BY orders DESC;}