
/*******************************************************************************
Medicare Advantage Non-Health Benefits Analysis
-------------------------------------------------------------------------------
This query analyzes the key supplemental non-health benefits offered by Medicare 
Advantage plans to chronically ill beneficiaries, providing insights into benefit 
coverage and access requirements.

Business Purpose:
- Understand what supplemental benefits plans offer to support chronically ill members
- Identify authorization/referral requirements that may impact benefit access
- Compare benefit coverage patterns across plan types
*******************************************************************************/

WITH benefit_flags AS (
  SELECT
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type,
    -- Flag presence of each major benefit category
    CASE WHEN pbp_b13i_fd_bendesc_yn = 'Y' THEN 1 ELSE 0 END as has_food_benefit,
    CASE WHEN pbp_b13i_ml_bendesc_service = 'Y' THEN 1 ELSE 0 END as has_meals_benefit,
    CASE WHEN pbp_b13i_ps_bendesc_yn = 'Y' THEN 1 ELSE 0 END as has_pest_control,
    CASE WHEN pbp_b13i_t_bendesc_yn = 'Y' THEN 1 ELSE 0 END as has_transportation,
    CASE WHEN pbp_b13i_air_bendesc_yn = 'Y' THEN 1 ELSE 0 END as has_air_quality,
    -- Flag authorization requirements
    CASE WHEN pbp_b13i_fd_auth_yn = 'Y' THEN 1 ELSE 0 END as food_needs_auth,
    CASE WHEN pbp_b13i_ml_auth_yn = 'Y' THEN 1 ELSE 0 END as meals_needs_auth,
    CASE WHEN pbp_b13i_ps_auth_yn = 'Y' THEN 1 ELSE 0 END as pest_needs_auth,
    CASE WHEN pbp_b13i_t_auth_yn = 'Y' THEN 1 ELSE 0 END as transport_needs_auth,
    CASE WHEN pbp_b13i_air_auth_yn = 'Y' THEN 1 ELSE 0 END as air_needs_auth
  FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
)

SELECT
  pbp_a_plan_type,
  COUNT(DISTINCT pbp_a_hnumber) as num_plans,
  
  -- Calculate percentage of plans offering each benefit
  ROUND(AVG(has_food_benefit)*100,1) as pct_with_food,
  ROUND(AVG(has_meals_benefit)*100,1) as pct_with_meals,
  ROUND(AVG(has_pest_control)*100,1) as pct_with_pest_control,
  ROUND(AVG(has_transportation)*100,1) as pct_with_transport,
  ROUND(AVG(has_air_quality)*100,1) as pct_with_air_quality,
  
  -- Calculate percentage requiring authorization
  ROUND(AVG(CASE WHEN has_food_benefit=1 THEN food_needs_auth END)*100,1) as pct_food_auth,
  ROUND(AVG(CASE WHEN has_meals_benefit=1 THEN meals_needs_auth END)*100,1) as pct_meals_auth,
  ROUND(AVG(CASE WHEN has_pest_control=1 THEN pest_needs_auth END)*100,1) as pct_pest_auth,
  ROUND(AVG(CASE WHEN has_transportation=1 THEN transport_needs_auth END)*100,1) as pct_transport_auth,
  ROUND(AVG(CASE WHEN has_air_quality=1 THEN air_needs_auth END)*100,1) as pct_air_auth

FROM benefit_flags
GROUP BY pbp_a_plan_type
HAVING COUNT(DISTINCT pbp_a_hnumber) >= 10
ORDER BY num_plans DESC;

/*******************************************************************************
HOW THIS QUERY WORKS:
1. Creates benefit_flags CTE to identify presence of key benefits and authorization requirements
2. Aggregates by plan type to show:
   - Number of plans
   - % offering each benefit type
   - % requiring authorization for each benefit type
3. Filters to plan types with at least 10 plans for statistical relevance

ASSUMPTIONS & LIMITATIONS:
- Assumes Y/N fields reliably indicate benefit presence/authorization requirements
- Does not account for benefit amounts/limits, only presence
- Groups all plan variations within each plan type
- Excludes small plan types with <10 plans

POSSIBLE EXTENSIONS:
1. Add geographic analysis by state/region
2. Include cost sharing requirements (copays, coinsurance)
3. Trend analysis over multiple years
4. Correlation with plan star ratings
5. Add benefit dollar amount analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:34:51.841081
    - Additional Notes: Query focuses on high-level benefit coverage patterns across plan types. Dollar amounts and detailed benefit parameters are excluded from this base analysis. Results are filtered to plan types with 10+ plans to ensure statistical relevance. Authorization requirement percentages are calculated only for plans offering each specific benefit to avoid skewed results.
    
    */