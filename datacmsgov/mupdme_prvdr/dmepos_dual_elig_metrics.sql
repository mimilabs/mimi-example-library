-- dmepos_dual_eligibility_impacts.sql

-- Business Purpose:
-- - Analyze DMEPOS utilization and cost patterns for dual-eligible Medicare/Medicaid beneficiaries
-- - Compare provider prescribing patterns between dual-eligible and non-dual populations
-- - Identify opportunities for care coordination and cost management
-- - Support policy decisions around dual-eligible coverage and reimbursement

WITH provider_metrics AS (
  -- Calculate key metrics at the provider level
  SELECT 
    rfrg_prvdr_spclty_desc,
    rfrg_prvdr_state_abrvtn,
    COUNT(DISTINCT rfrg_npi) as provider_count,
    
    -- Dual eligibility metrics
    SUM(bene_dual_cnt) as total_dual_benes,
    SUM(bene_ndual_cnt) as total_nondual_benes,
    AVG(CAST(bene_dual_cnt AS FLOAT)/(NULLIF(bene_dual_cnt + bene_ndual_cnt, 0))) as pct_dual_eligible,
    
    -- Cost and utilization metrics 
    AVG(suplr_mdcr_pymt_amt) as avg_medicare_payment,
    AVG(tot_suplr_srvcs) as avg_services_per_provider,
    AVG(bene_avg_risk_scre) as avg_risk_score
    
  FROM mimi_ws_1.datacmsgov.mupdme_prvdr
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    AND tot_suplr_benes >= 11  -- Exclude low-volume providers
  GROUP BY 1,2
)

SELECT
  rfrg_prvdr_spclty_desc,
  rfrg_prvdr_state_abrvtn,
  provider_count,
  ROUND(pct_dual_eligible * 100, 1) as pct_dual_eligible,
  ROUND(avg_medicare_payment, 2) as avg_medicare_payment,
  ROUND(avg_services_per_provider, 1) as avg_services_per_provider,
  ROUND(avg_risk_score, 2) as avg_risk_score,
  
  -- Calculate relative metrics
  ROUND(avg_medicare_payment / NULLIF(avg_services_per_provider, 0), 2) as payment_per_service
  
FROM provider_metrics
WHERE provider_count >= 10  -- Focus on specialties with meaningful volume
ORDER BY pct_dual_eligible DESC, avg_medicare_payment DESC
LIMIT 100;

-- How this query works:
-- 1. Creates provider_metrics CTE to aggregate key metrics by specialty and state
-- 2. Calculates dual eligibility percentages and cost/utilization metrics
-- 3. Filters for meaningful provider volumes and most recent data
-- 4. Presents results sorted by dual eligibility percentage and costs

-- Assumptions and Limitations:
-- - Uses 2022 data - results may vary for other years
-- - Excludes providers with <11 beneficiaries due to data suppression
-- - Focuses on specialties with at least 10 providers for statistical relevance
-- - Does not account for geographic cost variations
-- - Dual eligibility status is binary and doesn't reflect partial year coverage

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of dual eligible utilization
-- 2. Break down by specific DME/POS/drug categories
-- 3. Incorporate geographic factors like RUCA codes
-- 4. Add chronic condition prevalence correlations
-- 5. Compare standardized vs non-standardized payments
-- 6. Analyze seasonal patterns in dual eligible utilization

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:53:50.183316
    - Additional Notes: Query focuses on calculating key DMEPOS metrics by provider specialty and state, with emphasis on dual-eligible beneficiary patterns. Requires at least 10 providers per specialty and 11 beneficiaries per provider for statistical relevance. Uses 2022 data by default but can be modified for other years by changing mimi_src_file_date filter.
    
    */