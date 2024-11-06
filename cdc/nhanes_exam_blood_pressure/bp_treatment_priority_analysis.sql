-- Title: NHANES Blood Pressure Treatment Protocol Analysis

-- Business Purpose:
-- 1. Analyze blood pressure measurements to identify patients requiring immediate medical attention
-- 2. Support clinical decision-making by flagging severe hypertension cases
-- 3. Help healthcare providers prioritize patient interventions based on BP severity
-- 4. Generate actionable insights for emergency department protocols

SELECT 
    seqn,
    -- Calculate average BP readings across measurements
    ROUND(AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)), 1) as avg_systolic,
    ROUND(AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)), 1) as avg_diastolic,
    
    -- Classify BP severity based on AHA guidelines
    CASE 
        WHEN AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)) >= 180 
          OR AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)) >= 120 
        THEN 'Hypertensive Crisis'
        WHEN AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)) >= 140 
          OR AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)) >= 90 
        THEN 'Hypertensive'
        WHEN AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)) >= 120 
          AND AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)) < 80 
        THEN 'Isolated Systolic'
        ELSE 'Normal'
    END as bp_classification,
    
    -- Flag cases requiring immediate attention
    CASE 
        WHEN AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3)) >= 180 
          OR AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3)) >= 120 
        THEN 'Immediate Action Required'
        ELSE 'Routine Follow-up'
    END as action_needed,
    
    -- Count number of valid readings
    COUNT(DISTINCT CASE WHEN bpxsy1 IS NOT NULL THEN 1 
                       WHEN bpxsy2 IS NOT NULL THEN 2
                       WHEN bpxsy3 IS NOT NULL THEN 3
                  END) as valid_readings_count

FROM mimi_ws_1.cdc.nhanes_exam_blood_pressure
GROUP BY seqn
HAVING valid_readings_count > 0
ORDER BY 
    CASE WHEN bp_classification = 'Hypertensive Crisis' THEN 1
         WHEN bp_classification = 'Hypertensive' THEN 2
         WHEN bp_classification = 'Isolated Systolic' THEN 3
         ELSE 4
    END,
    avg_systolic DESC;

-- How the Query Works:
-- 1. Aggregates multiple BP readings per patient to get average values
-- 2. Classifies BP severity using American Heart Association guidelines
-- 3. Flags cases requiring immediate medical attention
-- 4. Counts valid readings to ensure data quality
-- 5. Orders results to prioritize severe cases

-- Assumptions and Limitations:
-- 1. Uses standard BP classification thresholds which may need adjustment for specific populations
-- 2. Requires at least one valid BP reading per patient
-- 3. Treats all readings as equally valid (no time-based weighting)
-- 4. Does not account for patient medical history or medications

-- Possible Extensions:
-- 1. Add pulse pressure calculation (systolic - diastolic)
-- 2. Incorporate age-specific BP thresholds
-- 3. Add trend analysis for patients with multiple visits
-- 4. Include risk factor analysis (smoking, alcohol, etc.)
-- 5. Add demographic stratification for population health analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:25:25.381385
    - Additional Notes: This query focuses on critical care prioritization and aligns with emergency department triage protocols. The BP classifications follow AHA guidelines but may need adjustment based on specific hospital protocols. The HAVING clause filters out records with no valid readings, which could exclude some records from the analysis.
    
    */