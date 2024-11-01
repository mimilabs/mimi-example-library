-- Medicare Beneficiary Access to Care and Provider Experience Analysis
--
-- Business Purpose:
-- Analyze Medicare beneficiaries' access to healthcare providers and their 
-- experience with care coordination to identify potential barriers and areas
-- for improving patient satisfaction and care quality.
-- This insight helps healthcare organizations optimize their service delivery
-- and payers improve care coordination programs.

WITH provider_access AS (
  -- Get core metrics about provider access and experience
  SELECT 
    surveyyr,
    COUNT(*) as total_beneficiaries,
    
    -- Regular provider relationship metrics
    SUM(CASE WHEN acw_placepar = '1' THEN 1 ELSE 0 END) as has_regular_provider,
    SUM(CASE WHEN acw_usualdoc = '1' THEN 1 ELSE 0 END) as has_usual_doctor,
    
    -- Access barriers 
    SUM(CASE WHEN acw_d_mdvist = '1' THEN 1 ELSE 0 END) as difficulty_getting_to_doc,
    SUM(CASE WHEN acw_d_mdappt = '1' THEN 1 ELSE 0 END) as difficulty_getting_appt,
    
    -- Care coordination metrics
    SUM(CASE WHEN acw_knowrslt = '4' THEN 1 ELSE 0 END) as specialist_always_knows_results,
    SUM(CASE WHEN acw_drinfrmd = '4' THEN 1 ELSE 0 END) as pcp_always_informed_of_specialist

  FROM mimi_ws_1.datacmsgov.mcbs_winter
  WHERE surveyyr IS NOT NULL
  GROUP BY surveyyr
)

SELECT
  surveyyr as year,
  total_beneficiaries,
  
  -- Calculate key percentages
  ROUND(100.0 * has_regular_provider / total_beneficiaries, 1) as pct_with_regular_provider,
  ROUND(100.0 * has_usual_doctor / total_beneficiaries, 1) as pct_with_usual_doctor,
  ROUND(100.0 * difficulty_getting_to_doc / total_beneficiaries, 1) as pct_difficulty_getting_to_doc,
  ROUND(100.0 * difficulty_getting_appt / total_beneficiaries, 1) as pct_difficulty_getting_appt,
  
  -- Care coordination metrics
  ROUND(100.0 * specialist_always_knows_results / total_beneficiaries, 1) as pct_specialist_knows_results,
  ROUND(100.0 * pcp_always_informed_of_specialist / total_beneficiaries, 1) as pct_pcp_informed_of_specialist

FROM provider_access
ORDER BY surveyyr DESC

-- How this works:
-- 1. Creates a CTE to aggregate core access and coordination metrics by year
-- 2. Calculates percentages in the main query to show trends
-- 3. Orders results by most recent year first
--
-- Assumptions & Limitations:
-- - Assumes null values should be excluded from calculations
-- - Percentages may not sum to 100% due to missing responses
-- - Survey responses are self-reported and subject to recall bias
--
-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, race) to identify disparities
-- 2. Include satisfaction metrics to correlate with access measures
-- 3. Analyze geographic variations by adding location data
-- 4. Compare Medicare Advantage vs Traditional Medicare experiences
-- 5. Add statistical significance testing between years

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:21:02.608880
    - Additional Notes: The query aggregates survey responses about provider access and care coordination, focused on key metrics like having a regular provider and experiencing difficulties accessing care. The results show year-over-year trends in percentages, making it useful for tracking changes in care access and coordination over time. Note that the accuracy depends on survey response rates and completeness of data in each year.
    
    */