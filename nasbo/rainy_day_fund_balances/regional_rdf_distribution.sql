-- Regional Rainy Day Fund Distribution Analysis
-- Business Purpose: Assess the geographic concentration and distribution of rainy day fund balances 
-- across different U.S. regions to identify regional fiscal patterns and potential risk clustering.
-- This helps policymakers and investors understand regional fiscal resilience and vulnerabilities.

WITH regional_funds AS (
  -- Get the most recent complete year of data (excluding estimates/projections)
  WITH latest_year AS (
    SELECT MAX(year) as max_year
    FROM mimi_ws_1.nasbo.rainy_day_fund_balances
    WHERE year <= 2023  -- Excluding future projections
  )
  
  -- Calculate regional totals and metrics
  SELECT 
    CASE 
      WHEN state IN ('Maine', 'New Hampshire', 'Vermont', 'Massachusetts', 'Rhode Island', 'Connecticut') THEN 'New England'
      WHEN state IN ('New York', 'Pennsylvania', 'New Jersey') THEN 'Mid-Atlantic'
      WHEN state IN ('Illinois', 'Indiana', 'Michigan', 'Ohio', 'Wisconsin', 'Minnesota', 'Iowa') THEN 'Midwest'
      WHEN state IN ('Florida', 'Georgia', 'North Carolina', 'South Carolina', 'Virginia', 'Tennessee', 'Kentucky') THEN 'Southeast'
      WHEN state IN ('Texas', 'Oklahoma', 'New Mexico', 'Arizona') THEN 'Southwest'
      WHEN state IN ('California', 'Oregon', 'Washington', 'Nevada', 'Idaho') THEN 'West Coast'
      ELSE 'Other'
    END as region,
    COUNT(DISTINCT state) as state_count,
    SUM(balance_in_dollars) as total_balance,
    AVG(percent_of_gf) as avg_percent_of_gf
  FROM mimi_ws_1.nasbo.rainy_day_fund_balances, latest_year
  WHERE year = latest_year.max_year
  GROUP BY 1
)

-- Final output with key metrics
SELECT 
  region,
  state_count,
  total_balance,
  ROUND(total_balance / state_count, 2) as avg_balance_per_state,
  ROUND(avg_percent_of_gf, 2) as avg_percent_of_gf,
  ROUND(100.0 * total_balance / SUM(total_balance) OVER(), 2) as pct_of_national_total
FROM regional_funds
WHERE region != 'Other'
ORDER BY total_balance DESC;

/* How it works:
1. The query first identifies the most recent complete year of data
2. It then maps states to geographic regions using CASE statements
3. Calculates key metrics by region: total balance, average percentage of general fund, etc.
4. Provides a final summary showing the distribution of rainy day funds across regions

Assumptions and limitations:
- Uses simplified regional definitions that may not match all standard geographic groupings
- Excludes territories and DC (grouped as 'Other')
- Assumes current year data is complete and accurate
- Does not account for regional economic differences or cost of living adjustments

Possible extensions:
1. Add year-over-year regional trend analysis
2. Include regional economic indicators (GDP, population) for per-capita analysis
3. Create regional risk scores based on balance distributions
4. Add seasonal patterns analysis by region
5. Include regional economic diversity metrics for context
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:39:29.156742
    - Additional Notes: Query provides geographic concentration insights of rainy day funds across major U.S. regions. Note that Alaska and Hawaii are currently grouped into 'Other' category, which might need adjustment if analyzing these states specifically. Regional groupings are simplified and may need to be updated based on specific analytical needs.
    
    */