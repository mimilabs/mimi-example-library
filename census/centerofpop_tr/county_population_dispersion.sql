-- County-Level Population Distance Analysis for Market Coverage Planning
-- 
-- Purpose: Calculate the average distance between population centers within each county
-- to help businesses optimize facility locations and service coverage areas.
-- This analysis supports decisions about:
-- - Retail location planning
-- - Healthcare facility placement
-- - Service delivery optimization
-- - Last-mile delivery strategies

WITH county_stats AS (
  -- Calculate center points and key metrics for each county
  SELECT 
    statefp,
    countyfp,
    COUNT(*) as tract_count,
    SUM(population) as total_county_pop,
    AVG(latitude) as county_center_lat,
    AVG(longitude) as county_center_long
  FROM mimi_ws_1.census.centerofpop_tr
  GROUP BY statefp, countyfp
),

tract_distances AS (
  -- Calculate average distance from each tract to county center
  SELECT 
    c.statefp,
    c.countyfp,
    AVG(
      2 * 3959 * ASIN(
        SQRT(
          POWER(SIN((t.latitude - c.county_center_lat) * PI()/180/2), 2) +
          COS(t.latitude * PI()/180) * 
          COS(c.county_center_lat * PI()/180) *
          POWER(SIN((t.longitude - c.county_center_long) * PI()/180/2), 2)
        )
      )
    ) as avg_distance_to_center
  FROM mimi_ws_1.census.centerofpop_tr t
  JOIN county_stats c 
    ON t.statefp = c.statefp 
    AND t.countyfp = c.countyfp
  GROUP BY c.statefp, c.countyfp
)

SELECT 
  cs.statefp,
  cs.countyfp,
  cs.tract_count,
  cs.total_county_pop,
  ROUND(td.avg_distance_to_center, 2) as avg_miles_to_center,
  ROUND(cs.total_county_pop / td.avg_distance_to_center, 2) as population_density_score
FROM county_stats cs
JOIN tract_distances td 
  ON cs.statefp = td.statefp 
  AND cs.countyfp = td.countyfp
WHERE cs.tract_count >= 5  -- Focus on counties with meaningful number of tracts
ORDER BY population_density_score DESC
LIMIT 100;

-- How it works:
-- 1. First CTE calculates county-level statistics including population centers
-- 2. Second CTE uses Haversine formula to calculate average distance from tracts to county center
-- 3. Final query combines metrics and calculates a population density score
--    (higher scores indicate more concentrated population)

-- Assumptions and limitations:
-- - Requires counties with at least 5 census tracts for meaningful analysis
-- - Uses straight-line distances, not road distances
-- - Assumes even population distribution within census tracts
-- - Does not account for geographic barriers or accessibility

-- Possible extensions:
-- 1. Add state names and geographic regions for broader analysis
-- 2. Include demographic data to analyze population characteristics
-- 3. Compare urban vs rural county patterns
-- 4. Add temporal analysis if historical data becomes available
-- 5. Include additional distance calculations (max distance, standard deviation)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:56:59.551095
    - Additional Notes: Query calculates a population density score based on the average distance between population centers and total population, which is useful for optimizing service coverage and facility placement. The score is higher for areas with more concentrated populations relative to geographic spread. Performance may be impacted for datasets with large numbers of census tracts due to the distance calculations.
    
    */