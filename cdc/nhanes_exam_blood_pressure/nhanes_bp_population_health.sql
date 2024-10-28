
/*******************************************************************************
Title: NHANES Blood Pressure Analysis - Basic Population Health Assessment

Business Purpose:
This query analyzes blood pressure measurements from the NHANES dataset to:
1. Calculate average systolic and diastolic readings across measurements
2. Classify blood pressure according to clinical guidelines
3. Provide a population-level view of hypertension prevalence
********************************************************************************/

WITH avg_bp AS (
  -- Calculate mean BP using all available readings per person
  SELECT 
    seqn,
    ROUND(AVG(COALESCE(bpxsy1, bpxsy2, bpxsy3, bpxsy4)), 1) as avg_systolic,
    ROUND(AVG(COALESCE(bpxdi1, bpxdi2, bpxdi3, bpxdi4)), 1) as avg_diastolic
  FROM mimi_ws_1.cdc.nhanes_exam_blood_pressure
  GROUP BY seqn
)

SELECT
  -- Classify BP according to American Heart Association guidelines
  CASE 
    WHEN avg_systolic < 120 AND avg_diastolic < 80 THEN 'Normal'
    WHEN (avg_systolic >= 120 AND avg_systolic < 130) AND avg_diastolic < 80 THEN 'Elevated'
    WHEN (avg_systolic >= 130 AND avg_systolic < 140) OR (avg_diastolic >= 80 AND avg_diastolic < 90) THEN 'Stage 1 Hypertension'
    WHEN avg_systolic >= 140 OR avg_diastolic >= 90 THEN 'Stage 2 Hypertension'
    ELSE 'Invalid/Missing Data'
  END as bp_category,
  
  -- Calculate summary statistics
  COUNT(*) as patient_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage,
  ROUND(AVG(avg_systolic), 1) as mean_systolic,
  ROUND(AVG(avg_diastolic), 1) as mean_diastolic

FROM avg_bp
WHERE avg_systolic IS NOT NULL 
  AND avg_diastolic IS NOT NULL
GROUP BY bp_category
ORDER BY 
  CASE bp_category
    WHEN 'Normal' THEN 1
    WHEN 'Elevated' THEN 2
    WHEN 'Stage 1 Hypertension' THEN 3
    WHEN 'Stage 2 Hypertension' THEN 4
    ELSE 5
  END;

/*******************************************************************************
How this query works:
1. Calculates average BP per person using all available readings
2. Classifies BP according to clinical guidelines
3. Provides distribution statistics across categories

Assumptions and Limitations:
- Uses simple averaging of readings (could be refined with time-weighted approaches)
- Assumes readings are valid and properly collected
- Does not account for measurement conditions or patient characteristics
- Classification uses AHA guidelines which may differ from other standards

Possible Extensions:
1. Add demographic breakdowns (would need to join with demographics table)
2. Include time-of-day analysis
3. Factor in recent food/alcohol/coffee consumption (using bpq150* columns)
4. Add trend analysis across different survey years
5. Include pulse pressure and other derived metrics
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:00:03.560709
    - Additional Notes: Query aggregates blood pressure readings from NHANES dataset to provide population-level hypertension classification statistics based on AHA guidelines. Results represent a point-in-time snapshot and should be interpreted within the context of the NHANES survey period. Users should verify the clinical guidelines are current before using for medical decision-making.
    
    */