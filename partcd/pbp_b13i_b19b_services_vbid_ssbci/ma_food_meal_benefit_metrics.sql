-- Medicare Advantage Food and Meal Benefits Analysis
-- 
-- This query analyzes the food and meal benefit offerings across Medicare Advantage plans,
-- focusing on maximum coverage amounts, cost sharing, and authorization requirements.
-- These benefits are critical for chronically ill beneficiaries and can impact health outcomes.

WITH latest_data AS (
  SELECT *
  FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
  )
),

plan_metrics AS (
  SELECT 
    -- Benefit offering rates
    COUNT(DISTINCT bid_id) as total_plans,
    COUNT(DISTINCT CASE WHEN pbp_b13i_fd_bendesc_yn = 'Y' THEN bid_id END) as plans_with_food,
    COUNT(DISTINCT CASE WHEN pbp_b13i_ml_bendesc_service = 'Y' THEN bid_id END) as plans_with_meals,
    
    -- Average coverage amounts
    ROUND(AVG(CASE WHEN pbp_b13i_fd_maxplan_yn = 'Y' 
      THEN CAST(pbp_b13i_fd_maxplan_amt AS FLOAT) END), 0) as avg_food_max_coverage,
    ROUND(AVG(CASE WHEN pbp_b13i_ml_maxplan_yn = 'Y' 
      THEN CAST(pbp_b13i_ml_maxplan_amt AS FLOAT) END), 0) as avg_meal_max_coverage,
      
    -- Authorization requirements  
    COUNT(CASE WHEN pbp_b13i_fd_auth_yn = 'Y' THEN 1 END) as food_auth_count,
    COUNT(CASE WHEN pbp_b13i_fd_bendesc_yn = 'Y' THEN 1 END) as food_total_count,
    COUNT(CASE WHEN pbp_b13i_ml_auth_yn = 'Y' THEN 1 END) as meal_auth_count,
    COUNT(CASE WHEN pbp_b13i_ml_bendesc_service = 'Y' THEN 1 END) as meal_total_count,
    
    -- Meal benefit averages
    ROUND(AVG(CAST(pbp_b13i_ml_days AS FLOAT)), 1) as avg_meal_days,
    ROUND(AVG(CAST(pbp_b13i_ml_max_meals AS FLOAT)), 1) as avg_max_meals
  FROM latest_data
)

SELECT
  total_plans,
  plans_with_food,
  plans_with_meals,
  ROUND(100.0 * plans_with_food / total_plans, 1) as pct_plans_with_food,
  ROUND(100.0 * plans_with_meals / total_plans, 1) as pct_plans_with_meals,
  avg_food_max_coverage,
  avg_meal_max_coverage,
  ROUND(100.0 * food_auth_count / NULLIF(food_total_count, 0), 1) as pct_food_requiring_auth,
  ROUND(100.0 * meal_auth_count / NULLIF(meal_total_count, 0), 1) as pct_meals_requiring_auth,
  avg_meal_days,
  avg_max_meals
FROM plan_metrics

/*
How this query works:
1. Creates CTE with latest data snapshot
2. Calculates all metrics in a single aggregation step
3. Formats final results with percentage calculations

Assumptions and Limitations:
- Assumes maximum coverage amounts are comparable across plans
- Does not account for benefit periodicity differences
- Does not segment by plan type or geography
- Focused only on food and meal benefits, excludes other supplemental benefits

Possible Extensions:
1. Add geographic analysis by state/region
2. Compare benefits across different plan types
3. Analyze trends over time using historical data
4. Include cost sharing analysis (copays/coinsurance)
5. Cross-reference with plan enrollment data to understand beneficiary impact
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:15:13.767992
    - Additional Notes: Query provides high-level metrics about Medicare Advantage food and meal benefits, including coverage rates, authorization requirements, and average benefit amounts. Results are aggregated at the program level and represent the most recent data snapshot. Consider memory usage when running on large datasets as it processes the full table.
    
    */