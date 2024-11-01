-- NHANES Cardiovascular Disease Risk Profile Analysis 
-- Business Purpose:
-- - Identify prevalence of key cardiovascular conditions and risk factors
-- - Analyze age of onset patterns for heart disease, stroke, and related conditions
-- - Understand familial risk patterns through family history data
-- - Support population health management and prevention strategies

WITH cardio_conditions AS (
  SELECT 
    seqn,
    -- Core cardiovascular conditions
    mcq160b as has_heart_failure,
    mcq160c as has_coronary_disease, 
    mcq160d as has_angina,
    mcq160e as has_heart_attack,
    mcq160f as has_stroke,
    -- Age at diagnosis 
    mcd180b as age_heart_failure_dx,
    mcd180c as age_coronary_dx,
    mcd180d as age_angina_dx,
    mcd180e as age_heart_attack_dx,
    mcd180f as age_stroke_dx,
    -- Risk factors
    mcq080 as told_overweight,
    mcq366c as told_reduce_sodium,
    mcq366d as told_reduce_fat,
    -- Family history
    mcq300a as family_history_heart_disease
  FROM mimi_ws_1.cdc.nhanes_qre_medical_conditions
)

SELECT
  -- Overall prevalence 
  COUNT(*) as total_participants,
  SUM(CASE WHEN has_heart_failure = 1 OR has_coronary_disease = 1 OR 
          has_angina = 1 OR has_heart_attack = 1 OR has_stroke = 1 
      THEN 1 ELSE 0 END) as any_cardio_condition,
      
  -- Specific condition counts
  SUM(CASE WHEN has_heart_failure = 1 THEN 1 ELSE 0 END) as heart_failure_count,
  SUM(CASE WHEN has_coronary_disease = 1 THEN 1 ELSE 0 END) as coronary_disease_count,
  SUM(CASE WHEN has_angina = 1 THEN 1 ELSE 0 END) as angina_count,
  SUM(CASE WHEN has_heart_attack = 1 THEN 1 ELSE 0 END) as heart_attack_count,
  SUM(CASE WHEN has_stroke = 1 THEN 1 ELSE 0 END) as stroke_count,

  -- Average age at diagnosis
  AVG(age_heart_failure_dx) as avg_age_heart_failure_dx,
  AVG(age_coronary_dx) as avg_age_coronary_dx, 
  AVG(age_angina_dx) as avg_age_angina_dx,
  AVG(age_heart_attack_dx) as avg_age_heart_attack_dx,
  AVG(age_stroke_dx) as avg_age_stroke_dx,
  
  -- Risk factor prevalence
  SUM(CASE WHEN told_overweight = 1 THEN 1 ELSE 0 END) as told_overweight_count,
  SUM(CASE WHEN told_reduce_sodium = 1 THEN 1 ELSE 0 END) as told_reduce_sodium_count,
  SUM(CASE WHEN told_reduce_fat = 1 THEN 1 ELSE 0 END) as told_reduce_fat_count,
  
  -- Family history
  SUM(CASE WHEN family_history_heart_disease = 1 THEN 1 ELSE 0 END) as family_history_count

FROM cardio_conditions;

-- How this query works:
-- 1. Creates CTE to organize relevant cardiovascular fields
-- 2. Calculates overall prevalence of any cardiovascular condition
-- 3. Breaks down counts by specific conditions
-- 4. Analyzes average age at diagnosis for each condition
-- 5. Examines prevalence of key risk factors
-- 6. Includes family history data

-- Assumptions and Limitations:
-- - Relies on self-reported data from survey participants
-- - Ages of diagnosis may be subject to recall bias
-- - Family history limited to early-onset heart disease
-- - Does not account for survey weights or sampling design

-- Possible Extensions:
-- 1. Add demographic stratification (age groups, gender, race/ethnicity)
-- 2. Include medication and treatment adherence analysis
-- 3. Expand risk factor analysis to include BMI and blood pressure
-- 4. Add temporal trends if multiple survey years available
-- 5. Calculate risk scores based on multiple factors
-- 6. Add geographic analysis if location data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:41:13.637450
    - Additional Notes: Query focuses on population-level cardiovascular health metrics using NHANES data. Key metrics include condition prevalence, age of onset, risk factors, and family history patterns. The CTE structure allows for easy modification to add demographic or temporal analysis. Note that results should be interpreted with consideration for survey methodology and self-reporting bias.
    
    */