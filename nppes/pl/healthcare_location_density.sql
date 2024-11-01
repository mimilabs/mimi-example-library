-- Provider Network Density Analysis
-- Business Purpose: Identify geographic areas with high concentrations of secondary practice locations
-- to understand healthcare service accessibility and potential market opportunities.
-- This analysis helps healthcare organizations and investors:
-- 1. Identify underserved areas for potential expansion
-- 2. Understand competitive landscape in specific regions
-- 3. Support network adequacy planning
-- 4. Guide strategic partnership decisions

WITH location_counts AS (
    -- Calculate the number of secondary practice locations by state and city
    SELECT 
        provider_secondary_practice_location_address__state_name as state,
        provider_secondary_practice_location_address__city_name as city,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(*) as location_count,
        -- Calculate locations per provider ratio
        ROUND(CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT npi), 2) as locations_per_provider
    FROM mimi_ws_1.nppes.pl
    WHERE provider_secondary_practice_location_address__state_name IS NOT NULL
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.nppes.pl)
    GROUP BY 1, 2
),

ranked_locations AS (
    -- Rank cities within each state by provider density
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY location_count DESC) as city_rank
    FROM location_counts
    WHERE location_count >= 5  -- Filter for meaningful comparison
)

-- Final output showing top healthcare hubs
SELECT 
    state,
    city,
    provider_count,
    location_count,
    locations_per_provider,
    city_rank
FROM ranked_locations
WHERE city_rank <= 10  -- Show top 10 cities per state
ORDER BY state, city_rank;

-- How this query works:
-- 1. Creates a base aggregation of locations by state and city
-- 2. Calculates key metrics including provider count and locations per provider
-- 3. Ranks cities within each state based on location density
-- 4. Filters to show only the most significant healthcare hubs

-- Assumptions and limitations:
-- 1. Uses most recent data snapshot only
-- 2. Assumes address data is accurate and standardized
-- 3. Minimum threshold of 5 locations for meaningful comparison
-- 4. Does not account for population density or market size
-- 5. Limited to US locations only

-- Possible extensions:
-- 1. Add population data to calculate provider density per capita
-- 2. Include specialty information to analyze service type distribution
-- 3. Compare current density with historical patterns
-- 4. Add geographic distance calculations between locations
-- 5. Incorporate demographic data for market analysis
-- 6. Create visualization layers for geographic information systems

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:46:42.436576
    - Additional Notes: Query provides market-level insights by calculating provider density metrics at state/city level. Minimum threshold of 5 locations helps filter out noise from single-provider practices. Results are limited to most recent data snapshot only. Consider adding temporal analysis for tracking density changes over time.
    
    */