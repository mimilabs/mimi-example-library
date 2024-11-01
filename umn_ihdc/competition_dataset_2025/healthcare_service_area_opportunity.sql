-- Healthcare Service Area Demographics Analysis
-- Business Purpose:
-- This query analyzes demographic patterns and service utilization across ZIP codes to:
-- - Identify underserved populations and potential market opportunities
-- - Support strategic facility location and service expansion decisions
-- - Guide targeted outreach and population health initiatives

WITH zip_demographics AS (
    -- Aggregate key demographic and utilization metrics by ZIP code
    SELECT 
        zip_code,
        COUNT(DISTINCT npi) as provider_count,
        SUM(tot_benes) as total_beneficiaries,
        AVG(bene_avg_age) as avg_patient_age,
        SUM(bene_dual_cnt) / NULLIF(SUM(tot_benes), 0) * 100 as dual_eligible_pct,
        SUM(tot_mdcr_pymt_amt) / NULLIF(SUM(tot_benes), 0) as payment_per_beneficiary,
        AVG(prop_rural_status) * 100 as rural_status_pct
    FROM mimi_ws_1.umn_ihdc.competition_dataset_2025
    GROUP BY zip_code
),

disease_burden AS (
    -- Calculate disease prevalence metrics by ZIP code
    SELECT 
        zip_code,
        AVG(bene_cc_ph_diabetes_v2_pct) as diabetes_pct,
        AVG(bene_cc_ph_hypertension_v2_pct) as hypertension_pct,
        AVG(bene_cc_ph_ckd_v2_pct) as ckd_pct,
        AVG(bene_cc_bh_depress_v1_pct) as depression_pct
    FROM mimi_ws_1.umn_ihdc.competition_dataset_2025
    GROUP BY zip_code
)

SELECT 
    d.zip_code,
    d.provider_count,
    d.total_beneficiaries,
    d.avg_patient_age,
    d.dual_eligible_pct,
    d.payment_per_beneficiary,
    d.rural_status_pct,
    db.diabetes_pct,
    db.hypertension_pct,
    db.ckd_pct,
    db.depression_pct,
    -- Calculate service area opportunity score
    (CASE 
        WHEN d.provider_count = 0 THEN 5
        WHEN d.provider_count < 5 THEN 4
        WHEN d.provider_count < 10 THEN 3
        WHEN d.provider_count < 20 THEN 2
        ELSE 1
    END) * 
    (CASE 
        WHEN d.rural_status_pct > 50 THEN 2
        ELSE 1
    END) * 
    (CASE 
        WHEN (db.diabetes_pct + db.hypertension_pct + db.ckd_pct + db.depression_pct) > 100 THEN 2
        ELSE 1
    END) as opportunity_score
FROM zip_demographics d
JOIN disease_burden db ON d.zip_code = db.zip_code
ORDER BY opportunity_score DESC, total_beneficiaries DESC;

-- How the Query Works:
-- 1. Creates two CTEs to aggregate demographic and disease burden metrics by ZIP code
-- 2. Joins these CTEs and calculates an opportunity score based on:
--    - Provider density (fewer providers = higher opportunity)
--    - Rural status (rural areas = higher opportunity)
--    - Disease burden (higher prevalence = higher opportunity)
-- 3. Orders results by opportunity score and beneficiary volume

-- Assumptions and Limitations:
-- - Assumes ZIP codes are valid and consistent
-- - Does not account for geographic proximity between ZIP codes
-- - Simplified scoring model may need refinement based on business priorities
-- - Does not consider competitor locations outside the dataset

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Include demographic growth trends and projections
-- 3. Incorporate social determinants of health data
-- 4. Add drive time/distance analysis between ZIP codes
-- 5. Include financial metrics like reimbursement rates
-- 6. Add provider specialty mix analysis
-- 7. Include quality metrics in opportunity scoring

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:44:22.373874
    - Additional Notes: The opportunity score calculation uses a weighted scoring system based on provider density (1-5 points), rural status (1-2x multiplier), and disease burden (1-2x multiplier). Higher scores indicate areas with potential market opportunities. The scoring thresholds may need adjustment based on specific market conditions and business objectives. Consider zip code population size when interpreting results.
    
    */