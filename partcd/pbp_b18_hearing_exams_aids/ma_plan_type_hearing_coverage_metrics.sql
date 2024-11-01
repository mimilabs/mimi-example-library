-- medicare_advantage_hearing_benefits_comparison_by_plan_type.sql
-- 
-- Business Purpose:
-- Analyzes how hearing benefits vary across different Medicare Advantage plan types (HMO, PPO, etc.)
-- to identify potential market opportunities and competitive positioning strategies.
-- This analysis helps:
-- - Healthcare consultants advising MA plans on benefit design
-- - Insurers evaluating competitive landscape
-- - Provider organizations understanding MA coverage patterns
--

WITH plan_type_summary AS (
    -- Get core metrics by plan type
    SELECT 
        pbp_a_plan_type,
        COUNT(DISTINCT bid_id) as total_plans,
        
        -- Hearing exam coverage metrics
        AVG(CASE WHEN pbp_b18a_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100 as pct_with_exam_coverage,
        AVG(COALESCE(pbp_b18a_maxplan_amt, 0)) as avg_exam_max_coverage,
        
        -- Hearing aid coverage metrics  
        AVG(CASE WHEN pbp_b18b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100 as pct_with_aid_coverage,
        AVG(COALESCE(pbp_b18b_maxplan_amt, 0)) as avg_aid_max_coverage,
        
        -- Authorization requirements
        AVG(CASE WHEN pbp_b18b_auth_yn = 'Y' THEN 1 ELSE 0 END) * 100 as pct_requiring_auth

    FROM mimi_ws_1.partcd.pbp_b18_hearing_exams_aids
    WHERE pbp_a_plan_type IS NOT NULL
    GROUP BY pbp_a_plan_type
)

SELECT 
    pbp_a_plan_type as plan_type,
    total_plans,
    ROUND(pct_with_exam_coverage, 1) as pct_covering_exams,
    ROUND(avg_exam_max_coverage, 0) as avg_exam_coverage_amt,
    ROUND(pct_with_aid_coverage, 1) as pct_covering_aids,
    ROUND(avg_aid_max_coverage, 0) as avg_aid_coverage_amt,
    ROUND(pct_requiring_auth, 1) as pct_requiring_authorization
FROM plan_type_summary
WHERE total_plans >= 10  -- Filter to meaningful sample sizes
ORDER BY total_plans DESC;

/*
How this query works:
1. Creates summary metrics by plan type using a CTE
2. Calculates key coverage percentages and average benefit amounts
3. Rounds results for readability
4. Filters to plan types with meaningful sample sizes

Assumptions and Limitations:
- Assumes current plan year data
- Does not account for geographical variations
- Maximum benefit amounts may combine in-network and out-of-network
- Small sample sizes for some plan types may limit conclusions

Possible Extensions:
1. Add trending over multiple years
2. Break out by state/region
3. Compare copay/coinsurance structures
4. Analyze correlation with plan star ratings
5. Add demographic context for service areas
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:47:37.256962
    - Additional Notes: Query provides a high-level comparative analysis across plan types, but current design excludes plans with small sample sizes (n<10). Consider adjusting the sample size threshold based on specific analysis needs. Dollar amounts are averaged across all coverage types which may mask important variations in benefit design.
    
    */