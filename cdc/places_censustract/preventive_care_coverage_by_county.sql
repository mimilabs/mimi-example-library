-- Title: Healthcare Access and Preventive Services Coverage Analysis
--
-- Business Purpose:
-- This query analyzes access to preventative healthcare services across census tracts
-- to identify underserved areas and disparities in healthcare utilization.
-- The insights can help healthcare organizations and policymakers:
-- 1. Target expansion of healthcare facilities
-- 2. Design outreach programs for preventive care
-- 3. Allocate resources to improve healthcare access
--

WITH preventive_measures AS (
    -- Filter to focus on key preventive healthcare measures
    SELECT 
        state_desc,
        county_name,
        location_name,
        measure,
        data_value,
        total_population,
        total_pop18plus
    FROM mimi_ws_1.cdc.places_censustract
    WHERE category = 'Prevention'
    AND year = 2021
    AND measure IN (
        'Cervical cancer screening',
        'Colorectal cancer screening',
        'Core preventive services among older adults',
        'Dental visits'
    )
),

tract_summary AS (
    -- Calculate average preventive care coverage by tract
    SELECT
        state_desc,
        county_name,
        location_name,
        ROUND(AVG(data_value), 1) as avg_preventive_coverage,
        MAX(total_population) as tract_population,
        MAX(total_pop18plus) as adult_population
    FROM preventive_measures
    GROUP BY 
        state_desc,
        county_name,
        location_name
)

-- Identify areas with low preventive care coverage
SELECT 
    state_desc,
    county_name,
    COUNT(location_name) as num_tracts,
    ROUND(AVG(avg_preventive_coverage), 1) as county_avg_coverage,
    SUM(tract_population) as total_county_pop,
    COUNT(CASE WHEN avg_preventive_coverage < 50 THEN location_name END) as low_coverage_tracts,
    ROUND(COUNT(CASE WHEN avg_preventive_coverage < 50 THEN location_name END) * 100.0 / 
          COUNT(location_name), 1) as pct_low_coverage_tracts
FROM tract_summary
GROUP BY 
    state_desc,
    county_name
HAVING COUNT(location_name) >= 5  -- Focus on counties with sufficient data
ORDER BY pct_low_coverage_tracts DESC
LIMIT 20;

-- Query Operation:
-- 1. Filters preventive healthcare measures from the PLACES dataset
-- 2. Calculates average preventive care coverage at the census tract level
-- 3. Aggregates to county level to identify areas with access challenges
-- 4. Highlights counties with high proportions of underserved tracts
--
-- Assumptions and Limitations:
-- - Uses 2021 data only
-- - Focuses on 4 key preventive measures
-- - Defines low coverage as <50% utilization
-- - Requires at least 5 tracts per county for meaningful analysis
--
-- Possible Extensions:
-- 1. Add temporal analysis to track changes over time
-- 2. Correlate with demographic and socioeconomic factors
-- 3. Include geographic clustering analysis
-- 4. Expand to include additional preventive measures
-- 5. Add distance analysis to nearest healthcare facilities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:44:45.058851
    - Additional Notes: This query provides county-level insights into preventive healthcare access disparities by analyzing census tract data. It identifies counties with significant gaps in preventive care coverage, which can be valuable for healthcare resource allocation and policy planning. Note that the 50% threshold for low coverage is a configurable assumption and should be adjusted based on specific program goals or regional benchmarks.
    
    */