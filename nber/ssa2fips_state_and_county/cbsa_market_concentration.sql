-- Title: County Market Share Assessment by CBSA Regions
-- 
-- Business Purpose:
-- This query helps analyze market distribution across counties and their associated
-- Core Based Statistical Areas (CBSAs) to:
-- - Identify counties that belong to major market regions
-- - Calculate the concentration of counties per CBSA
-- - Support market penetration and expansion strategies
--

WITH cbsa_metrics AS (
    -- Calculate county counts and unique states per CBSA
    SELECT 
        fy2023cbsa,
        fy2023cbsaname,
        COUNT(DISTINCT fipscounty) as county_count,
        COUNT(DISTINCT state) as state_count,
        COLLECT_SET(state_name) as states_covered
    FROM mimi_ws_1.nber.ssa2fips_state_and_county
    WHERE fy2023cbsa IS NOT NULL
    GROUP BY fy2023cbsa, fy2023cbsaname
)

SELECT 
    fy2023cbsa as cbsa_code,
    fy2023cbsaname as cbsa_name,
    county_count,
    state_count,
    ARRAY_JOIN(states_covered, ', ') as states_list,
    -- Calculate market significance metrics
    ROUND(county_count * 100.0 / (SELECT SUM(county_count) FROM cbsa_metrics), 2) as pct_total_counties
FROM cbsa_metrics
WHERE county_count >= 3  -- Focus on CBSAs with meaningful county presence
ORDER BY county_count DESC, state_count DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to aggregate county and state metrics per CBSA
-- 2. Uses COLLECT_SET and ARRAY_JOIN instead of STRING_AGG for state names
-- 3. Calculates the percentage of total counties each CBSA represents
-- 4. Filters to show only CBSAs with 3 or more counties
-- 5. Returns top 20 CBSAs by county coverage
--
-- Assumptions and Limitations:
-- - Assumes current CBSA definitions (FY2023) are relevant for analysis
-- - Does not account for population or economic size of counties
-- - Limited to geographic distribution only
--
-- Possible Extensions:
-- - Add population data to weight market importance
-- - Include year-over-year CBSA definition changes
-- - Add economic indicators per CBSA region
-- - Incorporate distance calculations between counties in same CBSA
-- - Analysis of cross-state CBSA regions for regulatory considerations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:29:06.751323
    - Additional Notes: Query provides market distribution insights by analyzing county clustering within CBSAs. Main metrics include county counts per CBSA and multi-state coverage. Results are filtered to focus on CBSAs with at least 3 counties to ensure meaningful market presence analysis.
    
    */