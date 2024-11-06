-- Title: Dental HPSA Medicaid Population Service Gap Analysis

-- Business Purpose:
-- This analysis identifies areas with high Medicaid-eligible populations and significant
-- dental provider shortages to help prioritize resources and support initiatives for
-- expanding dental care access to Medicaid beneficiaries. The insights can guide
-- state Medicaid programs, dental service organizations, and policy makers in
-- addressing care gaps for this vulnerable population.

WITH hpsa_medicaid_metrics AS (
  SELECT 
    common_state_name,
    designation_type,
    COUNT(DISTINCT hpsa_id) as total_hpsas,
    ROUND(AVG(hpsa_score), 1) as avg_hpsa_score,
    ROUND(AVG(pct_of_population_below_100pct_poverty), 1) as avg_poverty_pct,
    SUM(hpsa_fte) as total_providers_needed,
    SUM(hpsa_designation_population) as total_hpsa_population,
    ROUND(AVG(hpsa_formal_ratio), 0) as avg_population_provider_ratio
  FROM mimi_ws_1.hrsa.hpsa_fct_det_dh
  WHERE hpsa_status = 'Designated'  
    AND hpsa_designation_population_type_description LIKE '%Medicaid%'
  GROUP BY common_state_name, designation_type
)
SELECT 
  common_state_name,
  designation_type,
  total_hpsas,
  avg_hpsa_score,
  avg_poverty_pct,
  total_providers_needed,
  total_hpsa_population,
  avg_population_provider_ratio,
  ROUND(total_hpsa_population::FLOAT / NULLIF(total_providers_needed, 0), 0) as pop_per_needed_provider
FROM hpsa_medicaid_metrics
WHERE total_hpsas > 0
ORDER BY total_hpsa_population DESC, avg_hpsa_score DESC;

-- How the Query Works:
-- 1. Filters for active HPSA designations serving Medicaid populations
-- 2. Aggregates key metrics by state and designation type
-- 3. Calculates additional derived metrics for population coverage
-- 4. Orders results to highlight areas with largest affected populations and highest need

-- Assumptions and Limitations:
-- - Assumes current HPSA designations are up to date
-- - Limited to explicitly Medicaid-designated populations
-- - Does not account for potential overlap in service areas
-- - Population counts may include some duplication across designation types

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of Medicaid HPSA designations
-- 2. Include geographic coordinates for mapping service gaps
-- 3. Compare Medicaid vs non-Medicaid HPSA characteristics
-- 4. Add detailed facility-level analysis for specific states
-- 5. Incorporate demographic data for more detailed population analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:27:15.896707
    - Additional Notes: Query focuses specifically on HPSA designations serving Medicaid populations, providing state-level aggregations of service gaps and provider needs. The pop_per_needed_provider metric helps quantify the impact of provider shortages relative to population size. Consider performance optimization for large datasets by adding appropriate indexes on hpsa_status and hpsa_designation_population_type_description columns.
    
    */