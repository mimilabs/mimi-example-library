-- NNDSS Regional Disease Burden Analysis
--
-- Business Purpose: 
-- Analyze and compare the current disease burden across different reporting areas
-- to identify regions with high case volumes and year-over-year changes.
-- This information helps public health officials allocate resources and
-- prioritize interventions in areas with increasing disease prevalence.

WITH current_burden AS (
    -- Calculate total current year cases and previous year cases by region
    SELECT 
        reporting_area,
        SUM(cumulative_ytd_current_mmwr_year) as current_year_cases,
        SUM(cumulative_ytd_previous_mmwr_year) as previous_year_cases,
        COUNT(DISTINCT label) as distinct_diseases,
        MAX(current_mmwr_year) as report_year
    FROM mimi_ws_1.cdc.nndss
    WHERE reporting_area NOT IN ('TOTAL', 'UNITED STATES')
        AND cumulative_ytd_current_mmwr_year IS NOT NULL
    GROUP BY reporting_area
),

burden_metrics AS (
    -- Calculate year-over-year change and rank regions
    SELECT 
        reporting_area,
        current_year_cases,
        previous_year_cases,
        distinct_diseases,
        report_year,
        current_year_cases - previous_year_cases as yoy_change,
        ROUND(((current_year_cases::FLOAT - previous_year_cases) / 
            NULLIF(previous_year_cases, 0) * 100), 2) as yoy_change_percent
    FROM current_burden
)

SELECT 
    reporting_area,
    current_year_cases,
    previous_year_cases,
    distinct_diseases,
    report_year,
    yoy_change,
    yoy_change_percent,
    -- Add rankings to identify areas of concern
    RANK() OVER (ORDER BY current_year_cases DESC) as burden_rank,
    RANK() OVER (ORDER BY yoy_change_percent DESC) as growth_rank
FROM burden_metrics
WHERE current_year_cases > 0
ORDER BY current_year_cases DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE aggregates case counts by reporting area for current and previous years
-- 2. Second CTE calculates year-over-year changes and percentages
-- 3. Final SELECT adds rankings and filters to highlight key areas
--
-- Assumptions and Limitations:
-- - Excludes 'TOTAL' and 'UNITED STATES' to avoid double counting
-- - Assumes non-null current year cases for valid comparisons
-- - Does not account for population differences between regions
-- - Year-over-year comparisons may be affected by reporting changes
--
-- Possible Extensions:
-- 1. Add population-adjusted rates using census data
-- 2. Break down by disease category or specific conditions
-- 3. Include seasonal analysis using MMWR weeks
-- 4. Add statistical significance testing for changes
-- 5. Create regional groupings for broader geographic analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:10:58.624291
    - Additional Notes: The query focuses on comparing disease burden across regions with year-over-year trends, particularly useful for resource allocation decisions. The 20-record limit in the final output should be adjusted based on specific analysis needs. Consider adding WHERE clauses for specific time periods if analyzing particular outbreak periods.
    
    */