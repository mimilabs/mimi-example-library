-- ma_vision_benefit_trends.sql
-- Purpose: Analyze how vision benefits have changed over time by quarter
-- Business Value: Track market evolution and identify emerging benefit design trends
-- to inform product strategy and market positioning

WITH quarterly_summary AS (
  -- Summarize key vision benefit metrics by quarter
  SELECT 
    DATE_TRUNC('quarter', mimi_src_file_date) as benefit_quarter,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- Eye exam coverage metrics
    ROUND(AVG(CASE WHEN pbp_b17a_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_exam_coverage,
    ROUND(AVG(CASE WHEN pbp_b17a_maxplan_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_exam_max,
    
    -- Eyewear coverage metrics  
    ROUND(AVG(CASE WHEN pbp_b17b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_eyewear_coverage,
    ROUND(AVG(CASE WHEN pbp_b17b_maxplan_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_eyewear_max,
    
    -- Comprehensive coverage
    ROUND(AVG(CASE WHEN pbp_b17a_bendesc_yn = 'Y' AND pbp_b17b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_both_benefits

  FROM mimi_ws_1.partcd.pbp_b17_b19b_eye_exams_wear_vbid_uf
  GROUP BY DATE_TRUNC('quarter', mimi_src_file_date)
)

SELECT
  benefit_quarter,
  total_plans,
  pct_with_exam_coverage,
  pct_with_eyewear_coverage,
  pct_with_both_benefits,
  
  -- Calculate quarter-over-quarter changes
  pct_with_both_benefits - LAG(pct_with_both_benefits) 
    OVER (ORDER BY benefit_quarter) as qoq_change_comprehensive,
    
  -- Calculate year-over-year changes
  pct_with_both_benefits - LAG(pct_with_both_benefits, 4) 
    OVER (ORDER BY benefit_quarter) as yoy_change_comprehensive

FROM quarterly_summary
ORDER BY benefit_quarter DESC;

/* How it works:
1. Creates quarterly summaries of key vision benefit metrics
2. Calculates coverage percentages for exams, eyewear, and comprehensive coverage
3. Adds quarter-over-quarter and year-over-year trend analysis
4. Orders results by most recent quarter first

Assumptions & Limitations:
- Assumes quarterly data availability and completeness
- Does not account for mid-quarter changes
- Treats all plans equally regardless of enrollment
- Limited to binary coverage indicators (Y/N)

Possible Extensions:
1. Add geographic dimension to track regional trends
2. Include plan type breakdown (HMO vs PPO)
3. Incorporate cost sharing analysis
4. Add statistical significance testing for trends
5. Include enrollment-weighted analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:37:02.916990
    - Additional Notes: Query provides high-level tracking of vision benefit adoption trends across Medicare Advantage plans. Best used for strategic planning and market analysis. Performance may be impacted when analyzing multiple years of historical data due to the window functions.
    
    */