-- medicare_part_d_insulin_coverage_analysis.sql

-- Business Purpose:
-- Analyze Medicare Part D plans' insulin coverage and pricing under the Part D Senior Savings Model
-- This analysis helps:
-- 1. Identify plans offering enhanced insulin benefits
-- 2. Compare insulin copay structures across retail and mail order
-- 3. Support beneficiary education about affordable insulin access options
-- 4. Track adoption of insulin cost reduction programs

WITH insulin_coverage AS (
  SELECT 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    mrx_drug_ben_yn,
    part_d_enhncd_cvrg_demo,
    mrx_alt_ira_covg_tier,
    -- Get copays for different distribution channels
    mrx_gen_ira_rstd_copay_1m as retail_1month_copay,
    mrx_gen_ira_mostd_copay_1m as mailorder_1month_copay,
    mrx_gen_ira_rstd_copay_3m as retail_3month_copay,
    mrx_gen_ira_mostd_copay_3m as mailorder_3month_copay,
    mimi_src_file_date
  FROM mimi_ws_1.partcd.pbp_mrx
  WHERE mrx_drug_ben_yn = 'Y' -- Only include plans with drug benefits
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.pbp_mrx) -- Latest data
)

SELECT
  -- Calculate key metrics
  COUNT(DISTINCT pbp_a_hnumber || pbp_a_plan_identifier) as total_plans,
  
  SUM(CASE WHEN part_d_enhncd_cvrg_demo = 'Y' THEN 1 ELSE 0 END) as plans_with_enhanced_insulin,
  
  AVG(CASE 
    WHEN retail_1month_copay IS NOT NULL 
    THEN CAST(retail_1month_copay AS FLOAT) 
    ELSE NULL 
  END) as avg_retail_1month_copay,
  
  AVG(CASE 
    WHEN mailorder_3month_copay IS NOT NULL 
    THEN CAST(mailorder_3month_copay AS FLOAT)/3 
    ELSE NULL 
  END) as avg_mailorder_monthly_copay,
  
  -- Calculate participation rate
  ROUND(100.0 * SUM(CASE WHEN part_d_enhncd_cvrg_demo = 'Y' THEN 1 ELSE 0 END) / 
    COUNT(DISTINCT pbp_a_hnumber || pbp_a_plan_identifier), 1) as pct_plans_enhanced_insulin
    
FROM insulin_coverage

-- How the Query Works:
-- 1. Creates CTE to extract relevant insulin coverage fields
-- 2. Filters for active drug benefit plans and latest data
-- 3. Calculates summary statistics about insulin coverage and costs
-- 4. Converts copay amounts to monthly equivalents for comparison

-- Assumptions and Limitations:
-- - Assumes copay amounts are stored as valid numbers
-- - Does not account for deductibles or coverage phases
-- - Limited to standard insulin benefits, not all diabetes medications
-- - Mail order 3-month cost divided by 3 for monthly comparison

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare year-over-year trends in participation
-- 3. Include analysis of insulin-specific tier structures
-- 4. Add comparison of retail vs mail order savings
-- 5. Segment analysis by plan type (MA-PD vs PDP)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:21:29.597459
    - Additional Notes: Query focuses on aggregate metrics of insulin coverage in Part D plans, particularly tracking participation in enhanced coverage programs and comparative copay structures. Results are most meaningful when analyzing the full annual dataset rather than partial year data. Copay calculations assume standard pricing without adjusting for special circumstances or regional variations.
    
    */