-- Transportation Cost-Sharing Model Analysis
--
-- Business Purpose:
-- Analyze the distribution of cost-sharing models (copay vs coinsurance) 
-- for transportation benefits across plan types to understand predominant
-- payment structures and identify potential barriers to access.
-- This insight helps product teams design competitive benefit structures
-- and supports sales teams in explaining value propositions to clients.

WITH cost_share_summary AS (
    -- Aggregate cost-sharing approaches by plan type
    SELECT 
        pbp_a_plan_type,
        COUNT(*) as total_plans,
        SUM(CASE WHEN pbp_b10a_copay_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_copay,
        SUM(CASE WHEN pbp_b10a_coins_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_coinsurance,
        AVG(COALESCE(pbp_b10a_copay_mc_amt, 0)) as avg_min_copay,
        AVG(COALESCE(pbp_b10a_copay_mc_amt_max, 0)) as avg_max_copay,
        AVG(COALESCE(pbp_b10a_coins_pct_mc, 0)) as avg_min_coinsurance,
        AVG(COALESCE(pbp_b10a_coins_pct_mc_max, 0)) as avg_max_coinsurance
    FROM mimi_ws_1.partcd.pbp_b10_amb_trans
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.pbp_b10_amb_trans)
    GROUP BY pbp_a_plan_type
)

SELECT 
    pbp_a_plan_type as plan_type,
    total_plans,
    -- Calculate percentages of plans using each cost-sharing model
    ROUND(100.0 * plans_with_copay / total_plans, 1) as pct_plans_with_copay,
    ROUND(100.0 * plans_with_coinsurance / total_plans, 1) as pct_plans_with_coinsurance,
    -- Format average cost-sharing amounts
    ROUND(avg_min_copay, 2) as avg_min_copay_amt,
    ROUND(avg_max_copay, 2) as avg_max_copay_amt,
    ROUND(avg_min_coinsurance, 1) as avg_min_coinsurance_pct,
    ROUND(avg_max_coinsurance, 1) as avg_max_coinsurance_pct
FROM cost_share_summary
WHERE total_plans >= 10  -- Filter out plan types with small sample sizes
ORDER BY total_plans DESC;

-- How this query works:
-- 1. Creates a CTE to summarize cost-sharing approaches by plan type
-- 2. Calculates counts and averages for copay and coinsurance usage
-- 3. Presents results as percentages and rounded averages
-- 4. Filters for statistical significance and orders by market presence

-- Assumptions and Limitations:
-- - Uses most recent data snapshot only
-- - Assumes $0 for null copay amounts in averaging
-- - Excludes plan types with fewer than 10 plans
-- - Does not account for regional variations
-- - Does not consider authorization requirements

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic segmentation
-- 3. Correlate with plan premium levels
-- 4. Analyze relationship with other benefits
-- 5. Add waiver patterns analysis
-- 6. Include authorization requirement patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:06:33.717430
    - Additional Notes: Query provides plan-level cost sharing analysis focused on copay vs coinsurance distribution. Consider memory usage when running against large datasets as it requires full table scan. Results most meaningful when analyzing recent quarters due to benefit structure changes over time.
    
    */