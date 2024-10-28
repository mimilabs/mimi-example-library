
/*******************************************************************
Title: State Rainy Day Fund Analysis - Core Business Metrics
 
Business Purpose:
This query analyzes state rainy day fund balances to assess fiscal 
preparedness across states. It identifies states with the strongest
fiscal reserves and tracks changes in fund balances over time.
This information helps evaluate states' ability to weather economic
downturns and maintain essential services during crises.
*******************************************************************/

-- Main Analysis Query 
WITH current_balances AS (
  -- Get most recent year's data for each state
  SELECT state,
         year,
         balance_in_dollars,
         percent_of_gf,
         RANK() OVER (PARTITION BY state ORDER BY year DESC) as year_rank
  FROM mimi_ws_1.nasbo.rainy_day_fund_balances
  WHERE year <= 2023  -- Exclude projections
),

historical_changes AS (
  -- Calculate 5-year changes
  SELECT a.state,
         a.balance_in_dollars as current_balance,
         a.percent_of_gf as current_percent,
         a.balance_in_dollars - b.balance_in_dollars as five_year_change
  FROM mimi_ws_1.nasbo.rainy_day_fund_balances a
  LEFT JOIN mimi_ws_1.nasbo.rainy_day_fund_balances b 
    ON a.state = b.state 
    AND a.year = b.year + 5
  WHERE a.year = 2023
)

SELECT 
  c.state,
  c.balance_in_dollars as latest_balance_mm,
  c.percent_of_gf as pct_of_general_fund,
  h.five_year_change as change_over_5yr_mm,
  CASE 
    WHEN c.percent_of_gf >= 10 THEN 'Strong'
    WHEN c.percent_of_gf >= 5 THEN 'Moderate'
    ELSE 'Low'
  END as reserve_strength
FROM current_balances c
JOIN historical_changes h ON c.state = h.state
WHERE c.year_rank = 1
  AND c.state NOT IN ('District of Columbia', 'Guam', 'Puerto Rico', 'Virgin Islands')
ORDER BY c.percent_of_gf DESC;

/*******************************************************************
How it works:
1. Gets latest actual balances for each state (excluding projections)
2. Calculates 5-year change in balances
3. Categorizes states by reserve strength
4. Combines metrics into final analysis view

Assumptions & Limitations:
- Uses 2023 as latest actual year (not estimates/projections)
- Excludes territories and DC for consistency
- Assumes 10% of general fund is threshold for "strong" reserves
- Does not account for state-specific factors affecting needed reserves

Possible Extensions:
1. Add regional groupings to identify geographic patterns
2. Include year-over-year volatility metrics
3. Compare to economic indicators like unemployment
4. Add population-adjusted per capita metrics
5. Create time series visualization of balance trends
*******************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:54:45.855306
    - Additional Notes: Query only includes the 50 U.S. states and uses 2023 as the latest year for actual data. The reserve strength categorization (Strong/Moderate/Low) uses fixed thresholds that may need adjustment based on specific analysis needs. Five-year change calculations may include NULL values for states lacking historical data.
    
    */