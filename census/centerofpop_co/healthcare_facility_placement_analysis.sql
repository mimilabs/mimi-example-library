-- County Healthcare Access Analysis Based on Population Centers
-- -------------------------------------------------------------------------------
-- Business Purpose: Identifies counties where population centers could inform optimal 
-- healthcare facility placement, particularly focusing on counties with significant 
-- populations that may require enhanced healthcare access.
-- This analysis helps healthcare organizations and policymakers make data-driven
-- decisions about where to locate new facilities or optimize existing ones.

WITH population_ranked_counties AS (
  -- Rank counties within each state by population to identify key focus areas
  SELECT 
    stname,
    couname,
    population,
    latitude,
    longitude,
    RANK() OVER (PARTITION BY stname ORDER BY population DESC) as pop_rank
  FROM mimi_ws_1.census.centerofpop_co
),

significant_counties AS (
  -- Focus on the most populous counties in each state
  SELECT 
    stname,
    couname,
    population,
    latitude,
    longitude,
    pop_rank,
    -- Calculate rough distance from state average coordinates as a proxy for accessibility
    AVG(latitude) OVER (PARTITION BY stname) as state_avg_lat,
    AVG(longitude) OVER (PARTITION BY stname) as state_avg_long
  FROM population_ranked_counties
  WHERE pop_rank <= 5  -- Focus on top 5 counties by population in each state
)

SELECT 
  stname,
  couname,
  FORMAT_NUMBER(population, 0) as formatted_population,
  ROUND(latitude, 4) as center_latitude,
  ROUND(longitude, 4) as center_longitude,
  pop_rank as population_rank,
  -- Calculate approximate distance from state center (simplified calculation)
  ROUND(SQRT(POWER(latitude - state_avg_lat, 2) + 
             POWER(longitude - state_avg_long, 2)) * 69, 1) as miles_from_state_center
FROM significant_counties
ORDER BY stname, pop_rank;

-- How This Query Works:
-- 1. First CTE ranks counties within each state by population
-- 2. Second CTE filters to top 5 counties and calculates state center averages
-- 3. Main query formats results and calculates approximate distances
--
-- Assumptions and Limitations:
-- - Assumes population size correlates with healthcare facility needs
-- - Uses simplified distance calculation (not accounting for Earth's curvature)
-- - Limited to top 5 counties per state which may miss important rural areas
-- - Does not account for existing healthcare infrastructure
--
-- Possible Extensions:
-- 1. Add demographic data to analyze specific population needs
-- 2. Include existing hospital location data to identify coverage gaps
-- 3. Incorporate drive time analysis using road network data
-- 4. Add rural health analysis by including population density calculations
-- 5. Include economic indicators to assess healthcare access barriers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:02:55.837660
    - Additional Notes: Query focuses on population-based healthcare facility planning at county level. Distance calculations are approximated using Euclidean distance and should be validated against actual road networks for precise facility planning. Consider adding actual healthcare facility data for gap analysis.
    
    */