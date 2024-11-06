-- nursing_home_state_disparity.sql
-- Business Purpose:
-- Analyze regional disparities in nursing home coverage by measuring the ratio of 
-- affiliated vs independent facilities across states
-- Helps identify underserved areas and potential network gaps
-- Informs strategic decisions around market expansion and partnerships
-- Supports health equity and access initiatives

WITH state_summary AS (
    -- Calculate totals by state
    SELECT 
        nursing_home_state,
        COUNT(DISTINCT compendium_nh_id) as total_facilities,
        COUNT(DISTINCT CASE WHEN health_sys_id IS NOT NULL THEN compendium_nh_id END) as system_affiliated,
        COUNT(DISTINCT CASE WHEN health_sys_id IS NULL THEN compendium_nh_id END) as independent
    FROM mimi_ws_1.ahrq.compendium_nursinghome_linkage
    GROUP BY nursing_home_state
),

state_metrics AS (
    -- Calculate key metrics per state
    SELECT 
        nursing_home_state,
        total_facilities,
        system_affiliated,
        independent,
        ROUND(CAST(system_affiliated AS FLOAT) / NULLIF(total_facilities, 0) * 100, 1) as pct_affiliated,
        ROUND(CAST(independent AS FLOAT) / NULLIF(total_facilities, 0) * 100, 1) as pct_independent
    FROM state_summary
)

-- Final output with rankings
SELECT 
    nursing_home_state as state,
    total_facilities,
    system_affiliated,
    independent,
    pct_affiliated,
    pct_independent,
    RANK() OVER (ORDER BY pct_affiliated DESC) as affiliation_rank
FROM state_metrics
WHERE total_facilities > 0
ORDER BY pct_affiliated DESC;

-- How it works:
-- 1. First CTE (state_summary) counts total facilities and breaks them down by affiliation status
-- 2. Second CTE (state_metrics) calculates percentage metrics
-- 3. Final query adds rankings and filters out states with no facilities

-- Assumptions and Limitations:
-- - Assumes current affiliations are up-to-date
-- - Does not account for facility size or capacity
-- - May not reflect recent mergers or acquisitions
-- - Does not consider population demographics or demand

-- Possible Extensions:
-- 1. Add year-over-year trend analysis to track changes in affiliation patterns
-- 2. Include population density metrics to assess coverage relative to need
-- 3. Add facility bed capacity to weight the analysis by facility size
-- 4. Incorporate quality metrics to compare outcomes between affiliated and independent facilities
-- 5. Add geographic clustering analysis to identify regional patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:49:18.064982
    - Additional Notes: Query focuses on the ratio analysis between system-affiliated and independent nursing homes at the state level. Results are most meaningful for states with a sufficient number of facilities. Consider adding a minimum threshold filter (e.g., total_facilities > 10) for more reliable comparisons.
    
    */