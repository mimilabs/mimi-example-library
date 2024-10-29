-- pac_demographic_disparities.sql
--  
-- Business Purpose:
-- Examine demographic disparities in Medicare post-acute care utilization and spending
-- to identify potential gaps in care access and outcomes across different populations.
-- Key metrics analyzed include dual eligibility rates, racial/ethnic composition,
-- standardized payments, and service utilization by demographic groups.
--
-- This analysis can inform:
-- - Health equity initiatives and resource allocation
-- - Targeted outreach programs for underserved populations  
-- - Policy recommendations to address disparities

-- Main Query
WITH base_metrics AS (
  SELECT
    srvc_ctgry,
    state,
    -- Calculate weighted averages using beneficiary counts
    SUM(bene_dstnct_cnt * bene_dual_pct) / SUM(bene_dstnct_cnt) AS avg_dual_elig_pct,
    SUM(bene_dstnct_cnt * bene_rrl_pct) / SUM(bene_dstnct_cnt) AS avg_rural_pct,
    SUM(bene_dstnct_cnt * bene_race_black_pct) / SUM(bene_dstnct_cnt) AS avg_black_pct,
    SUM(bene_dstnct_cnt * bene_race_hspnc_pct) / SUM(bene_dstnct_cnt) AS avg_hispanic_pct,
    -- Payment and utilization metrics
    SUM(tot_mdcr_stdzd_pymt_amt) / SUM(bene_dstnct_cnt) AS avg_stdz_pymt_per_bene,
    SUM(tot_srvc_days) / SUM(bene_dstnct_cnt) AS avg_days_per_bene,
    SUM(bene_dstnct_cnt) AS total_benes
  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'State' -- State-level analysis
    AND state IS NOT NULL
  GROUP BY srvc_ctgry, state
)

SELECT 
  srvc_ctgry,
  state,
  ROUND(avg_dual_elig_pct, 1) AS dual_eligible_pct,
  ROUND(avg_rural_pct, 1) AS rural_pct,
  ROUND(avg_black_pct, 1) AS black_pct,
  ROUND(avg_hispanic_pct, 1) AS hispanic_pct,
  ROUND(avg_stdz_pymt_per_bene, 0) AS avg_payment_per_bene,
  ROUND(avg_days_per_bene, 1) AS avg_los,
  total_benes
FROM base_metrics
ORDER BY 
  srvc_ctgry,
  total_benes DESC

--
-- How it works:
-- 1. Calculates weighted averages of demographic metrics using beneficiary counts
-- 2. Computes per-beneficiary standardized payments and service days
-- 3. Groups results by service category and state to enable geographic comparisons
-- 4. Rounds metrics to appropriate decimal places for readability
--
-- Assumptions and Limitations:
-- - Relies on accurate demographic coding in claims data
-- - State-level aggregation may mask county/local variation
-- - Does not account for differences in patient acuity or social determinants
-- - Limited to Medicare FFS beneficiaries only
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis of disparities
-- 2. Include clinical outcomes metrics by demographic group
-- 3. Incorporate provider-level attributes (e.g., ownership, size)
-- 4. Add statistical testing for significant disparities
-- 5. Create demographic-adjusted benchmarks by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:30:06.449512
    - Additional Notes: This query calculates weighted averages to ensure accurate representation of demographic patterns across different facility sizes. The standardized payment metrics allow for fair geographic comparisons by adjusting for regional cost differences. Users should note that dual eligibility and rural status flags may have reporting lags compared to claims data.
    
    */