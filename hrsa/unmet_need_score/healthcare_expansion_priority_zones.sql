-- Title: Primary Care Resource Gap Analysis for Targeted Expansion
-- Business Purpose:
-- - Identify ZIP codes with high unmet healthcare needs but low health center coverage
-- - Support strategic planning for new health center locations or expansions
-- - Quantify potential impact based on population size and healthcare access metrics

WITH ranked_zips AS (
  SELECT 
    zip_code,
    state,
    population_size,
    zcta_uns,
    health_center_penetration,
    uninsured,
    no_vehicle_access,
    limited_healthy_food,
    below_200_federal_poverty_level
  FROM mimi_ws_1.hrsa.unmet_need_score
  -- Filter for meaningful population size and valid scores
  WHERE population_size >= 1000 
    AND zcta_uns IS NOT NULL
    AND health_center_penetration < 0.5 -- Areas with low health center coverage
),

prioritized_areas AS (
  SELECT *,
    -- Create composite score weighted by population impact
    (zcta_uns * population_size * (1 - health_center_penetration)) as expansion_priority_score,
    -- Calculate estimated underserved population
    ROUND(population_size * below_200_federal_poverty_level * (1 - health_center_penetration)) as potential_patients
  FROM ranked_zips
)

SELECT 
  zip_code,
  state,
  population_size,
  ROUND(zcta_uns, 2) as unmet_need_score,
  ROUND(health_center_penetration * 100, 1) as health_center_coverage_pct,
  ROUND(uninsured * 100, 1) as uninsured_pct,
  ROUND(no_vehicle_access * 100, 1) as no_vehicle_pct,
  ROUND(limited_healthy_food * 100, 1) as limited_food_access_pct,
  potential_patients,
  ROUND(expansion_priority_score, 0) as expansion_priority_score
FROM prioritized_areas
WHERE expansion_priority_score > 0
ORDER BY expansion_priority_score DESC
LIMIT 100;

-- How it works:
-- 1. Filters ZIP codes to focus on populated areas with low health center coverage
-- 2. Calculates a priority score that considers:
--    - Unmet need score
--    - Population size
--    - Current health center penetration gap
-- 3. Estimates potential patient population based on poverty levels
-- 4. Returns top 100 highest priority areas with relevant metrics

-- Assumptions & Limitations:
-- - Assumes areas with <50% health center penetration need additional coverage
-- - Population threshold of 1000 may exclude some rural areas
-- - Does not account for proximity to existing facilities in nearby ZIP codes
-- - Current health center capacity not considered

-- Possible Extensions:
-- 1. Add geographic clustering to identify opportunity zones
-- 2. Include demographic risk factors for specific service types
-- 3. Calculate distance to nearest existing health centers
-- 4. Incorporate state-specific healthcare policies and funding
-- 5. Add year-over-year trend analysis of key metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:41:58.367835
    - Additional Notes: Query identifies high-impact locations for healthcare facility expansion based on a composite score that balances population needs, current coverage gaps, and social determinants of health. The expansion_priority_score provides a standardized way to compare opportunities across different geographic areas while accounting for both the intensity of need (UNS) and potential impact (population size).
    
    */