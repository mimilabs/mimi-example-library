
/* Medicare Advantage Ambulance & Transportation Benefits Analysis
 
Purpose: Analyze key ambulance and transportation benefit characteristics across Medicare Advantage plans
to understand coverage patterns and identify plans with the most comprehensive benefits.

Business value:
- Helps identify plans offering the most generous transportation benefits for beneficiaries
- Enables comparison of cost sharing requirements across plans
- Supports analysis of supplemental transportation benefits beyond standard Medicare coverage
*/

WITH benefit_metrics AS (
  -- Calculate core benefit metrics by plan
  SELECT 
    pbp_a_plan_type,
    pbp_b10b_bendesc_yn AS offers_supp_transport,
    COUNT(*) as plan_count,
    
    -- Transportation benefit stats
    AVG(CASE WHEN pbp_b10b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) as pct_with_transport,
    AVG(CASE WHEN pbp_b10b_bendesc_lim_pal = 'N' THEN 1 ELSE 0 END) as pct_unlimited_trips,
    
    -- Cost sharing metrics  
    AVG(CASE WHEN pbp_b10b_copay_yn = 'Y' THEN 1 ELSE 0 END) as pct_with_copay,
    AVG(COALESCE(pbp_b10b_copay_amt_max, 0)) as avg_max_copay,
    
    -- Authorization requirements
    AVG(CASE WHEN pbp_b10b_auth_yn = 'Y' THEN 1 ELSE 0 END) as pct_req_auth
    
  FROM mimi_ws_1.partcd.pbp_b10_amb_trans
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.pbp_b10_amb_trans)
  GROUP BY pbp_a_plan_type, pbp_b10b_bendesc_yn
)

SELECT
  pbp_a_plan_type as plan_type,
  offers_supp_transport,
  plan_count,
  ROUND(pct_with_transport * 100, 1) as pct_with_transport,
  ROUND(pct_unlimited_trips * 100, 1) as pct_unlimited_trips,
  ROUND(pct_with_copay * 100, 1) as pct_with_copay,
  ROUND(avg_max_copay, 2) as avg_max_copay,
  ROUND(pct_req_auth * 100, 1) as pct_req_auth
FROM benefit_metrics
ORDER BY plan_count DESC;

/* How this query works:
1. Creates a CTE to calculate key benefit metrics by plan type
2. Aggregates data only for most recent time period
3. Calculates percentages and averages for key benefit characteristics
4. Returns summary statistics grouped by plan type and whether supplemental transport is offered

Assumptions & Limitations:
- Uses most recent data only - historical trends not included
- Focuses on plan-level metrics rather than enrollment-weighted statistics
- Does not account for geographic variations
- Combines all transportation types into single metrics

Possible Extensions:
1. Add geographic analysis by state/region
2. Include time series analysis to show benefit trends
3. Weight metrics by plan enrollment
4. Break out metrics by specific transportation types
5. Add cost sharing analysis for ambulance services
6. Compare urban vs rural benefit patterns
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:30:38.052452
    - Additional Notes: Query provides high-level summary of Medicare Advantage transportation benefits across plan types, focusing on supplemental benefits, cost sharing, and authorization requirements. Results are aggregated at the plan type level using most recent data only. Consider adjusting date filter if analyzing historical data.
    
    */