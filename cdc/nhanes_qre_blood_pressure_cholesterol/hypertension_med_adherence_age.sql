-- nhanes_bp_meds_demographics.sql
-- Business Purpose: Analyze demographic patterns in hypertension medication prescriptions
-- and usage to identify potential disparities in treatment approaches and adherence.
-- This analysis helps healthcare organizations develop targeted intervention programs
-- and improve medication adherence rates across different patient segments.

WITH medication_patterns AS (
  SELECT 
    -- Basic hypertension diagnosis info
    bpq020 AS has_hypertension,
    bpq030 AS multiple_bp_diagnoses,
    bpd035 AS age_at_diagnosis,
    
    -- Medication prescription and adherence
    bpq040a AS prescribed_bp_meds,
    bpq050a AS taking_bp_meds,
    
    -- Calculate medication adherence rate
    CASE 
      WHEN bpq040a = 1 AND bpq050a = 1 THEN 1
      WHEN bpq040a = 1 AND bpq050a = 2 THEN 0
      ELSE NULL
    END AS med_adherent,
    
    -- Count total patients
    COUNT(*) AS patient_count
  FROM mimi_ws_1.cdc.nhanes_qre_blood_pressure_cholesterol
  WHERE bpq020 = 1  -- Confirmed hypertension diagnosis
  GROUP BY 1,2,3,4,5,6
)

SELECT
  -- Age group analysis
  CASE 
    WHEN age_at_diagnosis < 40 THEN 'Under 40'
    WHEN age_at_diagnosis BETWEEN 40 AND 60 THEN '40-60'
    ELSE 'Over 60'
  END AS age_group,
  
  -- Calculate key metrics
  COUNT(*) AS total_patients,
  SUM(CASE WHEN prescribed_bp_meds = 1 THEN 1 ELSE 0 END) AS prescribed_count,
  ROUND(AVG(CASE WHEN med_adherent = 1 THEN 1.0 ELSE 0 END) * 100, 1) AS adherence_rate,
  
  -- Additional insights
  ROUND(AVG(CASE WHEN multiple_bp_diagnoses = 1 THEN 1.0 ELSE 0 END) * 100, 1) AS pct_multiple_diagnoses

FROM medication_patterns
WHERE age_at_diagnosis IS NOT NULL
GROUP BY 1
ORDER BY age_group;

-- How this query works:
-- 1. First CTE establishes base medication patterns and adherence calculations
-- 2. Main query segments by age groups and calculates key metrics
-- 3. Results show prescription patterns and adherence rates by age demographic

-- Assumptions and Limitations:
-- - Assumes accurate self-reporting of medication usage
-- - Limited to patients with confirmed hypertension diagnosis
-- - Age groupings are simplified for analysis purposes
-- - Does not account for medication types or dosage

-- Possible Extensions:
-- 1. Add temporal trends by including mimi_src_file_date
-- 2. Incorporate cholesterol medication patterns for comorbidity analysis
-- 3. Break down by additional demographic factors when available
-- 4. Add risk stratification based on multiple diagnoses and age
-- 5. Compare against national benchmarks for adherence rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:46:06.511903
    - Additional Notes: Query focuses on age-based patterns in hypertension medication adherence, useful for population health management and intervention planning. Results are grouped into three age brackets (Under 40, 40-60, Over 60) and include prescription rates and adherence metrics. Table must have complete medication and age data for accurate results.
    
    */