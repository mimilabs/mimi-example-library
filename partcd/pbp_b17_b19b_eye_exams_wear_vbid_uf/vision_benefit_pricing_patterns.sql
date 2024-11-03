-- ma_vision_benefits_pricing_strategy.sql
-- Purpose: Analyze pricing models and cost-sharing structures for vision benefits across MA plans
-- Business Value: Identify competitive pricing strategies and cost-sharing patterns to inform 
-- benefit design and market positioning decisions

-- Main Query
WITH vision_pricing AS (
    SELECT 
        pbp_a_plan_type,
        -- Aggregate eye exam cost sharing approach
        SUM(CASE WHEN pbp_b17a_copay_yn = 'Y' THEN 1 ELSE 0 END) as exam_copay_count,
        SUM(CASE WHEN pbp_b17a_coins_yn = 'Y' THEN 1 ELSE 0 END) as exam_coins_count,
        -- Aggregate eyewear cost sharing approach
        SUM(CASE WHEN pbp_b17b_copay_yn = 'Y' THEN 1 ELSE 0 END) as eyewear_copay_count,
        SUM(CASE WHEN pbp_b17b_coins_yn = 'Y' THEN 1 ELSE 0 END) as eyewear_coins_count,
        -- Track plans with maximum coverage limits
        SUM(CASE WHEN pbp_b17b_maxplan_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_max_coverage,
        -- Count total plans
        COUNT(*) as total_plans,
        -- Calculate latest quarter stats
        MAX(mimi_src_file_date) as data_quarter
    FROM mimi_ws_1.partcd.pbp_b17_b19b_eye_exams_wear_vbid_uf
    WHERE pbp_b17a_bendesc_yn = 'Y' -- Only include plans offering vision benefits
    GROUP BY pbp_a_plan_type
)

SELECT 
    pbp_a_plan_type,
    -- Calculate percentages for cost sharing approaches
    ROUND(100.0 * exam_copay_count / total_plans, 1) as pct_exam_copay,
    ROUND(100.0 * exam_coins_count / total_plans, 1) as pct_exam_coinsurance,
    ROUND(100.0 * eyewear_copay_count / total_plans, 1) as pct_eyewear_copay,
    ROUND(100.0 * eyewear_coins_count / total_plans, 1) as pct_eyewear_coinsurance,
    ROUND(100.0 * plans_with_max_coverage / total_plans, 1) as pct_with_max_coverage,
    total_plans,
    data_quarter
FROM vision_pricing
WHERE total_plans >= 10  -- Filter out plan types with small sample sizes
ORDER BY total_plans DESC;

-- How this works:
-- 1. Creates a CTE to aggregate cost sharing approaches by plan type
-- 2. Calculates percentages of plans using different pricing models
-- 3. Provides insights into dominant cost sharing strategies by plan type
-- 4. Filters out statistically insignificant samples

-- Assumptions and limitations:
-- - Assumes current quarter data is most relevant for analysis
-- - Does not account for actual dollar amounts of copays/coinsurance
-- - Limited to plans actively offering vision benefits
-- - Minimum threshold of 10 plans per type for statistical relevance

-- Possible extensions:
-- 1. Add geographic analysis to identify regional pricing patterns
-- 2. Include trend analysis across multiple quarters
-- 3. Incorporate maximum coverage amount analysis for plans with limits
-- 4. Cross-reference with plan star ratings or enrollment data
-- 5. Add competitor-specific analysis for targeted market segments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:37:25.591913
    - Additional Notes: Query focuses on cost-sharing distribution across plan types and could benefit from dollar amount analysis if cost data becomes available. For optimal results, ensure data covers at least one full quarter and multiple plan types have sufficient sample sizes (n>=10).
    
    */