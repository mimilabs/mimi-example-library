-- nursing_home_geographic_access.sql

-- Business Purpose:
-- Analyze geographic distribution and accessibility of nursing homes across states
-- Identify potential gaps in nursing home coverage and health system presence
-- Support healthcare planning and access equity initiatives
-- Aid in strategic decisions for expansion or resource allocation

WITH state_summary AS (
    -- Calculate summary metrics for each state
    SELECT 
        nursing_home_state,
        COUNT(DISTINCT compendium_nh_id) as total_nursing_homes,
        COUNT(DISTINCT CASE WHEN health_sys_id IS NOT NULL THEN compendium_nh_id END) as system_affiliated_homes,
        COUNT(DISTINCT health_sys_id) as unique_health_systems,
        COUNT(DISTINCT nursing_home_zip) as unique_zip_codes
    FROM mimi_ws_1.ahrq.compendium_nursinghome_linkage
    GROUP BY nursing_home_state
),
state_metrics AS (
    -- Calculate key access and coverage metrics
    SELECT 
        nursing_home_state,
        total_nursing_homes,
        system_affiliated_homes,
        unique_health_systems,
        unique_zip_codes,
        ROUND(system_affiliated_homes * 100.0 / total_nursing_homes, 1) as pct_system_affiliated,
        ROUND(total_nursing_homes * 1.0 / unique_zip_codes, 2) as homes_per_zip
    FROM state_summary
    WHERE nursing_home_state IS NOT NULL
)

SELECT 
    nursing_home_state as state,
    total_nursing_homes,
    system_affiliated_homes,
    unique_health_systems,
    unique_zip_codes,
    pct_system_affiliated as pct_affiliated_with_systems,
    homes_per_zip as nursing_homes_per_zip
FROM state_metrics
ORDER BY total_nursing_homes DESC;

-- How it works:
-- 1. First CTE aggregates basic counts by state
-- 2. Second CTE calculates derived metrics for coverage analysis
-- 3. Final query presents results in a clear, actionable format

-- Assumptions and Limitations:
-- - Assumes current data is representative of actual nursing home distribution
-- - ZIP codes are used as a proxy for geographic coverage
-- - Does not account for population density or demographic needs
-- - No consideration of nursing home size or capacity

-- Possible Extensions:
-- 1. Add population data to calculate homes per capita
-- 2. Include quality metrics to assess access to high-quality care
-- 3. Incorporate urban/rural designations for deeper geographic analysis
-- 4. Add temporal analysis to track changes in coverage over time
-- 5. Include distance analysis between ZIP codes to measure true accessibility

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:54:13.031350
    - Additional Notes: Query focuses on state-level geographic distribution metrics for nursing homes. Uses ZIP codes as coverage proxy but could benefit from additional geographic granularity. Consider adding demographic weighting for more meaningful access analysis.
    
    */