-- Coastal Proximity Population Analysis
--
-- Business Purpose:
-- Identify census tracts near coastlines to analyze population distribution patterns
-- along coastal areas. This helps businesses understand:
-- 1. Market opportunities in coastal regions
-- 2. Population exposure to coastal climate risks
-- 3. Strategic location planning for coastal-dependent businesses

WITH coastal_tracts AS (
  -- Filter for likely coastal areas based on longitude ranges
  -- East Coast: ~ -82 to -67
  -- West Coast: ~ -125 to -117
  -- Note: This is a simplified approach
  SELECT 
    statefp,
    countyfp,
    population,
    latitude,
    longitude,
    CASE 
      WHEN longitude BETWEEN -82 AND -67 THEN 'East Coast'
      WHEN longitude BETWEEN -125 AND -117 THEN 'West Coast'
      ELSE 'Inland'
    END AS coast_region
  FROM mimi_ws_1.census.centerofpop_tr
  WHERE population > 0
)

SELECT 
  coast_region,
  COUNT(*) as tract_count,
  SUM(population) as total_population,
  ROUND(AVG(population), 0) as avg_tract_population,
  COUNT(DISTINCT statefp) as state_count,
  COUNT(DISTINCT countyfp) as county_count
FROM coastal_tracts
GROUP BY coast_region
ORDER BY total_population DESC;

-- How this works:
-- 1. Identifies census tracts in approximate coastal regions using longitude ranges
-- 2. Calculates population statistics for each coastal region
-- 3. Provides comparison between East Coast, West Coast, and inland areas

-- Assumptions and Limitations:
-- 1. Uses simplified longitude ranges to identify coastal areas
-- 2. Does not account for Gulf Coast or other coastal regions
-- 3. May include some non-coastal areas within the longitude ranges
-- 4. Excludes tracts with zero population

-- Possible Extensions:
-- 1. Add more precise coastal definitions using geospatial functions
-- 2. Include Gulf Coast and other coastal regions
-- 3. Add elevation data to identify low-lying coastal areas
-- 4. Compare population density between coastal and inland regions
-- 5. Analyze demographic characteristics of coastal populations
-- 6. Add temporal analysis to track coastal population changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:51:56.041147
    - Additional Notes: Query uses simplified longitude ranges to approximate coastal regions. For more accurate coastal analysis, consider implementing proper geospatial functions or adding additional geographic reference data. Current implementation focuses on East and West coasts only, excluding Gulf Coast and other coastal areas.
    
    */