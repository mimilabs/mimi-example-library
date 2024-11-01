-- specialty_tier_affordability.sql
--
-- Business Purpose:
-- Analyzes specialty tier prevalence and cost sharing structures across Medicare Part D plans 
-- to understand patient affordability challenges for high-cost specialty medications.
-- This helps payers, manufacturers, and policymakers evaluate specialty drug access barriers
-- and identify opportunities to improve patient affordability.

WITH plan_metrics AS (
  SELECT DISTINCT
    contract_id,
    plan_id,
    segment_id,
    CASE WHEN MAX(CASE WHEN tier_specialty_yn = 'Y' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END as has_specialty_tier,
    MAX(CASE 
      WHEN tier_specialty_yn = 'Y' AND coverage_level = 1 AND cost_type_pref = 2 
      THEN cost_amt_pref END) as specialty_coinsurance,
    MAX(CASE WHEN tier_specialty_yn = 'Y' AND ded_applies_yn = 'Y' THEN 1 ELSE 0 END) as specialty_has_deductible,
    MAX(CASE WHEN tier_specialty_yn = 'Y' AND gap_cov_tier = 1 THEN 1 ELSE 0 END) as specialty_full_gap,
    MAX(CASE WHEN tier_specialty_yn = 'Y' AND gap_cov_tier = 2 THEN 1 ELSE 0 END) as specialty_partial_gap
  FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost)
  GROUP BY 1,2,3
)

SELECT 
  COUNT(*) as total_plans,
  SUM(has_specialty_tier) as plans_with_specialty_tier,
  ROUND(100.0 * SUM(has_specialty_tier) / COUNT(*), 1) as pct_plans_with_specialty_tier,
  ROUND(AVG(CASE WHEN specialty_coinsurance IS NOT NULL 
    THEN specialty_coinsurance * 100 END), 1) as avg_specialty_coinsurance_pct,
  SUM(specialty_has_deductible) as specialty_with_deductible,
  SUM(specialty_full_gap) as specialty_full_gap_coverage,
  SUM(specialty_partial_gap) as specialty_partial_gap_coverage
FROM plan_metrics;

-- How this query works:
-- 1. Creates a CTE to first aggregate metrics at the plan level
-- 2. Uses window functions to identify plans with specialty tiers
-- 3. Calculates cost sharing metrics for plans with specialty tiers
-- 4. Aggregates final results across all plans
-- 5. Uses most recent data snapshot via mimi_src_file_date

-- Assumptions & Limitations:
-- - Assumes specialty tier designation accurately reflects high-cost specialty drugs
-- - Limited to plan design analysis; does not include actual utilization/spend
-- - Coinsurance analysis focuses on preferred pharmacy network
-- - Does not account for plan-specific specialty drug formulary coverage

-- Possible Extensions:
-- 1. Add regional/state comparative analysis
-- 2. Trend analysis over multiple time periods
-- 3. Compare MA-PD vs PDP specialty tier structures
-- 4. Link to plan enrollment data to assess member impact
-- 5. Analyze specialty tier cost sharing by therapeutic categories

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:08:28.801984
    - Additional Notes: Query uses latest available data snapshot only. Coinsurance percentages are calculated based on preferred pharmacy rates. Plans without specialty tiers are included in total count but excluded from specialty-specific averages. Some plans may have multiple specialty tiers which could affect aggregated metrics.
    
    */