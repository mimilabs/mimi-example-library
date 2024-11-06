-- population_density_reference_point.sql

-- Business Purpose: 
-- This query uses the US center of population coordinates as a reference point to calculate 
-- approximate distances to key metropolitan areas. This helps understand population 
-- distribution patterns and can inform business decisions around market expansion,
-- logistics planning, and service area optimization.

-- Calculate the center point and demonstrate distance calculations
SELECT 
    -- Get the base center coordinates
    latitude as center_lat,
    longitude as center_long,
    population as total_population,
    
    -- Example distance calculations to major cities (using simplified degree difference)
    ABS(latitude - 40.7128) + ABS(longitude - (-74.0060)) as approx_dist_to_nyc,
    ABS(latitude - 34.0522) + ABS(longitude - (-118.2437)) as approx_dist_to_la,
    ABS(latitude - 41.8781) + ABS(longitude - (-87.6298)) as approx_dist_to_chicago,
    
    -- Add reference metadata
    mimi_src_file_date as reference_date

FROM mimi_ws_1.census.centerofpop_us

-- Most recent data point
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.census.centerofpop_us
);

-- HOW IT WORKS:
-- 1. Retrieves the center of population coordinates
-- 2. Calculates rough distances to major cities using coordinate differences
-- 3. Includes population and reference date information
-- 4. Filters to most recent data point

-- ASSUMPTIONS & LIMITATIONS:
-- - Distance calculations are simplified and not geodesically accurate
-- - Assumes straight-line distances rather than actual travel routes
-- - Based on census data timing, may not reflect very recent population shifts
-- - Major cities coordinates are hardcoded for demonstration

-- POSSIBLE EXTENSIONS:
-- 1. Add proper geodesic distance calculations using haversine formula
-- 2. Expand to include more cities or points of interest
-- 3. Join with additional demographic or economic data
-- 4. Create population-weighted service area calculations
-- 5. Add temporal analysis comparing multiple census periods
-- 6. Include state or regional subdivision analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:15:41.929486
    - Additional Notes: The query uses simplified linear distance calculations which are suitable for relative comparisons but should not be used for precise geographic measurements. For accurate distance calculations, consider implementing the haversine formula or using geographic information system (GIS) functions.
    
    */