-- Title: Census Tract Poverty and Housing Cost Analysis (2010)
-- Business Purpose: 
-- This query examines the relationship between poverty rates and housing characteristics
-- at the census tract level to identify areas where affordable housing interventions
-- may be most impactful for vulnerable populations.

WITH housing_metrics AS (
  SELECT 
    state_name,
    county,
    tract,
    e_p_pov as poverty_rate,
    e_p_munit as multi_unit_rate,
    e_p_noveh as no_vehicle_rate,
    totpop,
    e_pci as per_capita_income
  FROM mimi_ws_1.cdc.svi_censustract_y2010
  WHERE e_p_pov > 0 -- Filter out tracts with missing poverty data
),

ranked_tracts AS (
  SELECT 
    state_name,
    county,
    tract,
    poverty_rate,
    multi_unit_rate,
    no_vehicle_rate,
    totpop,
    per_capita_income,
    -- Calculate state-level averages for comparison
    AVG(poverty_rate) OVER (PARTITION BY state_name) as state_avg_poverty,
    AVG(multi_unit_rate) OVER (PARTITION BY state_name) as state_avg_multi_unit
  FROM housing_metrics
)

SELECT 
  state_name,
  county,
  COUNT(tract) as num_tracts,
  ROUND(AVG(poverty_rate) * 100, 1) as avg_poverty_pct,
  ROUND(AVG(multi_unit_rate) * 100, 1) as avg_multi_unit_pct,
  ROUND(AVG(no_vehicle_rate) * 100, 1) as avg_no_vehicle_pct,
  SUM(totpop) as total_population,
  ROUND(AVG(per_capita_income), 0) as avg_per_capita_income,
  -- Calculate number of high-need tracts
  SUM(CASE WHEN poverty_rate > state_avg_poverty 
           AND multi_unit_rate < state_avg_multi_unit THEN 1 ELSE 0 END) as high_need_tracts
FROM ranked_tracts
GROUP BY state_name, county
HAVING SUM(totpop) > 10000 -- Focus on counties with significant population
ORDER BY avg_poverty_pct DESC
LIMIT 50;

-- How it works:
-- 1. Creates a CTE with key housing and poverty metrics at tract level
-- 2. Adds state-level averages for comparison in ranked_tracts CTE
-- 3. Aggregates to county level with calculated metrics
-- 4. Identifies high-need areas where poverty is above state average but multi-unit housing is below average

-- Assumptions and Limitations:
-- - Assumes current poverty rates are meaningful indicators of housing need
-- - Limited to counties with population > 10,000 for statistical significance
-- - Does not account for cost of living differences between areas
-- - Multi-unit housing used as proxy for housing availability/affordability

-- Possible Extensions:
-- 1. Add temporal analysis comparing changes over different census years
-- 2. Include additional housing cost metrics like rent burden or housing cost indices
-- 3. Incorporate proximity to public transportation or job centers
-- 4. Add geographic clustering analysis to identify regional patterns
-- 5. Include correlation analysis with health outcomes or educational attainment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:32:10.473980
    - Additional Notes: Query identifies counties with potential affordable housing needs by comparing poverty rates against multi-unit housing availability. Results are limited to counties with population over 10,000 and focuses on top 50 areas by poverty rate. State-level averages are used as benchmarks for identifying high-need areas.
    
    */