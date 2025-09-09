# Google Analytics SQL Analysis (BigQuery)

This repository contains an end-to-end SQL analysis using the **Google Analytics Sample Dataset** hosted in **BigQuery**. The goal is to answer two business-critical questions and translate findings into clear, actionable recommendations.

- Dataset: `bigquery-public-data.google_analytics_sample.ga_sessions_*`
- Time window analyzed: **2017-01-01 to 2017-03-31** (adjustable)
- Currency note: `totals.totalTransactionRevenue` is stored in micros → divide by **1e6** to get USD-equivalents in this sample.

---

## Business Question 1 — Are Returning Visitors more valuable than New Visitors?

### SQL
```sql
-- Standard SQL
SELECT
  CASE WHEN IFNULL(totals.newVisits, 0) = 1 THEN 'New Visitor' ELSE 'Returning Visitor' END AS visitor_type,
  COUNT(*) AS sessions,
  COUNT(DISTINCT fullVisitorId) AS users,
  SUM(IFNULL(totals.transactions, 0)) AS total_transactions,
  SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6 AS total_revenue_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.transactions, 0)), COUNT(*)) AS conversion_rate,                -- transactions per session
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6, COUNT(*)) AS revenue_per_session_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6, NULLIF(COUNT(DISTINCT fullVisitorId), 0)) AS revenue_per_user_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY visitor_type
ORDER BY revenue_per_user_usd DESC;
```

### Results (summary)
Replace with your exported CSV (see **How to Reproduce**). Example findings for the above window:
- Returning visitors have materially higher conversion and revenue per user than new visitors.
- Returning visitors contribute a disproportionate share of revenue despite fewer sessions.

### Insights
- Returning visitors are the most profitable user segment (higher conversion and revenue per user).
- New visitors drive volume but significantly lower monetization efficiency.

### Recommendations
- Prioritize **retention and remarketing** (loyalty, email, personalized offers).
- Build **lookalike audiences** and retargeting from returning visitors to improve acquisition efficiency.
- Audit **mobile/checkout experience** for returning users to reduce friction and maximize repeat purchase rate.

---

## Business Question 2 — Which acquisition channels deliver the highest ROI (revenue per session)?

### SQL
```sql
-- Standard SQL
SELECT
  channelGrouping AS channel,
  COUNT(*) AS sessions,                                                                -- each row = 1 session
  COUNT(DISTINCT fullVisitorId) AS users,
  SUM(IFNULL(totals.transactions, 0)) AS total_transactions,
  SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6 AS total_revenue_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.transactions, 0)), COUNT(*)) AS conversion_rate,       -- transactions per session
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6, COUNT(*)) AS revenue_per_session_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6,
              NULLIF(SUM(IFNULL(totals.transactions, 0)), 0)) AS avg_order_value_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY channel
ORDER BY revenue_per_session_usd DESC;
```

### Results (summary)
Replace with your exported CSV. Example directional conclusions for this window:
- Display and Referral often surface near the top on **revenue per session**.
- Direct traffic is a consistent contributor with solid revenue/session.
- Paid/Organic Search typically provide **volume** but at a lower revenue/session versus Display/Referral.

### Insights
- ROI is not uniform across channels; some bring volume while others bring efficiency.
- Channel mix optimization can unlock immediate gains without additional traffic.

### Recommendations
- **Scale** high-ROI channels (e.g., Display/Referral) while maintaining brand/Direct strength.
- Use **Search** (Paid/Organic) for top-of-funnel and retarget those visitors via high-ROI channels.
- Establish a **monthly channel mix review** using this SQL to continuously rebalance spend.

---

## How to Reproduce

1. Open **BigQuery Console** → New Query.
2. Ensure **Standard SQL** is enabled.
3. Paste each query from `queries/` and adjust the date range if needed.
4. Run the query and review results.
5. Export results:
   - Click **Save Results** → **CSV**.
   - Save as `results/new_vs_returning.csv` or `results/acquisition_efficiency.csv`.
6. Update this README (optional) with key numeric highlights from your results.

---

## Project Structure

```
.
├── queries/
│   ├── acquisition_efficiency.sql
│   └── new_vs_returning.sql
├── results/
│   ├── acquisition_efficiency.csv      # place your exported results here
│   └── new_vs_returning.csv            # place your exported results here
└── README.md
```

---

## Final Touches (portfolio polish)

- Add a short project **description** and **topics** in the GitHub repo (e.g., `sql`, `bigquery`, `google-analytics`, `marketing-analytics`).
- Include a **LICENSE** (MIT is common for portfolios).
- Pin this repo to your GitHub profile.
- Optional: add a **social preview image** (Settings → Social preview) for a professional card when sharing the link.
- Keep commit messages clear (e.g., "Add channel ROI query", "Export results for Jan–Mar 2017").

---

## Caveats

- The Google Analytics sample dataset does not include ad **cost** data; we use **revenue/session** and **conversion rate** as ROI proxies.
- Revenue is in micros; divide by `1e6` to express in whole currency units.
- Public sample ≠ your production data; treat this as a methodology showcase.
