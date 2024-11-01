-- pac_behavioral_health_analysis.sql 

-- Business Purpose:
-- Analyze prevalence of behavioral health conditions among Medicare post-acute care users
-- to identify opportunities for integrated behavioral health services and specialized programs.
-- Key metrics include:
-- - Behavioral health condition rates across PAC settings
-- - Average costs and utilization for patients with behavioral health conditions
-- - Geographic variation in behavioral health needs

-- Main Analysis
WITH bh_metrics AS (
  SELECT
    state,
    srvc_ctgry,
    COUNT(DISTINCT prvdr_id) as provider_count,
    SUM(bene_dstnct_cnt) as total_beneficiaries,
    
    -- Calculate average behavioral health condition prevalence
    AVG(bene_cc_bh_depress_v1_pct) as avg_depression_pct,
    AVG(bene_cc_bh_anxiety_v1_pct) as avg_anxiety_pct,
    AVG(bene_cc_bh_alz_nonalzdem_v2_pct) as avg_dementia_pct,
    AVG(bene_cc_bh_schizo_othpsy_v1_pct) as avg_schizo_pct,
    AVG(bene_cc_bh_alcohol_drug_v1_pct) as avg_sud_pct,
    
    -- Calculate average costs and utilization
    AVG(tot_mdcr_pymt_amt/NULLIF(bene_dstnct_cnt,0)) as avg_payment_per_bene,
    AVG(tot_srvc_days/NULLIF(bene_dstnct_cnt,0)) as avg_los_per_bene

  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'State' -- State-level analysis
    AND state IS NOT NULL
  GROUP BY state, srvc_ctgry
)

SELECT 
  state,
  srvc_ctgry,
  provider_count,
  total_beneficiaries,
  ROUND(avg_depression_pct,1) as depression_pct,
  ROUND(avg_anxiety_pct,1) as anxiety_pct,
  ROUND(avg_dementia_pct,1) as dementia_pct,
  ROUND(avg_schizo_pct,1) as schizophrenia_pct,
  ROUND(avg_sud_pct,1) as substance_use_pct,
  ROUND(avg_payment_per_bene,0) as payment_per_patient,
  ROUND(avg_los_per_bene,1) as length_of_stay
FROM bh_metrics
ORDER BY state, srvc_ctgry;

-- How the Query Works:
-- 1. Creates CTE to calculate key behavioral health metrics at state/service category level
-- 2. Aggregates provider counts and beneficiary volumes
-- 3. Calculates average prevalence rates for major behavioral health conditions
-- 4. Computes cost and utilization metrics per beneficiary
-- 5. Formats final output with rounded values for readability

-- Assumptions & Limitations:
-- - Analysis at state level only; provider-level variation not captured
-- - Assumes behavioral health conditions are accurately coded/captured
-- - Does not account for severity of conditions
-- - Limited to Medicare FFS beneficiaries only

-- Possible Extensions:
-- 1. Add time trend analysis to track changes in BH prevalence
-- 2. Include urban/rural comparisons using bene_rrl_pct
-- 3. Analyze correlation between BH conditions and readmissions
-- 4. Compare therapy utilization patterns for BH vs non-BH patients
-- 5. Add risk-adjusted cost comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:06:18.178238
    - Additional Notes: Query focuses on state-level behavioral health patterns across post-acute care settings. Metrics include depression, anxiety, dementia, schizophrenia and substance use disorder prevalence rates along with associated costs. Results are aggregated at state/service category level with per-beneficiary calculations for cost and utilization analysis.
    
    */