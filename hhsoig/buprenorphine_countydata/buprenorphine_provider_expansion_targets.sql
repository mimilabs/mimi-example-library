-- Provider Capacity Expansion Opportunities Analysis 
--
-- Business Purpose:
-- This query identifies counties that could benefit most from expanding buprenorphine treatment 
-- capacity by analyzing current provider mix and capacity utilization. The analysis helps
-- healthcare organizations and policymakers prioritize where to focus provider recruitment
-- and waiver expansion efforts.

WITH provider_mix AS (
  SELECT 
    state,
    county,
    -- Calculate percentage of providers at each waiver level
    ROUND(number_of_providers_with_30patient_waivers * 100.0 / NULLIF(total_number_of_waivered_providers, 0), 1) as pct_30_patient,
    ROUND(number_of_providers_with_100patient_waivers * 100.0 / NULLIF(total_number_of_waivered_providers, 0), 1) as pct_100_patient,
    ROUND(number_of_providers_with_275patient_waivers * 100.0 / NULLIF(total_number_of_waivered_providers, 0), 1) as pct_275_patient,
    total_number_of_waivered_providers,
    patient_capacity,
    patient_capacity_rate,
    high_need_for_treatment_services
  FROM mimi_ws_1.hhsoig.buprenorphine_countydata
  WHERE total_number_of_waivered_providers > 0
)

SELECT 
  state,
  county,
  total_number_of_waivered_providers,
  pct_30_patient as pct_providers_at_30_limit,
  patient_capacity_rate,
  high_need_for_treatment_services,
  -- Identify expansion opportunity type
  CASE 
    WHEN pct_30_patient >= 50 AND high_need_for_treatment_services = TRUE 
      THEN 'High Priority for Waiver Expansion'
    WHEN pct_30_patient >= 50 
      THEN 'Potential for Waiver Expansion'
    WHEN high_need_for_treatment_services = TRUE 
      THEN 'High Need - Provider Recruitment'
    ELSE 'Monitor Status'
  END as expansion_opportunity
FROM provider_mix
ORDER BY 
  high_need_for_treatment_services DESC,
  pct_30_patient DESC,
  patient_capacity_rate

/*
How this query works:
1. Creates a CTE to calculate the provider mix percentages for each county
2. Identifies expansion opportunities based on:
   - High percentage of providers at 30-patient limit (indicating room for expansion)
   - High need status
3. Prioritizes results to highlight areas needing immediate attention

Assumptions & Limitations:
- Only includes counties with at least 1 waivered provider
- Assumes providers at 30-patient limit are candidates for expansion
- Does not account for actual utilization rates
- Based on point-in-time data from 2018

Possible Extensions:
1. Add geographic clustering analysis to identify regional patterns
2. Include demographic and socioeconomic factors 
3. Calculate potential capacity increase if providers expanded waivers
4. Compare against actual treatment rates or waitlist data
5. Incorporate drive time analysis for access assessment
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:48:55.786204
    - Additional Notes: Query identifies counties with high potential ROI for expanding treatment capacity based on current provider composition and need levels. Results can be used to prioritize provider outreach and waiver expansion programs. Note that the expansion opportunity classifications are simplified and may need adjustment based on local factors and current policy guidelines.
    
    */