-- provider_location_coverage_gaps.sql

-- Business Purpose:
-- This query identifies potential coverage gaps in provider networks by analyzing
-- the ratio of providers to ZIP codes within each state. This helps:
-- - Identify states with limited provider coverage
-- - Support network expansion planning
-- - Guide provider recruitment efforts
-- - Inform patient access initiatives

WITH provider_coverage AS (
    -- Get distinct provider counts by state and ZIP to avoid duplicates
    SELECT 
        state,
        COUNT(DISTINCT zip) as unique_zips,
        COUNT(DISTINCT npi) as unique_providers,
        -- Calculate provider density per ZIP code
        ROUND(CAST(COUNT(DISTINCT npi) AS FLOAT) / 
              NULLIF(COUNT(DISTINCT zip), 0), 2) as providers_per_zip
    FROM mimi_ws_1.datahealthcaregov.provider_addresses
    WHERE state IS NOT NULL 
      AND zip IS NOT NULL
      AND npi IS NOT NULL
    GROUP BY state
)

SELECT 
    state,
    unique_zips,
    unique_providers,
    providers_per_zip,
    -- Flag states with low provider density
    CASE 
        WHEN providers_per_zip < 5 THEN 'High Coverage Gap Risk'
        WHEN providers_per_zip < 10 THEN 'Moderate Coverage Gap Risk'
        ELSE 'Adequate Coverage'
    END as coverage_status
FROM provider_coverage
ORDER BY providers_per_zip ASC;

-- How it works:
-- 1. Creates a CTE to calculate unique provider and ZIP counts per state
-- 2. Calculates the provider-to-ZIP ratio as a density metric
-- 3. Assigns coverage status based on provider density thresholds
-- 4. Orders results to highlight states with lowest coverage first

-- Assumptions and Limitations:
-- - Assumes ZIP codes are valid and current
-- - Does not account for population density differences
-- - Does not consider provider specialties or capacity
-- - May include inactive or retired providers
-- - ZIP code boundaries may cross state lines

-- Possible Extensions:
-- 1. Add provider type analysis to identify specialty-specific gaps
-- 2. Include temporal analysis to track coverage trends
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Incorporate population data to calculate per-capita metrics
-- 5. Add distance analysis between ZIP codes to identify true access gaps

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:52:43.543487
    - Additional Notes: The query uses a simple providers-per-ZIP ratio which may oversimplify access issues in areas with varying population densities or geographic sizes. Consider supplementing with demographic data for more accurate coverage analysis. Density thresholds (5 and 10 providers per ZIP) are arbitrary and should be adjusted based on specific business requirements and local healthcare needs.
    
    */