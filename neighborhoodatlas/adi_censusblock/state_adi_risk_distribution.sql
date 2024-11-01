-- state_level_health_disparity_trends.sql
-- Business Purpose: This query analyzes state-level health disparities by examining 
-- the distribution of ADI rankings across states. This helps healthcare organizations:
-- 1. Identify states with the highest concentration of disadvantaged areas
-- 2. Support strategic planning for resource allocation and expansion
-- 3. Guide population health management initiatives
-- 4. Inform policy discussions around health equity

WITH state_summary AS (
    -- Extract state portion of FIPS code and calculate key metrics
    SELECT 
        LEFT(fips, 2) as state_fips,
        COUNT(*) as total_block_groups,
        COUNT(CASE WHEN adi_natrank > 80 THEN 1 END) as high_risk_areas,
        AVG(adi_natrank) as avg_natrank,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY adi_natrank) as median_natrank,
        MIN(adi_natrank) as min_natrank,
        MAX(adi_natrank) as max_natrank
    FROM mimi_ws_1.neighborhoodatlas.adi_censusblock
    GROUP BY LEFT(fips, 2)
),

ranked_states AS (
    -- Rank states by concentration of high-risk areas
    SELECT 
        state_fips,
        total_block_groups,
        high_risk_areas,
        ROUND(100.0 * high_risk_areas / total_block_groups, 2) as pct_high_risk,
        ROUND(avg_natrank, 2) as avg_natrank,
        median_natrank,
        max_natrank - min_natrank as natrank_range
    FROM state_summary
)

-- Final output with key insights
SELECT 
    state_fips,
    total_block_groups,
    high_risk_areas,
    pct_high_risk,
    avg_natrank,
    median_natrank,
    natrank_range
FROM ranked_states
ORDER BY pct_high_risk DESC;

-- How it works:
-- 1. First CTE extracts state FIPS and calculates key statistics for each state
-- 2. Second CTE calculates percentage of high-risk areas and formats metrics
-- 3. Final query orders states by concentration of high-risk areas

-- Assumptions and Limitations:
-- 1. Defines "high risk" as ADI national rank > 80 (adjustable threshold)
-- 2. Uses state FIPS codes as identifiers (may need mapping table for state names)
-- 3. Assumes current data is representative of actual conditions
-- 4. Does not account for population density or geographic size differences

-- Possible Extensions:
-- 1. Add state name mapping for better readability
-- 2. Include year-over-year trend analysis
-- 3. Add geographic region grouping for regional comparisons
-- 4. Incorporate population data for per-capita analysis
-- 5. Add correlation with specific health outcomes
-- 6. Create risk tiers based on multiple ADI metrics
-- 7. Include urban/rural classification analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:26:47.538873
    - Additional Notes: Query aggregates ADI data at state level to identify areas of concentrated socioeconomic disadvantage. The 80th percentile threshold for high-risk classification can be adjusted based on specific program needs. Consider adding state name lookup table for better reporting readability.
    
    */