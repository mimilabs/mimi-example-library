-- analyze_medicare_advantage_drug_benefit_cost_structure.sql
-- Business Purpose: Analyze cost-sharing structures and trends across Medicare Advantage Part D plans
-- to understand plan design variation and identify opportunities for benefit optimization.
-- This analysis helps stakeholders compare drug benefit designs and evaluate competitiveness.

WITH cost_share_stats AS (
  -- Calculate average cost sharing amounts by plan and tier
  SELECT 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    mrx_tier_id,
    -- Standard retail cost sharing
    AVG(mrx_tier_rstd_copay_1m_max) as avg_retail_copay_1m,
    AVG(mrx_tier_rstd_coins_1m_max) as avg_retail_coins_1m,
    -- Mail order cost sharing  
    AVG(mrx_tier_mostd_copay_1m_max) as avg_mail_copay_1m,
    AVG(mrx_tier_mostd_coins_1m_max) as avg_mail_coins_1m
  FROM mimi_ws_1.partcd.pbp_mrx_tier_vbid
  GROUP BY 1,2,3
)

SELECT
  -- Basic plan identifiers
  cs.pbp_a_hnumber,
  cs.pbp_a_plan_identifier,
  cs.mrx_tier_id,
  
  -- Calculate retail vs mail order differentials
  ROUND(cs.avg_retail_copay_1m, 2) as retail_copay,
  ROUND(cs.avg_mail_copay_1m, 2) as mail_copay,
  ROUND(cs.avg_retail_copay_1m - cs.avg_mail_copay_1m, 2) as copay_differential,
  
  ROUND(cs.avg_retail_coins_1m, 2) as retail_coins,
  ROUND(cs.avg_mail_coins_1m, 2) as mail_coins,
  ROUND(cs.avg_retail_coins_1m - cs.avg_mail_coins_1m, 2) as coins_differential

FROM cost_share_stats cs
WHERE cs.mrx_tier_id IS NOT NULL
ORDER BY 
  cs.pbp_a_hnumber,
  cs.pbp_a_plan_identifier,
  cs.mrx_tier_id;

-- How this query works:
-- 1. Creates a CTE to calculate average cost sharing amounts by plan and tier
-- 2. Compares retail vs mail order differentials for both copays and coinsurance
-- 3. Focuses on 1-month supply amounts as the standard comparison
-- 4. Rounds results to 2 decimal places for readability

-- Assumptions and Limitations:
-- - Uses maximum cost sharing amounts as the primary metric
-- - Focuses on standard (non-preferred) pharmacy networks
-- - Does not account for formulary differences between plans
-- - Limited to basic cost sharing comparison without considering utilization

-- Possible Extensions:
-- 1. Add preferred pharmacy network analysis
-- 2. Include temporal trends by analyzing multiple years
-- 3. Segment analysis by plan type or geographic region
-- 4. Add specialty tier specific analysis
-- 5. Incorporate enrollment data to weight the analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:10:07.049735
    - Additional Notes: Query focuses on plan-level cost differentials between retail and mail order pharmacy benefits. Averages may mask important variations in specific drug tiers or geographic regions. Consider adding geographic and temporal dimensions for more granular analysis.
    
    */