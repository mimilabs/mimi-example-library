-- NNDSS Data Quality and Reporting Completeness Analysis

-- Business Purpose:
-- This query assesses the data quality and reporting completeness across jurisdictions
-- in the National Notifiable Diseases Surveillance System (NNDSS). Understanding reporting
-- patterns helps identify areas needing improved surveillance and ensures reliable
-- public health decision-making.

WITH reporting_metrics AS (
    -- Calculate reporting completeness metrics by area and year
    SELECT 
        reporting_area,
        current_mmwr_year,
        COUNT(DISTINCT mmwr_week) as weeks_reported,
        COUNT(DISTINCT CASE WHEN current_week_flag IS NOT NULL THEN mmwr_week END) as weeks_with_flags,
        COUNT(DISTINCT label) as diseases_reported,
        AVG(CAST(current_week AS FLOAT)) as avg_weekly_cases,
        MAX(mimi_src_file_date) as latest_report_date
    FROM mimi_ws_1.cdc.nndss
    WHERE current_mmwr_year >= YEAR(CURRENT_DATE) - 1
    GROUP BY reporting_area, current_mmwr_year
)

SELECT 
    reporting_area,
    current_mmwr_year,
    weeks_reported,
    -- Calculate reporting completeness percentage
    ROUND((weeks_reported * 100.0) / 52, 1) as reporting_completeness_pct,
    -- Calculate data quality score
    ROUND(((weeks_reported - weeks_with_flags) * 100.0) / weeks_reported, 1) as data_quality_score,
    diseases_reported,
    ROUND(avg_weekly_cases, 1) as avg_weekly_cases,
    latest_report_date,
    -- Flag areas with potential reporting issues
    CASE 
        WHEN weeks_reported < 40 THEN 'Low Reporting'
        WHEN weeks_with_flags > weeks_reported * 0.2 THEN 'High Flag Rate'
        ELSE 'Good'
    END as reporting_status
FROM reporting_metrics
ORDER BY 
    current_mmwr_year DESC,
    reporting_completeness_pct DESC,
    reporting_area;

-- How this query works:
-- 1. Creates a CTE to aggregate reporting metrics by area and year
-- 2. Calculates key quality indicators: reporting completeness, data quality score
-- 3. Identifies areas with potential reporting issues
-- 4. Orders results to highlight areas needing attention

-- Assumptions and Limitations:
-- - Assumes 52 weeks per year as the denominator for completeness
-- - Quality score based on presence of flags only
-- - Limited to current and previous year
-- - Does not account for jurisdiction size or population
-- - Some jurisdictions may have legitimate reasons for partial reporting

-- Possible Extensions:
-- 1. Add population-adjusted metrics using external population data
-- 2. Include trend analysis comparing multiple years
-- 3. Break down quality issues by specific disease categories
-- 4. Add geographic clustering of reporting patterns
-- 5. Create benchmarking system for reporting performance

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:00:31.873499
    - Additional Notes: The query evaluates data quality and surveillance completeness on a jurisdiction level. It identifies gaps in reporting and potential data quality issues, making it valuable for both public health officials and data quality managers. Best used in conjunction with detailed jurisdiction profiles to understand legitimate variations in reporting patterns.
    
    */