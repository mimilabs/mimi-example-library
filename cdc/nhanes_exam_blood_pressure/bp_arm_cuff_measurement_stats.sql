-- Title: NHANES Blood Pressure Trend Detection by Arm and Cuff Size
--
-- Business Purpose:
-- 1. Evaluate potential measurement biases based on arm selection and cuff size
-- 2. Support medical device manufacturers in optimizing BP cuff designs
-- 3. Guide clinical protocol development for BP measurement standardization
-- 4. Inform medical equipment purchasing decisions for diverse patient populations

WITH avg_readings AS (
    -- Calculate average BP readings per patient
    SELECT 
        seqn,
        bpaarm AS selected_arm,
        bpacsz AS cuff_size,
        ROUND(AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)), 1) AS avg_systolic,
        ROUND(AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)), 1) AS avg_diastolic,
        bpaocsz AS mid_arm_circumference
    FROM mimi_ws_1.cdc.nhanes_exam_blood_pressure
    WHERE bpaarm IS NOT NULL 
    AND bpacsz IS NOT NULL
    GROUP BY seqn, bpaarm, bpacsz, bpaocsz
),

arm_cuff_stats AS (
    -- Generate summary statistics by arm and cuff size
    SELECT 
        selected_arm,
        cuff_size,
        COUNT(*) AS measurement_count,
        ROUND(AVG(avg_systolic), 1) AS mean_systolic,
        ROUND(STDDEV(avg_systolic), 1) AS std_dev_systolic,
        ROUND(AVG(avg_diastolic), 1) AS mean_diastolic,
        ROUND(STDDEV(avg_diastolic), 1) AS std_dev_diastolic,
        ROUND(AVG(mid_arm_circumference), 1) AS avg_arm_circumference
    FROM avg_readings
    GROUP BY selected_arm, cuff_size
)

SELECT 
    selected_arm,
    cuff_size,
    measurement_count,
    mean_systolic,
    std_dev_systolic,
    mean_diastolic,
    std_dev_diastolic,
    avg_arm_circumference,
    -- Calculate variation ratio to identify potential measurement inconsistencies
    ROUND(std_dev_systolic / mean_systolic * 100, 1) AS systolic_variation_pct
FROM arm_cuff_stats
WHERE measurement_count >= 10  -- Filter for statistical significance
ORDER BY measurement_count DESC, mean_systolic DESC;

-- How it works:
-- 1. First CTE calculates individual patient averages across multiple readings
-- 2. Second CTE generates aggregate statistics by arm and cuff size combinations
-- 3. Final query adds variation metrics and filters for statistical significance
--
-- Assumptions and limitations:
-- 1. Assumes multiple readings are comparable and averaging is appropriate
-- 2. Requires minimum sample size (n=10) for meaningful statistics
-- 3. Does not account for temporal factors or measurement conditions
-- 4. Missing or null readings are handled through COALESCE
--
-- Possible extensions:
-- 1. Add temporal analysis to detect measurement drift over time
-- 2. Include demographic stratification for population-specific insights
-- 3. Incorporate measurement quality indicators (enhancement flags)
-- 4. Add confidence intervals for more robust statistical analysis
-- 5. Create size-specific recommendations based on arm circumference ranges

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:23:51.484683
    - Additional Notes: Query requires minimum 10 measurements per arm/cuff combination for reliable statistics. Results focus on measurement methodology rather than clinical outcomes. Best used for equipment procurement and protocol optimization purposes.
    
    */