-- Title: Healthcare Access Risk Analysis by Census Tract (2010)
-- Business Purpose:
-- This query identifies census tracts with potential healthcare access barriers
-- by analyzing vehicle access, age vulnerability, and limited English proficiency.
-- These factors are critical for healthcare organizations to:
-- 1. Target mobile health services and transportation assistance programs
-- 2. Plan multilingual healthcare communications
-- 3. Allocate resources for elderly care services

SELECT 
    state_name,
    county,
    location,
    totpop AS total_population,
    -- Calculate percentage of households without vehicles
    ROUND(e_p_noveh * 100, 1) AS pct_no_vehicle,
    -- Calculate percentage of elderly population
    ROUND(p_age65 * 100, 1) AS pct_elderly,
    -- Calculate percentage with limited English
    ROUND(e_p_limeng * 100, 1) AS pct_limited_english,
    -- Create a composite risk score (0-3)
    (CASE WHEN f_pl_noveh = 1 THEN 1 ELSE 0 END +
     CASE WHEN f_pl_age65 = 1 THEN 1 ELSE 0 END +
     CASE WHEN f_pl_limeng = 1 THEN 1 ELSE 0 END) AS access_risk_factors,
    -- Estimated affected population
    ROUND(totpop * (e_p_noveh + p_age65 + e_p_limeng), 0) AS estimated_affected_pop
FROM mimi_ws_1.cdc.svi_censustract_y2010
WHERE totpop > 0  -- Exclude unpopulated tracts
  AND e_p_noveh IS NOT NULL
  AND p_age65 IS NOT NULL
  AND e_p_limeng IS NOT NULL
ORDER BY 
    access_risk_factors DESC,
    estimated_affected_pop DESC
LIMIT 1000;

-- How the Query Works:
-- 1. Selects relevant geographic identifiers and population data
-- 2. Calculates percentages for key healthcare access barriers
-- 3. Creates a simple risk score based on 90th percentile flags
-- 4. Estimates affected population using combined risk factors
-- 5. Orders results by risk factors and population impact

-- Assumptions and Limitations:
-- 1. Equal weighting of risk factors in the composite score
-- 2. Does not account for proximity to healthcare facilities
-- 3. Population estimates are simplified and may overlap
-- 4. Current year data may differ significantly from 2010

-- Possible Extensions:
-- 1. Add distance to nearest hospital/clinic
-- 2. Include income/poverty factors for financial barriers
-- 3. Create risk tiers with weighted factors
-- 4. Compare urban vs rural access patterns
-- 5. Correlate with health outcomes data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:15:24.738565
    - Additional Notes: Query focuses on three key access barriers (vehicle access, elderly population, English proficiency) and provides a simplified risk scoring system. Results are limited to top 1000 tracts for performance. Population estimates are approximations based on combined risk factors and may include overlapping populations.
    
    */