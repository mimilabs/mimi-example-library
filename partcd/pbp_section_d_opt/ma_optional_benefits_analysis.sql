-- Analysis of Medicare Advantage Optional Supplemental Benefits and Premiums
--
-- Business Purpose: 
-- Analyze the optional supplemental benefits offered by Medicare Advantage plans
-- to understand benefit packages, premium distributions, and coverage trends.
-- This information helps identify market opportunities and benefit design strategies.
--
-- Table: mimi_ws_1.partcd.pbp_section_d_opt
-- Last Modified: 2024

-- Main Analysis Query
WITH premium_stats AS (
  -- Calculate key metrics around premium distribution
  SELECT 
    COUNT(DISTINCT bid_id) as total_plans,
    COUNT(DISTINCT pbp_d_opt_identifier) as total_packages,
    ROUND(AVG(pbp_d_amt_opt_premium), 2) as avg_premium,
    ROUND(MIN(pbp_d_amt_opt_premium), 2) as min_premium,
    ROUND(MAX(pbp_d_amt_opt_premium), 2) as max_premium,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY pbp_d_amt_opt_premium), 2) as median_premium
  FROM mimi_ws_1.partcd.pbp_section_d_opt
  WHERE pbp_d_amt_opt_premium > 0
),

benefit_distribution AS (
  -- Analyze most common benefit packages
  SELECT 
    pbp_d_opt_description,
    COUNT(*) as package_count,
    ROUND(AVG(pbp_d_amt_opt_premium), 2) as avg_package_premium,
    COUNT(DISTINCT pbp_a_hnumber) as organization_count
  FROM mimi_ws_1.partcd.pbp_section_d_opt
  GROUP BY pbp_d_opt_description
  ORDER BY package_count DESC
  LIMIT 10
)

-- Combine results into final output
SELECT 
  'Market Overview' as metric_type,
  total_plans as value,
  'Total Medicare Advantage Plans' as description
FROM premium_stats
UNION ALL
SELECT 
  'Premium Analysis',
  avg_premium,
  'Average Optional Supplemental Premium'
FROM premium_stats
UNION ALL
SELECT 
  'Premium Analysis',
  median_premium,
  'Median Optional Supplemental Premium'
FROM premium_stats
UNION ALL
SELECT 
  'Benefit Package Analysis',
  package_count,
  'Number of Plans Offering: ' || pbp_d_opt_description
FROM benefit_distribution
WHERE package_count > 10
ORDER BY metric_type, value DESC;

-- How this query works:
-- 1. Creates a CTE for premium statistics across all plans
-- 2. Creates a CTE for analyzing benefit package distribution
-- 3. Combines results into a digestible format showing market overview,
--    premium analysis, and popular benefit packages

-- Assumptions and Limitations:
-- - Assumes premium amounts > 0 are valid entries
-- - Limited to current snapshot, no historical trending
-- - Does not account for geographic variations
-- - Package descriptions may vary in specificity

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include year-over-year trend analysis
-- 3. Segment analysis by plan type (HMO vs PPO)
-- 4. Correlation analysis with plan enrollment data
-- 5. Add benefit package combination analysis
-- 6. Include MOOP and deductible analysis
-- 7. Compare optional benefits against base plan offerings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:18:14.845370
    - Additional Notes: Query focuses on premium and package distribution metrics. Note that results may be impacted by data quality issues in premium amounts and package descriptions. Best used for high-level market analysis rather than detailed benefit comparisons. Consider implementing date filters if analyzing multiple years of data.
    
    */