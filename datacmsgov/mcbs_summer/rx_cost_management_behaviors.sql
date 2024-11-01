-- Medicare Beneficiary Prescription Cost Management Strategies Analysis

-- Business Purpose: This query analyzes how Medicare beneficiaries manage their prescription drug costs to:
-- 1. Identify prevalent cost-saving behaviors that may impact medication adherence
-- 2. Guide prescription drug plan design and beneficiary support programs
-- 3. Support medication therapy management program development
-- 4. Help evaluate the effectiveness of current prescription drug coverage

WITH behavior_counts AS (
  SELECT 
    surveyyr,
    -- Calculate total respondents who employ each cost-saving strategy frequently
    SUM(CASE WHEN rxs_generrx = '1' THEN 1 ELSE 0 END) as often_use_generics,
    SUM(CASE WHEN rxs_mailrx = '1' THEN 1 ELSE 0 END) as often_use_mail_order,
    SUM(CASE WHEN rxs_comparrx = '1' THEN 1 ELSE 0 END) as often_compare_prices,
    SUM(CASE WHEN rxs_samplerx = '1' THEN 1 ELSE 0 END) as often_request_samples,
    -- Calculate concerning cost-related behaviors
    SUM(CASE WHEN rxs_skiprx = '1' THEN 1 ELSE 0 END) as often_skip_doses,
    SUM(CASE WHEN rxs_delayrx = '1' THEN 1 ELSE 0 END) as often_delay_filling,
    SUM(CASE WHEN rxs_nofillrx = '1' THEN 1 ELSE 0 END) as often_dont_fill,
    -- Get total respondents for percentage calculations
    COUNT(*) as total_respondents
  FROM mimi_ws_1.datacmsgov.mcbs_summer
  WHERE surveyyr IS NOT NULL
  GROUP BY surveyyr
)

SELECT 
  surveyyr as survey_year,
  -- Calculate percentages for positive cost management strategies
  ROUND(100.0 * often_use_generics / total_respondents, 1) as pct_frequent_generic_users,
  ROUND(100.0 * often_use_mail_order / total_respondents, 1) as pct_frequent_mail_order_users,
  ROUND(100.0 * often_compare_prices / total_respondents, 1) as pct_frequent_price_comparers,
  ROUND(100.0 * often_request_samples / total_respondents, 1) as pct_frequent_sample_requesters,
  -- Calculate percentages for concerning behaviors
  ROUND(100.0 * (often_skip_doses + often_delay_filling + often_dont_fill) / 
    (total_respondents * 3), 1) as pct_cost_related_nonadherence
FROM behavior_counts
ORDER BY surveyyr DESC;

-- How this works:
-- 1. Creates a CTE to count respondents using different cost management strategies
-- 2. Categorizes behaviors into positive strategies vs concerning behaviors
-- 3. Calculates percentages to show prevalence of each behavior type
-- 4. Provides trend data across survey years

-- Assumptions and limitations:
-- - Assumes survey responses are representative of Medicare population
-- - Self-reported data may be subject to recall bias
-- - Missing or "Don't know" responses are excluded from calculations
-- - Combining multiple behaviors into single metrics may mask important variations

-- Possible extensions:
-- 1. Add demographic breakdowns to identify vulnerable populations
-- 2. Correlate behaviors with satisfaction metrics
-- 3. Analyze relationships between cost management strategies and health outcomes
-- 4. Include geographic analysis to identify regional patterns
-- 5. Compare behaviors across different types of prescription drug coverage

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:30:09.916344
    - Additional Notes: Query focuses on tracking adoption rates of both positive and concerning prescription cost management behaviors among Medicare beneficiaries. Results are aggregated annually to show trends in cost-coping strategies. Consider memory usage when running across multiple years due to the wide aggregation scope.
    
    */