-- Medicare Beneficiary COVID-19 Vaccination Status and Trends Analysis

-- Business Purpose: This query analyzes COVID-19 vaccination patterns among Medicare beneficiaries to:
-- 1. Track vaccination coverage and identify gaps in vaccine uptake
-- 2. Support targeted outreach and education efforts
-- 3. Monitor health equity in vaccine distribution
-- 4. Inform policy decisions around booster campaigns

WITH base_population AS (
  SELECT 
    surveyyr,
    pufs006 as race_ethnicity,
    pufs012 as income_category,
    pufs011 as census_region,
    cvs_vcnums as total_doses,
    cvs_onedose as received_first_dose,
    cvs_twodose as completed_initial_series,
    pufswgt as sample_weight
  FROM mimi_ws_1.datacmsgov.mcbs_summer
  WHERE surveyyr >= 2020
    AND surveyyr <= 2021
    AND cvs_vcnums IS NOT NULL
)

SELECT
  surveyyr,
  race_ethnicity,
  income_category,
  census_region,
  -- Calculate key vaccination metrics
  COUNT(*) * AVG(sample_weight) as weighted_beneficiaries,
  SUM(CASE WHEN received_first_dose = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_first_dose,
  SUM(CASE WHEN completed_initial_series = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_completed_series,
  AVG(CAST(total_doses as FLOAT)) as avg_doses_per_beneficiary,
  -- Track high coverage (3+ doses)
  SUM(CASE WHEN CAST(total_doses as INT) >= 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_three_plus_doses
FROM base_population
GROUP BY 
  surveyyr,
  race_ethnicity,
  income_category, 
  census_region
ORDER BY 
  surveyyr,
  race_ethnicity,
  income_category,
  census_region;

-- How this query works:
-- 1. Creates base population CTE with relevant vaccination and demographic fields
-- 2. Calculates weighted population totals and vaccination rates
-- 3. Segments analysis by key demographic factors
-- 4. Provides year-over-year trends from 2020-2021

-- Assumptions and Limitations:
-- 1. Relies on self-reported vaccination status
-- 2. Limited to 2020-2021 survey years when COVID vaccines were available
-- 3. Sample weights needed for population-level estimates
-- 4. Missing or refused responses excluded from calculations

-- Possible Extensions:
-- 1. Add confidence intervals around vaccination rates
-- 2. Incorporate health status and comorbidity analysis
-- 3. Compare vaccination rates to local COVID infection rates
-- 4. Analyze impact of Medicare coverage type on vaccination
-- 5. Include geographic analysis at more granular level

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:11:51.744244
    - Additional Notes: Query requires survey years 2020-2021 for complete vaccination data. Sample weights must be properly applied for accurate population estimates. Results are stratified by key demographic factors to support equity analysis.
    
    */