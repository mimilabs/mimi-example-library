-- svi_economic_vulnerability.sql
--
-- Purpose: Analyze socioeconomic vulnerability by identifying census tracts where residents face
-- multiple economic challenges. This helps organizations:
-- - Target financial assistance and social services programs
-- - Plan locations for job training and workforce development centers 
-- - Prioritize areas for economic development initiatives
--
-- Business Value:
-- 1. More effective allocation of limited social service resources
-- 2. Better understanding of areas needing economic support programs
-- 3. Data-driven approach to reducing poverty and unemployment
--

WITH economic_metrics AS (
  SELECT
    state,
    county,
    location,
    -- Core population metrics
    e_totpop as total_population,
    
    -- Economic vulnerability indicators 
    ep_pov150 as pct_below_150_poverty,
    ep_unemp as unemployment_rate,
    ep_nohsdp as pct_no_highschool,
    ep_hburd as pct_housing_cost_burden,
    
    -- Overall economic vulnerability score
    (rpl_theme1 * 100) as economic_vulnerability_percentile
  FROM mimi_ws_1.cdc.svi_censustract_y2022
  WHERE e_totpop >= 100  -- Filter out very small populations
),

high_risk_areas AS (
  SELECT
    state,
    county,
    location,
    total_population,
    economic_vulnerability_percentile,
    
    -- Calculate composite economic challenge score
    (pct_below_150_poverty + unemployment_rate + 
     pct_no_highschool + pct_housing_cost_burden)/4 as avg_economic_challenges
    
  FROM economic_metrics
  WHERE economic_vulnerability_percentile >= 75  -- Focus on highest risk quartile
)

SELECT
  state,
  county,
  COUNT(*) as high_risk_tracts,
  SUM(total_population) as affected_population,
  ROUND(AVG(economic_vulnerability_percentile),1) as avg_vulnerability_percentile,
  ROUND(AVG(avg_economic_challenges),1) as avg_economic_challenges
FROM high_risk_areas
GROUP BY state, county
HAVING COUNT(*) >= 3  -- Focus on counties with multiple high-risk tracts
ORDER BY avg_vulnerability_percentile DESC
LIMIT 100;

-- How it works:
-- 1. First CTE extracts key economic vulnerability metrics for each census tract
-- 2. Second CTE identifies high-risk areas based on SVI economic theme
-- 3. Final query aggregates results to county level for actionable insights
--
-- Assumptions & Limitations:
-- - Requires minimum population of 100 to avoid skewed percentages
-- - Uses simple averaging of metrics which may not capture full complexity
-- - Limited to recent 2022 data only
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis when historical data available
-- 2. Include correlation with health outcomes or education metrics
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Compare urban vs rural economic vulnerability patterns
--
-- Use: This analysis helps identify areas where multiple economic challenges
-- intersect, allowing for more targeted intervention strategies.

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:56:57.783007
    - Additional Notes: Query identifies geographic clusters of economic vulnerability based on multiple SVI indicators including poverty, unemployment, education, and housing burden. Best used for county-level program planning and resource allocation. Note that the 100-person population threshold may need adjustment for rural areas.
    
    */