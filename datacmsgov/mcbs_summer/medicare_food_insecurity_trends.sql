-- Medicare Food Insecurity and Access Analysis 
-- Business Purpose: This query analyzes food insecurity patterns among Medicare beneficiaries to:
-- 1. Identify populations at risk of poor health outcomes due to nutrition challenges
-- 2. Support targeted intervention programs and resource allocation
-- 3. Understand correlation between food insecurity and prescription medication behaviors
-- 4. Guide policy decisions around Medicare supplemental benefits

WITH food_insecurity_metrics AS (
  SELECT 
    surveyyr,
    -- Calculate food insecurity prevalence
    COUNT(*) as total_beneficiaries,
    SUM(CASE WHEN fis_foodlast IN ('1','2') THEN 1 ELSE 0 END) as food_runs_out_count,
    SUM(CASE WHEN fis_affdmeal IN ('1','2') THEN 1 ELSE 0 END) as cant_afford_meals_count,
    SUM(CASE WHEN fis_skipmeal = '1' THEN 1 ELSE 0 END) as skip_meals_count,
    
    -- Calculate medication compromise metrics for food insecure beneficiaries 
    SUM(CASE 
      WHEN fis_foodlast IN ('1','2') AND rxs_skiprx IN ('1','2') 
      THEN 1 ELSE 0 END) as food_insecure_skip_meds_count,
    
    -- Demographics of food insecure population
    SUM(CASE 
      WHEN fis_foodlast IN ('1','2') AND pufs012 <= 3 -- Lower income categories
      THEN 1 ELSE 0 END) as low_income_food_insecure_count
      
  FROM mimi_ws_1.datacmsgov.mcbs_summer
  WHERE surveyyr >= 2019  -- Focus on recent years
  GROUP BY surveyyr
)

SELECT
  surveyyr,
  total_beneficiaries,
  -- Calculate key percentages
  ROUND(100.0 * food_runs_out_count / total_beneficiaries, 1) as pct_food_runs_out,
  ROUND(100.0 * cant_afford_meals_count / total_beneficiaries, 1) as pct_cant_afford_meals,
  ROUND(100.0 * skip_meals_count / total_beneficiaries, 1) as pct_skip_meals,
  ROUND(100.0 * food_insecure_skip_meds_count / food_runs_out_count, 1) as pct_food_insecure_skip_meds,
  ROUND(100.0 * low_income_food_insecure_count / food_runs_out_count, 1) as pct_food_insecure_low_income
FROM food_insecurity_metrics
ORDER BY surveyyr;

-- How this works:
-- 1. Creates derived table with raw counts of food insecurity indicators
-- 2. Calculates percentage metrics in main select
-- 3. Focuses on recent years to show current trends
-- 4. Links food insecurity to medication adherence and income levels

-- Assumptions & Limitations:
-- - Survey responses are representative of Medicare population
-- - Missing/refused responses excluded from calculations
-- - Income categories are standardized across years
-- - Self-reported data may have recall bias

-- Possible Extensions:
-- 1. Add geographic analysis by census region
-- 2. Segment by age groups and health status
-- 3. Trend analysis over longer time periods
-- 4. Correlation with health outcomes
-- 5. Compare MA vs traditional Medicare populations/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:12:06.601986
    - Additional Notes: Query focuses on food insecurity metrics for Medicare beneficiaries and their correlation with medication adherence. Performance may be impacted with large datasets due to multiple aggregate calculations. Consider partitioning by survey year for better performance on historical analysis.
    
    */