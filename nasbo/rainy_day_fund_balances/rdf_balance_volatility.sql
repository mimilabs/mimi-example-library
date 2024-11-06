-- State Rainy Day Fund Historical Volatility Analysis
-- Business Purpose: Analyze the year-over-year stability of state rainy day fund balances 
-- to identify states with consistent vs volatile fiscal management practices.
-- This helps stakeholders assess fiscal reliability and predictive behavior.

WITH yearly_changes AS (
  -- Calculate year-over-year changes in balances
  SELECT 
    state,
    year,
    balance_in_dollars,
    LAG(balance_in_dollars) OVER (PARTITION BY state ORDER BY year) as prev_year_balance,
    ROUND(
      (balance_in_dollars - LAG(balance_in_dollars) OVER (PARTITION BY state ORDER BY year)) 
      / NULLIF(LAG(balance_in_dollars) OVER (PARTITION BY state ORDER BY year), 0) * 100,
      2
    ) as yoy_change_pct
  FROM mimi_ws_1.nasbo.rainy_day_fund_balances
  WHERE year >= 2018  -- Focus on recent 5-year trend
    AND year <= 2022  -- Exclude projected/estimated years
),

volatility_metrics AS (
  -- Calculate volatility metrics per state
  SELECT 
    state,
    AVG(balance_in_dollars) as avg_balance,
    STDDEV(yoy_change_pct) as balance_volatility,
    COUNT(*) as years_of_data,
    MIN(yoy_change_pct) as max_decrease,
    MAX(yoy_change_pct) as max_increase
  FROM yearly_changes
  WHERE yoy_change_pct IS NOT NULL
  GROUP BY state
  HAVING COUNT(*) >= 4  -- Ensure sufficient data points
)

SELECT 
  state,
  ROUND(avg_balance, 2) as avg_balance_mm,
  ROUND(balance_volatility, 2) as balance_volatility_score,
  ROUND(max_decrease, 2) as largest_yearly_decrease_pct,
  ROUND(max_increase, 2) as largest_yearly_increase_pct,
  CASE 
    WHEN balance_volatility <= 25 THEN 'Stable'
    WHEN balance_volatility <= 50 THEN 'Moderate'
    ELSE 'Volatile'
  END as stability_category
FROM volatility_metrics
WHERE avg_balance > 0  -- Focus on states with positive balances
ORDER BY balance_volatility;

/* How it works:
1. First CTE calculates year-over-year changes in rainy day fund balances
2. Second CTE computes volatility metrics including standard deviation of changes
3. Final query categorizes states based on their balance volatility

Assumptions and limitations:
- Focuses on 2018-2022 for recent but actual (non-projected) data
- Requires at least 4 years of data points per state
- Excludes states with zero or negative average balances
- Volatility thresholds (25/50) are somewhat arbitrary and may need adjustment

Possible extensions:
1. Add seasonal analysis to identify cyclical patterns
2. Incorporate economic indicators to contextualize volatility
3. Create moving window volatility metrics
4. Add peer group comparisons by state size or region
5. Include correlation analysis with revenue volatility
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:21:01.095499
    - Additional Notes: Query focuses on measuring fiscal stability through balance volatility metrics. The 5-year window (2018-2022) ensures recent, actual data while avoiding estimates/projections. The stability categories (Stable/Moderate/Volatile) use standardized thresholds that may need adjustment based on specific use cases or economic conditions.
    
    */