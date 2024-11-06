-- pac_dual_eligible_cost_analysis.sql

-- Business Purpose:
-- Analyze cost and utilization patterns for dual-eligible beneficiaries across post-acute care settings
-- to identify opportunities for improved care coordination and cost management.
-- This analysis helps:
-- - Quantify the financial impact of dual-eligible populations
-- - Identify settings with high dual-eligible concentrations
-- - Support care management program development
-- - Guide policy decisions around dual-eligible care delivery

WITH setting_summary AS (
  SELECT 
    srvc_ctgry,
    -- Calculate weighted averages and totals
    SUM(tot_mdcr_pymt_amt) as total_medicare_payment,
    SUM(bene_dstnct_cnt) as total_beneficiaries,
    AVG(bene_dual_pct) as avg_dual_pct,
    
    -- Calculate per-beneficiary metrics
    SUM(tot_mdcr_pymt_amt) / NULLIF(SUM(bene_dstnct_cnt), 0) as payment_per_beneficiary,
    
    -- Calculate dual-eligible specific metrics  
    SUM(bene_dstnct_cnt * bene_dual_pct/100) as est_dual_beneficiaries,
    SUM(tot_mdcr_pymt_amt * bene_dual_pct/100) as est_dual_payments
  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'National' -- Focus on national level stats
    AND year = 2022 -- Most recent year
  GROUP BY srvc_ctgry
)

SELECT 
  srvc_ctgry as service_category,
  ROUND(avg_dual_pct, 1) as dual_eligible_percentage,
  ROUND(est_dual_beneficiaries) as estimated_dual_beneficiaries,
  ROUND(payment_per_beneficiary, 0) as avg_payment_per_beneficiary,
  ROUND(est_dual_payments/1000000, 1) as est_dual_payments_millions,
  ROUND(est_dual_payments/est_dual_beneficiaries, 0) as est_payment_per_dual
FROM setting_summary
ORDER BY est_dual_payments DESC;

-- How the Query Works:
-- 1. Creates a CTE to aggregate national-level statistics by service category
-- 2. Calculates key metrics around dual-eligible beneficiaries and costs
-- 3. Returns formatted results showing dual-eligible percentages and financial impact
-- 4. Orders results by estimated dual-eligible payments to highlight highest impact areas

-- Assumptions and Limitations:
-- - Uses national level data only - state variations not captured
-- - Dual-eligible payment estimates are approximated using overall percentages
-- - Does not account for potential differences in service intensity between dual/non-dual
-- - Limited to Medicare payments only, does not include Medicaid portion

-- Possible Extensions:
-- 1. Add state-level analysis to identify geographic variations
-- 2. Include year-over-year trending of dual-eligible metrics
-- 3. Incorporate clinical conditions and demographics for dual populations
-- 4. Add length of stay and service utilization comparisons
-- 5. Calculate total cost of care including both Medicare and Medicaid portions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:05:04.559867
    - Additional Notes: Query focuses on national-level Medicare spending patterns for dual-eligible beneficiaries across post-acute care settings. Does not include Medicaid costs or state-level variations. The estimated dual payments are approximations based on overall percentages.
    
    */