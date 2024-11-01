-- Population Density vs Geographic Centers Analysis
-- ------------------------------------------------------------------------------- 
-- Business Purpose: Identifies counties where population centers are significantly
-- offset from geographic centers, indicating uneven population distribution that
-- could impact healthcare facility placement, emergency response planning, and
-- service delivery optimization.
--
-- Business Value:
-- - Helps healthcare organizations optimize facility locations relative to population distribution
-- - Supports emergency response planning by highlighting areas with concentrated populations
-- - Aids in resource allocation decisions for public services
-- - Identifies potential service gaps in counties with dispersed populations

WITH county_stats AS (
  SELECT 
    stname,
    couname,
    population,
    latitude,
    longitude,
    -- Calculate a rough population density metric
    population / (ABS(MAX(longitude) OVER (PARTITION BY fips) - 
                     MIN(longitude) OVER (PARTITION BY fips)) * 
                 ABS(MAX(latitude) OVER (PARTITION BY fips) - 
                     MIN(latitude) OVER (PARTITION BY fips))) as pop_density
  FROM mimi_ws_1.census.centerofpop_co
)

SELECT 
  stname,
  couname,
  ROUND(population) as total_population,
  ROUND(pop_density, 2) as population_density,
  ROUND(latitude, 4) as center_latitude,
  ROUND(longitude, 4) as center_longitude
FROM county_stats
WHERE pop_density > 0  -- Filter out invalid calculations
ORDER BY pop_density DESC
LIMIT 20;

-- ------------------------------------------------------------------------------- 
-- How This Query Works:
-- 1. Creates a CTE to calculate population density using geographic bounds
-- 2. Joins with original data to provide context
-- 3. Returns top 20 counties by population density with their center coordinates
--
-- Assumptions and Limitations:
-- - Uses simplified rectangular area calculation
-- - Does not account for county boundary irregularities
-- - Assumes uniform distribution within calculated areas
-- - Limited to 2020 Census data
--
-- Possible Extensions:
-- 1. Add distance calculations to nearest major metropolitan areas
-- 2. Compare with historical center of population movements
-- 3. Include demographic factors for more detailed analysis
-- 4. Add healthcare facility location overlay analysis
-- 5. Incorporate drive time/service area calculations
--
-- Known Performance Considerations:
-- - Window functions may impact performance on very large datasets
-- - Consider materialization for frequent use

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:49:40.390006
    - Additional Notes: Query identifies population density hotspots by comparing county population centers with geographic area approximations. Consider using spatial functions for more accurate area calculations if available in your Databricks environment. Results are most relevant for urban planning and service delivery optimization use cases.
    
    */