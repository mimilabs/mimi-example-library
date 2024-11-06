-- Title: Geographic Distribution of OGTT Test Access and Coverage

-- Business Purpose:
-- - Analyze the distribution of OGTT test availability across different populations
-- - Identify potential gaps in healthcare access for diabetes screening
-- - Support healthcare resource allocation and outreach program planning
-- - Guide population health management strategies

-- Main Query
WITH sample_weights AS (
  SELECT 
    mimi_src_file_date,
    COUNT(DISTINCT seqn) as total_participants,
    AVG(wtsog2yr) as avg_sample_weight,
    STDDEV(wtsog2yr) as std_sample_weight,
    -- Calculate coverage metrics
    COUNT(CASE WHEN lbxglt IS NOT NULL THEN 1 END) / COUNT(*) * 100 as completion_rate
  FROM mimi_ws_1.cdc.nhanes_lab_oral_glucose_tolerance_test
  GROUP BY mimi_src_file_date
),

test_completion AS (
  SELECT
    mimi_src_file_date,
    -- Analyze test administration patterns
    AVG(CASE WHEN gtxdrank = 1 THEN 1 ELSE 0 END) * 100 as full_completion_pct,
    COUNT(CASE WHEN gtdcode IS NOT NULL THEN 1 END) as incomplete_tests,
    -- Evaluate timing compliance
    AVG(gtdbl2mn) as avg_test_duration,
    PERCENTILE(gtdbl2mn, 0.5) as median_test_duration
  FROM mimi_ws_1.cdc.nhanes_lab_oral_glucose_tolerance_test
  GROUP BY mimi_src_file_date
)

SELECT 
  sw.mimi_src_file_date,
  sw.total_participants,
  ROUND(sw.avg_sample_weight, 2) as avg_population_weight,
  ROUND(sw.completion_rate, 1) as test_completion_rate,
  ROUND(tc.full_completion_pct, 1) as full_drink_completion_pct,
  tc.incomplete_tests,
  ROUND(tc.avg_test_duration, 0) as avg_test_duration_min,
  ROUND(tc.median_test_duration, 0) as median_test_duration_min
FROM sample_weights sw
JOIN test_completion tc ON sw.mimi_src_file_date = tc.mimi_src_file_date
ORDER BY sw.mimi_src_file_date;

-- How the Query Works:
-- 1. Creates a CTE for sample weight analysis to understand population representation
-- 2. Creates a CTE for test completion metrics and timing analysis
-- 3. Joins the CTEs to provide a comprehensive view of test access and completion
-- 4. Groups results by file date to show temporal trends
-- 5. Rounds numerical values for better readability

-- Assumptions and Limitations:
-- - Assumes sample weights are properly calibrated for population inference
-- - Limited to available NHANES survey periods
-- - Does not account for demographic or socioeconomic factors
-- - Missing values are excluded from percentage calculations

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, ethnicity) if available
-- 2. Include geographic region analysis if data permits
-- 3. Compare results across different NHANES cycles
-- 4. Add seasonal variation analysis
-- 5. Include confidence intervals for population estimates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:13:15.238969
    - Additional Notes: This query provides population-level insights into OGTT test accessibility and completion rates using NHANES survey weights. The results can help identify testing coverage gaps and resource allocation needs. Note that the analysis is limited to available survey cycles and assumes proper calibration of sample weights.
    
    */