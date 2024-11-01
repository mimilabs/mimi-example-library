-- dmepos_chronic_condition_impact.sql

-- Business Purpose:
-- This query analyzes the relationship between chronic conditions and DMEPOS utilization
-- to identify which medical conditions drive the highest equipment and supply needs.
-- The insights help suppliers better serve patient populations with specific conditions
-- and support care coordination between providers.

WITH supplier_metrics AS (
  -- Get key supplier metrics and filter out small volume suppliers
  SELECT 
    suplr_npi,
    suplr_prvdr_last_name_org,
    suplr_prvdr_state_abrvtn,
    tot_suplr_benes,
    suplr_mdcr_pymt_amt,
    suplr_mdcr_pymt_amt / NULLIF(tot_suplr_benes, 0) as payment_per_bene,
    
    -- Average chronic condition percentages for key conditions
    bene_cc_ph_copd_v2_pct,
    bene_cc_ph_diabetes_v2_pct,
    bene_cc_ph_hf_nonihd_v2_pct,
    bene_cc_ph_cancer6_v2_pct,
    bene_cc_ph_ckd_v2_pct,
    
    -- Risk profile
    bene_avg_risk_scre,
    bene_avg_age
  FROM mimi_ws_1.datacmsgov.mupdme_sup
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND tot_suplr_benes >= 100  -- Focus on established suppliers
)

SELECT
  -- Calculate condition correlation with utilization
  CORR(payment_per_bene, bene_cc_ph_copd_v2_pct) as copd_payment_correlation,
  CORR(payment_per_bene, bene_cc_ph_diabetes_v2_pct) as diabetes_payment_correlation,
  CORR(payment_per_bene, bene_cc_ph_hf_nonihd_v2_pct) as heart_failure_payment_correlation,
  CORR(payment_per_bene, bene_cc_ph_cancer6_v2_pct) as cancer_payment_correlation,
  CORR(payment_per_bene, bene_cc_ph_ckd_v2_pct) as ckd_payment_correlation,
  
  -- Summary statistics
  AVG(payment_per_bene) as avg_payment_per_bene,
  AVG(bene_avg_risk_scre) as avg_risk_score,
  COUNT(DISTINCT suplr_npi) as supplier_count,
  SUM(tot_suplr_benes) as total_benes

FROM supplier_metrics;

-- How this query works:
-- 1. Filters for most recent year of data and suppliers with meaningful volume
-- 2. Calculates per-beneficiary payment amounts for each supplier
-- 3. Correlates chronic condition prevalence with utilization metrics
-- 4. Provides overall summary statistics for context

-- Assumptions and Limitations:
-- - Uses 2022 data only - trends may vary year over year
-- - Focuses on larger suppliers (100+ beneficiaries)
-- - Correlation does not imply causation
-- - Does not account for regional variations
-- - Limited to key chronic conditions only

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Break down by geographic regions
-- 3. Include more granular service category analysis
-- 4. Add supplier specialty segmentation
-- 5. Incorporate demographic factors
-- 6. Calculate condition co-occurrence impacts

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:08:10.826550
    - Additional Notes: Query focuses on statistical correlations between chronic conditions and DMEPOS utilization patterns. Results should be interpreted carefully as correlations are calculated across supplier averages rather than patient-level data. The 100+ beneficiary threshold may exclude some specialized suppliers serving rare conditions.
    
    */