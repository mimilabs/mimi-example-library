-- state_revenue_volatility.sql
--
-- Business Purpose: 
-- - Analyze year-over-year volatility in state revenue streams
-- - Identify which revenue sources are most stable/volatile
-- - Help states better plan for revenue fluctuations and reserves
--
-- The query calculates year-over-year percentage changes for each revenue source
-- and summarizes volatility metrics to inform risk management strategies

WITH revenue_changes AS (
  -- Calculate year-over-year changes for each revenue stream
  SELECT 
    state,
    fiscal_year,
    -- Calculate % changes for each revenue source
    ((sales - LAG(sales) OVER (PARTITION BY state ORDER BY fiscal_year)) / NULLIF(LAG(sales) OVER (PARTITION BY state ORDER BY fiscal_year), 0) * 100) as sales_yoy_change,
    ((pit - LAG(pit) OVER (PARTITION BY state ORDER BY fiscal_year)) / NULLIF(LAG(pit) OVER (PARTITION BY state ORDER BY fiscal_year), 0) * 100) as pit_yoy_change,
    ((cit - LAG(cit) OVER (PARTITION BY state ORDER BY fiscal_year)) / NULLIF(LAG(cit) OVER (PARTITION BY state ORDER BY fiscal_year), 0) * 100) as cit_yoy_change,
    ((all_other - LAG(all_other) OVER (PARTITION BY state ORDER BY fiscal_year)) / NULLIF(LAG(all_other) OVER (PARTITION BY state ORDER BY fiscal_year), 0) * 100) as other_yoy_change
  FROM mimi_ws_1.nasbo.general_fund_revenue
  WHERE fiscal_year >= 2018  -- Focus on recent years including COVID impact
)

SELECT 
  state,
  -- Calculate volatility metrics for each revenue source
  ROUND(STDDEV(sales_yoy_change), 2) as sales_volatility,
  ROUND(STDDEV(pit_yoy_change), 2) as pit_volatility,
  ROUND(STDDEV(cit_yoy_change), 2) as cit_volatility,
  ROUND(STDDEV(other_yoy_change), 2) as other_volatility,
  -- Calculate average changes
  ROUND(AVG(sales_yoy_change), 2) as avg_sales_change,
  ROUND(AVG(pit_yoy_change), 2) as avg_pit_change,
  ROUND(AVG(cit_yoy_change), 2) as avg_cit_change,
  ROUND(AVG(other_yoy_change), 2) as avg_other_change
FROM revenue_changes
GROUP BY state
-- Focus on states with complete data
HAVING COUNT(*) >= 4
ORDER BY cit_volatility DESC  -- Order by most volatile revenue source

--
-- How it works:
-- 1. Creates CTE to calculate year-over-year percentage changes for each revenue source
-- 2. Uses window functions to compute changes within each state
-- 3. Calculates standard deviation as measure of volatility
-- 4. Computes average changes to show directional trends
--
-- Assumptions & Limitations:
-- - Requires at least 4 years of data for meaningful volatility calculation
-- - Doesn't account for inflation or economic cycles
-- - Extreme events (like COVID) may skew volatility measures
-- - Null handling may affect calculations for states with missing data
--
-- Possible Extensions:
-- 1. Add quartile analysis to identify outlier volatility
-- 2. Include seasonal adjustment factors
-- 3. Compare volatility pre/post major economic events
-- 4. Add regional groupings to identify geographic patterns
-- 5. Incorporate revenue size weights into volatility calculations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:43:17.077338
    - Additional Notes: Query provides risk assessment metrics for state fiscal planning by measuring revenue stream stability. Best used for states with at least 4 consecutive years of data between 2018-present. Standard deviation calculations may be sensitive to outlier years like 2020-2021 due to COVID-19 impact.
    
    */