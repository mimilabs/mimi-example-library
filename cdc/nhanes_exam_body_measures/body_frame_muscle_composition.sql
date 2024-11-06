-- Title: NHANES Adult Body Composition - Muscle Mass and Body Frame Analysis
-- Business Purpose:
-- This query analyzes key anthropometric measurements related to muscle mass and body frame
-- dimensions from the NHANES dataset. The analysis helps healthcare providers and fitness 
-- professionals understand population-level muscle mass distribution and frame size variations,
-- supporting personalized nutrition and exercise recommendations.

WITH valid_measurements AS (
    SELECT 
        seqn,
        bmxwt,  -- Weight in kg
        bmxht,  -- Height in cm
        bmxarmc,  -- Arm circumference 
        bmxleg,   -- Leg length
        bmxarml,  -- Arm length
        -- Calculate body surface area using Mosteller formula
        SQRT((bmxwt * bmxht) / 3600) as body_surface_area
    FROM mimi_ws_1.cdc.nhanes_exam_body_measures
    WHERE bmxwt IS NOT NULL 
        AND bmxht IS NOT NULL
        AND bmxarmc IS NOT NULL
        AND bmxleg IS NOT NULL
        AND bmxarml IS NOT NULL
),

frame_size_calculations AS (
    SELECT 
        *,
        -- Classify frame size based on arm length to height ratio
        CASE 
            WHEN (bmxarml / bmxht) < 0.36 THEN 'Small Frame'
            WHEN (bmxarml / bmxht) > 0.38 THEN 'Large Frame'
            ELSE 'Medium Frame'
        END as frame_size,
        -- Estimate muscle mass using arm circumference and height
        -- This is a simplified approximation
        (bmxarmc * bmxht) / 100 as estimated_muscle_index
    FROM valid_measurements
)

SELECT 
    frame_size,
    COUNT(*) as population_count,
    ROUND(AVG(estimated_muscle_index), 2) as avg_muscle_index,
    ROUND(AVG(body_surface_area), 2) as avg_body_surface_area,
    ROUND(AVG(bmxwt), 2) as avg_weight_kg,
    ROUND(AVG(bmxht), 2) as avg_height_cm,
    ROUND(AVG(bmxarmc), 2) as avg_arm_circumference_cm
FROM frame_size_calculations
GROUP BY frame_size
ORDER BY frame_size;

-- How this query works:
-- 1. First CTE filters for complete records with required measurements
-- 2. Second CTE calculates body frame size classification and estimated muscle mass
-- 3. Final SELECT aggregates results by frame size with key metrics
-- 4. Results provide population-level insights into body composition variations

-- Assumptions and Limitations:
-- 1. Assumes measurements are accurate and representative of the population
-- 2. Muscle mass estimation is simplified and should be validated clinically
-- 3. Frame size calculations use approximate ratios and may need adjustment
-- 4. Missing data is excluded which could impact population representations

-- Possible Extensions:
-- 1. Add age and gender stratification for more detailed analysis
-- 2. Incorporate additional circumference measurements for better muscle estimation
-- 3. Compare results across different NHANES survey years for trend analysis
-- 4. Add percentile calculations for each metric within frame size groups
-- 5. Include correlation analysis between muscle mass and other health indicators

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:02:36.559844
    - Additional Notes: The query uses simplified anthropometric ratios to estimate frame size and muscle mass. The muscle mass calculation is an approximation and should not be used for clinical decisions without validation. Consider local population characteristics when interpreting frame size classifications.
    
    */