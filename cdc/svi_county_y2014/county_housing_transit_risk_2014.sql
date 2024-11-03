-- housing_transit_vulnerability_2014.sql
--
-- Business Purpose:
-- Analyze counties with high housing and transportation vulnerability to identify areas 
-- where healthcare access may be impacted by infrastructure challenges. This helps 
-- healthcare organizations optimize service delivery locations and transportation 
-- assistance programs.

WITH county_housing_stats AS (
  -- Calculate key housing and transportation metrics by county
  SELECT 
    state,
    county,
    e_totpop AS total_population,
    ep_noveh AS pct_no_vehicle,
    ep_mobile AS pct_mobile_homes,
    ep_munit AS pct_multiunit,
    rpl_theme4 AS housing_transit_percentile,
    ep_uninsur AS pct_uninsured
  FROM mimi_ws_1.cdc.svi_county_y2014
  WHERE e_totpop > 0  -- Exclude counties with no population
),

high_risk_counties AS (
  -- Identify counties in the top quartile of housing/transportation vulnerability
  SELECT 
    state,
    county,
    total_population,
    pct_no_vehicle,
    pct_mobile_homes,
    pct_multiunit,
    pct_uninsured,
    housing_transit_percentile
  FROM county_housing_stats
  WHERE housing_transit_percentile >= 0.75
)

-- Final output with risk categorization
SELECT 
  state,
  county,
  ROUND(total_population, 0) as population,
  ROUND(pct_no_vehicle, 1) as pct_households_no_vehicle,
  ROUND(pct_mobile_homes, 1) as pct_mobile_homes,
  ROUND(pct_multiunit, 1) as pct_multiunit_housing,
  ROUND(pct_uninsured, 1) as pct_uninsured,
  ROUND(housing_transit_percentile * 100, 1) as housing_transit_risk_percentile,
  CASE 
    WHEN pct_no_vehicle >= 15 THEN 'High Transit Need'
    WHEN pct_mobile_homes >= 20 THEN 'High Mobile Home'
    WHEN pct_multiunit >= 30 THEN 'High Density Housing'
    ELSE 'Mixed Risk Factors'
  END as primary_risk_factor
FROM high_risk_counties
ORDER BY housing_transit_percentile DESC, total_population DESC
LIMIT 100;

-- How this works:
-- 1. First CTE gets core housing/transportation metrics by county
-- 2. Second CTE filters to most vulnerable counties (top quartile)
-- 3. Final query adds risk categorization and formats output
--
-- Assumptions and Limitations:
-- - Focuses only on housing/transportation theme of SVI
-- - Uses arbitrary thresholds for risk categorization
-- - Limited to top 100 most vulnerable counties
-- - Does not account for geographic clustering
--
-- Potential Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Include change over time by comparing to other years
-- 3. Cross-reference with healthcare facility locations
-- 4. Add urban/rural classification
-- 5. Incorporate public transportation availability data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:35:46.200411
    - Additional Notes: This query ranks counties by housing and transportation vulnerability, focusing on key metrics like vehicle access, mobile homes, and multi-unit housing density. It's particularly useful for understanding physical and infrastructure barriers to healthcare access at the county level. The 0.75 percentile threshold and top 100 limit can be adjusted based on analysis needs.
    
    */