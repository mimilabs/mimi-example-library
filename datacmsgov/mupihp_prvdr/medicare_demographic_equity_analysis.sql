-- Medicare Inpatient Demographic and Health Equity Analysis
--
-- Business Purpose:
-- This query analyzes demographic patterns and potential health disparities across Medicare inpatient providers to:
-- 1. Identify hospitals serving vulnerable populations (dual eligible, elderly, minority communities)
-- 2. Analyze differences in utilization and payment patterns by demographic segments
-- 3. Support health equity initiatives and resource allocation planning
--

WITH provider_metrics AS (
  SELECT 
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    rndrng_prvdr_ruca_desc,
    tot_dschrgs,
    tot_mdcr_pymt_amt,
    -- Calculate key demographic ratios
    ROUND(bene_dual_cnt * 100.0 / NULLIF(tot_benes, 0), 1) as dual_eligible_pct,
    ROUND(bene_age_gt_84_cnt * 100.0 / NULLIF(tot_benes, 0), 1) as elderly_85plus_pct,
    ROUND((bene_race_black_cnt + bene_race_hspnc_cnt) * 100.0 / NULLIF(tot_benes, 0), 1) as minority_pct,
    -- Calculate key financial metrics
    ROUND(tot_mdcr_pymt_amt / NULLIF(tot_dschrgs, 0), 0) as payment_per_discharge
  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
  AND tot_dschrgs >= 100 -- Focus on providers with meaningful volume
)

SELECT
  rndrng_prvdr_state_abrvtn as state,
  rndrng_prvdr_ruca_desc as rural_urban_status,
  COUNT(DISTINCT rndrng_prvdr_ccn) as hospital_count,
  ROUND(AVG(dual_eligible_pct), 1) as avg_dual_eligible_pct,
  ROUND(AVG(elderly_85plus_pct), 1) as avg_elderly_85plus_pct,
  ROUND(AVG(minority_pct), 1) as avg_minority_pct,
  ROUND(AVG(payment_per_discharge), 0) as avg_payment_per_discharge,
  ROUND(SUM(tot_dschrgs), 0) as total_discharges
FROM provider_metrics
GROUP BY 1, 2
HAVING hospital_count >= 3 -- Ensure adequate sample size
ORDER BY state, rural_urban_status;

-- How this query works:
-- 1. First CTE calculates key demographic ratios and financial metrics at the provider level
-- 2. Main query aggregates these metrics by state and rural/urban status
-- 3. Results show systematic patterns in how different demographic groups are served across geographies

-- Assumptions and Limitations:
-- - Analysis limited to fee-for-service Medicare beneficiaries
-- - Minimum volume threshold of 100 discharges applied to exclude very small providers
-- - Demographic categories are not mutually exclusive
-- - Rural/urban classifications may not capture full complexity of service areas

-- Possible Extensions:
-- 1. Add quality metrics to examine relationships between demographics and outcomes
-- 2. Incorporate time trends to analyze changes in demographic patterns
-- 3. Add geographic mapping capabilities to visualize regional variations
-- 4. Include analysis of specific clinical conditions by demographic groups
-- 5. Compare hospitals within peer groups based on size and teaching status

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:35:47.140729
    - Additional Notes: Query focuses on health equity metrics across geographic and demographic dimensions. Note that certain low-volume providers are excluded (<100 discharges) and results are only shown for geographic areas with at least 3 hospitals to ensure statistical relevance. Dual-eligible and minority population metrics may be particularly useful for policy and resource allocation decisions.
    
    */