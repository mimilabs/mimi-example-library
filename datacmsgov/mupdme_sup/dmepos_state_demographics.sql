-- dmepos_demographic_served_analysis.sql

-- Business Purpose:
-- This query analyzes DMEPOS supplier service patterns across different beneficiary demographics,
-- particularly focusing on age groups and dual eligibility status. This helps identify which 
-- suppliers are effectively serving vulnerable populations and potentially underserved groups.
-- Understanding these patterns can inform policy decisions and identify market opportunities.

WITH supplier_metrics AS (
    SELECT 
        suplr_prvdr_last_name_org,
        suplr_prvdr_state_abrvtn,
        tot_suplr_benes,
        suplr_mdcr_pymt_amt,
        -- Calculate percentages of beneficiary age groups
        bene_age_lt_65_cnt::FLOAT / NULLIF(tot_suplr_benes, 0) * 100 as pct_under_65,
        bene_age_gt_84_cnt::FLOAT / NULLIF(tot_suplr_benes, 0) * 100 as pct_over_84,
        -- Calculate dual eligibility percentage
        bene_dual_cnt::FLOAT / NULLIF(tot_suplr_benes, 0) * 100 as pct_dual_eligible,
        bene_avg_risk_scre
    FROM mimi_ws_1.datacmsgov.mupdme_sup
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
        AND tot_suplr_benes >= 100  -- Focus on suppliers with meaningful volume
)

SELECT 
    suplr_prvdr_state_abrvtn as state,
    COUNT(*) as supplier_count,
    -- Aggregate metrics
    AVG(pct_under_65) as avg_pct_under_65,
    AVG(pct_over_84) as avg_pct_over_84,
    AVG(pct_dual_eligible) as avg_pct_dual_eligible,
    AVG(bene_avg_risk_scre) as avg_risk_score,
    SUM(tot_suplr_benes) as total_beneficiaries,
    SUM(suplr_mdcr_pymt_amt) as total_medicare_payments
FROM supplier_metrics
GROUP BY suplr_prvdr_state_abrvtn
HAVING COUNT(*) >= 5  -- Exclude states with very few suppliers
ORDER BY total_beneficiaries DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE that calculates key demographic percentages for each supplier
-- 2. Aggregates the data at the state level to show geographic patterns
-- 3. Filters for meaningful volumes to ensure statistical relevance
-- 4. Provides multiple metrics to assess demographic service patterns

-- Assumptions and Limitations:
-- - Assumes 2022 data is most recent and complete
-- - Requires at least 100 beneficiaries per supplier for meaningful analysis
-- - Focuses only on age and dual eligibility as key demographic indicators
-- - State-level aggregation may mask local variations
-- - Excludes states with fewer than 5 suppliers

-- Possible Extensions:
-- 1. Add trends over time by comparing multiple years
-- 2. Include race/ethnicity demographics analysis
-- 3. Break down by urban/rural using RUCA codes
-- 4. Compare against state-level Medicare population demographics
-- 5. Add supplier specialty analysis to understand service patterns
-- 6. Include quality metrics or outcomes data if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:14:28.645833
    - Additional Notes: This query aggregates Medicare DMEPOS supplier data at the state level with focus on beneficiary demographics and dual eligibility. It requires 2022 data and filters for states with at least 5 suppliers serving 100+ beneficiaries each. Results show top 20 states by beneficiary volume.
    
    */