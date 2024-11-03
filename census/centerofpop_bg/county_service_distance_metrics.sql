-- block_group_service_radius.sql
-- 
-- Business Purpose: 
-- This query helps healthcare organizations optimize service coverage by calculating
-- the average distance between population centers of block groups and identifying
-- potential service radius gaps. This information is crucial for planning new
-- facility locations, mobile health services, and ensuring equitable healthcare access.
--

WITH block_group_pairs AS (
  -- Calculate distances between each block group's population center within the same county
  SELECT 
    a.statefp,
    a.countyfp,
    a.fips as origin_fips,
    a.population as origin_population,
    b.fips as destination_fips,
    b.population as destination_population,
    -- Calculate distance in miles between population centers
    2 * 3959 * asin(sqrt(
      power(sin((b.latitude - a.latitude) * pi()/180/2), 2) +
      cos(a.latitude * pi()/180) * cos(b.latitude * pi()/180) *
      power(sin((b.longitude - a.longitude) * pi()/180/2), 2)
    )) as distance_miles
  FROM mimi_ws_1.census.centerofpop_bg a
  JOIN mimi_ws_1.census.centerofpop_bg b
    ON a.statefp = b.statefp 
    AND a.countyfp = b.countyfp
    AND a.fips < b.fips -- Avoid duplicate pairs
)

SELECT 
  statefp,
  countyfp,
  COUNT(DISTINCT origin_fips) as block_groups_count,
  SUM(origin_population) as total_population,
  ROUND(AVG(distance_miles), 2) as avg_distance_between_centers,
  ROUND(MIN(distance_miles), 2) as min_distance_between_centers,
  ROUND(MAX(distance_miles), 2) as max_distance_between_centers
FROM block_group_pairs
GROUP BY statefp, countyfp
HAVING block_groups_count > 1
ORDER BY avg_distance_between_centers DESC
LIMIT 100;

--
-- How it works:
-- 1. Creates pairs of block groups within each county
-- 2. Calculates the great-circle distance between population centers using the Haversine formula
-- 3. Aggregates statistics at the county level to understand service coverage patterns
--
-- Assumptions and limitations:
-- - Assumes straight-line distances (doesn't account for road networks)
-- - Limited to intra-county analysis
-- - May not reflect actual travel times or accessibility barriers
--
-- Possible extensions:
-- 1. Add demographic factors to identify underserved populations
-- 2. Include existing facility locations to calculate actual coverage gaps
-- 3. Implement drive-time analysis using road network data
-- 4. Add seasonal population variations for tourist areas
-- 5. Include public transportation accessibility metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:57:53.909096
    - Additional Notes: Query provides valuable metrics for service area planning by calculating distances between population centers at the county level. Key metrics include average, minimum, and maximum distances between block groups, which can help identify coverage gaps and optimize service locations. Note that results are limited to counties with multiple block groups and distances are calculated as straight-line rather than actual travel routes.
    
    */