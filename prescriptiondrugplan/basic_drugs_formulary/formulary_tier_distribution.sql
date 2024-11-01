-- Title: Medicare Part D Formulary Cost Tier Distribution Analysis

-- Business Purpose:
-- This analysis examines the distribution of drug tier pricing levels across Medicare Part D formularies
-- to identify cost-sharing patterns and potential affordability concerns. Understanding tier distributions
-- helps:
-- 1. Health plans benchmark their tier structures against market norms
-- 2. Pharmacy benefit managers optimize formulary designs
-- 3. Healthcare consultants advise on competitive positioning
-- 4. Policymakers assess drug affordability across plans

WITH tier_summary AS (
  -- Calculate tier level distributions by formulary and contract year
  SELECT 
    formulary_id,
    contract_year,
    tier_level_value,
    COUNT(*) as drugs_in_tier,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY formulary_id, contract_year) as tier_percentage
  FROM mimi_ws_1.prescriptiondrugplan.basic_drugs_formulary
  WHERE tier_level_value IS NOT NULL
  GROUP BY formulary_id, contract_year, tier_level_value
),

formulary_metrics AS (
  -- Calculate key metrics per formulary
  SELECT
    contract_year,
    COUNT(DISTINCT formulary_id) as total_formularies,
    AVG(CASE WHEN tier_level_value = 1 THEN tier_percentage ELSE NULL END) as avg_tier1_pct,
    AVG(CASE WHEN tier_level_value = 2 THEN tier_percentage ELSE NULL END) as avg_tier2_pct,
    AVG(CASE WHEN tier_level_value = 3 THEN tier_percentage ELSE NULL END) as avg_tier3_pct,
    AVG(CASE WHEN tier_level_value >= 4 THEN tier_percentage ELSE NULL END) as avg_tier4plus_pct
  FROM tier_summary
  GROUP BY contract_year
)

-- Final output showing year-over-year tier distribution trends
SELECT
  contract_year,
  total_formularies,
  ROUND(avg_tier1_pct, 1) as avg_tier1_percentage,
  ROUND(avg_tier2_pct, 1) as avg_tier2_percentage,
  ROUND(avg_tier3_pct, 1) as avg_tier3_percentage,
  ROUND(avg_tier4plus_pct, 1) as avg_tier4plus_percentage
FROM formulary_metrics
ORDER BY contract_year;

-- How it works:
-- 1. First CTE calculates the percentage distribution of drugs across tiers for each formulary
-- 2. Second CTE aggregates these distributions across all formularies by contract year
-- 3. Final query formats and presents the yearly trends in tier distributions

-- Assumptions and Limitations:
-- - Assumes tier_level_value is populated and valid
-- - Groups all tiers 4 and above together for simplicity
-- - Does not account for formulary size differences
-- - Treats all drugs equally regardless of utilization or cost

-- Possible Extensions:
-- 1. Add drug class analysis to see tier patterns by therapeutic category
-- 2. Include regional comparisons of tier distributions
-- 3. Correlate tier distributions with plan enrollment numbers
-- 4. Compare tier patterns between MA-PD and PDP plans
-- 5. Analyze changes in tier assignments for specific drugs over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:52:35.547409
    - Additional Notes: The query aggregates tier distribution patterns across Medicare Part D formularies, focusing on yearly averages. Results will show percentage of drugs in each tier level, which is useful for market analysis and formulary design benchmarking. Note that the analysis treats all drugs equally regardless of their prescription volume or cost, which may not reflect real-world impact on beneficiaries.
    
    */