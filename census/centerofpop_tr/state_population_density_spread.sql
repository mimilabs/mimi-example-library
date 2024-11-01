-- State Population Density and Geographic Distribution Analysis
-- Purpose: Identify states with concentrated vs dispersed populations by analyzing
-- census tract population centers. This helps businesses make strategic decisions
-- about market entry, resource allocation, and service coverage optimization.

WITH state_metrics AS (
    -- Calculate key population metrics per state
    SELECT 
        statefp,
        COUNT(DISTINCT tractce) as tract_count,
        SUM(population) as total_population,
        
        -- Calculate geographic spread using standard deviation of coordinates
        STDDEV(latitude) as lat_spread,
        STDDEV(longitude) as long_spread,
        
        -- Find population-weighted center coordinates
        AVG(latitude * population)/AVG(population) as weighted_lat_center,
        AVG(longitude * population)/AVG(population) as weighted_long_center
    FROM mimi_ws_1.census.centerofpop_tr
    GROUP BY statefp
),
ranked_states AS (
    -- Rank states by population density and geographic spread
    SELECT 
        statefp,
        total_population,
        tract_count,
        total_population/tract_count as avg_tract_population,
        lat_spread * long_spread as geographic_spread,
        weighted_lat_center,
        weighted_long_center,
        -- Create density categories
        CASE 
            WHEN (lat_spread * long_spread) < 
                 PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY lat_spread * long_spread) 
                 OVER() THEN 'Concentrated'
            WHEN (lat_spread * long_spread) > 
                 PERCENTILE_CONT(0.66) WITHIN GROUP (ORDER BY lat_spread * long_spread) 
                 OVER() THEN 'Dispersed'
            ELSE 'Moderate'
        END as population_distribution
    FROM state_metrics
)
SELECT 
    statefp as state_fips,
    total_population,
    tract_count,
    ROUND(avg_tract_population, 0) as avg_population_per_tract,
    ROUND(geographic_spread, 4) as geographic_spread_index,
    ROUND(weighted_lat_center, 4) as population_center_lat,
    ROUND(weighted_long_center, 4) as population_center_long,
    population_distribution
FROM ranked_states
ORDER BY total_population DESC;

/* How this query works:
1. First CTE calculates key metrics per state including population totals and geographic spread
2. Second CTE ranks states and categorizes their population distribution
3. Final output provides actionable metrics for business decision-making

Assumptions and limitations:
- Assumes census tracts are reasonably consistent in geographic size
- Geographic spread calculation is simplified and doesn't account for Earth's curvature
- Categories are relative to current data distribution, not absolute thresholds

Possible extensions:
1. Add temporal analysis by comparing against historical census data
2. Include demographic variables to identify specialized market opportunities
3. Create distance calculations to major metropolitan areas or service centers
4. Add county-level analysis for more granular market planning
5. Incorporate external data (income, age, etc.) for enhanced market segmentation
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:38:12.018635
    - Additional Notes: Query calculates both absolute population metrics and relative geographic distribution patterns at the state level. Geographic spread calculations use a simplified linear approach and may need adjustment for more precise spatial analysis. Consider state size variations when interpreting results.
    
    */