-- hearing_aid_referral_authorization_patterns.sql --

-- Business Purpose:
-- Analyze referral and authorization requirements for hearing aid benefits across Medicare Advantage plans
-- to understand access barriers and administrative burden on members.
-- This analysis helps:
-- - Identify plans with less restrictive access requirements
-- - Understand market trends in benefit management approaches
-- - Support provider network and care management strategy decisions

WITH auth_ref_summary AS (
  -- Get core plan identifiers and summarize authorization/referral patterns
  SELECT
    pbp_a_plan_type,
    pbp_b18b_auth_yn AS requires_authorization,
    pbp_b18b_refer_yn AS requires_referral,
    COUNT(DISTINCT bid_id) as plan_count,
    ROUND(COUNT(DISTINCT bid_id) * 100.0 / SUM(COUNT(DISTINCT bid_id)) OVER(), 2) as pct_of_plans
  FROM mimi_ws_1.partcd.pbp_b18_hearing_exams_aids
  WHERE pbp_b18b_bendesc_yn = 'Y' -- Only look at plans offering hearing aid coverage
  GROUP BY 1,2,3
)

SELECT
  pbp_a_plan_type as plan_type,
  requires_authorization,
  requires_referral,
  plan_count,
  pct_of_plans as percent_of_plans,
  CASE 
    WHEN requires_authorization = 'Y' AND requires_referral = 'Y' THEN 'High Control'
    WHEN requires_authorization = 'Y' OR requires_referral = 'Y' THEN 'Medium Control'
    ELSE 'Low Control'
  END as access_control_level
FROM auth_ref_summary
ORDER BY 
  pbp_a_plan_type,
  requires_authorization,
  requires_referral;

-- How this query works:
-- 1. Filters to only plans offering hearing aid coverage
-- 2. Groups by plan type and authorization/referral requirements
-- 3. Calculates percentage distribution of requirements across plans
-- 4. Adds categorization of access control levels
-- 5. Returns results sorted by plan type and requirements

-- Assumptions and Limitations:
-- - Assumes Y/N values in auth/referral columns are clean and consistent
-- - Does not account for changes in requirements over time
-- - Does not distinguish between different types of hearing aids
-- - May include terminated or pending plans

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare requirements against member enrollment numbers
-- 3. Correlate with cost sharing amounts
-- 4. Analyze trends over multiple years
-- 5. Include additional dimensions like organization type or star ratings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:24:43.571538
    - Additional Notes: Query focuses on authorization and referral patterns in hearing aid coverage, providing insights into administrative barriers for Medicare Advantage beneficiaries. Only includes active plans with hearing aid coverage (pbp_b18b_bendesc_yn = 'Y'). Results show distribution of access control requirements by plan type.
    
    */