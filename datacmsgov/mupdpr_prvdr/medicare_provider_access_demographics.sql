-- Medicare Part D Prescriber Demographics and Access Analysis

-- Business Purpose:
-- This query analyzes Medicare Part D prescriber characteristics and beneficiary access patterns
-- to identify potential gaps in care delivery and opportunities for improved healthcare access.
-- The analysis focuses on geographic distribution, provider types, and beneficiary characteristics
-- to support healthcare delivery planning and equitable access initiatives.

WITH provider_summary AS (
    SELECT 
        -- Provider demographics and location
        prscrbr_state_abrvtn,
        prscrbr_type,
        COUNT(DISTINCT prscrbr_npi) as provider_count,
        
        -- Beneficiary access metrics
        SUM(tot_benes) as total_beneficiaries,
        SUM(tot_clms) as total_claims,
        AVG(bene_avg_risk_scre) as avg_risk_score,
        
        -- Care delivery metrics
        SUM(tot_drug_cst)/SUM(tot_clms) as avg_cost_per_claim,
        SUM(tot_day_suply)/SUM(tot_clms) as avg_days_per_claim,
        
        -- Demographic reach
        SUM(bene_dual_cnt) as dual_eligible_count,
        SUM(bene_age_gt_84_cnt) as elderly_count
        
    FROM mimi_ws_1.datacmsgov.mupdpr_prvdr
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
        AND prscrbr_state_abrvtn NOT IN ('ZZ', 'XX')  -- Exclude non-US locations
        AND tot_benes > 10  -- Exclude low-volume providers
    GROUP BY 
        prscrbr_state_abrvtn,
        prscrbr_type
)

SELECT 
    prscrbr_state_abrvtn as state,
    prscrbr_type as provider_type,
    provider_count,
    total_beneficiaries,
    total_claims,
    ROUND(avg_risk_score, 2) as avg_risk_score,
    ROUND(avg_cost_per_claim, 2) as avg_cost_per_claim,
    ROUND(avg_days_per_claim, 1) as avg_days_per_claim,
    ROUND(dual_eligible_count * 100.0 / total_beneficiaries, 1) as pct_dual_eligible,
    ROUND(elderly_count * 100.0 / total_beneficiaries, 1) as pct_elderly
FROM provider_summary
WHERE total_beneficiaries > 0
ORDER BY 
    prscrbr_state_abrvtn,
    total_beneficiaries DESC;

-- How the Query Works:
-- 1. Creates a summary table aggregating provider and beneficiary metrics by state and provider type
-- 2. Calculates key access indicators including costs, supply duration, and demographic reach
-- 3. Filters out non-US locations and low-volume providers
-- 4. Computes percentages for dual-eligible and elderly beneficiaries
-- 5. Orders results by state and total beneficiaries for easy analysis

-- Assumptions and Limitations:
-- 1. Uses 2022 data - results may not reflect current patterns
-- 2. Excludes providers with fewer than 10 beneficiaries
-- 3. Some demographic data may be suppressed in source data
-- 4. Geographic analysis limited to state level
-- 5. Provider types based on primary specialty only

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include rural/urban classification analysis
-- 3. Add provider density calculations by population
-- 4. Compare access metrics across different demographic groups
-- 5. Incorporate quality metrics or outcome measures
-- 6. Add geographic clustering analysis
-- 7. Compare with healthcare shortage area designations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:10:12.798752
    - Additional Notes: Query focuses on provider access patterns and demographic distribution across states. Note that the results may be limited in areas with high data suppression due to privacy rules for providers serving fewer than 11 beneficiaries. Best used for state-level healthcare planning and access analysis.
    
    */