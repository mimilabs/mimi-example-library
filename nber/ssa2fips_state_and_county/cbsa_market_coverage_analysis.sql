-- Title: CBSA Market Analysis and Demographic Coverage
-- Business Purpose: 
-- This query analyzes Core Based Statistical Areas (CBSAs) to understand:
-- - Market size and potential by identifying major metropolitan areas
-- - Population coverage and geographic distribution
-- - Strategic opportunities for healthcare service planning
-- This information is valuable for:
-- - Market expansion planning
-- - Network adequacy assessment
-- - Population health initiatives
-- - Resource allocation decisions

WITH cbsa_summary AS (
  -- Aggregate county-level data to CBSA level
  SELECT 
    fy2023cbsa,
    fy2023cbsaname,
    state_name,
    COUNT(DISTINCT fipscounty) as counties_count,
    COUNT(DISTINCT state) as states_count,
    COLLECT_SET(state) as state_array  -- Using COLLECT_SET instead of STRING_AGG
  FROM mimi_ws_1.nber.ssa2fips_state_and_county
  WHERE fy2023cbsa IS NOT NULL
  GROUP BY fy2023cbsa, fy2023cbsaname, state_name
),

ranked_cbsas AS (
  -- Rank CBSAs by county coverage
  SELECT 
    fy2023cbsa,
    fy2023cbsaname,
    counties_count,
    states_count,
    ARRAY_JOIN(state_array, ', ') as state_list,  -- Convert array to string
    ROW_NUMBER() OVER (ORDER BY counties_count DESC) as size_rank
  FROM cbsa_summary
)

-- Final output showing largest market areas
SELECT 
  fy2023cbsa as cbsa_code,
  fy2023cbsaname as market_area,
  counties_count as coverage_counties,
  states_count as states_span,
  state_list as market_states,
  size_rank as market_size_rank
FROM ranked_cbsas
WHERE size_rank <= 20
ORDER BY size_rank;

-- How it works:
-- 1. First CTE aggregates county data to CBSA level using COLLECT_SET for states
-- 2. Second CTE ranks CBSAs by county coverage and formats state list
-- 3. Final query filters for top 20 markets by size

-- Assumptions and Limitations:
-- - Uses FY2023 CBSA definitions
-- - Assumes county count is a proxy for market size
-- - Does not account for population density or demographics
-- - Limited to geographic coverage metrics

-- Possible Extensions:
-- 1. Add population data for more accurate market sizing
-- 2. Include healthcare facility counts per CBSA
-- 3. Calculate distance between CBSAs for network planning
-- 4. Analyze rural vs urban market distribution
-- 5. Compare year-over-year CBSA definition changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:37:51.008594
    - Additional Notes: Focuses on geographic distribution and market size of Core Based Statistical Areas (CBSAs). The query uses COLLECT_SET and ARRAY_JOIN functions specific to Databricks SQL for state aggregation. Results are limited to top 20 CBSAs by county coverage, which may not directly correlate with population or economic importance.
    
    */