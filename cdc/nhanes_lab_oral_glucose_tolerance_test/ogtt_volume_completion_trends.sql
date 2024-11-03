-- Title: OGTT Testing Volume and Completion Trends Analysis

-- Business Purpose:
-- - Track OGTT testing volumes across different time periods
-- - Analyze test completion rates to optimize resource allocation
-- - Identify trends in testing patterns to improve operational efficiency
-- - Support capacity planning for laboratory services

WITH test_summary AS (
    -- Calculate monthly testing volumes and completion metrics
    SELECT 
        DATE_TRUNC('month', mimi_src_file_date) AS report_month,
        COUNT(*) AS total_tests,
        COUNT(CASE WHEN gtdcode IS NULL THEN 1 END) AS completed_tests,
        COUNT(CASE WHEN gtxdrank = 'All' THEN 1 END) AS full_compliance,
        AVG(CASE WHEN lbxglt IS NOT NULL THEN lbxglt END) AS avg_glucose_level
    FROM mimi_ws_1.cdc.nhanes_lab_oral_glucose_tolerance_test
    GROUP BY DATE_TRUNC('month', mimi_src_file_date)
),
completion_metrics AS (
    -- Calculate key performance indicators
    SELECT 
        report_month,
        total_tests,
        completed_tests,
        ROUND(100.0 * completed_tests / NULLIF(total_tests, 0), 1) AS completion_rate,
        ROUND(100.0 * full_compliance / NULLIF(total_tests, 0), 1) AS compliance_rate,
        ROUND(avg_glucose_level, 1) AS avg_glucose_level
    FROM test_summary
)
SELECT 
    report_month,
    total_tests,
    completed_tests,
    completion_rate,
    compliance_rate,
    avg_glucose_level,
    -- Calculate month-over-month change
    total_tests - LAG(total_tests) OVER (ORDER BY report_month) AS mom_volume_change,
    completion_rate - LAG(completion_rate) OVER (ORDER BY report_month) AS mom_completion_change
FROM completion_metrics
ORDER BY report_month DESC;

-- How this query works:
-- 1. First CTE aggregates monthly testing volumes and completion status
-- 2. Second CTE calculates completion and compliance rates
-- 3. Main query adds month-over-month trending analysis
-- 4. Results are ordered by most recent month first

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date is a reliable proxy for test date
-- - Null gtdcode indicates successful test completion
-- - gtxdrank = 'All' indicates full protocol compliance
-- - Does not account for potential data quality issues or reporting delays

-- Possible Extensions:
-- 1. Add day-of-week analysis to identify optimal testing days
-- 2. Include geographic distribution if location data becomes available
-- 3. Incorporate seasonal adjustment factors
-- 4. Add resource utilization metrics based on test duration
-- 5. Create testing facility capacity forecasting model

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:10:09.608651
    - Additional Notes: Query focuses on operational metrics around OGTT test administration and completion rates. The monthly aggregation provides a high-level view for capacity planning, but may need adjustment based on actual reporting cycles. Consider local time zones when using mimi_src_file_date for temporal analysis.
    
    */