# Growth KPIs in BigQuery: Acquisition, Repeat Orders and Retention

An end-to-end growth analysis of an online retailer using SQL in Google BigQuery. I take the role of a growth analyst and answer five questions: what's in the data, how the business is trending, where new customers come from, how many order again, and how well each monthly cohort is retained. The project ends with recommendations.

**Tools:** Google BigQuery (Standard SQL) · **Dataset:** [`bigquery-public-data.thelook_ecommerce`](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce)
**Results as of:** 11 November 2026 (the dataset refreshes daily, so re-running will give slightly different numbers)

---

## Key findings

| # | Finding | Number |
|---|---|---|
| 1 | One order in four is cancelled or returned | 25.1% |
| 2 | Growth is driven by order volume, not basket size | Orders +132% YoY (Oct); revenue per order flat at ~$84–89 |
| 3 | Acquisition depends heavily on one channel | Search = 70.2% of new customers |
| 4 | Very few new customers order again quickly | 1.4% within 14 days; 8.9% within 90 days; median gap 135 days |
| 5 | Retention of recent cohorts is improving | Month-3 retention up from 2.7% (Nov 2025 cohort) to 5.8% (Jul 2026 cohort) |

---

## Repository structure

```
growth-kpis-bigquery/
├── README.md
├── sql/        one query per analysis step (01–05)
├── results/    each query's output as CSV
└── images/     charts
```

**How to run:** open BigQuery (the free sandbox works), paste any file from `sql/` into a new query and run it. No setup is needed; the dataset is public.

---

## 1. Data check
**Question:** What's in the data, and what counts as a real order?
**Query:** [`sql/01_data_check.sql`](sql/01_data_check.sql)

| Status | Orders | Share |
|---|---|---|
| Shipped | 37,478 | 30.0% |
| Complete | 31,127 | 24.9% |
| Processing | 24,809 | 19.9% |
| Cancelled | 18,877 | 15.1% |
| Returned | 12,486 | 10.0% |

**Result:** 124,777 orders from 80,000 customers, January 2019 – November 2026.
**Insight:** A quarter of all orders never become a completed sale. The data refreshes daily, so the current month is always incomplete.

## 2. Monthly KPIs
**Question:** How are orders, customers and revenue trending?
**Query:** [`sql/02_monthly_kpis.sql`](sql/02_monthly_kpis.sql)

| Month | Orders | Active customers | Revenue | Revenue per order |
|---|---|---|---|---|
| Oct 2025 | 1,984 | 1,961 | $181,296 | $91.38 |
| Oct 2026 | 4,610 | 4,265 | $390,718 | $84.75 |
| **Change** | **+132%** | **+117%** | **+116%** | **−7%** |

**Result:** Orders grew from 4 in January 2019 to 4,610 in October 2026. Revenue over the last 12 months (Nov 2025 – Oct 2026) was about $2.9M. Revenue per order has stayed between roughly $84 and $89 since 2020.
**Insight:** Growth comes almost entirely from more customers ordering, not from bigger baskets. Orders per active customer are about 1.0–1.08 a month, so customers rarely order twice in a month.

## 3. Acquisition
**Question:** Where do new customers come from?
**Query:** [`sql/03_acquisition.sql`](sql/03_acquisition.sql)

| Traffic source | New customers | Share |
|---|---|---|
| Search | 14,644 | 70.2% |
| Organic | 3,090 | 14.8% |
| Facebook | 1,251 | 6.0% |
| Email | 1,026 | 4.9% |
| Display | 848 | 4.1% |

**Result:** 20,859 new customers in the last 12 complete months. A new customer is defined by their first valid order.
**Insight:** Acquisition is concentrated in Search, which is a dependency risk. There is no marketing spend data, so cost per acquisition by channel can't be calculated; channels are compared on customer quality instead (Step 4).

## 4. Second orders
**Question:** What share of new customers order again, and how quickly?
**Query:** [`sql/04_second_orders.sql`](sql/04_second_orders.sql)

| Channel | New customers | 2nd order ≤14 days | ≤30 days | ≤90 days | Median days to 2nd |
|---|---|---|---|---|---|
| **All** | **25,355** | **1.4%** | **3.1%** | **8.9%** | **135** |
| Search | 17,745 | 1.4% | 3.2% | 9.1% | 130 |
| Organic | 3,763 | 1.2% | 2.7% | 8.6% | 136 |
| Facebook | 1,582 | 1.3% | 3.2% | 7.9% | 139 |
| Email | 1,256 | 2.0% | 3.8% | 8.4% | 152 |
| Display | 1,009 | 1.0% | 2.9% | 8.7% | 131 |

