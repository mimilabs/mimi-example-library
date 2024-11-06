-- glycemic_control_metrics.sql -- 
--
-- Business Purpose: 
-- This analysis examines glycemic control among diabetes patients by analyzing A1C test results
-- and comparing them to provider-recommended targets. The insights help:
-- 1. Assess the gap between actual and target A1C levels
-- 2. Identify the portion of patients meeting their glycemic goals
-- 3. Guide interventions for patients with suboptimal control
--

WITH a1c_comparison AS (
  -- Get actual vs target A1C values, filtering nulls and implausible values
  SELECT 
    seqn,
    diq280 as actual_a1c,
    diq29_ as target_a1c
  FROM mimi_ws_1.cdc.nhanes_qre_diabetes
  WHERE diq280 BETWEEN 4.0 AND 15.0  -- Valid A1C range
    AND diq29_ BETWEEN 4.0 AND 15.0
),

glycemic_status AS (
  -- Classify patients based on A1C control
  SELECT
    seqn,
    actual_a1c,
    target_a1c,
    actual_a1c - target_a1c as a1c_gap,
    CASE 
      WHEN actual_a1c <= target_a1c THEN 'At Goal'
      WHEN actual_a1c <= target_a1c + 1 THEN 'Near Goal'
      ELSE 'Above Goal'
    END as control_status
  FROM a1c_comparison
)

-- Generate summary metrics
SELECT
  control_status,
  COUNT(*) as patient_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_patients,
  ROUND(AVG(a1c_gap), 2) as avg_gap_from_target,
  ROUND(AVG(actual_a1c), 1) as avg_actual_a1c,
  ROUND(AVG(target_a1c), 1) as avg_target_a1c
FROM glycemic_status
GROUP BY control_status
ORDER BY 
  CASE control_status 
    WHEN 'At Goal' THEN 1
    WHEN 'Near Goal' THEN 2
    ELSE 3
  END;

-- How this query works:
-- 1. First CTE filters and extracts actual and target A1C values
-- 2. Second CTE calculates gaps and assigns control status
-- 3. Final query summarizes the distribution and key metrics
--
-- Assumptions & Limitations:
-- - Assumes A1C values between 4-15 are valid
-- - Excludes records with missing A1C data
-- - Does not account for temporal changes in A1C
--
-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, etc.)
-- 2. Include insulin/medication usage correlation
-- 3. Analyze trends in A1C control over time
-- 4. Compare with blood pressure and LDL control rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:39:53.765481
    - Additional Notes: Query assumes A1C values between 4.0-15.0 are valid and excludes records outside this range. Results will only include patients who have both actual and target A1C values recorded. Consider local clinical guidelines when interpreting control status thresholds.
    
    */