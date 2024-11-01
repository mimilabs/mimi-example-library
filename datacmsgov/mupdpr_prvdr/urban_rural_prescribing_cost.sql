-- Medicare Part D Urban vs Rural Provider Cost Analysis

-- Business Purpose:
-- This query analyzes Medicare Part D prescribing patterns and costs across urban and rural areas
-- to identify geographic disparities in prescription drug access and spending.
-- It helps healthcare organizations and policymakers understand:
-- 1. Cost variations between urban and rural providers
-- 2. Generic vs brand prescribing patterns by location
-- 3. Patient demographic differences across geographic areas

WITH provider_metrics AS (
    -- Get the most recent year's data and aggregate key metrics by RUCA category
    SELECT 
        prscrbr_ruca_desc,
        COUNT(DISTINCT prscrbr_npi) as provider_count,
        SUM(tot_drug_cst) as total_cost,
        SUM(tot_clms) as total_claims,
        SUM(gnrc_tot_clms) as generic_claims,
        SUM(brnd_tot_clms) as brand_claims,
        AVG(bene_avg_risk_scre) as avg_risk_score,
        AVG(bene_avg_age) as avg_patient_age
    FROM mimi_ws_1.datacmsgov.mupdpr_prvdr
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND prscrbr_ruca_desc IS NOT NULL
    GROUP BY prscrbr_ruca_desc
)

SELECT 
    prscrbr_ruca_desc,
    provider_count,
    total_cost,
    total_claims,
    -- Calculate key performance metrics
    ROUND(total_cost/NULLIF(total_claims,0), 2) as cost_per_claim,
    ROUND(100.0 * generic_claims/NULLIF(total_claims,0), 1) as generic_pct,
    ROUND(avg_risk_score, 2) as avg_risk_score,
    ROUND(avg_patient_age, 1) as avg_patient_age
FROM provider_metrics
ORDER BY provider_count DESC;

-- How the Query Works:
-- 1. Filters to most recent year of data (2022)
-- 2. Groups providers by RUCA (Rural-Urban Commuting Area) category
-- 3. Calculates key metrics including costs, claims, and patient characteristics
-- 4. Computes derived metrics like cost per claim and generic prescription percentage

-- Assumptions and Limitations:
-- 1. Assumes 2022 is the most recent year - adjust date filter as needed
-- 2. Limited to providers with valid RUCA codes
-- 3. Does not account for specialty mix differences between regions
-- 4. Aggregate metrics may mask individual provider variations

-- Possible Extensions:
-- 1. Add provider specialty analysis within each geographic category
-- 2. Include temporal trends to show changes over multiple years
-- 3. Incorporate additional demographic factors like dual eligibility rates
-- 4. Add statistical testing for urban/rural differences
-- 5. Break out costs by brand/generic categories
-- 6. Include Medicare Advantage vs Part D plan type analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:05:41.297243
    - Additional Notes: This query can be resource-intensive on large datasets due to aggregation across multiple metrics. Consider adding WHERE clauses to filter specific states or provider types if performance is a concern. The RUCA code analysis relies on accurate provider address data in the source table.
    
    */