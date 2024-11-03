-- outpatient_cost_burden_analysis.sql

-- Business Purpose:
-- Analyzes patient cost-sharing burden for outpatient hospital services
-- Identifies services and providers where patients face high out-of-pocket costs
-- Helps organizations understand financial impact on Medicare beneficiaries
-- Supports policy discussions around affordability of outpatient care

WITH patient_responsibility AS (
    -- Calculate estimated patient responsibility and key metrics
    SELECT 
        rndrng_prvdr_ccn,
        rndrng_prvdr_org_name,
        rndrng_prvdr_state_abrvtn,
        apc_cd,
        apc_desc,
        bene_cnt,
        avg_mdcr_alowd_amt,
        avg_mdcr_pymt_amt,
        -- Estimate patient responsibility as difference between allowed and Medicare payment
        (avg_mdcr_alowd_amt - avg_mdcr_pymt_amt) as est_patient_resp,
        -- Calculate patient responsibility as percentage of allowed amount
        ROUND(100.0 * (avg_mdcr_alowd_amt - avg_mdcr_pymt_amt) / avg_mdcr_alowd_amt, 1) as patient_resp_pct
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date = '2022-12-31'
        AND bene_cnt >= 10  -- Focus on services with meaningful volume
)

SELECT 
    apc_cd,
    apc_desc,
    COUNT(DISTINCT rndrng_prvdr_ccn) as provider_count,
    SUM(bene_cnt) as total_beneficiaries,
    ROUND(AVG(est_patient_resp), 2) as avg_patient_responsibility,
    ROUND(AVG(patient_resp_pct), 1) as avg_patient_resp_pct,
    ROUND(MIN(est_patient_resp), 2) as min_patient_responsibility,
    ROUND(MAX(est_patient_resp), 2) as max_patient_responsibility
FROM patient_responsibility
WHERE est_patient_resp > 0  -- Focus on services with patient cost-sharing
GROUP BY apc_cd, apc_desc
HAVING COUNT(DISTINCT rndrng_prvdr_ccn) >= 5  -- Ensure representative sample
ORDER BY avg_patient_responsibility DESC
LIMIT 20;

-- How it works:
-- 1. Creates CTE to calculate estimated patient responsibility per service
-- 2. Aggregates data by APC code to show burden across providers
-- 3. Includes provider count and beneficiary volume for context
-- 4. Filters for meaningful volume and representative samples
-- 5. Orders results by average patient responsibility

-- Assumptions and Limitations:
-- - Patient responsibility estimated as difference between allowed and Medicare payment
-- - Does not account for secondary insurance coverage
-- - Limited to Medicare FFS beneficiaries
-- - Requires minimum provider count for representative analysis
-- - Based on averages which may mask individual variation

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional cost-sharing patterns
-- 2. Compare patient burden across rural vs urban providers
-- 3. Analyze trends in patient responsibility over multiple years
-- 4. Include correlation with social vulnerability indices
-- 5. Add provider-level analysis for targeted interventions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:01:20.127295
    - Additional Notes: Query focuses on patient cost-sharing burden in outpatient settings using 2022 data. Results are filtered for services with at least 10 beneficiaries and 5 providers to ensure statistical relevance. Patient responsibility is estimated based on the difference between allowed amounts and Medicare payments, which may not reflect actual out-of-pocket costs due to secondary insurance coverage.
    
    */