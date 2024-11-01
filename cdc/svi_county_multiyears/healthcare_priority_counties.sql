-- Regional Healthcare Resource Allocation Prioritization
-- Business Purpose: 
-- This query helps healthcare organizations and policymakers identify high-priority regions
-- for healthcare resource allocation by combining multiple vulnerability factors.
-- The analysis supports:
-- - Strategic planning for new healthcare facility locations
-- - Resource distribution during public health emergencies
-- - Population health management program targeting
-- - Community health needs assessment

WITH RankedCounties AS (
  -- Get the most recent year's data for each county
  SELECT 
    state_abbr,
    county_name,
    fips,
    rpl_socioeconomic,
    rpl_householdcomp,
    rpl_minoritystatus,
    rpl_housingtransport,
    svi,
    year,
    -- Calculate weighted vulnerability score prioritizing healthcare-relevant factors
    (rpl_socioeconomic * 0.35 + 
     rpl_householdcomp * 0.35 + 
     rpl_minoritystatus * 0.15 + 
     rpl_housingtransport * 0.15) as healthcare_priority_score
  FROM mimi_ws_1.cdc.svi_county_multiyears
  WHERE year = (SELECT MAX(year) FROM mimi_ws_1.cdc.svi_county_multiyears)
)

SELECT
  state_abbr,
  county_name,
  healthcare_priority_score,
  rpl_socioeconomic as socioeconomic_vulnerability,
  rpl_householdcomp as household_vulnerability,
  CASE 
    WHEN healthcare_priority_score >= 0.75 THEN 'High Priority'
    WHEN healthcare_priority_score >= 0.5 THEN 'Medium Priority'
    ELSE 'Lower Priority'
  END as priority_category
FROM RankedCounties
WHERE healthcare_priority_score >= 0.5
ORDER BY healthcare_priority_score DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE with the most recent year's data
-- 2. Calculates a weighted healthcare priority score emphasizing socioeconomic and household factors
-- 3. Categorizes counties into priority levels
-- 4. Returns top 100 highest priority counties

-- Assumptions and Limitations:
-- - Assumes current year data is most relevant for planning
-- - Weighted scoring model gives higher importance to socioeconomic and household composition factors
-- - Limited to county-level analysis, may miss intra-county variations
-- - Does not account for existing healthcare infrastructure

-- Possible Extensions:
-- 1. Add year-over-year change analysis to identify trending vulnerabilities
-- 2. Include population size to weight priorities by impact potential
-- 3. Add state-level aggregations for regional planning
-- 4. Incorporate additional healthcare facility density data
-- 5. Create geographic clusters of high-priority counties for regional planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:37:37.488440
    - Additional Notes: The weighted scoring system (35% socioeconomic, 35% household, 15% minority status, 15% housing/transport) is configured for healthcare resource planning but may need adjustment based on specific organizational priorities or regional factors.
    
    */