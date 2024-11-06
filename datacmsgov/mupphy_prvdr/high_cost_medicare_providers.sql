-- medicare_high_cost_provider_insights.sql

-- Business Purpose: 
-- Analyze high-cost Medicare providers to identify patterns in service utilization,
-- submitted charges, and beneficiary characteristics. This analysis helps:
-- 1. Identify providers with significantly high Medicare payments for fraud detection
-- 2. Understand the relationship between provider specialties and high costs
-- 3. Examine beneficiary risk profiles associated with high-cost providers

WITH provider_costs AS (
    -- Calculate key cost and utilization metrics per provider
    SELECT 
        rndrng_npi,
        rndrng_prvdr_last_org_name,
        rndrng_prvdr_type,
        rndrng_prvdr_state_abrvtn,
        tot_benes,
        tot_srvcs,
        tot_sbmtd_chrg,
        tot_mdcr_pymt_amt,
        bene_avg_risk_scre,
        -- Calculate cost per beneficiary and service
        ROUND(tot_mdcr_pymt_amt / NULLIF(tot_benes, 0), 2) as cost_per_beneficiary,
        ROUND(tot_mdcr_pymt_amt / NULLIF(tot_srvcs, 0), 2) as cost_per_service,
        -- Calculate charge to payment ratio
        ROUND(tot_sbmtd_chrg / NULLIF(tot_mdcr_pymt_amt, 0), 2) as charge_to_payment_ratio
    FROM mimi_ws_1.datacmsgov.mupphy_prvdr
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
        AND tot_benes >= 10  -- Filter for statistical significance
)

SELECT 
    rndrng_prvdr_type,
    rndrng_prvdr_state_abrvtn,
    COUNT(DISTINCT rndrng_npi) as provider_count,
    ROUND(AVG(cost_per_beneficiary), 2) as avg_cost_per_beneficiary,
    ROUND(AVG(cost_per_service), 2) as avg_cost_per_service,
    ROUND(AVG(charge_to_payment_ratio), 2) as avg_charge_to_payment_ratio,
    ROUND(AVG(bene_avg_risk_scre), 2) as avg_risk_score,
    ROUND(SUM(tot_mdcr_pymt_amt)/1000000, 2) as total_medicare_payments_millions
FROM provider_costs
WHERE cost_per_beneficiary > (
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY cost_per_beneficiary)
    FROM provider_costs
)
GROUP BY 1, 2
HAVING COUNT(DISTINCT rndrng_npi) >= 5  -- Ensure adequate sample size
ORDER BY total_medicare_payments_millions DESC
LIMIT 20;

-- How the Query Works:
-- 1. Creates a CTE to calculate cost metrics per provider
-- 2. Filters for the most recent year and providers with sufficient beneficiaries
-- 3. Calculates key ratios like cost per beneficiary and charge-to-payment ratio
-- 4. Identifies high-cost providers (above 75th percentile)
-- 5. Aggregates results by provider type and state
-- 6. Orders by total Medicare payments to highlight biggest impact areas

-- Assumptions and Limitations:
-- 1. Uses 2022 data - results may vary for different years
-- 2. Focuses on providers with 10+ beneficiaries for statistical validity
-- 3. Defines high-cost as above 75th percentile - threshold could be adjusted
-- 4. Requires 5+ providers per specialty/state group for privacy/significance
-- 5. Does not account for case mix or procedure complexity differences

-- Possible Extensions:
-- 1. Add year-over-year trend analysis for cost growth
-- 2. Include quality metrics to identify high-cost, high-quality providers
-- 3. Incorporate geographic cost adjustments for fair comparisons
-- 4. Add specialty-specific benchmarks for better context
-- 5. Include analysis of specific types of services (drug vs. medical)
-- 6. Add demographic analysis of beneficiaries served by high-cost providers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:23:11.504475
    - Additional Notes: Query identifies high-cost Medicare providers by analyzing cost per beneficiary, charge ratios, and payment patterns. Requires at least 10 beneficiaries per provider and 5 providers per specialty/state group for statistical validity. Results are based on 2022 data and focus on providers above the 75th percentile for cost per beneficiary.
    
    */