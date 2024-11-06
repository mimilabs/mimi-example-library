/*
Prescription Drug Cost-Sharing Analysis for Medicare Advantage Plans
 
Business Purpose:
- Analyze cost-sharing structures and copay/coinsurance ranges across Medicare Advantage plans
- Identify plans with innovative cost-sharing approaches for prescription drugs
- Support strategic decision-making for plan design and competitive analysis
*/

WITH cost_sharing_summary AS (
    -- Get distinct cost sharing structures by plan and tier
    SELECT 
        pbp_a_hnumber,
        pbp_a_plan_type,
        mrx_tier_post_type_id,
        mrx_tier_post_cost_struct_vb,
        COUNT(*) as structure_count,
        -- Calculate average copay ranges
        AVG(CAST(mrx_tier_post_copay_min AS FLOAT)) as avg_min_copay,
        AVG(CAST(mrx_tier_post_copay_max AS FLOAT)) as avg_max_copay,
        -- Calculate average coinsurance ranges
        AVG(CAST(mrx_tier_post_coins_min AS FLOAT)) as avg_min_coinsurance,
        AVG(CAST(mrx_tier_post_coins_max AS FLOAT)) as avg_max_coinsurance
    FROM mimi_ws_1.partcd.pbp_mrx_p_vbid
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.pbp_mrx_p_vbid)
    GROUP BY 1,2,3,4
)

SELECT 
    pbp_a_plan_type,
    mrx_tier_post_type_id,
    mrx_tier_post_cost_struct_vb,
    COUNT(DISTINCT pbp_a_hnumber) as num_organizations,
    ROUND(AVG(structure_count),2) as avg_structures_per_org,
    -- Format cost sharing ranges
    ROUND(AVG(avg_min_copay),2) as avg_min_copay_dollars,
    ROUND(AVG(avg_max_copay),2) as avg_max_copay_dollars,
    ROUND(AVG(avg_min_coinsurance),2) as avg_min_coinsurance_pct,
    ROUND(AVG(avg_max_coinsurance),2) as avg_max_coinsurance_pct
FROM cost_sharing_summary
GROUP BY 1,2,3
ORDER BY 1,2,4 DESC;

/*
How this query works:
1. Creates a CTE to summarize cost sharing structures at the plan/tier level
2. Aggregates data to show patterns across plan types and tier types
3. Calculates average ranges for both copays and coinsurance
4. Formats results for easy business interpretation

Assumptions and Limitations:
- Uses most recent data snapshot only
- Assumes copay/coinsurance values are numeric and valid
- Does not account for special conditions or exceptions
- Aggregates may mask important plan-specific details

Possible Extensions:
1. Add time-series analysis to track changes in cost sharing approaches
2. Include geographical analysis by state or region
3. Compare cost sharing between standard plans vs VBID participants
4. Add filters for specific drug types or therapeutic categories
5. Create benchmarking analysis against industry averages
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:11:46.989400
    - Additional Notes: Query focuses on cost-sharing patterns across plan types and tiers, summarizing both copay and coinsurance structures. Best used for strategic analysis of benefit design patterns and competitive benchmarking. Note that the results are aggregated at the plan type level, which may mask individual plan variations.
    
    */