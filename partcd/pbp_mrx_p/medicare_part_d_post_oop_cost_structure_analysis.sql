-- Medicare Part D Post-OOP Threshold Plan Cost Structure Analysis

/*
Business Purpose:
Analyze the variation in Medicare Part D prescription drug plan cost-sharing structures 
after the out-of-pocket (OOP) threshold, providing insights into plan design strategies 
and potential cost implications for beneficiaries.

Key Business Questions Addressed:
- How do different plan types structure their post-OOP threshold drug benefits?
- What is the range of copayments and coinsurance across plans?
- How do cost-sharing approaches differ by organization type?
*/

WITH plan_cost_summary AS (
    -- Aggregate cost-sharing details across plan tiers
    SELECT 
        pbp_a_hnumber AS plan_number,
        pbp_a_plan_identifier AS plan_id,
        orgtype AS organization_type,
        pbp_a_plan_type AS plan_type,
        
        -- Summarize cost-sharing characteristics
        COUNT(DISTINCT mrx_tier_post_id) AS unique_tiers,
        
        -- Analyze copayment variations
        AVG(mrx_tier_post_copay_amt) AS avg_copay,
        MIN(mrx_tier_post_copay_amt) AS min_copay,
        MAX(mrx_tier_post_copay_amt) AS max_copay,
        
        -- Analyze coinsurance variations
        AVG(mrx_tier_post_coins_pct) AS avg_coinsurance,
        MIN(mrx_tier_post_coins_pct) AS min_coinsurance,
        MAX(mrx_tier_post_coins_pct) AS max_coinsurance,
        
        -- Identify unique cost-sharing types
        COUNT(DISTINCT mrx_tier_post_cst_shr_type) AS cost_sharing_approaches
    
    FROM mimi_ws_1.partcd.pbp_mrx_p
    
    -- Focus on most recent data version
    WHERE version = (SELECT MAX(version) FROM mimi_ws_1.partcd.pbp_mrx_p)
    
    GROUP BY 
        pbp_a_hnumber, 
        pbp_a_plan_identifier, 
        orgtype, 
        pbp_a_plan_type
)

-- Primary query to analyze plan cost structures
SELECT 
    organization_type,
    plan_type,
    
    COUNT(*) AS total_plans,
    
    -- Cost-sharing metrics
    ROUND(AVG(avg_copay), 2) AS mean_post_oop_copay,
    ROUND(AVG(avg_coinsurance), 2) AS mean_post_oop_coinsurance,
    
    -- Variation indicators
    ROUND(STDDEV(avg_copay), 2) AS copay_variation,
    ROUND(STDDEV(avg_coinsurance), 2) AS coinsurance_variation,
    
    -- Complexity metrics
    ROUND(AVG(unique_tiers), 2) AS avg_post_oop_tiers,
    ROUND(AVG(cost_sharing_approaches), 2) AS avg_cost_sharing_approaches

FROM plan_cost_summary
GROUP BY organization_type, plan_type
ORDER BY total_plans DESC, mean_post_oop_copay;

/*
Query Mechanics:
- Aggregates Medicare Part D post-OOP threshold benefit details
- Calculates summary statistics by organization and plan type
- Provides insights into cost-sharing strategies

Assumptions and Limitations:
- Uses most recent version of data
- Aggregates at plan level, not individual beneficiary
- Does not account for actual drug utilization

Potential Extensions:
1. Compare cost structures across different geographic regions
2. Analyze trends in cost-sharing over multiple years
3. Correlate cost-sharing with plan premiums
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:58:40.805012
    - Additional Notes: Query provides aggregated insights into Medicare Part D prescription drug plan cost-sharing strategies after out-of-pocket threshold, focusing on variations by organization and plan type. Requires latest version of the source table for most accurate results.
    
    */