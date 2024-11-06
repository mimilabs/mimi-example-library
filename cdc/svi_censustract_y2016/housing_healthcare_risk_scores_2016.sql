-- Housing Instability and Healthcare Risk by Census Tract - 2016
--
-- Business Purpose:
-- This analysis identifies census tracts where housing instability intersects with healthcare needs,
-- helping healthcare organizations target interventions for populations at risk of poor health outcomes
-- due to unstable living conditions. Housing instability is a key social determinant of health that
-- can significantly impact healthcare access and outcomes.

WITH housing_risk_factors AS (
  -- Calculate composite housing risk score based on key housing instability indicators
  SELECT 
    state,
    county,
    location,
    e_totpop,
    ep_crowd AS crowding_pct,
    ep_mobile AS mobile_homes_pct, 
    ep_munit AS multiunit_pct,
    ep_noveh AS no_vehicle_pct,
    -- Create weighted housing risk score
    (COALESCE(ep_crowd, 0) * 0.3 + 
     COALESCE(ep_mobile, 0) * 0.2 +
     COALESCE(ep_munit, 0) * 0.2 + 
     COALESCE(ep_noveh, 0) * 0.3) AS housing_risk_score,
    -- Include healthcare vulnerability indicators  
    ep_uninsur AS uninsured_pct,
    ep_disabl AS disability_pct
  FROM mimi_ws_1.cdc.svi_censustract_y2016
  WHERE e_totpop >= 100  -- Filter out very small populations
)

SELECT
  state,
  county, 
  location,
  e_totpop AS population,
  ROUND(housing_risk_score, 2) AS housing_risk_score,
  ROUND(crowding_pct, 1) AS pct_crowded_housing,
  ROUND(mobile_homes_pct, 1) AS pct_mobile_homes,
  ROUND(multiunit_pct, 1) AS pct_multiunit_housing,
  ROUND(no_vehicle_pct, 1) AS pct_no_vehicle,
  ROUND(uninsured_pct, 1) AS pct_uninsured,
  ROUND(disability_pct, 1) AS pct_disabled
FROM housing_risk_factors
WHERE housing_risk_score >= 50  -- Focus on highest risk areas
ORDER BY housing_risk_score DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE that calculates a composite housing risk score using weighted percentages of key housing instability factors
-- 2. Includes related healthcare vulnerability metrics (uninsured and disability rates)
-- 3. Filters for census tracts with meaningful population sizes
-- 4. Returns the top 100 highest risk areas with rounded percentages for easy interpretation

-- Assumptions and Limitations:
-- - Weights in the composite score are simplified estimates of relative importance
-- - Small population areas are excluded as percentages may be less reliable
-- - Does not account for regional variations in housing patterns
-- - Point-in-time analysis for 2016 only

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Include cost burden data if available (housing costs > 30% of income)
-- 3. Compare against healthcare facility locations or utilization data
-- 4. Create risk tiers rather than just top 100
-- 5. Add trend analysis if combining with other years' data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:05:40.353633
    - Additional Notes: The composite risk score weighting (0.3 for crowding and no vehicle, 0.2 for mobile and multiunit housing) prioritizes factors most directly linked to healthcare access barriers. Consider adjusting weights based on specific regional priorities or evidence-based research.
    
    */