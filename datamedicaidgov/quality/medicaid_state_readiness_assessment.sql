-- medicaid_quality_compliance_readiness.sql
--
-- Business Purpose:
-- Assesses state reporting readiness and compliance ahead of mandatory 2024 Child Core Set reporting by analyzing:
-- 1. Current participation rates by state across key measures
-- 2. Completeness of reporting methodology
-- 3. Measure adoption patterns
-- This helps identify states needing support for the transition to mandatory reporting.

WITH state_reporting_summary AS (
  -- Calculate reporting metrics per state for most recent year
  SELECT 
    state,
    ffy,
    COUNT(DISTINCT measure_abbreviation) as measures_reported,
    COUNT(DISTINCT CASE WHEN methodology IS NOT NULL THEN measure_abbreviation END) as measures_with_methodology,
    COUNT(DISTINCT CASE WHEN state_rate IS NOT NULL THEN measure_abbreviation END) as measures_with_rates,
    COUNT(DISTINCT domain) as domains_covered
  FROM mimi_ws_1.datamedicaidgov.quality
  WHERE reporting_program = 'Child Core Set'
  AND ffy = (SELECT MAX(ffy) FROM mimi_ws_1.datamedicaidgov.quality)
  GROUP BY state, ffy
),

state_rankings AS (
  -- Calculate completeness scores and rankings
  SELECT
    state,
    measures_reported,
    measures_with_methodology,
    measures_with_rates,
    domains_covered,
    ROUND((measures_with_rates * 100.0 / NULLIF(measures_reported, 0)), 1) as completeness_pct,
    RANK() OVER (ORDER BY measures_reported DESC) as reporting_rank
  FROM state_reporting_summary
)

SELECT 
  state,
  measures_reported,
  measures_with_methodology,
  measures_with_rates,
  domains_covered,
  completeness_pct,
  CASE 
    WHEN completeness_pct >= 90 THEN 'High Readiness'
    WHEN completeness_pct >= 75 THEN 'Moderate Readiness' 
    ELSE 'Needs Support'
  END as readiness_status
FROM state_rankings
ORDER BY measures_reported DESC, completeness_pct DESC;

-- How it works:
-- 1. First CTE aggregates reporting metrics by state for most recent year
-- 2. Second CTE calculates completeness scores and rankings
-- 3. Final query assigns readiness status based on completeness percentage
-- 4. Results ordered by number of measures reported and completeness

-- Assumptions & Limitations:
-- - Focuses only on Child Core Set measures due to 2024 mandatory reporting
-- - Uses most recent year's data as proxy for readiness
-- - Assumes methodology documentation indicates reporting capability
-- - Does not account for measure-specific reporting challenges
-- - Completeness thresholds are illustrative and may need adjustment

-- Possible Extensions:
-- 1. Add year-over-year trending to show reporting improvement
-- 2. Include specific measure gaps analysis by state
-- 3. Incorporate population size/resources for context
-- 4. Add geographic clustering to identify regional patterns
-- 5. Compare Child vs Adult Core Set reporting patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:04:58.330001
    - Additional Notes: Query evaluates preparedness for mandatory Child Core Set reporting based on completion rates and methodology documentation. Recommended for quarterly assessment of state readiness. Consider adjusting completeness thresholds based on specific state contexts and regulatory requirements.
    
    */