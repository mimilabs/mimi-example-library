-- Title: NHANES Pre-Exam Blood Pressure Risk Factor Analysis
-- Business Purpose:
-- 1. Analyze the impact of common pre-exam behaviors (food, alcohol, coffee, cigarettes) on blood pressure readings
-- 2. Help healthcare providers understand how these factors may affect measurement accuracy
-- 3. Support clinical protocols for standardizing blood pressure measurement conditions
-- 4. Identify potential measurement bias factors for population health studies

WITH bp_measurements AS (
    -- Calculate average BP per person from multiple readings
    SELECT 
        seqn,
        ROUND(AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)), 1) as avg_systolic,
        ROUND(AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)), 1) as avg_diastolic,
        MAX(bpq150a) as had_food,
        MAX(bpq150b) as had_alcohol,
        MAX(bpq150c) as had_coffee,
        MAX(bpq150d) as had_cigarettes
    FROM mimi_ws_1.cdc.nhanes_exam_blood_pressure
    GROUP BY seqn
)

SELECT 
    -- Risk factor presence
    CASE 
        WHEN had_food = 1 THEN 'Yes'
        WHEN had_food = 2 THEN 'No'
        ELSE 'Unknown'
    END as consumed_food_30min,
    
    CASE 
        WHEN had_alcohol = 1 THEN 'Yes'
        WHEN had_alcohol = 2 THEN 'No'
        ELSE 'Unknown'
    END as consumed_alcohol_30min,
    
    CASE 
        WHEN had_coffee = 1 THEN 'Yes'
        WHEN had_coffee = 2 THEN 'No'
        ELSE 'Unknown'
    END as consumed_coffee_30min,
    
    CASE 
        WHEN had_cigarettes = 1 THEN 'Yes'
        WHEN had_cigarettes = 2 THEN 'No'
        ELSE 'Unknown'
    END as smoked_cigarettes_30min,
    
    -- BP statistics by risk factor group
    COUNT(*) as patient_count,
    ROUND(AVG(avg_systolic), 1) as mean_systolic,
    ROUND(AVG(avg_diastolic), 1) as mean_diastolic,
    
    -- Hypertension risk assessment
    ROUND(100.0 * SUM(CASE WHEN avg_systolic >= 130 OR avg_diastolic >= 80 THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_elevated_bp

FROM bp_measurements
GROUP BY had_food, had_alcohol, had_coffee, had_cigarettes
HAVING patient_count >= 10  -- Exclude small groups for statistical reliability
ORDER BY patient_count DESC

-- How this query works:
-- 1. Creates a CTE to calculate average BP per person and collect risk factors
-- 2. Main query transforms risk factor codes into readable labels
-- 3. Calculates key BP statistics for each combination of risk factors
-- 4. Filters out small groups and sorts by sample size

-- Assumptions and Limitations:
-- 1. Uses average of available BP readings (up to 3) per person
-- 2. Assumes BP measurements were taken according to standard protocols
-- 3. Does not account for timing of consumption within the 30-minute window
-- 4. Does not control for other factors like age, medications, or medical history

-- Possible Extensions:
-- 1. Add temporal analysis to see if effects vary by time of day
-- 2. Include demographic factors to identify vulnerable populations
-- 3. Compare results against baseline BP measurements
-- 4. Add statistical significance testing for group differences
-- 5. Create risk adjustment factors for population health studies

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:32:48.389294
    - Additional Notes: Query focuses on common pre-exam behaviors (food, alcohol, coffee, cigarettes) and their relationship with blood pressure readings. Results are aggregated by risk factor combinations with a minimum group size of 10 patients for statistical reliability. The analysis includes both mean BP values and percentage of elevated readings for each risk factor group.
    
    */