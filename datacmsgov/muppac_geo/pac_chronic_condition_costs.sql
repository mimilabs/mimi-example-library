-- medicare_pac_chronic_conditions_analysis.sql

-- Business Purpose: 
-- Analyze the relationship between chronic conditions and Medicare post-acute care utilization/costs 
-- to identify high-risk patient populations and opportunities for care management.
-- This analysis can help:
-- 1. Target care management programs
-- 2. Optimize resource allocation
-- 3. Identify cost drivers
-- 4. Support value-based care initiatives

SELECT 
  srvc_ctgry,
  smry_ctgry,
  state,
  
  -- Volume metrics
  SUM(bene_dstnct_cnt) as total_beneficiaries,
  SUM(tot_mdcr_pymt_amt) as total_medicare_payments,
  
  -- Average costs and utilization 
  ROUND(AVG(tot_mdcr_pymt_amt / NULLIF(bene_dstnct_cnt, 0)), 2) as avg_payment_per_beneficiary,
  ROUND(AVG(tot_srvc_days / NULLIF(bene_dstnct_cnt, 0)), 1) as avg_service_days_per_beneficiary,
  
  -- Chronic condition prevalence
  ROUND(AVG(bene_avg_cc_cnt), 2) as avg_chronic_conditions,
  ROUND(AVG(bene_cc_ph_diabetes_v2_pct), 1) as diabetes_pct,
  ROUND(AVG(bene_cc_ph_ckd_v2_pct), 1) as ckd_pct,
  ROUND(AVG(bene_cc_ph_hf_nonihd_v2_pct), 1) as heart_failure_pct,
  ROUND(AVG(bene_cc_ph_copd_v2_pct), 1) as copd_pct,
  
  -- Risk and demographics
  ROUND(AVG(bene_avg_risk_scre), 2) as avg_risk_score,
  ROUND(AVG(bene_avg_age), 1) as avg_age,
  ROUND(AVG(bene_dual_pct), 1) as dual_eligible_pct

FROM mimi_ws_1.datacmsgov.muppac_geo

WHERE smry_ctgry IN ('State', 'National')
  AND year = 2022  -- Adjust year as needed
  
GROUP BY 
  srvc_ctgry,
  smry_ctgry,
  state

HAVING total_beneficiaries >= 100  -- Filter out small populations

ORDER BY 
  smry_ctgry,
  srvc_ctgry,
  state;

-- Query Operation:
-- 1. Aggregates key metrics by service category, summary level, and state
-- 2. Calculates per-beneficiary averages for costs and utilization
-- 3. Summarizes prevalence of major chronic conditions
-- 4. Includes risk and demographic context
-- 5. Filters for meaningful population sizes

-- Assumptions and Limitations:
-- 1. Requires 2017+ data for chronic condition metrics
-- 2. State-level aggregation may mask facility-level variations
-- 3. Correlation doesn't imply causation
-- 4. Assumes accurate coding and reporting of conditions

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include additional chronic conditions
-- 3. Break out costs by service type
-- 4. Add geographic region groupings
-- 5. Incorporate quality metrics
-- 6. Add statistical significance testing
-- 7. Create risk-adjusted comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:14:21.670282
    - Additional Notes: Query focuses on the relationship between chronic conditions and PAC costs/utilization at state/national levels. Requires data from 2017 onwards due to chronic condition metric availability. The 100 beneficiary minimum threshold may need adjustment based on specific analysis needs.
    
    */