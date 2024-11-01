-- Title: Healthcare Resource Accessibility and Transportation Barriers Analysis 2016

-- Business Purpose:
-- This analysis identifies counties with significant transportation and housing challenges
-- that could impact healthcare access and health outcomes. It helps:
-- - Healthcare organizations prioritize mobile health services and transportation assistance
-- - Public health planners identify areas needing improved healthcare infrastructure
-- - Health systems evaluate locations for new facilities or outreach programs

-- Main Query
WITH TransportationRisk AS (
  SELECT 
    state,
    county,
    e_totpop,
    ep_noveh AS pct_no_vehicle,
    ep_mobile AS pct_mobile_homes,
    rpl_theme4 AS transport_housing_percentile,
    ep_age65 AS pct_elderly,
    ep_disabl AS pct_disabled,
    ep_uninsur AS pct_uninsured
  FROM mimi_ws_1.cdc.svi_county_y2016
  WHERE e_totpop >= 1000  -- Focus on counties with meaningful population size
)

SELECT 
  state,
  county,
  e_totpop AS population,
  ROUND(pct_no_vehicle, 1) AS pct_households_no_vehicle,
  ROUND(pct_mobile_homes, 1) AS pct_mobile_homes,
  ROUND(transport_housing_percentile, 2) AS transport_vulnerability_score,
  ROUND(pct_elderly, 1) AS pct_elderly,
  ROUND(pct_disabled, 1) AS pct_disabled,
  ROUND(pct_uninsured, 1) AS pct_uninsured,
  -- Classify counties into risk categories
  CASE 
    WHEN pct_no_vehicle >= 10 AND transport_housing_percentile >= 0.75 THEN 'High Risk'
    WHEN pct_no_vehicle >= 5 AND transport_housing_percentile >= 0.5 THEN 'Medium Risk'
    ELSE 'Lower Risk'
  END AS access_risk_category
FROM TransportationRisk
WHERE pct_no_vehicle > 0  -- Exclude counties with missing data
ORDER BY pct_no_vehicle DESC, transport_housing_percentile DESC
LIMIT 100;

-- How the Query Works:
-- 1. Creates a CTE focusing on transportation and housing vulnerability metrics
-- 2. Filters for counties with meaningful population size
-- 3. Calculates key percentages and risk scores
-- 4. Classifies counties into risk categories based on vehicle access and overall transportation vulnerability
-- 5. Returns top 100 highest-risk counties

-- Assumptions and Limitations:
-- - Assumes counties with population < 1000 are less relevant for analysis
-- - Risk categorization thresholds are somewhat arbitrary and may need adjustment
-- - Does not account for public transportation availability
-- - County-level analysis may mask significant within-county variations

-- Possible Extensions:
-- 1. Add geographic clustering to identify regional patterns
-- 2. Include correlation with health outcomes data
-- 3. Compare rural vs urban counties
-- 4. Add temporal analysis if combining with other years
-- 5. Include cost analysis for potential mobile health service routes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:22:09.876124
    - Additional Notes: This analysis focuses specifically on transportation and housing barriers to healthcare access, with particular emphasis on vehicle availability and housing type. The query includes population filters that may need adjustment based on specific use cases, and the risk categorization thresholds (10% and 5% for vehicle access) should be validated against local contexts.
    
    */