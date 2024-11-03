-- Title: Condition Complexity Analysis for Care Coordination Planning
-- 
-- Business Purpose:
-- - Identify patients with multiple concurrent conditions to prioritize care coordination
-- - Support risk stratification by quantifying condition complexity per patient
-- - Enable targeted intervention planning for high-complexity cases

WITH concurrent_conditions AS (
    -- Get overlapping conditions per patient during active periods
    SELECT 
        patient,
        DATE_TRUNC('month', start) as month_start,
        COUNT(DISTINCT code) as condition_count
    FROM mimi_ws_1.synthea.conditions
    WHERE stop IS NULL 
        OR stop >= CURRENT_DATE
    GROUP BY patient, DATE_TRUNC('month', start)
),

patient_complexity AS (
    -- Calculate average and max complexity metrics per patient
    SELECT 
        patient,
        AVG(condition_count) as avg_concurrent_conditions,
        MAX(condition_count) as max_concurrent_conditions,
        COUNT(DISTINCT month_start) as months_with_conditions
    FROM concurrent_conditions
    GROUP BY patient
)

SELECT 
    -- Segment patients by complexity tiers
    CASE 
        WHEN max_concurrent_conditions >= 5 THEN 'High Complexity'
        WHEN max_concurrent_conditions >= 3 THEN 'Medium Complexity'
        ELSE 'Low Complexity'
    END as complexity_tier,
    
    -- Calculate key metrics per tier
    COUNT(DISTINCT patient) as patient_count,
    ROUND(AVG(avg_concurrent_conditions), 1) as avg_conditions_per_patient,
    ROUND(AVG(months_with_conditions), 1) as avg_months_with_conditions,
    ROUND(AVG(max_concurrent_conditions), 1) as avg_max_conditions

FROM patient_complexity
GROUP BY 
    CASE 
        WHEN max_concurrent_conditions >= 5 THEN 'High Complexity'
        WHEN max_concurrent_conditions >= 3 THEN 'Medium Complexity'
        ELSE 'Low Complexity'
    END
ORDER BY 
    avg_max_conditions DESC;

-- How this query works:
-- 1. First CTE calculates the number of concurrent conditions per patient-month
-- 2. Second CTE calculates patient-level complexity metrics
-- 3. Main query segments patients into complexity tiers and reports aggregate statistics
--
-- Assumptions and Limitations:
-- - Assumes current conditions are those without stop dates or stop dates >= current date
-- - Treats all conditions with equal weight (no severity consideration)
-- - Monthly granularity may mask shorter-term condition overlaps
-- - Complexity tiers are defined using simple thresholds
--
-- Possible Extensions:
-- - Add condition severity weighting based on historical outcomes
-- - Include demographic factors in complexity assessment
-- - Calculate trend analysis to identify increasing complexity over time
-- - Add cost impact analysis per complexity tier
-- - Include specialty care requirements per tier

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:36:50.243739
    - Additional Notes: The analysis focuses on current patient complexity by counting concurrent conditions. The tiers (High: >=5, Medium: >=3, Low: <3 conditions) are configurable thresholds that may need adjustment based on population health characteristics. Monthly aggregation provides a balance between granularity and computational efficiency.
    
    */