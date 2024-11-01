-- NHANES Antacid and Digestive Medication Analysis
-- Business Purpose: This analysis focuses on patient medication use patterns before lab tests to:
-- 1. Identify prevalence of antacid/digestive medication use that could affect lab results
-- 2. Analyze timing patterns of medication intake relative to lab tests 
-- 3. Support lab scheduling and patient preparation protocol improvements

WITH medication_timing AS (
  -- Calculate total minutes since last medication for each type
  SELECT 
    seqn,
    phq050 as took_antacids,
    (COALESCE(phaanthr, 0) * 60 + COALESCE(phaantmn, 0)) as minutes_since_antacids,
    phdsesn as lab_session,
    mimi_src_file_date as survey_date
  FROM mimi_ws_1.cdc.nhanes_lab_fasting_questionnaire
  WHERE phq050 IS NOT NULL  -- Focus on valid responses
),

timing_categories AS (
  -- Categorize medication timing relative to lab tests
  SELECT 
    lab_session,
    CASE 
      WHEN minutes_since_antacids < 120 THEN 'Recent (< 2hrs)'
      WHEN minutes_since_antacids < 360 THEN 'Moderate (2-6hrs)'
      ELSE 'Extended (>6hrs)'
    END as timing_category,
    COUNT(*) as patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY lab_session), 1) as percentage
  FROM medication_timing
  WHERE took_antacids = 1  -- Only include patients who took medications
  GROUP BY lab_session,
    CASE 
      WHEN minutes_since_antacids < 120 THEN 'Recent (< 2hrs)'
      WHEN minutes_since_antacids < 360 THEN 'Moderate (2-6hrs)'
      ELSE 'Extended (>6hrs)'
    END
)

-- Final summary with key metrics
SELECT 
  lab_session,
  timing_category,
  patient_count,
  percentage as pct_of_session,
  ROUND(AVG(percentage) OVER (PARTITION BY timing_category), 1) as avg_pct_across_sessions
FROM timing_categories
ORDER BY 
  lab_session,
  CASE timing_category 
    WHEN 'Recent (< 2hrs)' THEN 1
    WHEN 'Moderate (2-6hrs)' THEN 2
    ELSE 3
  END;

-- How this query works:
-- 1. First CTE (medication_timing) normalizes the hours/minutes into total minutes
-- 2. Second CTE (timing_categories) creates meaningful time categories and calculates distributions
-- 3. Final query adds cross-session averages and formats results for analysis

-- Assumptions and Limitations:
-- - Assumes antacid use is accurately reported by patients
-- - Limited to single medication type analysis
-- - Does not account for medication strength or type
-- - Missing values are excluded from analysis

-- Possible Extensions:
-- 1. Add correlation analysis with specific lab test results
-- 2. Include multiple medication type interactions
-- 3. Add demographic breakdowns of medication timing patterns
-- 4. Incorporate seasonal or temporal trend analysis
-- 5. Compare patterns across different NHANES survey cycles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:56:24.250919
    - Additional Notes: This query specifically tracks antacid medication timing patterns before lab tests, categorizing them into meaningful time windows and comparing distributions across lab sessions. The results can help identify potential impacts on lab test scheduling and patient preparation protocols. Note that the timing categories (2hrs, 6hrs) are based on common clinical guidelines but may need adjustment based on specific lab test requirements.
    
    */