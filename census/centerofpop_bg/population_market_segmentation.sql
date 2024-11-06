
-- File: population_center_market_segmentation.sql
-- Business Purpose: 
-- Identify and segment census block groups by population size and geographic centrality
-- to support targeted market expansion, resource allocation, and demographic analysis strategies

WITH population_segment_analysis AS (
    -- Categorize block groups into population size tiers
    SELECT 
        statefp,
        countyfp,
        population,
        latitude,
        longitude,
        
        -- Create population size segments for strategic market targeting
        CASE 
            WHEN population < 100 THEN 'Very Small'
            WHEN population BETWEEN 100 AND 500 THEN 'Small'
            WHEN population BETWEEN 501 AND 1000 THEN 'Medium'
            WHEN population BETWEEN 1001 AND 2500 THEN 'Large'
            ELSE 'Very Large'
        END AS population_segment,
        
        -- Calculate proximity to median latitude/longitude as a centrality metric
        ROUND(
            ABS(latitude - AVG(latitude) OVER ()),
            4
        ) AS latitude_deviation,
        
        ROUND(
            ABS(longitude - AVG(longitude) OVER ()),
            4
        ) AS longitude_deviation
    
    FROM mimi_ws_1.census.centerofpop_bg
)

SELECT 
    population_segment,
    COUNT(*) AS segment_count,
    ROUND(AVG(population), 2) AS avg_population,
    ROUND(AVG(latitude_deviation), 4) AS avg_latitude_deviation,
    ROUND(AVG(longitude_deviation), 4) AS avg_longitude_deviation
FROM population_segment_analysis
GROUP BY population_segment
ORDER BY segment_count DESC

-- Query Mechanics:
-- 1. Segments block groups by population size
-- 2. Calculates geographic centrality metrics
-- 3. Provides aggregated insights for market strategy

-- Assumptions:
-- - Population data represents 2020 Census snapshot
-- - Geographic centrality is calculated using simple deviation from mean coordinates

-- Potential Extensions:
-- 1. Add geospatial clustering analysis
-- 2. Integrate with economic or industry-specific overlay data
-- 3. Create predictive models for market potential


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T20:59:40.919907
    - Additional Notes: Segments census block groups by population size and geographic centrality, providing a framework for targeted market analysis and strategic resource allocation.
    
    */