
/***************************************************************
Medicare Part B Drug Coverage Analysis - Core Metrics
****************************************************************

Business Purpose:
This query analyzes the key aspects of Medicare Part B prescription drug 
coverage across Medicare Advantage plans, focusing on cost sharing approaches
and insulin coverage to understand plan benefit design patterns.

Created: 2024
*/

WITH cost_sharing_summary AS (
  -- Summarize cost sharing approaches by plan
  SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    ROUND(AVG(CASE WHEN mrx_b_coins_yn = 'Y' THEN 1 ELSE 0 END)*100,1) as pct_with_coinsurance,
    ROUND(AVG(CASE WHEN mrx_b_copay_yn = 'Y' THEN 1 ELSE 0 END)*100,1) as pct_with_copay,
    ROUND(AVG(CASE WHEN mrx_b_ira_copay_yn = 'Y' THEN 1 ELSE 0 END)*100,1) as pct_with_insulin_copay
  FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs
  GROUP BY pbp_a_plan_type
),

insulin_stats AS (
  -- Calculate insulin coverage statistics
  SELECT
    ROUND(AVG(mrx_b_ira_copay_month_amt),2) as avg_monthly_insulin_copay,
    ROUND(AVG(mrx_b_ira_coins_max_pct),1) as avg_max_insulin_coinsurance
  FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs
  WHERE mrx_b_ira_copay_month_amt IS NOT NULL
)

SELECT 
  cs.pbp_a_plan_type as plan_type,
  cs.total_plans,
  cs.pct_with_coinsurance,
  cs.pct_with_copay,
  cs.pct_with_insulin_copay,
  i.avg_monthly_insulin_copay,
  i.avg_max_insulin_coinsurance
FROM cost_sharing_summary cs
CROSS JOIN insulin_stats i
WHERE cs.total_plans >= 10  -- Filter to plan types with meaningful sample sizes
ORDER BY cs.total_plans DESC;

/*
HOW IT WORKS:
1. First CTE summarizes cost sharing approaches by plan type
2. Second CTE calculates average insulin coverage metrics
3. Main query joins these together and filters for meaningful samples

ASSUMPTIONS & LIMITATIONS:
- Assumes current data reflects active plans
- Limited to high-level cost sharing indicators
- Does not account for regional variations
- May include plans no longer accepting enrollments

POSSIBLE EXTENSIONS:
1. Add temporal trends by incorporating mimi_src_file_date
2. Include geographic analysis by joining with contract/plan tables
3. Add analysis of authorization requirements (mrx_b_auth_yn)
4. Compare chemotherapy vs regular drug cost sharing
5. Analyze relationship between copay and coinsurance combinations
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:41:33.819297
    - Additional Notes: Script focuses on core metrics but excludes deductible analysis. Monthly insulin copay values may be NULL for some plans which could affect averages. Consider adding error handling for NULL values and data quality checks if using for production reporting.
    
    */