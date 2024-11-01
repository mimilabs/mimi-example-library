-- Title: Healthcare Access Barriers Analysis Using SVI 2020
-- Business Purpose: Analyze counties with significant healthcare access challenges by combining 
-- uninsured rates, disability status, and transportation barriers. This helps healthcare organizations
-- identify areas needing targeted outreach, mobile clinics, or transportation assistance programs.

WITH healthcare_barriers AS (
    -- Calculate composite healthcare access barriers score
    SELECT 
        state,
        county,
        e_totpop,
        ep_uninsur AS uninsured_rate,
        ep_disabl AS disability_rate,
        ep_noveh AS no_vehicle_rate,
        -- Create weighted composite score (higher = more barriers)
        (ep_uninsur * 0.4 + ep_disabl * 0.3 + ep_noveh * 0.3) AS access_barrier_score
    FROM mimi_ws_1.cdc.svi_county_y2020
    WHERE e_totpop >= 10000  -- Focus on counties with meaningful population size
),

ranked_counties AS (
    -- Rank counties by access barriers within each state
    SELECT 
        state,
        county,
        e_totpop AS population,
        ROUND(uninsured_rate, 1) AS uninsured_pct,
        ROUND(disability_rate, 1) AS disability_pct,
        ROUND(no_vehicle_rate, 1) AS no_vehicle_pct,
        ROUND(access_barrier_score, 2) AS barrier_score,
        RANK() OVER (PARTITION BY state ORDER BY access_barrier_score DESC) AS state_rank
    FROM healthcare_barriers
)

-- Output top 3 highest-barrier counties per state
SELECT 
    state,
    county,
    population,
    uninsured_pct,
    disability_pct,
    no_vehicle_pct,
    barrier_score
FROM ranked_counties
WHERE state_rank <= 3
ORDER BY state, state_rank;

-- How this query works:
-- 1. Creates healthcare_barriers CTE that calculates a weighted composite score
-- 2. Creates ranked_counties CTE that ranks counties within each state
-- 3. Filters to show top 3 counties per state with highest barriers
-- 4. Presents results in an actionable format for healthcare planning

-- Assumptions and Limitations:
-- - Equal weighting between disability and transportation barriers (0.3 each)
-- - Higher weight (0.4) given to uninsured status as direct healthcare barrier
-- - Minimum population threshold of 10,000 to exclude very small counties
-- - Does not account for proximity to healthcare facilities
-- - Does not consider telehealth accessibility

-- Possible Extensions:
-- 1. Add distance to nearest hospital/clinic from external dataset
-- 2. Include broadband access metrics for telehealth potential
-- 3. Segment analysis by urban/rural classification
-- 4. Add time-based trends by joining with historical SVI data
-- 5. Include demographic breakdowns of affected populations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:22:29.649628
    - Additional Notes: Query applies weighted scoring (40% uninsured, 30% disability, 30% transportation) to identify counties with multiple healthcare access challenges. Population threshold of 10,000 ensures statistical relevance. Results are grouped by state to enable state-level healthcare planning and resource allocation.
    
    */