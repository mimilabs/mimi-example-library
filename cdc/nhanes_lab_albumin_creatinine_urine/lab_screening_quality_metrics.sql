-- screening_efficiency_assessment.sql
-- Business Purpose: This query analyzes the quality and completeness of urine albumin and
-- creatinine screening tests in the NHANES dataset to evaluate screening efficiency and
-- identify potential areas for improvement in population health screening programs.
-- The analysis helps healthcare administrators and public health officials optimize
-- resource allocation and screening protocols.

WITH sample_metrics AS (
    -- Calculate basic screening metrics
    SELECT 
        mimi_src_file_name,
        COUNT(*) as total_samples,
        COUNT(CASE WHEN urxuma1 IS NOT NULL AND urxucr1 IS NOT NULL THEN 1 END) as complete_samples,
        COUNT(CASE WHEN urxuma2 IS NOT NULL OR urxucr2 IS NOT NULL THEN 1 END) as retested_samples,
        COUNT(CASE WHEN urdumalc IS NOT NULL OR urducrlc IS NOT NULL THEN 1 END) as samples_with_comments
    FROM mimi_ws_1.cdc.nhanes_lab_albumin_creatinine_urine
    GROUP BY mimi_src_file_name
),
repeat_test_analysis AS (
    -- Analyze cases requiring repeat testing
    SELECT
        mimi_src_file_name,
        COUNT(*) as total_retests,
        AVG(ABS(COALESCE(urdact, 0) - COALESCE(urdact2, 0))) as avg_ratio_difference
    FROM mimi_ws_1.cdc.nhanes_lab_albumin_creatinine_urine
    WHERE urxuma2 IS NOT NULL
    GROUP BY mimi_src_file_name
)

SELECT 
    sm.mimi_src_file_name,
    sm.total_samples,
    ROUND(100.0 * sm.complete_samples / sm.total_samples, 2) as completion_rate,
    ROUND(100.0 * sm.retested_samples / sm.total_samples, 2) as retest_rate,
    ROUND(100.0 * sm.samples_with_comments / sm.total_samples, 2) as comment_rate,
    COALESCE(rta.avg_ratio_difference, 0) as avg_retest_difference
FROM sample_metrics sm
LEFT JOIN repeat_test_analysis rta ON sm.mimi_src_file_name = rta.mimi_src_file_name
ORDER BY sm.mimi_src_file_name;

-- How it works:
-- 1. First CTE (sample_metrics) calculates basic screening quality metrics per source file
-- 2. Second CTE (repeat_test_analysis) focuses on samples requiring repeat testing
-- 3. Final query joins these metrics and calculates relevant percentages
-- 4. Results are grouped by source file to track changes over time

-- Assumptions and Limitations:
-- - Assumes NULL values indicate missing measurements rather than zero values
-- - Does not account for specific comment codes' meanings
-- - Treats all samples as equally important (no weighting)
-- - Limited to available NHANES cycles in the dataset

-- Possible Extensions:
-- 1. Add temporal trend analysis across NHANES cycles
-- 2. Include demographic stratification of screening completion rates
-- 3. Analyze specific comment codes to identify common quality issues
-- 4. Compare screening efficiency across different collection sites or seasons
-- 5. Calculate cost implications of repeat testing rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:03:28.487188
    - Additional Notes: Query provides key performance indicators for laboratory testing quality, including completion rates, retest rates, and measurement consistency. Best used for operational quality monitoring and resource optimization in clinical laboratory settings. Note that temporal granularity depends on the mimi_src_file_name pattern and may require adjustment based on specific NHANES data cycles available.
    
    */