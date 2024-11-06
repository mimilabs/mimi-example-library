-- hearing_coverage_changes_over_time.sql

-- Business Purpose: 
-- Analyze how Medicare Advantage hearing benefit designs have evolved over time
-- to identify emerging trends in benefit generosity and market differentiation.
-- This helps plans understand competitive positioning and opportunities for benefit enhancement.

WITH quarterly_stats AS (
  -- Calculate key metrics for each quarter
  SELECT 
    mimi_src_file_date AS report_date,
    COUNT(DISTINCT bid_id) AS total_plans,
    
    -- Hearing exam coverage metrics
    ROUND(AVG(CASE WHEN pbp_b18a_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_with_exam_coverage,
    ROUND(AVG(CASE WHEN pbp_b18a_maxplan_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_with_exam_limits,
    
    -- Hearing aid coverage metrics  
    ROUND(AVG(CASE WHEN pbp_b18b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_with_aid_coverage,
    ROUND(AVG(pbp_b18b_maxplan_amt) FILTER(WHERE pbp_b18b_maxplan_amt > 0), 0) AS avg_aid_coverage_amt,
    
    -- OTC hearing aid trends
    ROUND(AVG(CASE WHEN pbp_b18b_otc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_with_otc_coverage

  FROM mimi_ws_1.partcd.pbp_b18_b19b_hearing_exams_aids_vbid_uf
  GROUP BY mimi_src_file_date
)

SELECT
  report_date,
  total_plans,
  pct_with_exam_coverage,
  pct_with_exam_limits,
  pct_with_aid_coverage,
  avg_aid_coverage_amt,
  pct_with_otc_coverage,
  
  -- Calculate quarter-over-quarter changes
  pct_with_aid_coverage - LAG(pct_with_aid_coverage) OVER (ORDER BY report_date) AS aid_coverage_qoq_chg,
  avg_aid_coverage_amt - LAG(avg_aid_coverage_amt) OVER (ORDER BY report_date) AS aid_amt_qoq_chg
  
FROM quarterly_stats
ORDER BY report_date DESC;

/* How this query works:
1. Creates quarterly summary metrics for key hearing benefit characteristics
2. Calculates penetration rates for different benefit features
3. Determines average coverage amounts for hearing aids
4. Shows quarter-over-quarter changes in key metrics

Assumptions and limitations:
- Assumes consistent reporting across quarters
- Dollar amounts may need inflation adjustment for true comparisons
- Does not account for mid-year benefit changes
- OTC coverage tracking may vary by reporting period

Possible extensions:
1. Add organization type segmentation to see trends by plan sponsor type
2. Include geographic analysis to identify regional patterns
3. Incorporate plan enrollment data to weight by member impact
4. Add benefit design clustering to identify common coverage patterns
5. Compare trends against overall supplemental benefit changes
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:34:15.489003
    - Additional Notes: Query aggregates and tracks quarterly changes in Medicare Advantage hearing benefit design across multiple dimensions including coverage rates, benefit limits, and average coverage amounts. May require additional date filtering if analyzing specific time periods.
    
    */