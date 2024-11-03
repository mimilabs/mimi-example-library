-- Medicare Provider Efficiency and Cost Analysis
-- Business Purpose: 
-- This query analyzes Medicare provider cost efficiency and payment patterns to:
-- - Identify providers with optimal cost-to-reimbursement ratios
-- - Understand service volume and payment efficiency patterns
-- - Support strategic planning for value-based care initiatives

WITH provider_metrics AS (
  SELECT 
    npi,
    facility_name,
    pri_spec,
    -- Calculate key efficiency metrics
    tot_mdcr_pymt_amt / NULLIF(tot_srvcs, 0) as payment_per_service,
    tot_mdcr_pymt_amt / NULLIF(tot_benes, 0) as payment_per_beneficiary,
    tot_mdcr_pymt_amt / NULLIF(tot_sbmtd_chrg, 0) as payment_to_charge_ratio,
    tot_srvcs / NULLIF(tot_benes, 0) as services_per_beneficiary,
    tot_benes,
    tot_srvcs,
    tot_mdcr_pymt_amt
  FROM mimi_ws_1.umn_ihdc.competition_dataset_2025
  WHERE tot_benes > 0  -- Filter for active providers
)

SELECT 
  pri_spec,
  COUNT(DISTINCT npi) as provider_count,
  ROUND(AVG(payment_per_service), 2) as avg_payment_per_service,
  ROUND(AVG(payment_per_beneficiary), 2) as avg_payment_per_beneficiary,
  ROUND(AVG(payment_to_charge_ratio), 3) as avg_payment_to_charge_ratio,
  ROUND(AVG(services_per_beneficiary), 1) as avg_services_per_beneficiary,
  ROUND(SUM(tot_mdcr_pymt_amt)/1000000, 2) as total_payments_millions,
  ROUND(SUM(tot_benes), 0) as total_beneficiaries
FROM provider_metrics
GROUP BY pri_spec
HAVING provider_count >= 5  -- Ensure statistical significance
ORDER BY total_payments_millions DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to calculate key efficiency metrics per provider
-- 2. Aggregates metrics by specialty to identify patterns
-- 3. Includes protection against division by zero using NULLIF
-- 4. Filters for meaningful sample sizes
-- 5. Focuses on highest-impact specialties by total payments

-- Assumptions and Limitations:
-- - Assumes tot_benes > 0 for valid providers
-- - Limited to top 20 specialties by payment volume
-- - May not account for complexity differences between specialties
-- - Geographic variations not considered
-- - Payment amounts may need adjustment for regional cost differences

-- Possible Extensions:
-- 1. Add geographic analysis by zip_code
-- 2. Include quality metrics correlation analysis
-- 3. Trend analysis if historical data available
-- 4. Risk adjustment using bene_avg_risk_scre
-- 5. Specialty-specific benchmarking
-- 6. Analysis of outlier providers within specialties

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:22:10.808369
    - Additional Notes: Query focuses on cost efficiency ratios and payment patterns. Results are filtered for providers with at least 5 providers per specialty to ensure statistical validity. Payment metrics are normalized per service and beneficiary to enable fair comparisons across different practice sizes.
    
    */