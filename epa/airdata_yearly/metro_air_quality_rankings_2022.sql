-- regional_air_quality_rankings.sql

-- Business Purpose:
-- Identify regions with best and worst air quality across multiple pollutants to:
-- 1. Help businesses evaluate environmental conditions for facility locations
-- 2. Assist real estate developers in assessing area environmental quality
-- 3. Support public health organizations in targeting intervention programs
-- 4. Guide economic development agencies in promoting clean air regions

WITH ranked_regions AS (
    -- Calculate average pollutant levels by CBSA (metro area)
    SELECT 
        cbsa_name,
        parameter_name,
        year,
        COUNT(DISTINCT site_num) as monitor_count,
        ROUND(AVG(arithmetic_mean), 2) as avg_concentration,
        ROUND(AVG(observation_percent), 1) as avg_completeness,
        -- Rank regions within each pollutant type
        ROW_NUMBER() OVER (
            PARTITION BY parameter_name, year 
            ORDER BY AVG(arithmetic_mean) ASC
        ) as cleanest_rank,
        ROW_NUMBER() OVER (
            PARTITION BY parameter_name, year 
            ORDER BY AVG(arithmetic_mean) DESC
        ) as dirtiest_rank
    FROM mimi_ws_1.epa.airdata_yearly
    WHERE 
        -- Focus on recent complete year
        year = 2022
        -- Look at major pollutants
        AND parameter_name IN (
            'PM2.5 - Local Conditions',
            'Ozone',
            'NO2 (Nitrogen Dioxide)',
            'SO2 (Sulfur Dioxide)'
        )
        -- Ensure data quality
        AND completeness_indicator = 'Y'
        AND observation_percent >= 75
        AND cbsa_name IS NOT NULL
    GROUP BY cbsa_name, parameter_name, year
    -- Ensure adequate monitoring coverage
    HAVING COUNT(DISTINCT site_num) >= 3
)

-- Get top and bottom regions for each pollutant
SELECT
    parameter_name as pollutant,
    -- Cleanest regions
    MAX(CASE WHEN cleanest_rank = 1 THEN 
        cbsa_name || ' (' || avg_concentration || ' ' || monitor_count || ' monitors)'
    END) as cleanest_region,
    MAX(CASE WHEN cleanest_rank = 2 THEN
        cbsa_name || ' (' || avg_concentration || ' ' || monitor_count || ' monitors)'
    END) as second_cleanest,
    -- Most polluted regions  
    MAX(CASE WHEN dirtiest_rank = 1 THEN
        cbsa_name || ' (' || avg_concentration || ' ' || monitor_count || ' monitors)'
    END) as most_polluted,
    MAX(CASE WHEN dirtiest_rank = 2 THEN
        cbsa_name || ' (' || avg_concentration || ' ' || monitor_count || ' monitors)'
    END) as second_most_polluted
FROM ranked_regions
GROUP BY parameter_name
ORDER BY parameter_name;

-- How this works:
-- 1. Creates regional averages for key pollutants with data quality filters
-- 2. Ranks regions from cleanest to dirtiest for each pollutant
-- 3. Pivots results to show best/worst regions side by side
-- 4. Includes monitoring counts for context on data reliability

-- Assumptions & Limitations:
-- 1. Requires 3+ monitors per region for reliability
-- 2. Uses arithmetic mean which may not capture peaks/variations
-- 3. Limited to regions with CBSA designation (metro areas)
-- 4. 75% observation completeness threshold is arbitrary
-- 5. Most recent complete year used - check currency

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include population exposure weights
-- 3. Add seasonal variations analysis
-- 4. Correlate with health outcomes
-- 5. Add economic indicators
-- 6. Compare to EPA standards
-- 7. Add geographic clustering analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:01:11.870931
    - Additional Notes: Query provides a balanced view of air quality across metropolitan areas by showing both best and worst performing regions for each major pollutant. Requires at least 3 monitoring stations per region and 75% data completeness for reliability. Results include monitor counts to help assess data confidence.
    
    */