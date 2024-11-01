-- Title: Geographic Market Segmentation for Healthcare Service Planning
-- Business Purpose:
-- This query helps healthcare organizations identify potential service areas by:
-- - Analyzing county-level market segments within states
-- - Understanding metropolitan vs rural coverage through CBSA designations
-- - Supporting strategic planning for service expansion or market assessment
-- - Enabling population health management initiatives

WITH CountyClassification AS (
    -- Classify counties based on CBSA presence
    SELECT 
        state_name,
        COUNT(DISTINCT fipscounty) as total_counties,
        COUNT(DISTINCT CASE WHEN fy2023cbsa IS NOT NULL THEN fipscounty END) as metro_counties,
        COUNT(DISTINCT CASE WHEN fy2023cbsa IS NULL THEN fipscounty END) as rural_counties
    FROM mimi_ws_1.nber.ssa2fips_state_and_county
    GROUP BY state_name
),
MarketMetrics AS (
    -- Calculate market composition metrics
    SELECT 
        state_name,
        total_counties,
        metro_counties,
        rural_counties,
        ROUND(100.0 * metro_counties / total_counties, 1) as metro_county_pct,
        ROUND(100.0 * rural_counties / total_counties, 1) as rural_county_pct
    FROM CountyClassification
)

SELECT 
    state_name,
    total_counties,
    metro_counties,
    rural_counties,
    metro_county_pct || '%' as metro_coverage,
    rural_county_pct || '%' as rural_coverage
FROM MarketMetrics
WHERE total_counties >= 5  -- Focus on states with meaningful county counts
ORDER BY total_counties DESC, metro_county_pct DESC;

-- How this query works:
-- 1. First CTE groups counties by state and counts metro vs rural areas
-- 2. Second CTE calculates percentage distributions
-- 3. Final select formats results for business analysis
-- 4. Filter ensures meaningful sample sizes
-- 5. Ordering highlights largest markets first

-- Assumptions and Limitations:
-- - Counties without CBSA codes are considered rural
-- - Current analysis uses FY2023 CBSA definitions
-- - Does not account for population density or actual market size
-- - Equal weight given to all counties regardless of size

-- Possible Extensions:
-- 1. Add population weighting when available
-- 2. Include market size categories based on CBSA classifications
-- 3. Compare historical CBSA changes over time
-- 4. Add geographic regions for broader market analysis
-- 5. Include specific healthcare facility counts per county

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:54:48.935096
    - Additional Notes: Query provides state-level healthcare market analysis based on metropolitan vs rural county distribution. Note that this is a high-level geographic segmentation and should be supplemented with population data for more accurate market sizing. Best used for initial market assessment and strategic planning phases.
    
    */