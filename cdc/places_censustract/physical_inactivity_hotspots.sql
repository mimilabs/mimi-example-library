-- Title: Physical Activity and Chronic Disease Prevention Analysis

-- Business Purpose: 
-- This query analyzes physical activity levels across census tracts to identify areas
-- where targeted interventions could help prevent chronic diseases. Understanding
-- physical activity patterns can inform public health strategies, urban planning,
-- and community wellness initiatives.

-- Main Query
WITH physical_activity AS (
    -- Get physical activity data by census tract
    SELECT 
        state_desc,
        county_name,
        locationid AS tract_fips,
        data_value AS physical_inactivity_pct,
        total_population,
        geolocation
    FROM mimi_ws_1.cdc.places_censustract
    WHERE year = 2021
    AND measure_id = 'PA'  -- Physical inactivity
    AND data_value_type = 'Age-adjusted prevalence'
),

high_inactivity_tracts AS (
    -- Identify tracts with concerning physical inactivity levels
    SELECT 
        state_desc,
        county_name,
        tract_fips,
        physical_inactivity_pct,
        total_population,
        geolocation
    FROM physical_activity
    WHERE physical_inactivity_pct > 30  -- Focus on areas with >30% physical inactivity
)

-- Final result set showing priority areas for intervention
SELECT 
    state_desc,
    county_name,
    COUNT(*) as high_inactivity_tract_count,
    SUM(total_population) as affected_population,
    ROUND(AVG(physical_inactivity_pct), 1) as avg_inactivity_pct
FROM high_inactivity_tracts
GROUP BY state_desc, county_name
HAVING COUNT(*) >= 5  -- Focus on counties with multiple affected tracts
ORDER BY affected_population DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE extracts physical inactivity data for all census tracts
-- 2. Second CTE identifies tracts with concerning levels of physical inactivity
-- 3. Final query aggregates results to county level to identify priority areas
-- 4. Results show counties with multiple high-risk tracts and large affected populations

-- Assumptions and Limitations:
-- - Uses 30% physical inactivity as threshold for concern (adjustable based on needs)
-- - Focuses on 2021 data only
-- - Assumes age-adjusted prevalence is most appropriate measure
-- - Does not account for seasonal variations in physical activity
-- - May not reflect recent changes in community infrastructure

-- Possible Extensions:
-- 1. Add correlation analysis with other health outcomes (diabetes, obesity)
-- 2. Include demographic factors to identify disparities
-- 3. Compare with previous years to show trends
-- 4. Add proximity analysis to parks and recreation facilities
-- 5. Include weather/climate data to understand environmental factors
-- 6. Calculate economic impact of physical inactivity by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:35:59.272316
    - Additional Notes: Query identifies geographic clusters of high physical inactivity, focusing on census tracts where more than 30% of the population is physically inactive. Results prioritize counties with multiple affected tracts and large populations, making it useful for targeting public health interventions and community wellness programs.
    
    */