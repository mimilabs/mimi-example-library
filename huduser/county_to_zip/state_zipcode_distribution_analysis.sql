-- Title: ZIP Code Coverage Analysis by County and State
-- 
-- Business Purpose:
-- Analyzes ZIP code coverage patterns across counties and states to identify:
-- 1. Areas with high residential vs business address concentration
-- 2. Potential service coverage gaps or opportunities 
-- 3. Market penetration planning based on address type distribution
--
-- This analysis helps businesses make informed decisions about:
-- - Market expansion strategies
-- - Resource allocation
-- - Service coverage optimization
-- - Customer segmentation by geography

WITH latest_data AS (
    -- Get the most recent data snapshot
    SELECT DISTINCT mimi_src_file_date
    FROM mimi_ws_1.huduser.county_to_zip 
    ORDER BY mimi_src_file_date DESC
    LIMIT 1
),

county_summary AS (
    -- Aggregate metrics at county level
    SELECT 
        county,
        usps_zip_pref_state AS state,
        COUNT(DISTINCT zip) AS num_zips,
        AVG(res_ratio) AS avg_residential_ratio,
        AVG(bus_ratio) AS avg_business_ratio,
        SUM(CASE WHEN res_ratio > bus_ratio THEN 1 ELSE 0 END) AS residential_dominant_zips
    FROM mimi_ws_1.huduser.county_to_zip c
    WHERE mimi_src_file_date = (SELECT mimi_src_file_date FROM latest_data)
    GROUP BY county, usps_zip_pref_state
)

SELECT 
    state,
    COUNT(DISTINCT county) AS total_counties,
    SUM(num_zips) AS total_zips,
    ROUND(AVG(num_zips), 1) AS avg_zips_per_county,
    ROUND(AVG(avg_residential_ratio) * 100, 1) AS avg_residential_pct,
    ROUND(AVG(avg_business_ratio) * 100, 1) AS avg_business_pct,
    SUM(residential_dominant_zips) AS total_residential_dominant_zips
FROM county_summary
GROUP BY state
HAVING total_counties >= 5  -- Focus on states with meaningful county counts
ORDER BY total_zips DESC
LIMIT 20;

-- How it works:
-- 1. Creates a CTE to identify the most recent data snapshot
-- 2. Aggregates ZIP code metrics at the county level
-- 3. Summarizes patterns at the state level
-- 4. Filters for states with significant county presence
-- 5. Orders results by total ZIP coverage

-- Assumptions and Limitations:
-- - Uses only the most recent data snapshot
-- - Assumes ZIP codes and county relationships are relatively stable
-- - Does not account for seasonal variations in address patterns
-- - May not reflect recent municipal boundary changes

-- Possible Extensions:
-- 1. Add year-over-year comparison of ZIP coverage changes
-- 2. Include population density correlation analysis
-- 3. Add geographic clustering analysis
-- 4. Incorporate demographic data for market sizing
-- 5. Add seasonal trending analysis for tourist areas
-- 6. Include economic indicators for market potential assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:17:56.934958
    - Additional Notes: This query analyzes ZIP code distribution patterns across states and provides insights into residential vs. business address concentrations. Best used for strategic planning and market analysis. Note that the 5-county minimum threshold may need adjustment for smaller states or specific use cases.
    
    */