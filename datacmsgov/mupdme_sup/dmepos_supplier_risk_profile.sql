-- medical_equipment_supplier_risk_analysis.sql

-- Business Purpose: 
-- This query analyzes Medicare DMEPOS suppliers by combining financial metrics with patient risk factors
-- to identify suppliers serving high-risk beneficiary populations. This analysis helps:
-- 1. Identify suppliers specializing in complex patient populations
-- 2. Support care coordination for high-risk beneficiaries
-- 3. Guide resource allocation and supplier network development
-- 4. Inform value-based care program development

SELECT 
    s.suplr_npi,
    s.suplr_prvdr_last_name_org as supplier_name,
    s.suplr_prvdr_city as city,
    s.suplr_prvdr_state_abrvtn as state,
    
    -- Financial metrics
    s.suplr_mdcr_pymt_amt as total_medicare_payments,
    s.tot_suplr_benes as total_beneficiaries,
    
    -- Calculate payment per beneficiary
    ROUND(s.suplr_mdcr_pymt_amt / NULLIF(s.tot_suplr_benes, 0), 2) as payment_per_beneficiary,
    
    -- Risk profile metrics
    s.bene_avg_risk_scre as avg_risk_score,
    
    -- Key chronic condition percentages
    s.bene_cc_ph_diabetes_v2_pct as diabetes_pct,
    s.bene_cc_ph_ckd_v2_pct as chronic_kidney_disease_pct,
    s.bene_cc_ph_copd_v2_pct as copd_pct,
    s.bene_cc_ph_hf_nonihd_v2_pct as heart_failure_pct,
    
    -- Demographic splits
    ROUND(100.0 * s.bene_dual_cnt / NULLIF(s.tot_suplr_benes, 0), 1) as dual_eligible_pct,
    ROUND(100.0 * s.bene_age_gt_84_cnt / NULLIF(s.tot_suplr_benes, 0), 1) as elderly_pct

FROM mimi_ws_1.datacmsgov.mupdme_sup s

-- Filter for most recent year and significant suppliers
WHERE s.mimi_src_file_date = '2022-12-31'  -- Adjust year as needed
  AND s.tot_suplr_benes >= 100  -- Focus on suppliers with meaningful volume
  AND s.bene_avg_risk_scre > 0  -- Ensure valid risk scores

-- Order by risk score to highlight high-risk populations
ORDER BY s.bene_avg_risk_scre DESC
LIMIT 100;

-- Query Operation:
-- 1. Selects key supplier identification, financial, and risk metrics
-- 2. Calculates per-beneficiary payment rates
-- 3. Includes major chronic condition percentages
-- 4. Computes demographic percentages
-- 5. Filters for recent data and meaningful supplier volume
-- 6. Sorts by average risk score to highlight high-risk populations

-- Assumptions & Limitations:
-- 1. Assumes current year data is available (2022)
-- 2. Limited to suppliers with 100+ beneficiaries for statistical relevance
-- 3. Risk scores and chronic condition data may have reporting lags
-- 4. Does not account for regional cost variations

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic clustering analysis
-- 3. Add service mix analysis (DME vs. POS vs. Drug)
-- 4. Incorporate quality metrics when available
-- 5. Add peer group comparisons by specialty or region/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:07:50.179249
    - Additional Notes: The query focuses on suppliers' patient risk profiles and chronic condition rates. Note that the payment analysis is based on total Medicare payments rather than service-specific breakdowns (DME, POS, drug). The results are limited to suppliers with 100+ beneficiaries to ensure statistical significance. Consider adjusting the date filter (2022-12-31) based on the most recent data available in the system.
    
    */