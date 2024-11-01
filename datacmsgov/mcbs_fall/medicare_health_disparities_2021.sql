-- Medicare Health Disparities Analysis
--
-- Business Purpose:
-- Analyze health disparities across different demographic groups of Medicare beneficiaries
-- to identify populations at higher risk for poor health outcomes and inform targeted
-- interventions and policy recommendations.

WITH health_status AS (
  -- Calculate health status indicators by demographic group
  SELECT
    dem_race, 
    dem_edu,
    dem_income,
    COUNT(*) as total_beneficiaries,
    
    -- Poor health indicators
    AVG(CASE WHEN hlt_genhelth IN ('4','5') THEN 1 ELSE 0 END) as pct_poor_health,
    AVG(CASE WHEN hlt_ocbetes = '1' THEN 1 ELSE 0 END) as pct_diabetes,
    AVG(CASE WHEN hlt_ochbp = '1' THEN 1 ELSE 0 END) as pct_hypertension,
    AVG(CASE WHEN hlt_ocdeprss = '1' THEN 1 ELSE 0 END) as pct_depression,
    
    -- Access barriers
    AVG(CASE WHEN acc_hctroubl = '1' THEN 1 ELSE 0 END) as pct_access_trouble,
    AVG(CASE WHEN acc_hcdelay = '1' THEN 1 ELSE 0 END) as pct_delayed_care,
    AVG(CASE WHEN acc_payprob = '1' THEN 1 ELSE 0 END) as pct_payment_problems
    
  FROM mimi_ws_1.datacmsgov.mcbs_fall
  WHERE surveyyr = '2021' -- Focus on most recent year
  GROUP BY dem_race, dem_edu, dem_income
)

SELECT
  -- Format demographic categories
  CASE dem_race 
    WHEN '1' THEN 'Non-Hispanic White'
    WHEN '2' THEN 'Non-Hispanic Black' 
    WHEN '3' THEN 'Hispanic'
    WHEN '4' THEN 'Other'
  END as race_ethnicity,
  
  CASE dem_edu
    WHEN '1' THEN 'Less than HS'
    WHEN '2' THEN 'HS/Vocational'
    WHEN '3' THEN 'More than HS'
  END as education,
  
  CASE dem_income
    WHEN '1' THEN 'Under $25K'
    WHEN '2' THEN '$25K or more'
  END as income_level,
  
  -- Round percentages to 2 decimal places
  ROUND(pct_poor_health * 100, 2) as pct_poor_health,
  ROUND(pct_diabetes * 100, 2) as pct_diabetes,
  ROUND(pct_hypertension * 100, 2) as pct_hypertension,
  ROUND(pct_depression * 100, 2) as pct_depression,
  ROUND(pct_access_trouble * 100, 2) as pct_access_trouble,
  ROUND(pct_delayed_care * 100, 2) as pct_delayed_care,
  ROUND(pct_payment_problems * 100, 2) as pct_payment_problems,
  
  total_beneficiaries

FROM health_status
WHERE total_beneficiaries >= 100 -- Filter out small cells
ORDER BY 
  race_ethnicity,
  education,
  income_level;

-- How this works:
-- 1. Creates a CTE to calculate health status indicators by demographic group
-- 2. Uses CASE statements to convert categorical codes to readable labels
-- 3. Calculates percentages for key health and access measures
-- 4. Filters out small cell sizes and formats output

-- Assumptions and Limitations:
-- - Uses 2021 data only - trends over time not captured
-- - Self-reported data may have reporting biases
-- - Does not account for geographic variations
-- - Small cell sizes suppressed for statistical reliability
-- - Does not control for age or other confounding factors

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic analysis by metro/non-metro areas
-- 3. Add risk-adjusted measures controlling for age/gender
-- 4. Analyze disparities in preventive care utilization
-- 5. Examine variations in Medicare Advantage vs Traditional Medicare
-- 6. Add statistical testing for significant differences between groups

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:17:37.725174
    - Additional Notes: Query focuses on health outcome disparities across demographic groups in 2021. Results show percentages for poor health status, chronic conditions, and access barriers stratified by race/ethnicity, education, and income. Requires at least 100 beneficiaries per demographic group for reliable estimates.
    
    */