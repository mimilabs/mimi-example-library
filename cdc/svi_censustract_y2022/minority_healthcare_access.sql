-- svi_minority_healthcare_needs.sql

-- Purpose: Analyze healthcare needs in minority communities by combining SVI minority data 
-- with key health vulnerability indicators. This helps healthcare organizations:
-- - Identify areas for culturally-sensitive healthcare services
-- - Target outreach and preventive care programs
-- - Allocate resources for translation/interpretation services
-- - Plan facilities and services in high-need minority communities

-- Main Query
WITH minority_metrics AS (
  SELECT 
    state,
    county,
    location,
    -- Population metrics
    e_totpop as total_population,
    e_minrty as minority_population,
    ep_minrty as minority_percentage,
    
    -- Healthcare vulnerability indicators 
    ep_uninsur as uninsured_rate,
    ep_disabl as disability_rate,
    ep_limeng as limited_english_rate,
    
    -- Overall vulnerability metrics
    rpl_themes as overall_vulnerability_percentile,
    f_total as total_vulnerability_flags

  FROM mimi_ws_1.cdc.svi_censustract_y2022
  WHERE e_totpop > 0  -- Exclude unpopulated areas
)

SELECT
  state,
  county,
  -- Calculate composite scores
  ROUND(AVG(minority_percentage),1) as avg_minority_pct,
  ROUND(AVG(uninsured_rate),1) as avg_uninsured_pct,
  ROUND(AVG(disability_rate),1) as avg_disability_pct,
  ROUND(AVG(limited_english_rate),1) as avg_limited_english_pct,
  
  -- Population totals
  SUM(total_population) as total_pop,
  SUM(minority_population) as minority_pop,
  
  -- Risk categorization
  CASE 
    WHEN AVG(overall_vulnerability_percentile) >= 0.75 THEN 'High Risk'
    WHEN AVG(overall_vulnerability_percentile) >= 0.50 THEN 'Medium Risk'
    ELSE 'Lower Risk'
  END as vulnerability_category,
  
  -- Count of census tracts
  COUNT(*) as tract_count

FROM minority_metrics
GROUP BY state, county
HAVING SUM(total_population) > 10000  -- Focus on larger population areas
ORDER BY avg_minority_pct DESC, total_pop DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE with key minority and healthcare metrics at census tract level
-- 2. Aggregates to county level with averages and totals
-- 3. Categorizes counties by overall vulnerability
-- 4. Filters for meaningful population size
-- 5. Ranks by minority percentage and population size

-- Assumptions and limitations:
-- - Focuses on county-level analysis (may miss neighborhood variations)
-- - Assumes current census estimates are accurate
-- - Does not account for seasonal population changes
-- - May not capture all cultural and linguistic nuances

-- Possible extensions:
-- 1. Add time-based trends by incorporating historical data
-- 2. Break down by specific minority groups (Hispanic, Asian, etc.)
-- 3. Include proximity to healthcare facilities
-- 4. Add economic indicators for healthcare affordability
-- 5. Create geographic clusters of similar communities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:10:29.584958
    - Additional Notes: Query identifies counties with high minority populations and healthcare vulnerability indicators, useful for healthcare resource planning and culturally sensitive service deployment. Performance may be impacted when analyzing large states due to census tract aggregation.
    
    */