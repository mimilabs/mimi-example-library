-- Title: Outpatient Hospital Service Affordability Assessment
--
-- Business Purpose:
-- This query analyzes the financial burden of outpatient hospital services on Medicare beneficiaries
-- by comparing Medicare-allowed amounts to submitted charges across states and services.
-- The analysis helps identify areas where beneficiaries may face high out-of-pocket costs
-- and supports policy decisions around Medicare coverage and payment rates.

WITH service_metrics AS (
    -- Calculate average beneficiary responsibility and coverage rates
    SELECT 
        rndrng_prvdr_geo_desc as state_name,
        apc_desc as service_description,
        COUNT(DISTINCT apc_cd) as unique_services,
        SUM(bene_cnt) as total_beneficiaries,
        AVG(avg_tot_sbmtd_chrgs) as avg_submitted_charge,
        AVG(avg_mdcr_alowd_amt) as avg_allowed_amount,
        AVG(avg_mdcr_pymt_amt) as avg_medicare_payment,
        -- Calculate average beneficiary responsibility
        AVG(avg_mdcr_alowd_amt - avg_mdcr_pymt_amt) as avg_beneficiary_responsibility,
        -- Calculate Medicare coverage rate
        AVG(avg_mdcr_pymt_amt / NULLIF(avg_tot_sbmtd_chrgs, 0)) * 100 as medicare_coverage_rate
    FROM mimi_ws_1.datacmsgov.mupohp_geo
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND rndrng_prvdr_geo_lvl = 'State'  -- State-level analysis
    GROUP BY 1, 2
)
SELECT 
    state_name,
    service_description,
    total_beneficiaries,
    ROUND(avg_submitted_charge, 2) as avg_submitted_charge,
    ROUND(avg_allowed_amount, 2) as avg_allowed_amount,
    ROUND(avg_beneficiary_responsibility, 2) as avg_beneficiary_responsibility,
    ROUND(medicare_coverage_rate, 1) as medicare_coverage_percentage
FROM service_metrics
WHERE total_beneficiaries > 100  -- Focus on services with significant utilization
ORDER BY avg_beneficiary_responsibility DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to calculate key affordability metrics by state and service
-- 2. Calculates average beneficiary responsibility (difference between allowed amount and Medicare payment)
-- 3. Computes Medicare coverage rate as percentage of submitted charges covered
-- 4. Filters for services with significant utilization
-- 5. Returns top 20 services with highest beneficiary financial responsibility

-- Assumptions and Limitations:
-- 1. Assumes 2022 data is most recent and complete
-- 2. Focuses on state-level patterns, missing facility-level variations
-- 3. Does not account for secondary insurance coverage
-- 4. Minimum beneficiary threshold of 100 may exclude some specialized services

-- Possible Extensions:
-- 1. Add year-over-year comparison of beneficiary responsibility
-- 2. Include regional groupings for geographic pattern analysis
-- 3. Add service category classification for better grouping
-- 4. Compare with state-level income data to assess relative burden
-- 5. Include analysis of outlier payments impact on affordability

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:13:55.409012
    - Additional Notes: Query identifies high financial burden services by analyzing beneficiary out-of-pocket costs across states. Minimum threshold of 100 beneficiaries ensures statistical significance but may exclude rare procedures. Coverage rate calculation could be affected by zero-charge edge cases.
    
    */