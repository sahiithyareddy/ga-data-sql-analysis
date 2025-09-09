-- new_vs_returning.sql
SELECT
  CASE WHEN IFNULL(totals.newVisits, 0) = 1 THEN 'New Visitor' ELSE 'Returning Visitor' END AS visitor_type,
  COUNT(*) AS sessions,
  COUNT(DISTINCT fullVisitorId) AS users,
  SUM(IFNULL(totals.transactions, 0)) AS total_transactions,
  SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6 AS total_revenue_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.transactions, 0)), COUNT(*)) AS conversion_rate,               
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6, COUNT(*)) AS revenue_per_session_usd,
  SAFE_DIVIDE(SUM(IFNULL(totals.totalTransactionRevenue, 0)) / 1e6, NULLIF(COUNT(DISTINCT fullVisitorId), 0)) AS revenue_per_user_usd
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY visitor_type
ORDER BY revenue_per_user_usd DESC;
