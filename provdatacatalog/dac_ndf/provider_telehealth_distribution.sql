
/* 
Title: Healthcare Provider Distribution and Telehealth Analysis

Business Purpose:
This query analyzes the geographic distribution of healthcare providers and their 
telehealth capabilities to understand:
1. Provider accessibility across states
2. Telehealth adoption rates by specialty
3. Potential gaps in healthcare coverage

This insight helps:
- Healthcare organizations with provider network planning
- Policymakers in addressing healthcare access disparities  
- Patients seeking care options in their area
*/

-- Main Analysis Query
WITH provider_metrics AS (
  -- Get the most recent data for each provider
  SELECT 
    state,
    pri_spec,
    telehlth,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT CASE WHEN telehlth = 'Y' THEN npi END) as telehealth_providers,
    COUNT(DISTINCT facility_name) as facility_count
  FROM mimi_ws_1.provdatacatalog.dac_ndf
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.provdatacatalog.dac_ndf)
  GROUP BY state, pri_spec, telehlth
)

SELECT
  state,
  pri_spec,
  provider_count,
  -- Calculate telehealth adoption rate
  ROUND(CAST(telehealth_providers AS FLOAT)/NULLIF(provider_count,0) * 100, 2) as telehealth_adoption_pct,
  facility_count,
  -- Calculate providers per facility ratio
  ROUND(CAST(provider_count AS FLOAT)/NULLIF(facility_count,0), 2) as providers_per_facility
FROM provider_metrics
-- Focus on states with significant provider presence
WHERE provider_count >= 10
ORDER BY state, provider_count DESC;

/*
How it works:
1. Uses CTE to aggregate provider metrics at state/specialty level
2. Calculates key ratios for telehealth adoption and facility coverage
3. Filters for meaningful sample sizes
4. Orders results geographically and by provider density

Assumptions:
- Most recent data provides current state of provider landscape
- NPI uniquely identifies providers
- Blank telehealth values treated as non-telehealth providers
- Minimum threshold of 10 providers per group for significance

Limitations:
- Does not account for provider capacity/patient load
- May include inactive providers
- Geographic analysis at state level only
- Does not consider population density/demand

Possible Extensions:
1. Add temporal analysis to track changes over time:
   - Add year-over-year comparison
   - Track telehealth adoption trends

2. Enhance geographic analysis:
   - Add city/county level detail
   - Include population demographics
   - Calculate provider density per capita

3. Specialty focus:
   - Compare primary vs secondary specialties
   - Analyze specialty combinations
   - Group related specialties

4. Network adequacy:
   - Add distance/drive time analysis
   - Compare urban vs rural access
   - Identify coverage gaps
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:50:55.457563
    - Additional Notes: Query focuses on active providers and telehealth adoption patterns across states. Performance may be impacted with very large datasets due to the COUNT DISTINCT operations. Consider adding date range parameters and/or geographic filters for larger datasets. Results exclude provider groups with fewer than 10 providers, which may impact analysis of rural or specialized practices.
    
    */