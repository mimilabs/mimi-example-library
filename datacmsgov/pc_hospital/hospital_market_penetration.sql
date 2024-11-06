-- Hospital Geographic Market Penetration and Service Mix
--
-- Business Purpose:
-- - Identify high-opportunity markets by analyzing hospital density and service gaps
-- - Guide market expansion strategies by understanding current hospital footprint
-- - Support competitive intelligence by revealing provider market concentrations
--

WITH hospital_metrics AS (
  -- Group hospitals by state and calculate key metrics
  SELECT 
    state,
    COUNT(DISTINCT enrollment_id) as total_hospitals,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN enrollment_id END) as for_profit_count,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' THEN enrollment_id END) as non_profit_count,
    COUNT(DISTINCT CASE WHEN subgroup_acute_care = 'Y' THEN enrollment_id END) as acute_care_count,
    COUNT(DISTINCT organization_name) as unique_organizations,
    COUNT(DISTINCT npi) as unique_npis
  FROM mimi_ws_1.datacmsgov.pc_hospital
  GROUP BY state
),

market_density AS (
  -- Calculate market concentration metrics
  SELECT
    state,
    total_hospitals,
    unique_organizations,
    ROUND(total_hospitals * 1.0 / unique_organizations, 2) as hospitals_per_org,
    ROUND(for_profit_count * 100.0 / total_hospitals, 1) as for_profit_pct,
    ROUND(acute_care_count * 100.0 / total_hospitals, 1) as acute_care_pct
  FROM hospital_metrics
  WHERE total_hospitals > 0
)

-- Generate final market analysis with rankings
SELECT 
  state,
  total_hospitals,
  unique_organizations,
  hospitals_per_org,
  for_profit_pct,
  acute_care_pct,
  RANK() OVER (ORDER BY total_hospitals DESC) as market_size_rank,
  RANK() OVER (ORDER BY hospitals_per_org DESC) as consolidation_rank
FROM market_density
ORDER BY total_hospitals DESC;

-- How This Query Works:
-- 1. First CTE calculates basic hospital counts and breakdowns by state
-- 2. Second CTE derives market concentration metrics
-- 3. Final SELECT adds ranking dimensions and orders results
--
-- Assumptions & Limitations:
-- - Assumes current enrollment data is complete and accurate
-- - Does not account for hospital bed capacity or revenue
-- - State-level analysis may mask local market dynamics
-- - Organization name matching may be imperfect due to variations
--
-- Possible Extensions:
-- 1. Add metropolitan statistical area (MSA) level analysis
-- 2. Include temporal trends using historical data
-- 3. Incorporate population data to calculate per capita metrics
-- 4. Add service line penetration analysis
-- 5. Include financial metrics if available
--
-- Sample Use Case:
-- Private equity firms can use this analysis to:
-- - Identify markets with consolidation opportunities
-- - Target states with favorable for-profit/non-profit mix
-- - Evaluate market entry strategies based on service gaps

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:08:55.111400
    - Additional Notes: The query provides market concentration metrics that can guide strategic decision-making for healthcare investors and operators. Consider adding volume/capacity metrics and local demographic data for more granular market analysis. State-level aggregation may oversimplify complex metropolitan healthcare markets that cross state boundaries.
    
    */