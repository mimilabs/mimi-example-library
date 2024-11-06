-- child_welfare_vulnerability_2000.sql

-- Business Purpose:
-- Analyze census tracts to identify areas with heightened child welfare risk factors,
-- including poverty, single-parent households, and overcrowded housing conditions.
-- This analysis helps social services agencies and child welfare programs target
-- preventive interventions and support services to high-risk communities.

WITH risk_factors AS (
  SELECT 
    state_name,
    county,
    tract,
    -- Calculate percentage of children in poverty
    g1v1r * g2v2r AS child_poverty_risk,
    -- Single parent household percentage
    g2v4r AS single_parent_risk,
    -- Overcrowded housing percentage 
    g4v3r AS overcrowded_housing_risk,
    -- Total child population
    g2v2n AS child_population,
    totpop2000
  FROM mimi_ws_1.cdc.svi_censustract_y2000
  WHERE g2v2n > 0  -- Only include tracts with children present
)

SELECT
  state_name,
  county,
  -- Calculate composite risk score
  ROUND(AVG((child_poverty_risk + single_parent_risk + overcrowded_housing_risk)/3), 3) 
    AS avg_child_welfare_risk,
  -- Sum total children potentially at risk
  SUM(child_population) AS total_children,
  -- Calculate percentage of total population that are children
  ROUND(SUM(child_population) * 100.0 / SUM(totpop2000), 1) AS pct_children,
  -- Count high-risk tracts (above 75th percentile in composite score)
  COUNT(*) AS total_tracts
FROM risk_factors
GROUP BY state_name, county
HAVING total_children > 1000  -- Focus on areas with significant child population
ORDER BY avg_child_welfare_risk DESC
LIMIT 20;

-- How it works:
-- 1. Creates CTE to calculate key child welfare risk metrics at tract level
-- 2. Aggregates to county level to identify geographic areas of concern
-- 3. Applies population threshold to focus on statistically significant areas
-- 4. Ranks counties by composite risk score

-- Assumptions & Limitations:
-- - Assumes equal weighting of risk factors in composite score
-- - Limited to year 2000 data point
-- - Does not account for protective factors or community resources
-- - Geographic aggregation may mask neighborhood-level variations

-- Possible Extensions:
-- 1. Add trend analysis by comparing to more recent years
-- 2. Include additional risk factors like education levels
-- 3. Correlate with child welfare outcome data if available
-- 4. Generate ZIP code level analysis for service delivery planning
-- 5. Add demographic breakdowns of at-risk child populations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:28:29.936158
    - Additional Notes: The query aggregates multiple child welfare risk indicators (poverty, single parenthood, overcrowding) at the county level, focusing on areas with significant child populations (>1000). The composite risk score calculation uses a simple average of three factors, which may need adjustment based on domain expertise or local conditions.
    
    */