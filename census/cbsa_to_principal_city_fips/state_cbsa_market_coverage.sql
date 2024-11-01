-- State-Level CBSA Distribution Analysis for Market Coverage Planning
-- Business Purpose: 
-- Analyze the distribution of CBSAs (Core Based Statistical Areas) across states
-- to identify market coverage gaps and opportunities for business expansion.
-- This helps in strategic planning for healthcare networks, retail locations,
-- and service area development.

WITH state_cbsa_stats AS (
    -- Calculate key metrics for each state
    SELECT 
        fips_state_code,
        COUNT(DISTINCT cbsa_code) as total_cbsas,
        COUNT(DISTINCT CASE WHEN metropolitan_micropolitan_statistical_area = 'Metropolitan Statistical Area' 
            THEN cbsa_code END) as metro_areas,
        COUNT(DISTINCT CASE WHEN metropolitan_micropolitan_statistical_area = 'Micropolitan Statistical Area' 
            THEN cbsa_code END) as micro_areas,
        COUNT(DISTINCT principal_city_name) as total_principal_cities
    FROM mimi_ws_1.census.cbsa_to_principal_city_fips
    GROUP BY fips_state_code
)

-- Generate final analysis with rankings
SELECT 
    s.fips_state_code,
    s.total_cbsas,
    s.metro_areas,
    s.micro_areas,
    s.total_principal_cities,
    -- Calculate market coverage indicators
    ROUND(s.metro_areas * 100.0 / s.total_cbsas, 1) as metro_percentage,
    ROUND(s.total_principal_cities * 1.0 / s.total_cbsas, 1) as cities_per_cbsa
FROM state_cbsa_stats s
WHERE s.total_cbsas > 0
ORDER BY s.total_cbsas DESC, s.metro_areas DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate state-level statistics about CBSAs
-- 2. Calculates the distribution of metropolitan vs micropolitan areas
-- 3. Provides metrics for market coverage analysis
-- 4. Orders results by total CBSAs to highlight states with largest market potential

-- Assumptions and Limitations:
-- - Assumes current CBSA definitions are up-to-date
-- - Does not account for population size or economic activity
-- - State FIPS codes need to be mapped to state names for better readability
-- - Equal weighting given to all CBSAs regardless of size

-- Possible Extensions:
-- 1. Add state name lookup
-- 2. Include population data for weighted analysis
-- 3. Add year-over-year comparison for growth analysis
-- 4. Calculate market penetration rates by combining with sales/coverage data
-- 5. Add geographic region grouping for regional analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:56:05.296841
    - Additional Notes: The query provides state-level market coverage analysis using CBSA distributions. Division by total_cbsas might need null handling for edge cases. FIPS state codes in results need to be joined with a state lookup table for readable state names.
    
    */