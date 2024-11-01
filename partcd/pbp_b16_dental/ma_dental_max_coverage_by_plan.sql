-- Medicare Advantage Dental Maximum Plan Coverage Analysis
-- Business Purpose: Analyze maximum dental coverage amounts and conditions across MA plans
-- to identify plans with the most generous dental benefits, inform network strategy, 
-- and support product development decisions.

WITH dental_maxplan AS (
  SELECT 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type,
    
    -- Get preventive dental max coverage
    pbp_b16b_maxplan_pv_yn AS prev_has_max,
    pbp_b16b_maxplan_pv_amt AS prev_max_amt,
    pbp_b16b_maxplan_pv_per AS prev_max_period,
    
    -- Get comprehensive dental max coverage  
    pbp_b16c_maxplan_cmp_yn AS comp_has_max,
    pbp_b16c_maxplan_cmp_amt AS comp_max_amt,
    pbp_b16c_maxplan_cmp_per AS comp_max_period,
    
    -- Network applicability
    pbp_b16b_maxplan_pv_in_oon AS prev_network_type,
    pbp_b16c_maxplan_cmp_in_oon AS comp_network_type

  FROM mimi_ws_1.partcd.pbp_b16_dental
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.pbp_b16_dental)
)

SELECT
  pbp_a_plan_type,
  COUNT(*) AS total_plans,
  
  -- Preventive stats
  COUNT(CASE WHEN prev_has_max = 'Y' THEN 1 END) AS plans_with_prev_max,
  AVG(CASE WHEN prev_has_max = 'Y' THEN prev_max_amt END) AS avg_prev_max_amt,
  MAX(prev_max_amt) AS highest_prev_max,
  
  -- Comprehensive stats  
  COUNT(CASE WHEN comp_has_max = 'Y' THEN 1 END) AS plans_with_comp_max,
  AVG(CASE WHEN comp_has_max = 'Y' THEN comp_max_amt END) AS avg_comp_max_amt,
  MAX(comp_max_amt) AS highest_comp_max,
  
  -- Network stats
  COUNT(CASE WHEN prev_network_type = '1' THEN 1 END) AS prev_in_network_only,
  COUNT(CASE WHEN comp_network_type = '1' THEN 1 END) AS comp_in_network_only

FROM dental_maxplan
GROUP BY pbp_a_plan_type
ORDER BY total_plans DESC;

/* How this query works:
1. CTE filters to latest data and extracts key maximum coverage fields
2. Main query aggregates by plan type to show maximum coverage patterns
3. Includes both preventive and comprehensive dental maximums
4. Shows network restrictions on maximum coverage

Assumptions & Limitations:
- Uses most recent data snapshot only
- Assumes amount fields contain valid numeric data
- Does not account for mid-year benefit changes
- Network type codes assumed to be standardized

Possible Extensions:
1. Add geographic analysis by state/region
2. Compare maximum coverage trends over multiple years
3. Correlate maximum coverage with plan premiums
4. Add analysis of deductibles and cost sharing
5. Cross-reference with enrollment data to see member impact
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:32:29.151209
    - Additional Notes: Query specifically tracks maximum benefit amounts and network restrictions for both preventive and comprehensive dental coverage across different plan types. Limited to latest snapshot only. Useful for product strategy and competitor analysis but should be combined with enrollment data for full impact assessment.
    
    */