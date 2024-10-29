-- provider_pac_quality_metrics.sql
--
-- Business Purpose: 
-- Analyze quality metrics for Medicare post-acute care providers by examining:
-- - Patient risk profiles and chronic conditions
-- - Therapy service intensity and mix
-- - Patient demographics and dual eligibility status
-- - Payment patterns including outliers
-- This analysis helps identify high-performing providers and opportunities
-- for quality improvement across different PAC settings.

WITH provider_metrics AS (
  SELECT 
    prvdr_id,
    prvdr_name,
    state,
    srvc_ctgry,
    -- Key volume metrics
    bene_dstnct_cnt,
    tot_epsd_stay_cnt,
    tot_srvc_days,
    
    -- Risk and complexity metrics 
    bene_avg_risk_scre,
    bene_avg_cc_cnt,
    bene_dual_pct,
    
    -- Therapy intensity metrics
    tot_pt_mnts / NULLIF(tot_srvc_days, 0) as pt_mins_per_day,
    tot_ot_mnts / NULLIF(tot_srvc_days, 0) as ot_mins_per_day,
    tot_slp_mnts / NULLIF(tot_srvc_days, 0) as slp_mins_per_day,
    
    -- Payment metrics
    tot_mdcr_pymt_amt / NULLIF(tot_epsd_stay_cnt, 0) as pymt_per_stay,
    tot_outlier_pymt_amt / NULLIF(tot_mdcr_pymt_amt, 0) * 100 as outlier_pymt_pct

  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'Provider'
    AND prvdr_id IS NOT NULL
    AND year = 2022
)

SELECT
  srvc_ctgry,
  COUNT(DISTINCT prvdr_id) as provider_cnt,
  
  -- Volume metrics
  AVG(bene_dstnct_cnt) as avg_beneficiaries,
  AVG(tot_epsd_stay_cnt) as avg_stays,
  
  -- Risk metrics 
  AVG(bene_avg_risk_scre) as avg_risk_score,
  AVG(bene_avg_cc_cnt) as avg_chronic_conditions,
  AVG(bene_dual_pct) as avg_dual_pct,
  
  -- Therapy intensity
  AVG(pt_mins_per_day) as avg_pt_mins_per_day,
  AVG(ot_mins_per_day) as avg_ot_mins_per_day,
  AVG(slp_mins_per_day) as avg_slp_mins_per_day,
  
  -- Payment metrics
  AVG(pymt_per_stay) as avg_payment_per_stay,
  AVG(outlier_pymt_pct) as avg_outlier_pct

FROM provider_metrics
GROUP BY srvc_ctgry
ORDER BY avg_payment_per_stay DESC;

-- How this query works:
-- 1. Creates a CTE with provider-level metrics normalized by volume
-- 2. Aggregates key quality and performance metrics by PAC setting
-- 3. Focuses on risk-adjusted measures to enable fair comparisons

-- Assumptions and Limitations:
-- - Assumes 2022 data is complete and accurate
-- - Does not account for regional cost variations
-- - Therapy minutes may be reported differently across settings
-- - Risk scores may not fully capture patient complexity

-- Possible Extensions:
-- 1. Add provider percentile rankings within each PAC setting
-- 2. Compare urban vs rural providers
-- 3. Analyze trends over multiple years
-- 4. Add quality outcome measures
-- 5. Create provider peer groups based on size and patient mix/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:05:46.763561
    - Additional Notes: The query provides a comprehensive provider-level analysis of post-acute care performance metrics including risk profiles, therapy intensity, and payment patterns. Note that therapy minutes calculations may be incomplete for certain provider types like hospice, and risk score comparisons should be made within, not across, PAC settings.
    
    */