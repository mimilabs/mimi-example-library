-- dmepos_prosthetic_orthotic_analysis.sql

-- Business Purpose:
-- - Analyze Medicare prosthetic and orthotic (POS) prescribing patterns and costs
-- - Identify key providers and specialties driving POS utilization
-- - Support medical policy and coverage decisions for prosthetics/orthotics
-- - Enable strategic planning for DME suppliers and manufacturers

SELECT 
    -- Provider identification and location
    rfrg_prvdr_spclty_desc,
    rfrg_prvdr_state_abrvtn,
    rfrg_prvdr_ruca_desc,
    COUNT(DISTINCT rfrg_npi) as provider_count,
    
    -- POS utilization metrics 
    SUM(pos_tot_suplr_benes) as total_pos_beneficiaries,
    SUM(pos_tot_suplr_srvcs) as total_pos_services,
    ROUND(AVG(pos_tot_suplr_hcpcs_cds),1) as avg_pos_hcpcs_per_provider,
    
    -- Cost and payment analysis
    ROUND(SUM(pos_suplr_mdcr_pymt_amt)/1000000,2) as total_pos_payments_millions,
    ROUND(AVG(pos_suplr_mdcr_pymt_amt),0) as avg_pos_payment_per_provider,
    
    -- Beneficiary demographics
    ROUND(AVG(bene_avg_age),1) as avg_patient_age,
    SUM(bene_age_gt_84_cnt)/SUM(tot_suplr_benes)*100 as pct_patients_over_84,
    SUM(bene_dual_cnt)/SUM(tot_suplr_benes)*100 as pct_dual_eligible

FROM mimi_ws_1.datacmsgov.mupdme_prvdr
WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
  AND pos_sprsn_ind IS NULL              -- Exclude suppressed records
  AND pos_tot_suplr_benes > 0            -- Only providers with POS claims
  
GROUP BY 1,2,3
HAVING total_pos_beneficiaries >= 100    -- Focus on providers with material volume

ORDER BY total_pos_payments_millions DESC
LIMIT 100;

-- How this query works:
-- 1. Filters to focus on prosthetic/orthotic services from providers with meaningful volume
-- 2. Aggregates key metrics by provider specialty and geography
-- 3. Calculates utilization, cost and demographic measures
-- 4. Returns top 100 specialty/geography combinations by total payments

-- Assumptions and Limitations:
-- - Uses most recent complete year of data (2022)
-- - Excludes suppressed records which may impact completeness
-- - Minimum volume threshold of 100 beneficiaries may exclude some specialties
-- - Geographic analysis at state level only, more granular analysis possible
-- - Does not distinguish between different types of prosthetics/orthotics

-- Possible Extensions:
-- 1. Add year-over-year trending analysis
-- 2. Break out by specific HCPCS codes or categories
-- 3. Include chronic condition analysis for POS patients
-- 4. Add supplier/manufacturer analysis
-- 5. Enhance geographic analysis to ZIP or county level
-- 6. Compare standardized vs actual payments
-- 7. Analyze authorization patterns and denial rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:05:16.460195
    - Additional Notes: Query analyzes prosthetic/orthotic (POS) utilization patterns across provider specialties and geographies, focusing on Medicare payment patterns and beneficiary demographics. Minimum threshold of 100 beneficiaries per specialty/geography group ensures statistical relevance but may exclude some smaller providers or rural areas. Data suppression rules may impact completeness of analysis.
    
    */