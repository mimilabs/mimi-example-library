-- Title: Healthcare Provider Concentration in Metropolitan Areas
-- Business Purpose: Identifies high-density provider areas by analyzing
-- provider counts in major cities to support strategic market expansion,
-- network development, and competitive intelligence initiatives.

WITH city_metrics AS (
    -- Get provider counts and distinct practice types by city
    SELECT 
        city,
        state,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT type) as address_type_count
    FROM mimi_ws_1.nppes.fhir_address
    WHERE 
        city IS NOT NULL
        AND period_end IS NULL -- Only active addresses
    GROUP BY city, state
),
ranked_cities AS (
    -- Rank cities by provider concentration
    SELECT 
        city,
        state,
        provider_count,
        address_type_count,
        ROW_NUMBER() OVER (ORDER BY provider_count DESC) as city_rank
    FROM city_metrics
)
SELECT 
    city,
    state,
    provider_count,
    address_type_count,
    ROUND(provider_count * 100.0 / SUM(provider_count) OVER (), 2) as pct_of_total_providers
FROM ranked_cities
WHERE city_rank <= 20
ORDER BY provider_count DESC;

-- How it works:
-- 1. First CTE aggregates provider and address type counts by city
-- 2. Second CTE ranks cities based on provider count
-- 3. Final query returns top 20 cities with their provider statistics
-- 4. Includes percentage calculation to show relative market share

-- Assumptions and Limitations:
-- - Assumes current addresses (period_end IS NULL)
-- - City names must be standardized/cleaned for accurate grouping
-- - Does not account for population size or geographic area
-- - May include both primary and satellite offices

-- Possible Extensions:
-- 1. Add population data to calculate provider density per capita
-- 2. Include specialty information for targeted market analysis
-- 3. Incorporate geographic coordinates for radius-based analysis
-- 4. Add year-over-year growth rate calculations
-- 5. Compare with competitor locations or facility distributions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:46:28.120073
    - Additional Notes: Query identifies provider concentration in major urban areas. Note that results may be skewed for cities with multiple naming variations (e.g., 'New York' vs 'NYC') or where city boundaries are complex metropolitan areas. Consider data standardization before production use.
    
    */