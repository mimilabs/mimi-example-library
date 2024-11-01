-- preferred_city_state_grouping.sql

-- Business Purpose: This query analyzes the concentration of census tracts across USPS preferred 
-- cities and states, helping understand geographic service patterns and administrative boundaries.
-- This information is valuable for:
-- - Healthcare network planning across administrative regions
-- - Understanding market penetration opportunities 
-- - Identifying areas where service delivery may need special coordination

WITH recent_data AS (
    -- Get most recent tract-zip mapping data
    SELECT *
    FROM mimi_ws_1.huduser.tract_to_zip 
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.huduser.tract_to_zip)
),

city_state_metrics AS (
    -- Calculate summary metrics for each preferred city-state combination
    SELECT 
        usps_zip_pref_city,
        usps_zip_pref_state,
        COUNT(DISTINCT zip) as zip_count,
        COUNT(DISTINCT tract) as tract_count,
        ROUND(AVG(res_ratio * 100), 2) as avg_residential_coverage,
        COUNT(DISTINCT CASE WHEN res_ratio > 0.5 THEN tract END) as high_coverage_tracts
    FROM recent_data
    GROUP BY 1, 2
)

-- Generate final analytical output
SELECT 
    usps_zip_pref_city,
    usps_zip_pref_state,
    zip_count,
    tract_count,
    avg_residential_coverage,
    high_coverage_tracts,
    ROUND(high_coverage_tracts * 100.0 / tract_count, 1) as pct_high_coverage_tracts
FROM city_state_metrics
WHERE zip_count > 1  -- Focus on multi-ZIP areas
ORDER BY tract_count DESC
LIMIT 50;

-- How it works:
-- 1. First CTE gets the most recent data snapshot
-- 2. Second CTE calculates key metrics per city-state
-- 3. Final query formats and filters results for analysis

-- Assumptions and Limitations:
-- - Uses only the most recent data snapshot
-- - Defines "high coverage" as res_ratio > 0.5
-- - Limited to top 50 areas by tract count
-- - Focuses on areas with multiple ZIP codes

-- Possible Extensions:
-- 1. Add year-over-year comparison of coverage patterns
-- 2. Include business ratio analysis for commercial centers
-- 3. Add population data to weight the importance of coverage
-- 4. Create geographic clusters of similar city-state patterns
-- 5. Incorporate distance/proximity analysis between cities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:41:18.461786
    - Additional Notes: Query focuses on geographic administrative patterns by analyzing USPS preferred city coverage. Results are particularly useful for regional planning and service area analysis. Note that the 0.5 threshold for high coverage tracts is a configurable assumption that may need adjustment based on specific business needs.
    
    */