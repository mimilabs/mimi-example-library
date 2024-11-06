-- state_population_gravity_centers.sql
--
-- Business Purpose: 
-- This query calculates the "gravity center" of each state's population by averaging 
-- the latitude/longitude coordinates weighted by block group populations. This helps
-- organizations understand where their target populations are concentrated to optimize
-- placement of distribution centers, regional offices, and service locations.

WITH state_metrics AS (
  -- Calculate population-weighted center coordinates for each state
  SELECT 
    statefp,
    SUM(population) as total_state_pop,
    SUM(latitude * population) / SUM(population) as weighted_lat,
    SUM(longitude * population) / SUM(population) as weighted_long,
    COUNT(DISTINCT countyfp) as num_counties,
    COUNT(*) as num_block_groups
  FROM mimi_ws_1.census.centerofpop_bg
  GROUP BY statefp
)
SELECT
  sm.statefp,
  sm.total_state_pop,
  ROUND(sm.weighted_lat, 4) as population_center_lat,
  ROUND(sm.weighted_long, 4) as population_center_long,
  sm.num_counties,
  sm.num_block_groups,
  -- Calculate metrics about population distribution
  ROUND(sm.total_state_pop / sm.num_block_groups, 0) as avg_block_group_pop,
  ROUND(sm.total_state_pop / sm.num_counties, 0) as avg_county_pop
FROM state_metrics sm
ORDER BY sm.total_state_pop DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate population and coordinate data at the state level
-- 2. Calculates population-weighted average coordinates to find the "gravity center"
-- 3. Includes additional metrics about population distribution across counties/block groups
-- 4. Orders results by total population to highlight largest states first

-- Assumptions and Limitations:
-- - Assumes coordinate weighting by population provides meaningful center points
-- - Does not account for geographic barriers or travel distances
-- - Based on 2020 Census data snapshot
-- - Simple spherical distance calculations may have edge cases near poles/date line

-- Possible Extensions:
-- 1. Add distance calculations from population center to major cities
-- 2. Compare with historical census data to show population center shifts
-- 3. Include demographic variables to find specialized population centers
-- 4. Add geographic clustering analysis within states
-- 5. Calculate accessibility metrics from population centers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:04:19.161811
    - Additional Notes: Query provides high-level population distribution metrics across states using weighted coordinates. Results are particularly useful for initial site selection and regional planning, but should be supplemented with more detailed local analysis for final decision making.
    
    */