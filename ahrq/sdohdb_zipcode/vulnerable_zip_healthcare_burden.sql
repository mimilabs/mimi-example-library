-- Title: Social Vulnerability and Healthcare Cost Burden Analysis by ZIP Code

-- Business Purpose:
--   Analyze areas where high financial burden for healthcare overlaps with social vulnerability to:
--   1. Identify ZIP codes where residents face both economic strain and high healthcare costs
--   2. Support resource allocation and intervention planning for vulnerable populations
--   3. Guide policy decisions around healthcare affordability initiatives

-- Main Query
WITH healthcare_cost_burden AS (
  SELECT 
    zipcode,
    state,
    acs_median_hh_inc_zc,
    -- High healthcare cost indicators
    acs_pct_owner_hu_cost_50pct_zc AS housing_cost_burden,
    acs_pct_uninsured_below64_zc AS uninsured_rate,
    acs_pct_health_inc_below137_zc AS low_income_healthcare,
    
    -- Social vulnerability markers
    acs_pct_disable_zc AS disability_rate,
    acs_pct_age_above65_zc AS elderly_rate,
    acs_pct_child_disab_zc AS child_disability_rate,
    
    -- Population context
    acs_tot_pop_wt_zc AS total_population,
    year
  FROM mimi_ws_1.ahrq.sdohdb_zipcode
  WHERE year = 2020  -- Using most recent year
)

SELECT 
  state,
  COUNT(DISTINCT zipcode) as vulnerable_zips,
  ROUND(AVG(housing_cost_burden), 1) as avg_housing_cost_burden,
  ROUND(AVG(uninsured_rate), 1) as avg_uninsured_rate,
  ROUND(AVG(disability_rate), 1) as avg_disability_rate,
  ROUND(AVG(elderly_rate), 1) as avg_elderly_rate,
  SUM(total_population) as total_affected_population
FROM healthcare_cost_burden
WHERE 
  -- Define vulnerable areas as those with multiple overlapping challenges
  housing_cost_burden > 25 AND
  uninsured_rate > 15 AND
  (disability_rate > 15 OR elderly_rate > 20)
GROUP BY state
HAVING total_affected_population > 10000
ORDER BY vulnerable_zips DESC
LIMIT 20;

-- How the Query Works:
--   1. Creates a CTE focusing on key healthcare cost and vulnerability metrics
--   2. Filters for areas with significant overlapping challenges
--   3. Aggregates results by state to identify geographic patterns
--   4. Includes population weighting to focus on impact

-- Assumptions and Limitations:
--   1. Uses 2020 data - may not reflect current conditions
--   2. Threshold values (25%, 15%, etc.) are somewhat arbitrary and should be validated
--   3. Does not account for regional cost of living differences
--   4. Missing data points are excluded which could bias results

-- Possible Extensions:
--   1. Add temporal analysis to track changes over multiple years
--   2. Include healthcare facility proximity metrics
--   3. Add racial/ethnic disparity analysis
--   4. Incorporate mental health and substance abuse indicators
--   5. Create risk scores based on multiple weighted factors
--   6. Map results using geographic visualization tools

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:43:00.210210
    - Additional Notes: Query focuses on intersecting financial and social vulnerability metrics at ZIP code level. Thresholds (25% housing cost, 15% uninsured, etc.) may need adjustment based on specific program requirements. Population minimum of 10,000 helps ensure statistical significance but may exclude some rural areas.
    
    */