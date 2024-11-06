-- Healthcare Market Segmentation and Strategic Planning Analysis
-- Business Purpose: Identify and analyze county-level characteristics to support healthcare market entry, resource allocation, and strategic planning across urban-rural continuum

WITH county_urbanization_profile AS (
    SELECT 
        state_abr,
        COUNT(*) AS total_counties,
        -- Categorize counties by urban-rural classification
        SUM(CASE WHEN 2013_code IN (1,2) THEN 1 ELSE 0 END) AS metro_counties,
        SUM(CASE WHEN 2013_code IN (5,6) THEN 1 ELSE 0 END) AS nonmetro_counties,
        
        -- Calculate population metrics
        SUM(county_2012_pop) AS total_population,
        AVG(county_2012_pop) AS avg_county_population,
        
        -- Identify counties with significant population centers
        COUNT(CASE WHEN cbsa_2012_pop >= 1000000 THEN 1 END) AS large_metro_counties
    FROM mimi_ws_1.cdc.urbanrural_classification
    GROUP BY state_abr
),

market_complexity_score AS (
    SELECT 
        state_abr,
        total_counties,
        metro_counties,
        nonmetro_counties,
        total_population,
        avg_county_population,
        large_metro_counties,
        
        -- Calculate a market complexity index
        ROUND(
            (metro_counties * 1.0 / total_counties) * 100 +
            (large_metro_counties * 1.5) +
            (total_population / 1000000),
            2
        ) AS market_complexity_index
    FROM county_urbanization_profile
)

-- Final output highlighting strategic market insights
SELECT 
    state_abr,
    total_counties,
    metro_counties,
    nonmetro_counties,
    ROUND(total_population, 0) AS total_population,
    ROUND(avg_county_population, 0) AS avg_county_population,
    large_metro_counties,
    market_complexity_index,
    
    -- Rank states by market complexity for strategic planning
    DENSE_RANK() OVER (ORDER BY market_complexity_index DESC) AS market_complexity_rank
FROM market_complexity_score
ORDER BY market_complexity_index DESC
LIMIT 25;

/*
Query Workflow:
1. Create county-level urbanization profile
2. Calculate market complexity score
3. Rank states by market complexity index

Assumptions:
- Uses 2013 urban-rural classification as primary reference
- Population data from July 2012
- Market complexity is a composite metric combining urbanization and population metrics

Potential Extensions:
- Integrate healthcare facility density data
- Add healthcare outcome metrics by urban-rural classification
- Create predictive models for healthcare market potential

Business Insights:
- Supports healthcare market entry strategies
- Helps identify regions with complex healthcare market characteristics
- Provides a data-driven approach to resource allocation and strategic planning
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:05:24.853713
    - Additional Notes: Provides a comprehensive state-level view of urban-rural market characteristics, useful for healthcare strategic planning. Uses 2013 classification data with population metrics from July 2012. Market complexity index is a custom composite metric and should be interpreted as a relative ranking tool rather than an absolute measure.
    
    */