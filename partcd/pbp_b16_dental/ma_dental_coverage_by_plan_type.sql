-- Medicare Advantage Dental Services Coverage by Plan Type Analysis 
-- Business Purpose: Analyze differences in dental benefit design across MA plan types
-- (HMO, PPO, etc.) to understand how plan structure affects dental coverage.
-- This informs provider network strategy, product design and market competition analysis.

WITH dental_plans AS (
  -- Get unique plans with dental coverage 
  SELECT DISTINCT
    pbp_a_plan_type,
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_ben_cov,
    -- Flags for preventive and comprehensive coverage
    CASE WHEN pbp_b16a_bendesc_yn = 'Y' THEN 1 ELSE 0 END as has_preventive,
    CASE WHEN pbp_b16b_bendesc_yn = 'Y' THEN 1 ELSE 0 END as has_comprehensive
  FROM mimi_ws_1.partcd.pbp_b16_dental
  WHERE pbp_a_plan_type IS NOT NULL
),

plan_type_summary AS (
  -- Aggregate dental coverage by plan type
  SELECT 
    pbp_a_plan_type,
    COUNT(*) as total_plans,
    SUM(has_preventive) as plans_with_preventive,
    SUM(has_comprehensive) as plans_with_comprehensive,
    ROUND(100.0 * SUM(has_preventive)/COUNT(*), 1) as pct_with_preventive,  
    ROUND(100.0 * SUM(has_comprehensive)/COUNT(*), 1) as pct_with_comprehensive,
    COUNT(*) FILTER (WHERE has_preventive = 1 AND has_comprehensive = 1) as plans_with_both
  FROM dental_plans
  GROUP BY pbp_a_plan_type
)

-- Final output with key metrics by plan type
SELECT
  pbp_a_plan_type as plan_type,
  total_plans,
  plans_with_preventive,
  pct_with_preventive,
  plans_with_comprehensive,
  pct_with_comprehensive,
  plans_with_both,
  ROUND(100.0 * plans_with_both/total_plans, 1) as pct_with_both
FROM plan_type_summary
ORDER BY total_plans DESC;

/* How the Query Works:
1. First CTE identifies unique plans and flags presence of preventive/comprehensive coverage
2. Second CTE calculates summary metrics by plan type
3. Final query formats results with percentages and sorts by plan volume

Assumptions & Limitations:
- Assumes pbp_a_plan_type is populated and accurate
- Does not account for mid-year benefit changes
- Does not consider benefit details beyond presence/absence
- Groups all sub-types of plans (eg HMO-POS with regular HMO)

Possible Extensions:
1. Add geographic analysis by state/region
2. Include premium data to analyze relationship with coverage
3. Trend analysis over multiple years
4. Deeper analysis of specific benefits within each coverage type
5. Network adequacy correlation with coverage types
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:25:04.235874
    - Additional Notes: Query provides aggregate view of dental benefit offerings across MA plan types but does not account for plan enrollment numbers or market share. Consider combining with enrollment data for market impact analysis.
    
    */