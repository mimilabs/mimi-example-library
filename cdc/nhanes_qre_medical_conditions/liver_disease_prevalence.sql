-- NHANES Liver Disease and Hepatic Conditions Analysis

-- Business Purpose:
-- - Analyze prevalence and characteristics of liver conditions in the population
-- - Examine specific types of liver diseases and their demographics
-- - Identify patterns in liver disease diagnosis timing and current status
-- - Support liver health screening and intervention program planning

WITH liver_conditions AS (
  SELECT 
    -- Basic demographics identifier
    seqn,
    
    -- Core liver disease indicators
    mcq160l AS ever_had_liver_condition,
    mcq170l AS current_liver_condition,
    mcd180l AS age_first_diagnosed,
    
    -- Specific liver condition types (newer survey data)
    mcq500 AS liver_condition_newer,
    mcq510a AS viral_hepatitis,
    mcq510b AS fatty_liver,
    mcq510c AS autoimmune_hepatitis,
    mcq510d AS liver_fibrosis,
    mcq510e AS liver_cirrhosis,
    mcq510f AS other_liver_condition,
    
    -- Related symptoms and complications
    mcq203 AS had_jaundice,
    mcq206 AS age_first_jaundice,
    mcq520 AS abdominal_pain
  FROM mimi_ws_1.cdc.nhanes_qre_medical_conditions
  WHERE mcq160l IS NOT NULL
)

SELECT
  -- Calculate prevalence statistics
  COUNT(*) AS total_respondents,
  SUM(CASE WHEN ever_had_liver_condition = 1 THEN 1 ELSE 0 END) AS total_with_liver_disease,
  ROUND(100.0 * SUM(CASE WHEN ever_had_liver_condition = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS liver_disease_prevalence,
  
  -- Current status metrics
  SUM(CASE WHEN current_liver_condition = 1 THEN 1 ELSE 0 END) AS currently_affected,
  
  -- Age statistics for diagnosis
  AVG(CASE WHEN age_first_diagnosed > 0 THEN age_first_diagnosed END) AS avg_age_at_diagnosis,
  
  -- Specific condition breakdowns (for newer survey data)
  SUM(CASE WHEN viral_hepatitis = 1 THEN 1 ELSE 0 END) AS viral_hepatitis_count,
  SUM(CASE WHEN fatty_liver = 1 THEN 1 ELSE 0 END) AS fatty_liver_count,
  SUM(CASE WHEN liver_cirrhosis = 1 THEN 1 ELSE 0 END) AS cirrhosis_count,
  
  -- Complication indicators
  SUM(CASE WHEN had_jaundice = 1 THEN 1 ELSE 0 END) AS jaundice_cases,
  SUM(CASE WHEN abdominal_pain = 1 THEN 1 ELSE 0 END) AS with_abdominal_pain
FROM liver_conditions;

-- How this query works:
-- 1. Creates a CTE focusing on liver-related fields from the main table
-- 2. Calculates key prevalence metrics and demographics for liver conditions
-- 3. Breaks down specific types of liver diseases where data is available
-- 4. Includes related symptoms and complications

-- Assumptions and Limitations:
-- - Relies on self-reported data which may underestimate true prevalence
-- - Some liver condition types are only available in newer survey years
-- - Age of diagnosis may have recall bias
-- - Cannot determine severity or progression of conditions

-- Possible Extensions:
-- 1. Add demographic breakdowns by age groups, gender, race
-- 2. Analyze correlation with risk factors like alcohol use or obesity
-- 3. Compare liver disease patterns across different survey cycles
-- 4. Calculate time between initial symptoms and diagnosis
-- 5. Examine co-occurrence with other medical conditions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:31:36.739009
    - Additional Notes: Query aggregates both historical and newer survey questions about liver conditions, resulting in potential data inconsistencies across survey years. Consider adding survey year stratification for more accurate trend analysis.
    
    */