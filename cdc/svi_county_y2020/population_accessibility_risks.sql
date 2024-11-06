-- Title: Population Accessibility Analysis for Emergency Planning using SVI 2020
-- 
-- Business Purpose:
-- This query analyzes county-level population accessibility metrics combining daytime population,
-- transportation access, and language barriers to help emergency planners identify areas where 
-- reaching and communicating with residents during disasters may be challenging.
-- The insights support emergency response planning, public health outreach, and resource allocation.

WITH ranked_counties AS (
  SELECT 
    state,
    county,
    e_daypop, -- Daytime population 
    e_totpop, -- Total residential population
    ep_limeng, -- % limited English
    ep_noveh, -- % no vehicle
    
    -- Calculate accessibility risk score
    (COALESCE(ep_limeng, 0) + COALESCE(ep_noveh, 0))/2 as accessibility_risk_score,
    
    -- Calculate population fluctuation ratio
    CASE 
      WHEN e_totpop > 0 THEN (e_daypop::FLOAT / e_totpop) 
      ELSE NULL 
    END as daytime_population_ratio

  FROM mimi_ws_1.cdc.svi_county_y2020
  WHERE e_totpop > 0  -- Filter out invalid population entries
)

SELECT
  state,
  county,
  ROUND(e_daypop::NUMERIC, 0) as daytime_population,
  ROUND(e_totpop::NUMERIC, 0) as total_population,
  ROUND(accessibility_risk_score::NUMERIC, 2) as accessibility_risk_score,
  ROUND(daytime_population_ratio::NUMERIC, 2) as daytime_population_ratio,
  
  -- Classify counties by accessibility challenges
  CASE
    WHEN accessibility_risk_score >= 75 THEN 'High Risk'
    WHEN accessibility_risk_score >= 50 THEN 'Medium Risk'
    ELSE 'Low Risk'
  END as accessibility_risk_category,
  
  -- Flag significant population fluctuations
  CASE
    WHEN daytime_population_ratio >= 1.5 THEN 'Significant Daytime Influx'
    WHEN daytime_population_ratio <= 0.7 THEN 'Significant Daytime Outflow'
    ELSE 'Stable Population'
  END as population_pattern

FROM ranked_counties
ORDER BY accessibility_risk_score DESC, daytime_population_ratio DESC;

-- How this works:
-- 1. Creates base table with key population and accessibility metrics
-- 2. Calculates composite accessibility risk score using language and transportation barriers
-- 3. Determines population fluctuation patterns using daytime vs total population
-- 4. Classifies counties by risk levels and population patterns
-- 5. Returns ordered results prioritizing highest risk areas

-- Assumptions & Limitations:
-- - Assumes current daytime population estimates are representative of typical patterns
-- - Limited to language and vehicle access as key accessibility barriers
-- - Does not account for seasonal population variations
-- - Missing data is treated as 0 in composite score calculations

-- Possible Extensions:
-- 1. Add geographic clustering to identify regional patterns
-- 2. Incorporate distance to emergency services/hospitals
-- 3. Add temporal analysis comparing multiple years
-- 4. Include weather/disaster risk factors
-- 5. Create population-weighted risk scores

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:16:43.705346
    - Additional Notes: Query provides composite accessibility risk analysis at county level using both static (language, transportation) and dynamic (daytime vs residential population) factors. Note that the accessibility_risk_score calculation treats NULL values as 0, which may understate risks in counties with incomplete data.
    
    */