
-- Medicare Inpatient Hospital Provider Complexity and Specialty Characterization

/*
Business Purpose:
This query identifies and characterizes Medicare inpatient hospital providers 
based on their unique patient complexity, demographic composition, and specialty 
service characteristics. The analysis helps:
1. Understand provider-level patient population nuances
2. Identify specialized hospitals with unique patient mix
3. Support strategic provider network and referral analysis
*/

WITH provider_complexity_analysis AS (
    SELECT 
        rndrng_prvdr_ccn,
        rndrng_prvdr_org_name,
        rndrng_prvdr_state_abrvtn,
        rndrng_prvdr_ruca_desc,
        
        -- Patient Complexity Metrics
        ROUND(bene_avg_risk_scre, 2) AS avg_patient_risk_score,
        
        -- Demographic Composition
        ROUND(100.0 * bene_age_lt_65_cnt / tot_benes, 2) AS pct_under_65,
        ROUND(100.0 * bene_age_gt_84_cnt / tot_benes, 2) AS pct_over_84,
        ROUND(100.0 * bene_feml_cnt / tot_benes, 2) AS pct_female,
        ROUND(100.0 * bene_dual_cnt / tot_benes, 2) AS pct_dual_eligible,
        
        -- Service Utilization Metrics
        tot_dschrgs,
        tot_cvrd_days,
        ROUND(tot_mdcr_pymt_amt / tot_dschrgs, 2) AS avg_medicare_payment_per_discharge,
        
        -- Chronic Condition Prevalence
        ROUND(100.0 * (
            bene_cc_ph_diabetes_v2_pct + 
            bene_cc_ph_hypertension_v2_pct + 
            bene_cc_ph_ckd_v2_pct
        ), 2) AS chronic_condition_burden_pct,
        
        mimi_src_file_date
    FROM 
        mimi_ws_1.datacmsgov.mupihp_prvdr
    WHERE 
        mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.mupihp_prvdr)
)

SELECT 
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    rndrng_prvdr_ruca_desc,
    avg_patient_risk_score,
    pct_over_84,
    pct_dual_eligible,
    chronic_condition_burden_pct,
    tot_dschrgs,
    avg_medicare_payment_per_discharge
FROM 
    provider_complexity_analysis
WHERE 
    tot_dschrgs > 100  -- Focus on providers with significant patient volume
ORDER BY 
    avg_patient_risk_score DESC, 
    tot_dschrgs DESC
LIMIT 50;

/*
Query Mechanics:
- Calculates provider-level patient complexity and demographic metrics
- Focuses on most recent available data
- Filters for providers with meaningful discharge volume
- Ranks providers by patient risk score and discharge volume

Assumptions and Limitations:
- Uses single year of data
- Assumes Medicare fee-for-service data represents full provider characteristics
- Risk scores and chronic condition metrics are based on CMS algorithms

Potential Extensions:
1. Add geographic clustering analysis
2. Incorporate additional chronic condition dimensions
3. Compare urban vs rural provider characteristics
4. Time series analysis of provider complexity trends
*/


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:30:56.232948
    - Additional Notes: Query focuses on provider-level patient complexity, highlighting nuanced characteristics beyond standard utilization metrics. Provides insights into demographic composition, chronic condition prevalence, and Medicare service patterns.
    
    */