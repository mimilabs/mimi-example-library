-- Population Density Hotspots Across Metropolitan Counties
--
-- Business Purpose:
-- This query identifies high-density population clusters within major metropolitan counties,
-- helping businesses and organizations make strategic location decisions for services,
-- retail locations, or resource allocation. It's particularly valuable for:
-- - Real estate development planning
-- - Retail site selection
-- - Healthcare facility placement
-- - Emergency service coverage optimization

WITH metro_counties AS (
    -- Identify metropolitan counties with significant population
    SELECT 
        countyfp,
        statefp,
        SUM(population) as county_pop,
        COUNT(blkgrpce) as num_block_groups
    FROM mimi_ws_1.census.centerofpop_bg
    GROUP BY countyfp, statefp
    HAVING SUM(population) > 250000  -- Focus on larger metropolitan areas
),

density_calc AS (
    -- Calculate population density indicators for block groups
    SELECT 
        c.statefp,
        c.countyfp,
        c.tractce,
        c.blkgrpce,
        c.population,
        c.latitude,
        c.longitude,
        -- Use population relative to county average as density indicator
        c.population / (m.county_pop / m.num_block_groups) as relative_density
    FROM mimi_ws_1.census.centerofpop_bg c
    JOIN metro_counties m 
        ON c.countyfp = m.countyfp 
        AND c.statefp = m.statefp
)

SELECT 
    statefp,
    countyfp,
    COUNT(*) as high_density_blocks,
    SUM(population) as total_pop_in_hotspots,
    ROUND(AVG(latitude), 4) as avg_latitude,
    ROUND(AVG(longitude), 4) as avg_longitude
FROM density_calc
WHERE relative_density > 2.0  -- Focus on areas with >2x average density
GROUP BY statefp, countyfp
HAVING COUNT(*) >= 5  -- Ensure we have genuine clusters, not isolated high-density blocks
ORDER BY total_pop_in_hotspots DESC
LIMIT 20;

-- How it works:
-- 1. First CTE identifies metropolitan counties based on total population
-- 2. Second CTE calculates relative density for each block group compared to county average
-- 3. Final query aggregates high-density clusters at county level
--
-- Assumptions and limitations:
-- - Uses population count as proxy for density (doesn't account for block group area)
-- - Focuses only on metropolitan counties (>250k population)
-- - Assumes cluster definition of 5+ high-density block groups
-- - Does not account for geographic continuity of clusters
--
-- Possible extensions:
-- 1. Add demographic characteristics of identified hotspots
-- 2. Compare hotspots across different years to track urbanization
-- 3. Include proximity analysis to key infrastructure
-- 4. Add economic indicators for identified areas
-- 5. Create geographic visualization using latitude/longitude

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:11:38.715689
    - Additional Notes: Query focuses on metropolitan-level population density patterns and requires counties with 250k+ population. Results are most relevant for urban planning and business location analysis in major metropolitan areas. The relative density calculation method may need adjustment based on specific use cases.
    
    */