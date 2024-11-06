-- NHANES Cancer History and Screening Patterns Analysis

-- Business Purpose:
-- - Analyze prevalence of different types of cancer across the population 
-- - Identify patterns in age of diagnosis for common cancers
-- - Examine family history connections and screening behaviors
-- - Support population health cancer screening program design

-- Main Query 
WITH cancer_prevalence AS (
  SELECT
    -- Basic cancer diagnosis check
    COUNT(*) as total_respondents,
    COUNT(CASE WHEN mcq220 = 1 THEN 1 END) as had_cancer,
    
    -- Most common cancer types
    SUM(CASE WHEN mcq230a = 1 OR mcq230b = 1 OR mcq230c = 1 THEN 1 END) as bladder_cancer,
    SUM(CASE WHEN mcq230a = 4 OR mcq230b = 4 OR mcq230c = 4 THEN 1 END) as breast_cancer,
    SUM(CASE WHEN mcq230a = 19 OR mcq230b = 19 OR mcq230c = 19 THEN 1 END) as prostate_cancer,
    SUM(CASE WHEN mcq230a = 22 OR mcq230b = 22 OR mcq230c = 22 THEN 1 END) as skin_cancer,
    
    -- Age patterns  
    AVG(CASE WHEN mcq230a = 4 THEN mcd240a -- Breast cancer age
             WHEN mcq230b = 4 THEN mcd240b 
             WHEN mcq230c = 4 THEN mcd240c END) as avg_breast_cancer_age,
             
    -- Family history
    COUNT(CASE WHEN mcq300c = 1 THEN 1 END) as family_history_count,
    
    -- Screening behavior (using PSA as example)
    COUNT(CASE WHEN mcq310 = 1 THEN 1 END) as had_psa_screening
    
  FROM mimi_ws_1.cdc.nhanes_qre_medical_conditions
)

SELECT
  total_respondents,
  had_cancer,
  ROUND(100.0 * had_cancer/total_respondents, 1) as cancer_prevalence_pct,
  
  -- Common cancer type counts
  bladder_cancer,
  breast_cancer, 
  prostate_cancer,
  skin_cancer,
  
  -- Age metrics
  ROUND(avg_breast_cancer_age, 1) as avg_breast_cancer_diagnosis_age,
  
  -- Screening metrics
  had_psa_screening,
  ROUND(100.0 * had_psa_screening/total_respondents, 1) as psa_screening_pct
  
FROM cancer_prevalence;

-- How this query works:
-- 1. Creates CTE to calculate key cancer statistics
-- 2. Uses CASE statements to identify different cancer types across multiple columns
-- 3. Calculates prevalence percentages and averages in final SELECT
-- 4. Rounds numeric results for readability

-- Assumptions and Limitations:
-- - Cancer types are coded consistently across mcq230a/b/c columns
-- - Age values are recorded accurately in source data
-- - PSA screening is representative of general cancer screening patterns
-- - Family history may be underreported

-- Possible Extensions:
-- 1. Add demographic breakdowns by age groups and gender
-- 2. Include temporal trends if data spans multiple years
-- 3. Analyze correlation between family history and cancer occurrence
-- 4. Compare screening rates across different cancer types
-- 5. Add survival analysis metrics if outcome data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:32:40.011995
    - Additional Notes: Query focuses on key cancer metrics from NHANES data, including prevalence rates, common cancer types, diagnosis ages, and screening behaviors. PSA screening is used as a representative example but may not reflect overall cancer screening patterns. Results are population-level aggregates without demographic stratification.
    
    */