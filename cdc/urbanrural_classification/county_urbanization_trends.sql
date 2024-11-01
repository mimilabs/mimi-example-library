-- Urban-Rural Trend Analysis for County Health Planning
--
-- Business Purpose: 
-- Analyze changes in urban-rural classification of counties over time (1990-2013)
-- to identify areas experiencing significant urbanization or maintaining rural status.
-- This insight helps healthcare organizations and policymakers:
-- 1. Plan long-term healthcare facility investments
-- 2. Understand demographic shifts affecting healthcare needs
-- 3. Target interventions for counties with consistent rural classification

SELECT 
    state_abr,
    county_name,
    -- Create classification change indicators
    CASE 
        WHEN 2013_code = 1990based_code THEN 'Stable'
        WHEN 2013_code < 1990based_code THEN 'More Urban'
        WHEN 2013_code > 1990based_code THEN 'More Rural'
        ELSE 'Unknown'
    END as urbanization_trend,
    -- Classify current status
    CASE 
        WHEN 2013_code IN (1,2) THEN 'Major Metro'
        WHEN 2013_code IN (3,4) THEN 'Metro'
        ELSE 'Rural'
    END as current_status,
    -- Population metrics
    county_2012_pop as current_population,
    cbsa_2012_pop as metro_area_population,
    -- Original classification codes for reference
    1990based_code as classification_1990,
    2013_code as classification_2013
FROM mimi_ws_1.cdc.urbanrural_classification
WHERE 
    -- Focus on counties with valid classification data
    1990based_code IS NOT NULL 
    AND 2013_code IS NOT NULL
ORDER BY 
    state_abr, 
    county_2012_pop DESC;

-- How this works:
-- 1. Compares 1990 and 2013 classifications to identify trends
-- 2. Groups counties into simplified categories for easier analysis
-- 3. Includes population data to understand the scale of each county
-- 4. Orders results by state and population for logical review

-- Assumptions and Limitations:
-- 1. Missing classification codes are excluded
-- 2. Assumes linear progression between 1990 and 2013
-- 3. Does not account for intermediate changes in 2006
-- 4. Population data is from 2012 only

-- Possible Extensions:
-- 1. Add percentage calculations for population distribution
-- 2. Include state-level summaries of urbanization trends
-- 3. Incorporate 2006 data for more detailed trend analysis
-- 4. Add filters for specific population thresholds
-- 5. Compare against healthcare facility locations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:22:24.802431
    - Additional Notes: Query focuses on long-term urbanization patterns (1990-2013) and classifies counties into three trend categories (Stable, More Urban, More Rural). Population data from 2012 provides context for the scale of demographic changes. Best used for initial assessment of regional development patterns and healthcare planning needs.
    
    */