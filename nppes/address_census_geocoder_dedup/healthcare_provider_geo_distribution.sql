
/* Healthcare Provider Geographic Distribution Analysis
 * 
 * Business Purpose:
 * This query analyzes the geographic distribution of healthcare providers by state
 * to identify potential gaps in coverage and support healthcare access planning.
 * It calculates key metrics about provider locations and geocoding quality by state.
 */

WITH state_metrics AS (
  -- Calculate metrics per state
  SELECT 
    state_fips,
    COUNT(*) as total_providers,
    COUNT(CASE WHEN match_indicator = 'Matched' THEN 1 END) as matched_addresses,
    COUNT(DISTINCT tract_fips) as unique_census_tracts,
    ROUND(AVG(CASE 
      WHEN longitude IS NOT NULL AND latitude IS NOT NULL 
      THEN latitude END),4) as avg_latitude,
    ROUND(AVG(CASE 
      WHEN longitude IS NOT NULL AND latitude IS NOT NULL 
      THEN longitude END),4) as avg_longitude
  FROM mimi_ws_1.nppes.address_census_geocoder_dedup
  GROUP BY state_fips
)

SELECT
  sm.state_fips,
  sm.total_providers,
  sm.matched_addresses,
  ROUND(sm.matched_addresses * 100.0 / sm.total_providers, 1) as match_rate_pct,
  sm.unique_census_tracts,
  ROUND(sm.total_providers * 1.0 / sm.unique_census_tracts, 1) as avg_providers_per_tract,
  sm.avg_latitude,
  sm.avg_longitude
FROM state_metrics sm
WHERE sm.state_fips IS NOT NULL
ORDER BY sm.total_providers DESC
LIMIT 20;

/* How this query works:
 * 1. Creates a CTE to aggregate metrics by state_fips
 * 2. Calculates total providers, successfully geocoded addresses, and unique census tracts
 * 3. Computes average coordinates for each state
 * 4. Final SELECT formats the results with derived metrics like match rate and provider density
 *
 * Assumptions & Limitations:
 * - Assumes state_fips is populated for most records
 * - Match_indicator = 'Matched' indicates successful geocoding
 * - Only shows top 20 states by provider count
 * - Simple geographic center calculation may not be meaningful for large/irregular states
 *
 * Possible Extensions:
 * 1. Add state name lookup to make results more readable
 * 2. Break down by provider type or specialty
 * 3. Calculate additional geographic distribution metrics (e.g. standard deviation of coordinates)
 * 4. Compare provider density to population data
 * 5. Add temporal analysis if data includes timestamps
 * 6. Generate geospatial visualizations using the coordinates
 */
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:57:22.495226
    - Additional Notes: Query focuses on state-level metrics and requires valid state_fips values. Match rates may need investigation if below expected thresholds. Average coordinates are simplified centroids and may not represent true geographic centers. Consider memory usage when extending beyond top 20 states.
    
    */