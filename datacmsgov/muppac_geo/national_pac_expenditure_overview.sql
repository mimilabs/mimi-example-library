
-- medicare_national_pac_overview.sql
-- Business Purpose:
-- Provide a comprehensive national-level snapshot of Medicare Post-Acute Care (PAC) expenditures, 
-- service utilization, and beneficiary characteristics across different care settings.
-- Key insights help healthcare leaders and policymakers understand:
-- 1. Total Medicare spending on post-acute care services
-- 2. Beneficiary demographic and health complexity profiles
-- 3. Service utilization patterns across different PAC settings

WITH national_pac_summary AS (
    SELECT 
        year,
        -- Aggregate key metrics across all PAC settings at national level
        srvc_ctgry,
        
        -- Financial Metrics
        SUM(tot_mdcr_pymt_amt) AS total_medicare_payment,
        SUM(tot_chrg_amt) AS total_charges,
        
        -- Beneficiary Volume
        SUM(bene_dstnct_cnt) AS total_beneficiaries,
        
        -- Demographic Insights
        AVG(bene_avg_age) AS avg_beneficiary_age,
        AVG(bene_male_pct) AS pct_male_beneficiaries,
        AVG(bene_dual_pct) AS pct_dual_eligible,
        
        -- Health Complexity
        AVG(bene_avg_risk_scre) AS avg_risk_score,
        AVG(bene_avg_cc_cnt) AS avg_chronic_conditions
    FROM 
        mimi_ws_1.datacmsgov.muppac_geo
    WHERE 
        smry_ctgry = 'National' 
        AND year = (SELECT MAX(year) FROM mimi_ws_1.datacmsgov.muppac_geo)
    GROUP BY 
        year, srvc_ctgry
)

SELECT 
    srvc_ctgry,
    total_medicare_payment,
    total_charges,
    total_beneficiaries,
    avg_beneficiary_age,
    pct_male_beneficiaries,
    pct_dual_eligible,
    avg_risk_score,
    avg_chronic_conditions,
    
    -- Calculate payment per beneficiary for comparative analysis
    ROUND(total_medicare_payment / total_beneficiaries, 2) AS payment_per_beneficiary
FROM 
    national_pac_summary
ORDER BY 
    total_medicare_payment DESC;

-- Query Mechanics:
-- 1. Filter for national-level data and most recent year
-- 2. Aggregate key metrics by service category
-- 3. Compute derived metrics like payment per beneficiary

-- Assumptions and Limitations:
-- - Uses most recent available year's data
-- - National-level aggregation masks regional variations
-- - Relies on CMS reporting and classification of service categories

-- Potential Query Extensions:
-- 1. Add time-series analysis to track year-over-year changes
-- 2. Incorporate more granular chronic condition breakdowns
-- 3. Compare metrics across different PAC settings


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:00:19.827765
    - Additional Notes: Query focuses on national-level aggregation of Medicare post-acute care metrics. Calculation of payment per beneficiary and health complexity metrics requires recent, complete data from CMS reporting.
    
    */