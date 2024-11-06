-- Glycohemoglobin Test Coverage and Accessibility Analysis
--
-- Business Purpose:
-- This query evaluates the testing coverage and accessibility of glycohemoglobin measurements
-- across different time periods to identify potential gaps in healthcare screening and
-- inform resource allocation decisions for diabetes monitoring programs.
--
-- The analysis helps healthcare organizations:
-- 1. Identify periods with low testing volumes that may indicate access barriers
-- 2. Support capacity planning for laboratory services
-- 3. Guide outreach initiatives to improve screening rates
-- 4. Optimize resource allocation for diabetes monitoring programs

-- Main Analysis
WITH testing_metrics AS (
    -- Calculate testing volumes and statistics by month
    SELECT 
        DATE_TRUNC('month', mimi_src_file_date) AS month_date,
        COUNT(*) AS test_count,
        COUNT(DISTINCT seqn) AS unique_patients,
        ROUND(AVG(lbxgh), 2) AS avg_glycohemoglobin
    FROM mimi_ws_1.cdc.nhanes_lab_glycohemoglobin
    WHERE lbxgh IS NOT NULL
    GROUP BY DATE_TRUNC('month', mimi_src_file_date)
),
month_over_month AS (
    -- Calculate month-over-month changes in testing volumes
    SELECT 
        month_date,
        test_count,
        unique_patients,
        avg_glycohemoglobin,
        LAG(test_count) OVER (ORDER BY month_date) AS prev_month_count,
        ROUND(((test_count - LAG(test_count) OVER (ORDER BY month_date))::FLOAT / 
               NULLIF(LAG(test_count) OVER (ORDER BY month_date), 0) * 100), 1) AS mom_change
    FROM testing_metrics
)
SELECT 
    month_date,
    test_count,
    unique_patients,
    avg_glycohemoglobin,
    mom_change AS month_over_month_change_pct,
    CASE 
        WHEN mom_change < -10 THEN 'Significant Decrease'
        WHEN mom_change < 0 THEN 'Moderate Decrease'
        WHEN mom_change = 0 THEN 'No Change'
        WHEN mom_change <= 10 THEN 'Moderate Increase'
        ELSE 'Significant Increase'
    END AS volume_trend_category
FROM month_over_month
ORDER BY month_date DESC;

-- How this query works:
-- 1. First CTE aggregates testing volumes and statistics by month
-- 2. Second CTE calculates month-over-month changes
-- 3. Final select adds trend categorization and formats results
--
-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date represents actual testing date
-- - Does not account for seasonal variations in testing patterns
-- - May be affected by data loading patterns/frequencies
--
-- Possible Extensions:
-- 1. Add seasonal adjustment factors for more accurate trend analysis
-- 2. Include geographic analysis if location data becomes available
-- 3. Compare testing volumes against population benchmarks
-- 4. Add capacity utilization metrics if lab capacity data is available
-- 5. Include cost analysis for resource planning purposes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:33:24.402268
    - Additional Notes: This query focuses on operational metrics rather than clinical outcomes, making it particularly useful for healthcare administrators and lab managers planning resource allocation. The month-over-month trend analysis provides early warning indicators of potential access issues or capacity constraints.
    
    */