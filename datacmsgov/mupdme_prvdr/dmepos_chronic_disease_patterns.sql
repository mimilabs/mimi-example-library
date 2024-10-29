-- dmepos_chronic_condition_utilization.sql 

-- Business Purpose:
-- - Analyze DMEPOS utilization patterns for providers treating high-risk chronic conditions
-- - Identify opportunities for care coordination between DMEPOS and chronic disease management
-- - Support medical policy and coverage decisions for specific patient populations
-- - Guide provider outreach and education efforts

WITH provider_summary AS (
  SELECT 
    -- Provider demographics
    rfrg_npi,
    rfrg_prvdr_last_name_org,
    rfrg_prvdr_spclty_desc,
    
    -- Utilization metrics
    tot_suplr_benes,
    suplr_mdcr_stdzd_pymt_amt,
    
    -- Key chronic conditions
    bene_cc_ph_diabetes_v2_pct,
    bene_cc_ph_copd_v2_pct,
    bene_cc_ph_hf_nonihd_v2_pct,
    bene_cc_ph_ckd_v2_pct,
    
    -- Overall patient risk
    bene_avg_risk_scre
    
  FROM mimi_ws_1.datacmsgov.mupdme_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent year
    AND tot_suplr_benes >= 11 -- Remove suppressed data
)

SELECT
  rfrg_prvdr_spclty_desc AS provider_specialty,
  COUNT(DISTINCT rfrg_npi) AS provider_count,
  
  -- Utilization summary
  SUM(tot_suplr_benes) AS total_beneficiaries,
  ROUND(SUM(suplr_mdcr_stdzd_pymt_amt)/1000000, 2) AS total_payments_millions,
  
  -- Average chronic condition percentages
  ROUND(AVG(bene_cc_ph_diabetes_v2_pct), 1) AS avg_diabetes_pct,
  ROUND(AVG(bene_cc_ph_copd_v2_pct), 1) AS avg_copd_pct,
  ROUND(AVG(bene_cc_ph_hf_nonihd_v2_pct), 1) AS avg_heart_failure_pct,
  ROUND(AVG(bene_cc_ph_ckd_v2_pct), 1) AS avg_ckd_pct,
  
  -- Risk profile
  ROUND(AVG(bene_avg_risk_scre), 2) AS avg_risk_score

FROM provider_summary
GROUP BY rfrg_prvdr_spclty_desc
HAVING COUNT(DISTINCT rfrg_npi) >= 10 -- Focus on specialties with meaningful sample size
ORDER BY total_payments_millions DESC
LIMIT 20;

-- How this works:
-- 1. Creates provider_summary CTE with key metrics for each provider
-- 2. Aggregates data by specialty to show chronic condition patterns
-- 3. Filters for statistically meaningful specialty groups
-- 4. Shows top 20 specialties by Medicare payments

-- Assumptions & Limitations:
-- - Uses 2022 data only - trends over time not captured
-- - Excludes providers with <11 beneficiaries due to data suppression
-- - Limited to top 4 chronic conditions most relevant to DMEPOS
-- - Specialty groups must have at least 10 providers

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic variation in chronic condition patterns
-- 3. Break down by specific DMEPOS product categories
-- 4. Add provider-level outlier analysis within specialties
-- 5. Incorporate additional chronic conditions or comorbidity combinations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:12:54.607933
    - Additional Notes: Query focuses on Medicare DMEPOS provider specialties and their patient populations with chronic conditions. Requires minimum beneficiary counts (>=11) and provider counts (>=10) per specialty for statistical significance. Limited to 2022 data and top 4 chronic conditions most relevant to DMEPOS utilization.
    
    */