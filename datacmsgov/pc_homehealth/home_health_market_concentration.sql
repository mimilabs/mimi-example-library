-- Home Health Agency Market Concentration Analysis
-- 
-- Business Purpose:
-- Analyzes market concentration of home health agencies at the city level to:
-- 1. Identify potential service gaps or oversaturated markets
-- 2. Guide market entry/expansion decisions
-- 3. Support strategic planning for healthcare networks and investors
-- 4. Assist regulators in monitoring market dynamics

WITH city_metrics AS (
  -- Calculate key metrics for each city
  SELECT 
    state,
    city,
    COUNT(DISTINCT enrollment_id) as num_agencies,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN enrollment_id END) as num_for_profit,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' THEN enrollment_id END) as num_nonprofit,
    COUNT(DISTINCT organization_type_structure) as distinct_org_types
  FROM mimi_ws_1.datacmsgov.pc_homehealth
  WHERE city IS NOT NULL
  GROUP BY state, city
),

state_avg AS (
  -- Calculate state-level averages for comparison
  SELECT 
    state,
    AVG(num_agencies) as avg_agencies_per_city
  FROM city_metrics
  GROUP BY state
)

SELECT 
  cm.state,
  cm.city,
  cm.num_agencies,
  cm.num_for_profit,
  cm.num_nonprofit,
  cm.distinct_org_types,
  sa.avg_agencies_per_city as state_avg_agencies,
  ROUND(cm.num_agencies / sa.avg_agencies_per_city, 2) as market_concentration_index
FROM city_metrics cm
JOIN state_avg sa ON cm.state = sa.state
WHERE cm.num_agencies >= 5  -- Focus on cities with meaningful presence
ORDER BY market_concentration_index DESC
LIMIT 100;

-- How this works:
-- 1. First CTE aggregates agency counts and characteristics by city
-- 2. Second CTE calculates average agencies per city at state level
-- 3. Main query joins these to create a market concentration index
-- 4. Results show cities with highest concentration relative to state average

-- Assumptions & Limitations:
-- - Uses current snapshot only, doesn't reflect historical trends
-- - City boundaries may not perfectly align with service areas
-- - Raw counts don't account for agency size/capacity
-- - Assumes state is appropriate geographic unit for comparison

-- Possible Extensions:
-- 1. Add population data to calculate per-capita metrics
-- 2. Include Medicare claims data to measure market share by revenue
-- 3. Incorporate demographic data to identify underserved populations
-- 4. Add temporal analysis to track market evolution
-- 5. Include radius analysis for rural vs urban market definition

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:34:24.793077
    - Additional Notes: Query uses a relative concentration index (compared to state averages) rather than absolute numbers, which helps identify both oversaturated and underserved markets. Cities with fewer than 5 agencies are filtered out to ensure statistical relevance. Consider adding geographic radius analysis for more accurate market definition, especially in metropolitan areas where city boundaries may not reflect true service areas.
    
    */