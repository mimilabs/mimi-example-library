-- Title: NHANES Child Growth Analysis - Pediatric Development Indicators
-- Business Purpose: This query analyzes key anthropometric measurements for children
-- to assess growth patterns and developmental status, supporting pediatric health
-- monitoring and early intervention programs.

WITH pediatric_measurements AS (
    -- Select core measurements for children, focusing on key growth indicators
    SELECT 
        seqn,
        bmxwt as weight_kg,
        bmxrecum as recumbent_length_cm,
        bmxhead as head_circumference_cm,
        bmxht as standing_height_cm,
        bmxbmi as bmi,
        bmxarmc as arm_circumference_cm,
        mimi_src_file_date as measurement_date
    FROM mimi_ws_1.cdc.nhanes_exam_body_measures
    WHERE 
        -- Focus on valid measurements
        bmxwt IS NOT NULL 
        AND (bmxrecum IS NOT NULL OR bmxht IS NOT NULL)
        AND bmxhead IS NOT NULL
),

growth_metrics AS (
    -- Calculate basic growth statistics
    SELECT 
        measurement_date,
        COUNT(*) as total_measurements,
        -- Weight statistics
        ROUND(AVG(weight_kg), 2) as avg_weight_kg,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY weight_kg), 2) as median_weight_kg,
        -- Length/Height statistics
        ROUND(AVG(COALESCE(recumbent_length_cm, standing_height_cm)), 2) as avg_height_cm,
        -- Head circumference statistics
        ROUND(AVG(head_circumference_cm), 2) as avg_head_circumference_cm,
        -- BMI statistics
        ROUND(AVG(bmi), 2) as avg_bmi,
        -- Arm circumference statistics
        ROUND(AVG(arm_circumference_cm), 2) as avg_arm_circumference_cm
    FROM pediatric_measurements
    GROUP BY measurement_date
    ORDER BY measurement_date
)

SELECT * FROM growth_metrics;

-- How this query works:
-- 1. First CTE selects relevant pediatric measurements, excluding NULL values
-- 2. Second CTE calculates average growth metrics by measurement date
-- 3. Final output presents temporal trends in child growth indicators

-- Assumptions and limitations:
-- - Assumes measurements are taken consistently across survey periods
-- - Does not account for age groups or gender differences
-- - Missing values are excluded from calculations
-- - Does not differentiate between recumbent and standing height based on age

-- Possible extensions:
-- 1. Add age group stratification for more precise developmental assessment
-- 2. Include gender-specific analysis
-- 3. Calculate z-scores based on WHO growth standards
-- 4. Add flags for measurements outside expected ranges
-- 5. Incorporate seasonal variation analysis
-- 6. Add trending analysis across multiple survey cycles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:07:00.316724
    - Additional Notes: Query focuses on population-level pediatric growth metrics across measurement periods. Data aggregation at the date level provides temporal trends but may mask individual variations. Consider adding age/gender stratification for clinical applications.
    
    */