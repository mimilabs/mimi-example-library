-- NHANES Blood Pressure Self-Management Analysis
-- Business Purpose: Analyze patient engagement in blood pressure self-monitoring
-- and adherence to lifestyle modifications, which are critical factors in 
-- hypertension management and healthcare cost reduction.

WITH bp_monitoring AS (
    -- Get blood pressure self-monitoring patterns
    SELECT 
        COUNT(*) as total_respondents,
        SUM(CASE WHEN bpq056 = 1 THEN 1 ELSE 0 END) as home_bp_monitors,
        SUM(CASE WHEN bpq059 = 1 THEN 1 ELSE 0 END) as doctor_recommended,
        SUM(CASE WHEN bpq056 = 1 AND bpq059 = 1 THEN 1 ELSE 0 END) as following_doctor_orders
    FROM mimi_ws_1.cdc.nhanes_qre_blood_pressure_cholesterol
    WHERE bpq020 = 1  -- Only including those diagnosed with hypertension
),

lifestyle_changes AS (
    -- Analyze adherence to lifestyle modifications
    SELECT 
        COUNT(*) as diagnosed_count,
        SUM(CASE WHEN bpq050b = 1 THEN 1 ELSE 0 END) as weight_control,
        SUM(CASE WHEN bpq050c = 1 THEN 1 ELSE 0 END) as sodium_reduction,
        SUM(CASE WHEN bpq050d = 1 THEN 1 ELSE 0 END) as exercise_increase,
        SUM(CASE WHEN bpq050e = 1 THEN 1 ELSE 0 END) as alcohol_reduction
    FROM mimi_ws_1.cdc.nhanes_qre_blood_pressure_cholesterol
    WHERE bpq020 = 1  -- Only including those diagnosed with hypertension
)

SELECT 
    -- Calculate percentages for monitoring patterns
    (home_bp_monitors * 100.0 / total_respondents) as pct_home_monitoring,
    (doctor_recommended * 100.0 / total_respondents) as pct_doctor_recommended,
    (following_doctor_orders * 100.0 / total_respondents) as pct_following_orders,
    
    -- Calculate percentages for lifestyle modifications
    (weight_control * 100.0 / diagnosed_count) as pct_weight_control,
    (sodium_reduction * 100.0 / diagnosed_count) as pct_sodium_reduction,
    (exercise_increase * 100.0 / diagnosed_count) as pct_exercise,
    (alcohol_reduction * 100.0 / diagnosed_count) as pct_alcohol_reduction
FROM bp_monitoring
CROSS JOIN lifestyle_changes;

-- How this query works:
-- 1. First CTE focuses on blood pressure self-monitoring patterns
-- 2. Second CTE analyzes adherence to various lifestyle modifications
-- 3. Main query combines both aspects and calculates percentages
-- 4. All metrics are calculated only for diagnosed hypertensive patients

-- Assumptions and limitations:
-- - Assumes responses are accurate and representative
-- - Missing or null values are treated as non-compliance
-- - Does not account for temporal changes in behavior
-- - Limited to diagnosed hypertensive patients only

-- Possible extensions:
-- 1. Add demographic breakdowns (age groups, gender)
-- 2. Include trend analysis across survey years
-- 3. Correlate with medication adherence patterns
-- 4. Compare outcomes between self-monitoring and non-monitoring groups
-- 5. Add cost-benefit analysis using typical healthcare cost data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:29:51.573484
    - Additional Notes: Query focuses on patient engagement metrics in hypertension self-management, including home monitoring rates and lifestyle modification adherence. Results can be used to identify gaps in patient compliance and opportunities for improved healthcare interventions. Note that percentages may not sum to 100% as patients may be following multiple recommendations simultaneously.
    
    */