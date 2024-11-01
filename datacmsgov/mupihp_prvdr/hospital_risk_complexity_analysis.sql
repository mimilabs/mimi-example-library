-- Medicare Inpatient Hospital Case Mix and Risk Analysis

-- Business Purpose:
-- This query analyzes patient complexity and risk profiles across Medicare inpatient hospitals to:
-- 1. Identify facilities managing high-risk/complex patient populations 
-- 2. Understand relationship between case mix, utilization and payments
-- 3. Support strategic planning and resource allocation decisions
-- 4. Enable risk-adjusted performance comparisons

WITH hospital_metrics AS (
  SELECT 
    -- Provider identifiers
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    
    -- Volume metrics 
    tot_dschrgs,
    tot_benes,
    
    -- Case mix indicators
    bene_avg_risk_scre,
    bene_avg_age,
    
    -- Key condition prevalence 
    bene_cc_ph_ckd_v2_pct AS ckd_pct,
    bene_cc_ph_diabetes_v2_pct AS diabetes_pct,
    bene_cc_ph_hf_nonihd_v2_pct AS heart_failure_pct,
    
    -- Payment metrics
    tot_pymt_amt / NULLIF(tot_dschrgs, 0) AS payment_per_discharge,
    tot_mdcr_pymt_amt / NULLIF(tot_pymt_amt, 0) AS medicare_payment_ratio

  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
    AND tot_dschrgs >= 100 -- Focus on facilities with material volume
)

SELECT
  rndrng_prvdr_state_abrvtn AS state,
  COUNT(*) AS hospital_count,
  
  -- Risk and complexity metrics
  ROUND(AVG(bene_avg_risk_scre),2) AS avg_risk_score,
  ROUND(AVG(ckd_pct),1) AS avg_ckd_pct,
  ROUND(AVG(diabetes_pct),1) AS avg_diabetes_pct,
  ROUND(AVG(heart_failure_pct),1) AS avg_hf_pct,
  
  -- Volume and payment metrics  
  ROUND(AVG(tot_dschrgs),0) AS avg_discharges,
  ROUND(AVG(payment_per_discharge),0) AS avg_payment_per_discharge,
  ROUND(AVG(medicare_payment_ratio)*100,1) AS avg_medicare_pmt_pct

FROM hospital_metrics
GROUP BY rndrng_prvdr_state_abrvtn
HAVING hospital_count >= 10
ORDER BY avg_risk_score DESC;

-- How this works:
-- 1. CTE calculates key metrics per hospital including case mix indicators and payment measures
-- 2. Main query aggregates to state level for comparison
-- 3. Filters ensure statistical validity by requiring minimum volume thresholds
-- 4. Results ordered by risk score to highlight areas with most complex populations

-- Assumptions & Limitations:
-- - Uses 2022 data - trends over time not captured
-- - Hospital volume threshold of 100 discharges may exclude some specialty facilities
-- - State-level aggregation masks important regional variations
-- - Risk scores may not fully capture all patient complexity factors

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Incorporate quality metrics for value analysis
-- 3. Break out by hospital characteristics (size, teaching status, etc)
-- 4. Add geographic analysis at more granular level
-- 5. Include payer mix and demographic factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:52:20.120276
    - Additional Notes: Query focuses on hospital risk and complexity profiling using risk scores and chronic condition prevalence, best used for strategic market analysis and care management planning. Note that risk score interpretation may vary by year due to CMS methodology changes.
    
    */