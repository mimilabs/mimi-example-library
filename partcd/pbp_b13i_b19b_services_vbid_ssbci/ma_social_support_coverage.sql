-- Medicare Advantage Social Support Services Analysis
--
-- This query analyzes the coverage patterns of social support services for chronically ill beneficiaries,
-- focusing on comparing key offerings like self-directed care services and general living supports
-- across Medicare Advantage plans. These benefits help address social determinants of health
-- and support aging in place.
--
-- Business purpose:
-- - Identify plans offering comprehensive social support packages
-- - Compare coverage levels and authorization requirements
-- - Understand the prevalence of self-directed vs. plan-managed support services
-- - Track maximum benefit amounts and utilization controls

WITH social_support_metrics AS (
  SELECT 
    pbp_a_plan_type,
    -- Self-directed services coverage
    COUNT(CASE WHEN pbp_b13i_selfd_bendesc_yn = 'Y' THEN 1 END) as plans_with_self_directed,
    AVG(CASE WHEN pbp_b13i_selfd_maxplan_yn = 'Y' THEN CAST(pbp_b13i_selfd_maxplan_amt AS FLOAT) END) as avg_self_directed_max_amt,
    
    -- General living supports coverage 
    COUNT(CASE WHEN pbp_b13i_suppt_bendesc_yn = 'Y' THEN 1 END) as plans_with_living_support,
    AVG(CASE WHEN pbp_b13i_suppt_maxplan_yn = 'Y' THEN CAST(pbp_b13i_suppt_maxplan_amt AS FLOAT) END) as avg_living_support_max_amt,
    
    -- Authorization patterns
    SUM(CASE WHEN pbp_b13i_selfd_auth_yn = 'Y' THEN 1 ELSE 0 END) as self_directed_auth_required,
    SUM(CASE WHEN pbp_b13i_suppt_auth_yn = 'Y' THEN 1 ELSE 0 END) as living_support_auth_required,
    
    COUNT(*) as total_plans

  FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci)
  GROUP BY pbp_a_plan_type
)

SELECT
  pbp_a_plan_type as plan_type,
  plans_with_self_directed as self_directed_count,
  ROUND(100.0 * plans_with_self_directed / total_plans, 1) as self_directed_pct,
  plans_with_living_support as living_support_count,
  ROUND(100.0 * plans_with_living_support / total_plans, 1) as living_support_pct,
  ROUND(avg_self_directed_max_amt, 0) as avg_self_directed_max,
  ROUND(avg_living_support_max_amt, 0) as avg_living_support_max,
  ROUND(100.0 * self_directed_auth_required / NULLIF(plans_with_self_directed, 0), 1) as self_directed_auth_pct,
  ROUND(100.0 * living_support_auth_required / NULLIF(plans_with_living_support, 0), 1) as living_support_auth_pct
FROM social_support_metrics
WHERE total_plans >= 10
ORDER BY total_plans DESC;

-- How this query works:
-- 1. Creates a CTE to calculate key metrics by plan type
-- 2. Uses conditional counting and averaging to analyze benefit patterns
-- 3. Calculates percentages in the final SELECT
-- 4. Filters for plan types with meaningful sample sizes
--
-- Assumptions and limitations:
-- - Uses most recent data snapshot only
-- - Assumes monetary amounts are comparable across plans
-- - Does not account for regional variations
-- - Authorization requirements may not fully reflect access barriers
--
-- Possible extensions:
-- 1. Add trending over multiple time periods
-- 2. Include geographic analysis by state/region
-- 3. Correlate with plan star ratings or enrollment
-- 4. Compare cost sharing requirements
-- 5. Analyze combinations of different support services

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:09:53.900298
    - Additional Notes: Focus is on self-directed care services and general living supports metrics, providing plan-level comparison of social support benefits. Query filters out plan types with fewer than 10 plans to ensure statistical relevance. Maximum benefit amounts may need adjustment for inflation when comparing across years.
    
    */