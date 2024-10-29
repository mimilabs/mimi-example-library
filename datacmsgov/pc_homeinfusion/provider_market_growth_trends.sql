-- Provider Growth and Market Penetration Analysis for Home Infusion Therapy Services
--
-- Business Purpose:
-- Analyzes enrollment trends and market penetration of home infusion therapy providers
-- to identify growth patterns and potential market opportunities. This helps:
-- - Strategic planning for market expansion
-- - Understanding competitive landscape
-- - Identifying underserved markets
-- - Supporting investment decisions

WITH provider_growth AS (
    -- Calculate provider counts and growth by state and quarter
    SELECT 
        geographic_location_state_code as state,
        DATE_TRUNC('quarter', mimi_src_file_date) as quarter,
        COUNT(DISTINCT enrollment_id) as provider_count,
        COUNT(DISTINCT state_county_name) as counties_served
    FROM mimi_ws_1.datacmsgov.pc_homeinfusion
    GROUP BY 1,2
),
growth_metrics AS (
    -- Calculate quarter-over-quarter growth rates
    SELECT 
        state,
        quarter,
        provider_count,
        counties_served,
        (provider_count - LAG(provider_count) OVER (PARTITION BY state ORDER BY quarter)) / 
            NULLIF(LAG(provider_count) OVER (PARTITION BY state ORDER BY quarter), 0) * 100 as qoq_growth_rate,
        counties_served::float / 
            (SELECT COUNT(DISTINCT state_county_name) 
             FROM mimi_ws_1.datacmsgov.pc_homeinfusion hi2 
             WHERE hi2.geographic_location_state_code = state) * 100 as county_coverage_pct
    FROM provider_growth
)

SELECT 
    state,
    quarter,
    provider_count,
    counties_served,
    ROUND(qoq_growth_rate, 2) as qoq_growth_pct,
    ROUND(county_coverage_pct, 2) as county_coverage_pct
FROM growth_metrics
WHERE quarter IS NOT NULL
ORDER BY state, quarter DESC;

-- How the Query Works:
-- 1. First CTE aggregates provider counts by state and quarter
-- 2. Second CTE calculates growth metrics:
--    - Quarter-over-quarter growth rate
--    - County coverage percentage
-- 3. Final output presents key metrics for market analysis

-- Assumptions and Limitations:
-- - Assumes enrollment_id uniquely identifies providers
-- - Growth calculations may be affected by data completeness
-- - County coverage may not reflect actual service areas
-- - Does not account for population density or demand factors

-- Possible Extensions:
-- 1. Add market concentration analysis (HHI calculation)
-- 2. Include demographic data to identify underserved populations
-- 3. Incorporate Medicare claims data to analyze service utilization
-- 4. Add competitor analysis by comparing provider size and coverage
-- 5. Include revenue potential calculations based on Medicare rates/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:14:30.265764
    - Additional Notes: Query calculates key market metrics including provider growth rates and county coverage. Performance may be impacted when analyzing large time periods due to window functions. Ensure mimi_src_file_date contains consistent data points for accurate growth calculations.
    
    */