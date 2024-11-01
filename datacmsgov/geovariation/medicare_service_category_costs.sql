-- medicare_service_cost_patterns.sql

-- Purpose: Analyze cost variations between different Medicare service categories 
-- to identify where spending is concentrated and how service mix varies by region.
-- This analysis helps identify cost drivers and opportunities for care optimization.

WITH service_costs AS (
  SELECT 
    year,
    bene_geo_lvl,
    bene_geo_desc,
    
    -- Total costs
    tot_mdcr_stdzd_pymt_pc as total_cost_per_capita,
    
    -- Calculate percentage of total cost for key service categories
    ROUND(em_mdcr_stdzd_pymt_pct, 1) as eval_mgmt_pct,
    ROUND(prcdrs_mdcr_stdzd_pymt_pct, 1) as procedures_pct,
    ROUND(imgng_mdcr_stdzd_pymt_pct, 1) as imaging_pct,
    ROUND(tests_mdcr_stdzd_pymt_pct, 1) as tests_pct,
    ROUND(dme_mdcr_stdzd_pymt_pct, 1) as dme_pct,
    
    -- Calculate per capita costs for key categories
    ROUND(em_mdcr_stdzd_pymt_pc, 0) as eval_mgmt_per_capita,
    ROUND(prcdrs_mdcr_stdzd_pymt_pc, 0) as procedures_per_capita,
    ROUND(imgng_mdcr_stdzd_pymt_pc, 0) as imaging_per_capita,
    ROUND(tests_mdcr_stdzd_pymt_pc, 0) as tests_per_capita,
    ROUND(dme_mdcr_stdzd_pymt_pc, 0) as dme_per_capita,
    
    -- Calculate utilization rates
    ROUND(benes_em_pct, 1) as eval_mgmt_util_pct,
    ROUND(benes_prcdrs_pct, 1) as procedures_util_pct,
    ROUND(benes_imgng_pct, 1) as imaging_util_pct,
    ROUND(benes_tests_pct, 1) as tests_util_pct,
    ROUND(benes_dme_pct, 1) as dme_util_pct
    
  FROM mimi_ws_1.datacmsgov.geovariation
  WHERE bene_geo_lvl IN ('State', 'National')
    AND year >= 2019
    AND bene_age_lvl = 'All Beneficiaries'
)

SELECT
  year,
  bene_geo_lvl,
  bene_geo_desc,
  total_cost_per_capita,
  
  -- Service mix percentages
  eval_mgmt_pct,
  procedures_pct,
  imaging_pct,
  tests_pct,
  dme_pct,
  
  -- Per capita costs
  eval_mgmt_per_capita,
  procedures_per_capita,
  imaging_per_capita,
  tests_per_capita,
  dme_per_capita,
  
  -- Utilization percentages  
  eval_mgmt_util_pct,
  procedures_util_pct,
  imaging_util_pct,
  tests_util_pct,
  dme_util_pct

FROM service_costs
ORDER BY 
  year DESC,
  bene_geo_lvl DESC,
  total_cost_per_capita DESC;

-- How this query works:
-- 1. Creates CTE to calculate key metrics for major service categories
-- 2. Focuses on standardized payments to enable fair geographic comparisons
-- 3. Looks at both cost percentages and per capita amounts
-- 4. Includes utilization rates to understand service use patterns
-- 5. Filters to state and national level data for recent years

-- Assumptions and limitations:
-- - Uses standardized payments which remove geographic payment rate differences
-- - Focuses on high-level service categories only
-- - Limited to fee-for-service Medicare beneficiaries
-- - State level analysis may mask county-level variations
-- - Recent years only to focus on current patterns

-- Possible extensions:
-- 1. Add year-over-year change calculations
-- 2. Include additional service categories
-- 3. Add regional groupings
-- 4. Compare against quality metrics
-- 5. Break out by age groups
-- 6. Add risk score adjustments
-- 7. Include county-level details for specific states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:13:52.649566
    - Additional Notes: This query performs standard geographic cost analysis across major Medicare service categories, providing a balanced view of both spending distribution and utilization rates. The standardized payments enable fair comparisons across regions. Limited to state and national level data from 2019 onward.
    
    */