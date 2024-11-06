
-- Population Center Economic Opportunity Index
-- 
-- Business Purpose:
-- Develop a scoring mechanism to identify high-potential census tracts
-- by combining population concentration with geographic positioning.
-- This analysis helps businesses and investors understand nuanced
-- population distribution patterns beyond simple population counts.

WITH tract_economic_scoring AS (
    -- Calculate a composite economic opportunity score
    SELECT 
        statefp,                      -- State FIPS code
        countyfp,                     -- County FIPS code
        fips,                         -- Full tract FIPS code
        population,                   -- Total population
        latitude,
        longitude,
        
        -- Economic potential scoring mechanism
        ROUND(
            (population / 1000.0) *   -- Scale population impact
            (1 / (ABS(latitude - 39.8) + 1)) *  -- Adjust for proximity to economic corridors
            (1 / (ABS(longitude - (-98.5)) + 1)),  -- Normalize across US mainland
            4
        ) AS economic_opportunity_score
    
    FROM mimi_ws_1.census.centerofpop_tr
    WHERE population > 100  -- Exclude very small tracts
),

ranked_tracts AS (
    -- Rank tracts by economic opportunity
    SELECT 
        *,
        DENSE_RANK() OVER (ORDER BY economic_opportunity_score DESC) as opportunity_rank
    FROM tract_economic_scoring
)

-- Select top economic opportunity tracts
SELECT 
    statefp,
    countyfp,
    fips,
    population,
    latitude,
    longitude,
    economic_opportunity_score,
    opportunity_rank
FROM ranked_tracts
WHERE opportunity_rank <= 100
ORDER BY economic_opportunity_score DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Calculates a composite economic opportunity score
-- 2. Uses population, geographic positioning as scoring factors
-- 3. Ranks census tracts to highlight high-potential areas

-- Assumptions:
-- - Population is proxy for economic potential
-- - Geographic centrality correlates with opportunity
-- - Scores are relative, not absolute measures

-- Potential Extensions:
-- 1. Incorporate additional economic indicators
-- 2. Add industry-specific weighting
-- 3. Integrate with other demographic datasets
-- 4. Create geospatial visualizations


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:38:32.696943
    - Additional Notes: Provides a novel scoring mechanism for census tracts by combining population and geographic positioning. Useful for initial market potential screening, but requires further domain-specific refinement for precise economic insights.
    
    */