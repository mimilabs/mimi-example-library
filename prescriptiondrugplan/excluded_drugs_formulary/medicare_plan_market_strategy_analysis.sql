-- pharmacy_market_analysis_of_medicare_plan_formularies.sql

-- Business Purpose:
-- Analyzes pharmacy market dynamics by examining how Medicare Part D plans structure their 
-- supplemental drug coverage through tier placement and utilization management tools.
-- This helps understand competitive differentiation and market access strategies.

WITH tier_summary AS (
  -- Calculate tier distribution and management controls by contract
  SELECT 
    contract_id,
    COUNT(DISTINCT rxcui) as total_drugs,
    AVG(tier::int) as avg_tier,
    SUM(CASE WHEN prior_auth_yn = 1 THEN 1 ELSE 0 END) / COUNT(*)::float as prior_auth_rate,
    SUM(CASE WHEN step_therapy_yn = 1 THEN 1 ELSE 0 END) / COUNT(*)::float as step_therapy_rate,
    SUM(CASE WHEN quantity_limit_yn = 1 THEN 1 ELSE 0 END) / COUNT(*)::float as qty_limit_rate
  FROM mimi_ws_1.prescriptiondrugplan.excluded_drugs_formulary
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.prescriptiondrugplan.excluded_drugs_formulary)
  GROUP BY contract_id
),
ranked_contracts AS (
  -- Rank contracts by formulary size and management intensity
  SELECT 
    contract_id,
    total_drugs,
    avg_tier,
    prior_auth_rate + step_therapy_rate + qty_limit_rate as total_mgmt_rate,
    RANK() OVER (ORDER BY total_drugs DESC) as drugs_rank,
    RANK() OVER (ORDER BY (prior_auth_rate + step_therapy_rate + qty_limit_rate) DESC) as controls_rank
  FROM tier_summary
)
-- Final output showing market positioning
SELECT 
  contract_id,
  total_drugs,
  ROUND(avg_tier, 2) as avg_tier_placement,
  ROUND(total_mgmt_rate, 2) as utilization_mgmt_intensity,
  CASE 
    WHEN drugs_rank <= 10 AND controls_rank <= 10 THEN 'Market Leader - High Control'
    WHEN drugs_rank <= 10 AND controls_rank > 10 THEN 'Market Leader - Low Control'
    WHEN drugs_rank > 10 AND controls_rank <= 10 THEN 'Niche Player - High Control'
    ELSE 'Niche Player - Low Control'
  END as market_position
FROM ranked_contracts
ORDER BY total_drugs DESC
LIMIT 20;

-- How it works:
-- 1. Creates summary metrics for each contract's formulary strategy
-- 2. Ranks contracts based on formulary size and management controls
-- 3. Categorizes contracts into market positioning segments
-- 4. Returns top 20 contracts with key strategic metrics

-- Assumptions and Limitations:
-- - Uses most recent data snapshot only
-- - Assumes tier numbers are meaningful when averaged
-- - Does not account for regional market differences
-- - Equal weighting of different management controls in intensity calculation

-- Possible Extensions:
-- 1. Add temporal analysis to track strategy changes over time
-- 2. Include geographic analysis using contract service areas
-- 3. Incorporate drug costs and rebate potential analysis
-- 4. Compare strategies for different therapeutic classes
-- 5. Add beneficiary enrollment data to weight market impact

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:09:05.531653
    - Additional Notes: Query provides strategic market positioning analysis of Medicare Part D plans based on their excluded drug coverage patterns and management controls. Useful for competitive analysis and market landscaping. Note that the market position categories are simplified and may need adjustment based on specific business context.
    
    */