-- File: premium_deductible_trend_analysis.sql
-- Title: Medicare Plan Premium and Deductible Trend Analysis

-- Business Purpose:
-- - Track premium and deductible changes over time for Medicare prescription drug plans
-- - Identify plans with competitive pricing structures
-- - Support formulary and benefit design optimization
-- - Enable price positioning analysis for new plan offerings

WITH base_metrics AS (
  -- Calculate key price metrics by contract and plan
  SELECT 
    contract_id,
    LEFT(contract_id, 1) as plan_type_code,
    formulary_id,
    ROUND(AVG(premium), 2) as avg_premium,
    ROUND(AVG(deductible), 2) as avg_deductible,
    COUNT(DISTINCT segment_id) as segment_count,
    -- Extract quarter from file date for trending
    DATE_TRUNC('quarter', mimi_src_file_date) as data_quarter,
    COUNT(*) as plan_count
  FROM mimi_ws_1.prescriptiondrugplan.plan_information
  WHERE plan_suppressed_yn = 'N'
  GROUP BY 1,2,3,7
)

SELECT 
  data_quarter,
  plan_type_code,
  -- Map plan type codes to descriptions
  CASE plan_type_code
    WHEN 'H' THEN 'Local MA Plan'
    WHEN 'R' THEN 'Regional MA Plan' 
    WHEN 'S' THEN 'Standalone PDP'
  END as plan_type_desc,
  -- Calculate price metrics
  COUNT(DISTINCT contract_id) as contract_count,
  COUNT(DISTINCT formulary_id) as formulary_count,
  SUM(plan_count) as total_plans,
  ROUND(AVG(avg_premium), 2) as mean_premium,
  ROUND(MIN(avg_premium), 2) as min_premium,
  ROUND(MAX(avg_premium), 2) as max_premium,
  ROUND(AVG(avg_deductible), 2) as mean_deductible,
  ROUND(MIN(avg_deductible), 2) as min_deductible,
  ROUND(MAX(avg_deductible), 2) as max_deductible,
  SUM(segment_count) as total_segments
FROM base_metrics
GROUP BY 1,2,3
ORDER BY 1,2;

-- How it works:
-- 1. Creates base metrics CTE to aggregate plan-level premium and deductible data
-- 2. Extracts plan type from contract_id first character
-- 3. Calculates quarterly averages and ranges for premiums and deductibles
-- 4. Groups results by quarter and plan type with descriptive labels
-- 5. Includes count metrics for context (contracts, formularies, segments)

-- Assumptions and Limitations:
-- - Excludes suppressed plans (plan_suppressed_yn = 'N')
-- - Uses simple averages without weighting by enrollment
-- - Quarterly trending based on source file dates
-- - Does not account for mid-year plan changes
-- - Premium/deductible analysis may not reflect total cost to beneficiary

-- Possible Extensions:
-- 1. Add year-over-year premium change calculations
-- 2. Include SNP vs non-SNP comparison
-- 3. Incorporate geographic analysis by state/region
-- 4. Add benefit design features (ICL analysis)
-- 5. Compare premium trends against formulary coverage metrics
-- 6. Segment analysis by deductible tiers or premium ranges
-- 7. Add market share analysis using contract counts
-- 8. Create price positioning quadrants
-- 9. Add statistical measures (standard deviation, median)
-- 10. Include seasonality analysis for premium changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:52:45.451488
    - Additional Notes: Query focuses on key pricing metrics (premium/deductible) tracked quarterly across plan types. Useful for market analysis and price benchmarking, but lacks enrollment weighting which could skew average calculations. The quarterly trending assumes consistent data availability in source files and may need adjustment based on actual file delivery patterns.
    
    */