**Result:** Customers whose first order was between January 2025 and July 2026, so everyone had at least 90 days to reorder.
**Insight:** Repeat buying is rare and slow, which fits a fashion retailer: people buy clothes every few months, not every few days. Differences between channels are small. Email's 2.0% versus 1.4% overall is about 7 extra customers out of 1,256, too few to be confident it's a real difference.

## 5. Cohort retention
**Question:** Of each month's new customers, what share ordered again one, two and three months later?
**Query:** [`sql/05_cohort_retention.sql`](sql/05_cohort_retention.sql)

| Cohort (first order) | Cohort size | Month 1 | Month 2 | Month 3 |
|---|---|---|---|---|
| Nov 2025 | 1,279 | 3.6% | 3.1% | 2.7% |
| Dec 2025 | 1,357 | 2.4% | 1.9% | 3.3% |
| Jan 2026 | 1,478 | 3.4% | 3.0% | 2.7% |
| Feb 2026 | 1,320 | 4.0% | 3.9% | 3.4% |
| Mar 2026 | 1,549 | 3.1% | 3.2% | 3.6% |
| Apr 2026 | 1,522 | 4.5% | 4.1% | 4.4% |
| May 2026 | 1,687 | 3.0% | 4.7% | 4.2% |
| Jun 2026 | 1,738 | 4.7% | 4.9% | 6.1% |
| Jul 2026 | 1,918 | 5.3% | 6.0% | 5.8% |

**Insight:** Two patterns stand out.
- **Retention is flat across months.** Instead of the usual steep drop after month 1, a similar small share returns each month. Customers who come back trickle in steadily rather than all at once.
- **Recent cohorts are retained better.** Month-1 retention rose from 3.6% (Nov 2025) to 5.3% (Jul 2026), and month-3 from 2.7% to 5.8%, while cohorts also grew 50% in size. Each cohort is about 1,300–1,900 customers, so one percentage point is only 13–19 people; the trend matters more than any single cell.

---

## Recommendations

1. **Make retention the main growth lever.** More than 90% of new customers don't return within 90 days. Even a small lift in repeat orders compounds, because acquisition is already paid for.
2. **Time retention campaigns to the natural reorder cycle.** The median gap to a second order is 135 days, so nudges in the first few days would mostly be wasted. Trigger them at 60–120 days, or around new collections and seasons.
3. **Find out what improved the 2026 cohorts, and do more of it.** Month-3 retention roughly doubled between the November 2025 and July 2026 cohorts. Identifying the cause (product mix, a campaign, delivery speed) is the highest-value next analysis.
4. **Reduce dependence on Search, and add cost data.** With spend by channel, cost per new customer and payback can be compared directly. Since customer quality is similar across channels, the cheapest channel would win.
5. **Test basket-size levers.** Revenue per order has been flat for six years. Bundles or a free-shipping threshold could raise it without needing new customers.
6. **Investigate the 15% cancellation rate.** Every cancelled order is acquisition spend with no revenue.

---

## Decisions log

| Decision | Reason |
|---|---|
| Excluded Cancelled and Returned orders | No completed sale took place. 93,414 valid orders remain. |
| Kept Processing and Shipped orders | They are real orders that simply haven't been delivered yet. |
| Stopped monthly trends at the last complete month | The data refreshes daily, so the current month is always partial and would look like a drop. |
| Defined a new customer by their first *valid* order | A customer whose only orders were cancelled never bought anything. |
| Only included customers with ≥90 days of history in Step 4 | Recent customers haven't had time to reorder and would make rates look falsely low. |
| Only included cohorts with 3 full months observed in Step 5 | Same reason: unobserved months would show as fake 0%. |
| Defined all cleaning rules in one `valid_orders` CTE | Every step uses the same definition of a valid order, so numbers stay consistent. |

## Limitations

- **Synthetic data.** thelook is generated by Google for practice, so trends (such as the 2026 acceleration) reflect how the data is built, not real customer behaviour. The value of this project is the method.
- **No cost data.** CAC, payback and profitability by channel can't be calculated.
- **Revenue is sale price only.** No discounts, shipping fees or product costs, so this is revenue, not contribution.
- **Small segments.** Channel and cohort differences of about one percentage point are within normal noise at these sizes.

## SQL techniques used

CTEs · `COUNT(DISTINCT)` · `SAFE_DIVIDE` · `DATE_TRUNC` / `DATE_DIFF` · window functions (`ROW_NUMBER`, `SUM() OVER ()`) · conditional aggregation (`COUNTIF`, `MIN(IF())`, `COUNT(DISTINCT IF())`) · `GROUP BY ROLLUP` with `COALESCE` · `APPROX_QUANTILES` for medians · cohort analysis

---

**Author:** Omoyajowo David · [GitHub](https://github.com/Jows1?tab=repositories) · [LinkedIn](https://linkedin.com/in/omoyajowo-david-56524a217)
