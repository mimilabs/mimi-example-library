-- NWSS Mpox Geographic Coverage and Population Analysis
-- Business Purpose: Evaluate the geographic reach and population coverage of the wastewater surveillance 
-- program to assess monitoring capabilities and identify potential gaps in surveillance coverage.

WITH latest_data AS (
    -- Get the most recent data for each sewershed
    SELECT 
        sewershed,
        fullgeoname,
        population_served,
        latitude,
        longitude,
        source,
        MAX(sample_collect_date) as latest_sample_date
    FROM mimi_ws_1.cdc.nwss_mpox
    WHERE population_served IS NOT NULL
    GROUP BY sewershed, fullgeoname, population_served, latitude, longitude, source
),

coverage_metrics AS (
    -- Calculate coverage statistics
    SELECT 
        source as data_source,
        COUNT(DISTINCT sewershed) as total_sites,
        COUNT(DISTINCT fullgeoname) as states_covered,
        SUM(population_served) as total_population_covered,
        ROUND(AVG(population_served)) as avg_population_per_site
    FROM latest_data
    GROUP BY source
)

SELECT 
    data_source,
    total_sites,
    states_covered,
    FORMAT_NUMBER(total_population_covered, 0) as total_population_covered,
    FORMAT_NUMBER(avg_population_per_site, 0) as avg_population_per_site,
    ROUND(total_population_covered / 331900000.0 * 100, 1) as pct_us_population_covered
FROM coverage_metrics
ORDER BY total_population_covered DESC;

-- How this query works:
-- 1. First CTE gets the most recent sample date for each unique sewershed
-- 2. Second CTE calculates key coverage metrics by data source
-- 3. Final SELECT formats the results and calculates percentage of US population covered
-- (using approximate 2021 US population of 331.9M)

-- Assumptions and Limitations:
-- - Assumes population_served values are accurate and current
-- - Assumes no overlap in populations between different sewersheds
-- - Limited to sewersheds with non-null population data
-- - Uses simplified US total population estimate

-- Possible Extensions:
-- 1. Add geographic distribution analysis by state/region
-- 2. Include time-based metrics like sampling frequency
-- 3. Compare coverage between urban and rural areas
-- 4. Add cost-effectiveness metrics if cost data available
-- 5. Analyze gaps in coverage based on demographic factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:11:29.240377
    - Additional Notes: Query provides strategic insights into surveillance system coverage across different data providers, with population reach calculations. Useful for program managers and public health officials to assess monitoring capabilities and identify coverage gaps. Note that population coverage percentages are approximate due to simplified total US population estimate.
    
    */