-- Title: Medicare Advantage Plan Star Rating and Premium Cost Analysis

-- Business Purpose:
-- This analysis examines the relationship between plan star ratings and premium costs to help:
-- - Identify high-performing, cost-effective Medicare Advantage plans
-- - Understand pricing strategies of top-rated plans
-- - Support strategic planning for market entry and competition analysis
-- - Guide beneficiary education about value-based plan selection

WITH premium_stats AS (
  -- Calculate average premiums by star rating level
  SELECT 
    overall_star_rating,
    COUNT(DISTINCT contract_id || plan_id) as plan_count,
    ROUND(AVG(COALESCE(part_c_premium, 0) + COALESCE(part_d_total_premium, 0)), 2) as avg_total_premium,
    MIN(COALESCE(part_c_premium, 0) + COALESCE(part_d_total_premium, 0)) as min_total_premium,
    MAX(COALESCE(part_c_premium, 0) + COALESCE(part_d_total_premium, 0)) as max_total_premium
  FROM mimi_ws_1.partcd.landscape_plan_premium_report
  WHERE overall_star_rating IS NOT NULL 
    AND overall_star_rating >= 2.5  -- Focus on plans with meaningful ratings
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.landscape_plan_premium_report)  -- Latest data only
  GROUP BY overall_star_rating
)

SELECT 
  overall_star_rating,
  plan_count,
  avg_total_premium,
  min_total_premium,
  max_total_premium,
  -- Calculate premium difference from overall average
  ROUND(avg_total_premium - (SELECT AVG(avg_total_premium) FROM premium_stats), 2) as premium_diff_from_avg
FROM premium_stats
ORDER BY overall_star_rating DESC;

-- How this query works:
-- 1. Creates a CTE to calculate premium statistics for each star rating level
-- 2. Uses the most recent data based on mimi_src_file_date
-- 3. Combines Part C and Part D premiums for total cost analysis
-- 4. Calculates plan counts and premium ranges at each rating level
-- 5. Compares average premiums to overall market average

-- Assumptions and Limitations:
-- - Assumes current star ratings reflect plan quality consistently
-- - Does not account for regional cost variations
-- - Excludes plans without star ratings
-- - Combines all plan types (MA, MA-PD) in the analysis
-- - Premium comparison does not account for benefit differences

-- Possible Extensions:
-- 1. Add geographic segmentation to analyze regional variations
-- 2. Include organization_type analysis to compare different sponsor types
-- 3. Trend analysis by incorporating historical data
-- 4. Add benefit type segmentation for more detailed comparison
-- 5. Include market share or enrollment data if available
-- 6. Analyze correlation between star ratings and specific benefit features

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:16:54.923166
    - Additional Notes: Query provides valuable insights for value-based purchasing decisions but requires recent data with valid star ratings to be meaningful. Premium calculations assume consistent benefit structures across plans which may not reflect total cost of coverage. Best used in conjunction with benefit design analysis for complete market assessment.
    
    */