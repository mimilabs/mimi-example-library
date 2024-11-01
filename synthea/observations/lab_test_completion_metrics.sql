-- lab_test_completion_tracking.sql

-- Business Purpose:
-- - Track lab test completion rates and turnaround times across patient populations
-- - Identify bottlenecks in lab testing workflows
-- - Support resource allocation and capacity planning for laboratory services
-- - Monitor quality metrics for laboratory operations
-- - Improve patient care through timely lab result delivery

WITH lab_tests AS (
    -- Filter for lab test observations and add date parts
    SELECT 
        date,
        DATE_TRUNC('month', date) as month,
        patient,
        encounter,
        code,
        description,
        value,
        units,
        CASE WHEN value IS NOT NULL THEN 1 ELSE 0 END as completed_flag
    FROM mimi_ws_1.synthea.observations
    WHERE type = 'laboratory'
    AND DATE_PART('year', date) >= 2020
),

monthly_metrics AS (
    -- Calculate monthly completion rates and volumes
    SELECT 
        month,
        COUNT(DISTINCT patient) as total_patients,
        COUNT(*) as total_tests,
        SUM(completed_flag) as completed_tests,
        ROUND(100.0 * SUM(completed_flag) / COUNT(*), 2) as completion_rate,
        COUNT(DISTINCT code) as unique_test_types
    FROM lab_tests
    GROUP BY month
),

test_type_metrics AS (
    -- Analyze most common test types and their completion rates
    SELECT 
        description as test_name,
        COUNT(*) as test_volume,
        ROUND(100.0 * SUM(completed_flag) / COUNT(*), 2) as test_completion_rate,
        COUNT(DISTINCT patient) as unique_patients
    FROM lab_tests
    GROUP BY description
    HAVING COUNT(*) >= 100
)

-- Final output combining key metrics
SELECT 
    m.*,
    t.test_name as most_common_test,
    t.test_volume as top_test_volume,
    t.test_completion_rate as top_test_completion_rate
FROM monthly_metrics m
CROSS JOIN (
    SELECT test_name, test_volume, test_completion_rate
    FROM test_type_metrics
    ORDER BY test_volume DESC
    LIMIT 1
) t
ORDER BY m.month;

-- How it works:
-- 1. First CTE filters for laboratory observations and adds useful date calculations
-- 2. Second CTE aggregates monthly metrics including completion rates
-- 3. Third CTE analyzes metrics by test type
-- 4. Final query combines monthly trends with top test information

-- Assumptions and Limitations:
-- - Assumes 'laboratory' type is consistently coded in the source data
-- - Focuses on completion rates based on presence of value field
-- - Limited to data from 2020 onwards
-- - Minimum threshold of 100 tests for test type analysis to ensure significance

-- Possible Extensions:
-- 1. Add patient demographic analysis to identify disparities in lab test completion
-- 2. Include turnaround time calculations between order and result dates
-- 3. Add seasonal trending analysis for different types of lab tests
-- 4. Incorporate cost analysis if billing data is available
-- 5. Add statistical analysis for identifying significant variations in completion rates
-- 6. Include lab result range analysis to identify abnormal result patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:21:45.578203
    - Additional Notes: Query focuses on laboratory operational efficiency metrics with completion rates as the primary KPI. Best used for monthly operational reviews and capacity planning. May need adjustment of the 100-test threshold based on facility size and test volumes.
    
    */