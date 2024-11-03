-- beneficiary_cost_coverage_transition_analysis.sql

-- Business Purpose:
-- Analyzes how beneficiary cost sharing changes across different coverage levels (pre-deductible,
-- initial coverage, coverage gap, catastrophic) to help:
-- - Understand typical out-of-pocket cost progression through benefit phases
-- - Identify plans with more favorable cost structures during coverage transitions
-- - Support beneficiary education about expected cost changes throughout the year
-- - Guide plan selection based on expected drug utilization patterns

WITH cost_by_coverage AS (
  -- Get average preferred pharmacy copay amounts for each coverage level
  SELECT 
    contract_id,
    plan_id,
    coverage_level,
    ROUND(AVG(CASE 
      WHEN cost_type_pref = 1 AND cost_amt_pref > 0 
      THEN cost_amt_pref 
      ELSE NULL 
    END), 2) as avg_copay,
    COUNT(DISTINCT tier) as tier_count
  FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost
  WHERE days_supply = 1  -- Focus on 30-day supply
    AND cost_type_pref = 1  -- Look at copays only
  GROUP BY 1,2,3
)

SELECT
  contract_id,
  plan_id,
  -- Calculate cost changes between coverage levels
  MAX(CASE WHEN coverage_level = 0 THEN avg_copay END) as prededuct_avg_copay,
  MAX(CASE WHEN coverage_level = 1 THEN avg_copay END) as initial_avg_copay,
  MAX(CASE WHEN coverage_level = 2 THEN avg_copay END) as gap_avg_copay, 
  MAX(CASE WHEN coverage_level = 3 THEN avg_copay END) as cata_avg_copay,
  -- Calculate percentage increases
  ROUND(100.0 * (MAX(CASE WHEN coverage_level = 1 THEN avg_copay END) - 
    MAX(CASE WHEN coverage_level = 0 THEN avg_copay END)) / 
    NULLIF(MAX(CASE WHEN coverage_level = 0 THEN avg_copay END),0), 1) as pct_increase_initial,
  ROUND(100.0 * (MAX(CASE WHEN coverage_level = 2 THEN avg_copay END) - 
    MAX(CASE WHEN coverage_level = 1 THEN avg_copay END)) / 
    NULLIF(MAX(CASE WHEN coverage_level = 1 THEN avg_copay END),0), 1) as pct_increase_gap
FROM cost_by_coverage
GROUP BY 1,2
HAVING prededuct_avg_copay IS NOT NULL 
  AND initial_avg_copay IS NOT NULL
  AND gap_avg_copay IS NOT NULL
ORDER BY pct_increase_gap DESC
LIMIT 100;

-- How it works:
-- 1. Creates CTE to calculate average copays for each coverage level by plan
-- 2. Uses CASE statements to pivot coverage levels into columns
-- 3. Calculates percentage increases between coverage phases
-- 4. Filters for plans with complete data across phases
-- 5. Orders by gap coverage increase to identify plans with largest cost jumps

-- Assumptions & Limitations:
-- - Focuses only on preferred pharmacy copays for 30-day supply
-- - Averages across all tiers may mask tier-specific patterns
-- - Does not account for coinsurance cost sharing
-- - May not reflect actual patient costs due to subsidies

-- Possible Extensions:
-- 1. Add tier-specific analysis to see which drugs drive cost increases
-- 2. Compare patterns between different plan types (MA-PD vs PDP)
-- 3. Incorporate geographic analysis to identify regional variations
-- 4. Add year-over-year trending to track changes in coverage transition impacts
-- 5. Include both copay and coinsurance analysis for fuller cost picture

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:55:02.591781
    - Additional Notes: Query effectively tracks cost progression across benefit phases but could be sensitive to NULL values in cost_amt_pref field. Consider adding validation for minimum number of tiers per plan and handling zero-value edge cases in percentage calculations. Best used for comparing relative cost increases rather than absolute dollar amounts due to tier averaging.
    
    */