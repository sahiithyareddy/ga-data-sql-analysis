-- acquisition_efficiency.sql
SELECT
  channelGrouping AS channel,
  COUNT(*) AS sessions,                                                               
  COUNT(DISTINCT fullVisitorId) AS users,
  SUM(IFNULL(totals.transactions, 0)) AS total_transactions,
  SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6 AS total_revenue_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.transactions, 0)), COUNT(*)) AS conversion_rate,      
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6, COUNT(*)) AS revenue_per_session_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6,
              NULLIF(SUM(IFNULL(totals.transactions, 0)), 0)) AS avg_order_value_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY channel
ORDER BY revenue_per_session_usd DESC;
