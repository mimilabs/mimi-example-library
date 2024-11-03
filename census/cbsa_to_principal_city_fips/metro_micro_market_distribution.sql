-- Metropolitan vs. Micropolitan Service Areas Market Size Analysis
--
-- Business Purpose:
-- Analyzes the distribution and characteristics of metropolitan vs. micropolitan areas
-- to help businesses make informed decisions about market entry and resource allocation.
-- This insight is valuable for:
-- - Healthcare network planning
-- - Retail expansion strategies
-- - Population health management initiatives
-- - Market size assessment

WITH area_type_stats AS (
    -- Calculate key metrics by statistical area type
    SELECT 
        metropolitan_micropolitan_statistical_area as area_type,
        COUNT(DISTINCT cbsa_code) as total_areas,
        COUNT(DISTINCT principal_city_name) as total_principal_cities,
        COUNT(DISTINCT fips_state_code) as states_covered,
        ROUND(COUNT(DISTINCT principal_city_name) * 1.0 / 
              COUNT(DISTINCT cbsa_code), 2) as avg_cities_per_area
    FROM mimi_ws_1.census.cbsa_to_principal_city_fips
    GROUP BY metropolitan_micropolitan_statistical_area
)

SELECT 
    area_type,
    total_areas,
    total_principal_cities,
    states_covered,
    avg_cities_per_area,
    -- Calculate percentage distribution of areas
    ROUND(total_areas * 100.0 / SUM(total_areas) OVER(), 1) as pct_of_total_areas
FROM area_type_stats
ORDER BY total_areas DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate statistics by metropolitan/micropolitan designation
-- 2. Calculates total areas, principal cities, state coverage, and averages
-- 3. Adds percentage distribution in the final output
-- 4. Orders results by total number of areas to highlight the larger category first

-- Assumptions and Limitations:
-- - Assumes current CBSA definitions are up-to-date
-- - Does not account for population size differences
-- - Treats all principal cities equally regardless of economic importance
-- - Based on geographic boundaries, not economic activity levels

-- Possible Extensions:
-- 1. Add time-based trend analysis using mimi_src_file_date
-- 2. Include population data to weight the analysis
-- 3. Add regional groupings (Northeast, South, etc.)
-- 4. Compare year-over-year changes in CBSA designations
-- 5. Include economic indicators to assess market potential

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:30:07.671032
    - Additional Notes: The query provides a high-level market size comparison between metropolitan and micropolitan areas, useful for initial market assessment. Note that results are based purely on geographic classifications without economic indicators, which may need to be considered for detailed market analysis.
    
    */