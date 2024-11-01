-- Title: NHANES Blood Pressure Measurement Quality and Reliability Analysis

-- Business Purpose:
-- 1. Assess the quality and reliability of blood pressure measurements in the NHANES dataset
-- 2. Identify patterns in measurement variations that could impact clinical decisions
-- 3. Support quality improvement initiatives in blood pressure measurement protocols
-- 4. Help clinicians understand the reliability of different measurement methods

WITH measurement_variance AS (
    -- Calculate variance between manual and oscillometric readings
    SELECT 
        seqn,
        -- Average of manual readings
        (bpxsy1 + bpxsy2 + bpxsy3) / 3.0 as avg_manual_systolic,
        (bpxdi1 + bpxdi2 + bpxdi3) / 3.0 as avg_manual_diastolic,
        -- Average of oscillometric readings
        (bpxosy1 + bpxosy2 + bpxosy3) / 3.0 as avg_oscil_systolic,
        (bpxodi1 + bpxodi2 + bpxodi3) / 3.0 as avg_oscil_diastolic,
        -- Arm measurements
        bpaarm as arm_side,  -- Using bpaarm instead of bpaoarm
        bpaocsz
    FROM mimi_ws_1.cdc.nhanes_exam_blood_pressure
    WHERE bpxsy1 IS NOT NULL 
      AND bpxosy1 IS NOT NULL
)

SELECT 
    -- Calculate summary statistics
    COUNT(*) as total_measurements,
    
    -- Method comparison
    ROUND(AVG(ABS(avg_manual_systolic - avg_oscil_systolic)), 1) as avg_systolic_difference,
    ROUND(AVG(ABS(avg_manual_diastolic - avg_oscil_diastolic)), 1) as avg_diastolic_difference,
    
    -- Measurement consistency
    ROUND(STDDEV(avg_manual_systolic), 1) as manual_systolic_std_dev,
    ROUND(STDDEV(avg_oscil_systolic), 1) as oscil_systolic_std_dev,
    
    -- Arm measurements
    ROUND(AVG(bpaocsz), 1) as avg_arm_circumference,
    SUM(CASE WHEN arm_side = '1' THEN 1 ELSE 0 END) as right_arm_count,
    SUM(CASE WHEN arm_side = '2' THEN 1 ELSE 0 END) as left_arm_count

FROM measurement_variance;

-- How this query works:
-- 1. Creates a CTE to calculate averages for both manual and oscillometric measurements
-- 2. Uses bpaarm instead of bpaoarm for arm selection
-- 3. Treats arm selection values as strings instead of integers
-- 4. Uses SUM with CASE statements instead of COUNT for arm counts
-- 5. Provides summary statistics about measurement variation

-- Assumptions and Limitations:
-- 1. Assumes both manual and oscillometric readings were taken properly
-- 2. Doesn't account for timing between measurements
-- 3. Treats all measurements as equally valid
-- 4. Doesn't consider patient conditions that might affect measurement accuracy
-- 5. Assumes arm selection is coded as '1' for right and '2' for left

-- Possible Extensions:
-- 1. Add time-based analysis to see if measurement differences vary by time of day
-- 2. Include analysis of pulse pressure and irregular heartbeat impact
-- 3. Segment analysis by arm circumference ranges
-- 4. Add quality control metrics based on standard deviation thresholds
-- 5. Compare measurement variations across different NHANES survey cycles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:48:56.725811
    - Additional Notes: Query focuses on comparing manual vs oscillometric blood pressure measurement methods and provides quality metrics including measurement differences and arm selection patterns. Note that arm selection coding assumes '1'=right and '2'=left arm, which should be verified against the source data documentation.
    
    */