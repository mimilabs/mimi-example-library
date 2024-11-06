/*************************************************************************
Medicare Advantage Vision Benefits Analysis - Core Coverage and Cost Sharing

Business Purpose:
This query provides a high-level overview of vision benefits coverage and 
cost-sharing in Medicare Advantage plans, focusing on the most important 
aspects that impact member access and out-of-pocket costs for eye exams 
and eyewear.

Key metrics include:
- Coverage rates for routine eye exams and eyewear
- Maximum benefit amounts and frequencies
- Average copays and coinsurance
**************************************************************************/

WITH plan_metrics AS (
  SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- Eye Exam Coverage
    AVG(CASE WHEN pbp_b17a_bendesc_yn = 'Y' THEN 1 ELSE 0 END) as pct_with_eye_exams,
    AVG(CASE WHEN pbp_b17a_copay_yn = 'Y' THEN 1 ELSE 0 END) as pct_with_exam_copay,
    AVG(pbp_b17a_copay_amt_rex_max) as avg_exam_max_copay,
    
    -- Eyewear Coverage  
    AVG(CASE WHEN pbp_b17b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) as pct_with_eyewear,
    AVG(pbp_b17b_comb_maxplan_amt) as avg_eyewear_allowance,
    
    -- Maximum Benefit Amounts
    MAX(pbp_b17b_comb_maxplan_amt) as max_eyewear_allowance,
    MIN(pbp_b17b_comb_maxplan_amt) as min_eyewear_allowance
    
  FROM mimi_ws_1.partcd.pbp_b17_eye_exams_wear
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.pbp_b17_eye_exams_wear)
  GROUP BY pbp_a_plan_type
)

SELECT
  pbp_a_plan_type as plan_type,
  total_plans,
  ROUND(pct_with_eye_exams * 100, 1) as pct_covering_exams,
  ROUND(pct_with_exam_copay * 100, 1) as pct_with_exam_copay,
  ROUND(avg_exam_max_copay, 2) as avg_exam_copay,
  ROUND(pct_with_eyewear * 100, 1) as pct_covering_eyewear,
  ROUND(avg_eyewear_allowance, 0) as avg_eyewear_allowance,
  ROUND(max_eyewear_allowance, 0) as max_eyewear_allowance
FROM plan_metrics
WHERE total_plans >= 10  -- Filter to common plan types
ORDER BY total_plans DESC;

/*************************************************************************
How the Query Works:
1. Creates a CTE to calculate key metrics by plan type
2. Uses latest data snapshot based on mimi_src_file_date
3. Calculates averages and percentages for coverage and cost metrics
4. Presents final results filtered to common plan types

Assumptions and Limitations:
- Uses most recent data snapshot only
- Focuses on basic coverage and cost metrics
- Excludes plan types with small sample sizes
- Does not account for network differences
- Averages may mask important variations

Possible Extensions:
1. Add geographic analysis by state/region
2. Compare trends over multiple years
3. Add network (in/out) analysis
4. Include more detailed benefit limits and restrictions
5. Add premium correlation analysis
6. Segment by parent organization
**************************************************************************/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:16:01.544542
    - Additional Notes: Query provides high-level metrics for Medicare Advantage vision benefits across plan types, focusing on coverage rates and cost-sharing. Best used for initial market analysis and benchmarking. Note that averages may not reflect regional variations or specific plan designs. Data represents most recent snapshot only.
    
    */