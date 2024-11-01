-- Medicare Inpatient Hospital Cost Efficiency Analysis
--
-- Business Purpose:
-- This query analyzes Medicare inpatient hospital cost efficiency to:
-- 1. Calculate key efficiency metrics like cost per discharge and Medicare payment ratio
-- 2. Identify hospitals with optimal cost management practices
-- 3. Support strategic decisions around network optimization and value-based care
--
-- The analysis helps healthcare organizations and payers understand:
-- - Which hospitals deliver care most cost-efficiently
-- - Variations in cost structures and payment rates
-- - Opportunities for improving operational efficiency

SELECT
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    rndrng_prvdr_ruca_desc,
    
    -- Volume metrics
    tot_dschrgs as total_discharges,
    tot_cvrd_days as total_covered_days,
    
    -- Cost metrics
    tot_submtd_cvrd_chrg as total_submitted_charges,
    tot_mdcr_pymt_amt as total_medicare_payments,
    
    -- Calculate key efficiency ratios
    ROUND(tot_submtd_cvrd_chrg / NULLIF(tot_dschrgs, 0), 2) as avg_charge_per_discharge,
    ROUND(tot_mdcr_pymt_amt / NULLIF(tot_dschrgs, 0), 2) as avg_medicare_payment_per_discharge,
    ROUND(tot_mdcr_pymt_amt / NULLIF(tot_submtd_cvrd_chrg, 0) * 100, 1) as medicare_payment_ratio,
    ROUND(tot_cvrd_days / NULLIF(tot_dschrgs, 0), 1) as avg_length_of_stay

FROM mimi_ws_1.datacmsgov.mupihp_prvdr
WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
  AND tot_dschrgs >= 100 -- Focus on hospitals with material volume
  
ORDER BY avg_medicare_payment_per_discharge DESC
LIMIT 1000;

-- How this works:
-- 1. Filters to most recent year of data and hospitals with significant volume
-- 2. Calculates key efficiency metrics per discharge and payment ratios
-- 3. Orders results by Medicare payment per discharge to identify cost patterns
--
-- Assumptions & Limitations:
-- - Focuses only on Medicare fee-for-service payments, not Medicare Advantage
-- - Cost variations may reflect differences in case mix and regional factors
-- - Minimum discharge threshold may exclude some smaller hospitals
--
-- Possible Extensions:
-- 1. Add case mix adjustment using HCC risk scores
-- 2. Compare urban vs rural cost patterns
-- 3. Analyze relationship between efficiency and quality metrics
-- 4. Trend analysis over multiple years
-- 5. Segment analysis by hospital characteristics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:11:17.117142
    - Additional Notes: The query focuses on Medicare cost efficiency metrics at the provider level. It requires at least 100 discharges per provider to ensure statistical reliability. The payment ratios and per-discharge metrics provide insights into cost management effectiveness, though they should be interpreted alongside quality metrics for a complete performance assessment.
    
    */