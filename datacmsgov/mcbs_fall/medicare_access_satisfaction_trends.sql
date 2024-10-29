-- Medicare Beneficiary Access and Satisfaction Analysis
--
-- Business Purpose:
-- Analyze Medicare beneficiaries' healthcare access barriers and satisfaction levels
-- to identify opportunities for improving care delivery and patient experience.
-- This insight helps healthcare organizations optimize their service offerings 
-- and Medicare Advantage plans tailor their benefits.

-- Main Query
SELECT 
  surveyyr as survey_year,
  
  -- Access barriers
  COUNT(*) as total_beneficiaries,
  SUM(CASE WHEN acc_hctroubl = 1 THEN 1 ELSE 0 END) as had_trouble_getting_care,
  SUM(CASE WHEN acc_hcdelay = 1 THEN 1 ELSE 0 END) as delayed_care_cost,
  SUM(CASE WHEN acc_payprob = 1 THEN 1 ELSE 0 END) as payment_problems,
  
  -- Satisfaction metrics 
  SUM(CASE WHEN acc_mcqualty = 1 THEN 1 ELSE 0 END) as very_satisfied_quality,
  SUM(CASE WHEN acc_mccosts = 1 THEN 1 ELSE 0 END) as very_satisfied_costs,
  SUM(CASE WHEN acc_mcconcrn = 1 THEN 1 ELSE 0 END) as very_satisfied_dr_concern,
  
  -- Calculate percentages
  ROUND(100.0 * SUM(CASE WHEN acc_hctroubl = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) 
    as pct_trouble_access,
  ROUND(100.0 * SUM(CASE WHEN acc_mcqualty = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) 
    as pct_very_satisfied_quality

FROM mimi_ws_1.datacmsgov.mcbs_fall

-- Filter to most recent years for trending
WHERE surveyyr >= 2019

GROUP BY surveyyr
ORDER BY surveyyr DESC;

-- How this query works:
-- 1. Aggregates key metrics around healthcare access barriers and satisfaction levels
-- 2. Calculates both raw counts and percentages for trend analysis
-- 3. Groups by survey year to show changes over time
-- 4. Focuses on recent years (2019+) for current relevance

-- Assumptions and Limitations:
-- - Survey responses are representative of Medicare population
-- - Non-response and missing data handled appropriately in source
-- - Satisfaction ratings may have cultural/regional biases
-- - Limited to fall survey responses only

-- Possible Extensions:
-- 1. Break down by demographics (age, race, income levels)
-- 2. Compare Traditional Medicare vs Medicare Advantage 
-- 3. Add geographic analysis by region/state
-- 4. Correlate with health conditions and utilization
-- 5. Build predictive model for satisfaction
-- 6. Compare different survey rounds (fall vs other seasons)
-- 7. Add statistical significance testing for trends
-- 8. Create standardized satisfaction index

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:41:04.654406
    - Additional Notes: Query aggregates key Medicare access and satisfaction metrics over recent years (2019+). Results show both absolute counts and percentages to facilitate trend analysis. Performance may be impacted when analyzing full historical data or when adding multiple demographic breakdowns.
    
    */