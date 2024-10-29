-- Medicare Hospital Specialty Unit Analysis
-- Business Purpose:
-- - Analyze the availability of specialized hospital units across states
-- - Identify service gaps in specialized care delivery
-- - Support strategic planning for healthcare service expansion
-- - Enable targeted outreach for specialty care partnerships

WITH specialty_summary AS (
    -- Aggregate specialty unit presence by state
    SELECT 
        state,
        COUNT(*) as total_hospitals,
        SUM(CASE WHEN subgroup_psychiatric = 'Y' THEN 1 ELSE 0 END) as psychiatric_units,
        SUM(CASE WHEN subgroup_rehabilitation = 'Y' THEN 1 ELSE 0 END) as rehab_units,
        SUM(CASE WHEN subgroup_childrens = 'Y' THEN 1 ELSE 0 END) as childrens_units,
        SUM(CASE WHEN subgroup_longterm = 'Y' THEN 1 ELSE 0 END) as longterm_units
    FROM mimi_ws_1.datacmsgov.pc_hospital
    GROUP BY state
),
state_rankings AS (
    -- Calculate specialty coverage ratios and rankings
    SELECT 
        state,
        total_hospitals,
        psychiatric_units,
        rehab_units,
        childrens_units,
        longterm_units,
        ROUND(psychiatric_units / NULLIF(total_hospitals, 0)::DECIMAL * 100, 1) as psych_coverage_pct,
        ROUND(rehab_units / NULLIF(total_hospitals, 0)::DECIMAL * 100, 1) as rehab_coverage_pct,
        ROUND(childrens_units / NULLIF(total_hospitals, 0)::DECIMAL * 100, 1) as childrens_coverage_pct,
        ROUND(longterm_units / NULLIF(total_hospitals, 0)::DECIMAL * 100, 1) as longterm_coverage_pct
    FROM specialty_summary
)

SELECT 
    state,
    total_hospitals,
    psychiatric_units,
    psych_coverage_pct,
    rehab_units,
    rehab_coverage_pct,
    childrens_units,
    childrens_coverage_pct,
    longterm_units,
    longterm_coverage_pct
FROM state_rankings
WHERE total_hospitals >= 5  -- Filter out states with very few hospitals
ORDER BY total_hospitals DESC;

-- How it works:
-- 1. First CTE aggregates specialty unit counts by state
-- 2. Second CTE calculates coverage percentages for each specialty type
-- 3. Final query presents results for states with meaningful hospital counts
-- 4. Results ordered by total hospitals to highlight larger markets first

-- Assumptions and Limitations:
-- - Assumes current Medicare enrollment data is representative of overall hospital landscape
-- - Does not account for hospital size or capacity
-- - Coverage percentages may not reflect actual access due to geographic distribution within states
-- - Minimum threshold of 5 hospitals per state may exclude some relevant markets

-- Possible Extensions:
-- 1. Add geographic clustering analysis within states
-- 2. Include population density correlations
-- 3. Incorporate profit status analysis by specialty type
-- 4. Add year-over-year trend analysis if historical data available
-- 5. Cross-reference with demographic data for needs assessment
-- 6. Calculate distance-based access metrics for each specialty type/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:06:50.618126
    - Additional Notes: Query focuses on comparative analysis of specialty care availability across states. The 5-hospital minimum threshold may need adjustment based on specific analysis needs. Coverage percentages should be interpreted alongside absolute numbers for meaningful insights.
    
    */