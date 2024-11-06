-- Title: Rural Healthcare Access and Resource Analysis

-- Business Purpose:
-- - Identify rural areas with critical healthcare access challenges
-- - Analyze the intersection of transportation barriers and healthcare utilization
-- - Guide resource allocation for mobile health services and transportation assistance programs
-- - Support rural health program planning with objective data-driven insights

WITH rural_analysis AS (
  -- Identify ZIPs with potential rural healthcare access challenges
  SELECT 
    zip_code,
    state,
    population_size,
    zcta_uns,
    no_vehicle_access,
    limited_healthy_food,
    preventable_hospital_stays,
    health_center_penetration,
    life_expectancy
  FROM mimi_ws_1.hrsa.unmet_need_score
  WHERE limited_healthy_food > 0.20  -- Focus on areas with food access barriers as proxy for rurality
    AND population_size < 20000      -- Target smaller communities
),

ranked_areas AS (
  -- Calculate composite access barrier score and rank areas
  SELECT 
    *,
    (no_vehicle_access + limited_healthy_food + 
     (preventable_hospital_stays/1000)) AS access_barrier_score,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY zcta_uns DESC) as state_rank
  FROM rural_analysis
)

-- Generate final analysis of most challenged rural areas
SELECT 
  state,
  COUNT(DISTINCT zip_code) as high_need_zips,
  ROUND(AVG(population_size), 0) as avg_population,
  ROUND(AVG(zcta_uns), 2) as avg_uns_score,
  ROUND(AVG(no_vehicle_access) * 100, 1) as pct_no_vehicle,
  ROUND(AVG(limited_healthy_food) * 100, 1) as pct_limited_food_access,
  ROUND(AVG(preventable_hospital_stays), 0) as avg_preventable_stays,
  ROUND(AVG(health_center_penetration) * 100, 1) as pct_health_center_coverage,
  ROUND(AVG(life_expectancy), 1) as avg_life_expectancy
FROM ranked_areas 
WHERE state_rank <= 10  -- Focus on top 10 highest need areas per state
GROUP BY state
HAVING COUNT(DISTINCT zip_code) >= 5  -- Only include states with meaningful sample sizes
ORDER BY avg_uns_score DESC;

-- How this query works:
-- 1. Identifies rural areas using food access limitations and population size as proxies
-- 2. Calculates a composite access barrier score combining transportation, food access, and preventable hospitalizations
-- 3. Ranks areas within each state by unmet need score
-- 4. Aggregates data for the highest-need rural areas by state
-- 5. Provides summary statistics relevant for rural healthcare program planning

-- Assumptions and Limitations:
-- - Uses food access and population size as proxies for rural areas
-- - Focus on top 10 highest need areas may miss some important secondary priority areas
-- - State-level aggregation may mask significant intra-state variations
-- - Does not account for seasonal variation in access barriers

-- Possible Extensions:
-- 1. Add seasonal analysis for states with severe winter weather impacts
-- 2. Include distance to nearest emergency department or trauma center
-- 3. Incorporate broadband access for telehealth potential
-- 4. Add demographic breakdowns for age groups most impacted
-- 5. Calculate drive times to nearest health centers for each ZIP
-- 6. Compare access barriers between frontier, rural, and urban areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:22:22.886073
    - Additional Notes: The query targets small population ZIP codes with food access limitations as a proxy for rural areas. The composite access barrier score combines transportation barriers, food access issues, and preventable hospitalizations to identify areas most in need of rural healthcare interventions. Results are limited to states with at least 5 high-need ZIP codes to ensure statistical relevance.
    
    */