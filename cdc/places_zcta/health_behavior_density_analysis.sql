-- Title: Health Behavior Risk Analysis by Population Density
-- Business Purpose: Identify correlations between population density and high-risk health behaviors 
-- to help healthcare organizations target interventions and resource allocation in densely populated areas.

WITH health_behaviors AS (
    -- Filter to focus on key behavioral risk measures from latest year
    SELECT 
        location_name as zcta,
        measure,
        data_value,
        total_population,
        ROUND(total_population / 
            REGEXP_REPLACE(SUBSTRING(geolocation, 7, LENGTH(geolocation)-8), '[^0-9.]', ''), 2) 
            as pop_density
    FROM mimi_ws_1.cdc.places_zcta
    WHERE year = 2023
    AND category = 'Health Risk Behaviors'
    AND data_value IS NOT NULL
    AND total_population > 1000  -- Filter out very small areas
),

ranked_areas AS (
    -- Rank ZCTAs by population density into quartiles
    SELECT 
        zcta,
        measure,
        data_value,
        pop_density,
        NTILE(4) OVER (ORDER BY pop_density) as density_quartile
    FROM health_behaviors
)

-- Calculate average risk behaviors by population density quartile
SELECT 
    density_quartile,
    measure,
    ROUND(AVG(data_value), 1) as avg_prevalence,
    COUNT(DISTINCT zcta) as num_zctas,
    ROUND(MIN(pop_density), 1) as min_density,
    ROUND(MAX(pop_density), 1) as max_density
FROM ranked_areas
GROUP BY density_quartile, measure
ORDER BY measure, density_quartile;

-- How this works:
-- 1. Creates a CTE filtering to health risk behaviors and calculating population density
-- 2. Ranks ZCTAs into population density quartiles
-- 3. Aggregates risk behavior prevalence by density quartile
-- 4. Returns averaged results showing relationship between density and behaviors

-- Assumptions and Limitations:
-- - Uses total_population and geolocation for basic density calculation
-- - Excludes ZCTAs with population under 1000 to avoid outliers
-- - Assumes current year data is most relevant
-- - Does not account for geographic or demographic factors beyond density

-- Possible Extensions:
-- 1. Add demographic factors like age distribution or income levels
-- 2. Compare urban vs rural classifications
-- 3. Track changes in behavior patterns over multiple years
-- 4. Include additional health outcomes correlated with behaviors
-- 5. Add statistical significance testing between quartiles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:52:47.661840
    - Additional Notes: The query calculates population density using a simplified approach from geolocation data, which may not be as accurate as using actual area measurements. The quartile analysis provides a high-level view of behavioral trends but should be validated with more detailed geographic analysis for specific interventions.
    
    */