-- Title: Analysis of High-Risk Rural Communities with Limited Healthcare Infrastructure

-- Business Purpose:
-- This query identifies rural counties with high social vulnerability and significant 
-- healthcare access challenges by analyzing mobile home prevalence, uninsured rates,
-- and elderly population concentrations. The insights help healthcare organizations
-- and policymakers prioritize mobile health services, telemedicine initiatives, and
-- rural healthcare infrastructure investments.

WITH rural_vulnerability AS (
  -- Identify counties with significant rural characteristics and healthcare needs
  SELECT 
    state,
    county,
    e_totpop AS total_population,
    ep_mobile AS pct_mobile_homes,
    ep_uninsur AS pct_uninsured,
    ep_age65 AS pct_elderly,
    rpl_themes AS overall_vulnerability_percentile,
    -- Calculate a composite rural healthcare risk score
    (ep_mobile + ep_uninsur + ep_age65)/3 AS rural_healthcare_risk_score
  FROM mimi_ws_1.cdc.svi_county_y2020
  WHERE ep_mobile > 10  -- Focus on areas with above-average mobile home presence
    AND e_totpop > 1000 -- Exclude very small counties
)

SELECT 
  state,
  county,
  total_population,
  ROUND(pct_mobile_homes, 1) AS pct_mobile_homes,
  ROUND(pct_uninsured, 1) AS pct_uninsured,
  ROUND(pct_elderly, 1) AS pct_elderly,
  ROUND(overall_vulnerability_percentile, 2) AS svi_percentile,
  ROUND(rural_healthcare_risk_score, 2) AS risk_score
FROM rural_vulnerability
WHERE rural_healthcare_risk_score > 20  -- Focus on highest risk areas
ORDER BY rural_healthcare_risk_score DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE focusing on rural characteristics using mobile home percentage as a proxy
-- 2. Calculates a composite risk score based on mobile homes, uninsured rates, and elderly population
-- 3. Filters for counties with meaningful population size and significant risk factors
-- 4. Returns the top 100 counties ranked by healthcare risk score

-- Assumptions and Limitations:
-- - Uses mobile home prevalence as a proxy for rural character
-- - Assumes equal weighting of risk factors in composite score
-- - May not capture all aspects of rural healthcare access challenges
-- - Does not account for proximity to metropolitan healthcare facilities

-- Possible Extensions:
-- 1. Add distance to nearest hospital or emergency room
-- 2. Include broadband access metrics for telemedicine potential
-- 3. Factor in healthcare workforce shortages
-- 4. Incorporate seasonal population variations
-- 5. Add correlation with health outcomes data
-- 6. Include analysis of specific disease prevalence in rural areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:13:39.680608
    - Additional Notes: Query assumes mobile home prevalence as a primary indicator of rural character, which may not be accurate for all regions. Risk score calculation uses a simple average of three factors - consider adjusting weights based on local context. Performance may be impacted when analyzing very large datasets due to multiple percentage calculations.
    
    */