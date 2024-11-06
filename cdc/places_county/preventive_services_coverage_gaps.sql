-- places_county_preventive_services_disparities.sql

-- Purpose: Analyze geographic disparities in preventive healthcare services utilization 
-- across counties to identify potential access gaps and inform resource allocation decisions
--
-- Business Value:
-- 1. Helps healthcare organizations identify underserved areas for expansion
-- 2. Supports public health planning for preventive service programs
-- 3. Assists in targeting outreach and education initiatives
-- 4. Informs policy decisions around healthcare access equity

WITH preventive_services AS (
    -- Filter and aggregate key preventive service measures
    SELECT 
        state_desc,
        location_name,
        measure,
        data_value,
        total_population,
        total_pop18plus
    FROM mimi_ws_1.cdc.places_county
    WHERE year = 2021
        AND category = 'Prevention'
        AND measure IN (
            'Annual checkup',
            'Routine checkup in the past year',
            'Dental visit in the past year'
        )
        AND data_value IS NOT NULL
),

county_rankings AS (
    -- Calculate state-level rankings for each preventive service
    SELECT 
        state_desc,
        location_name,
        measure,
        data_value,
        total_population,
        total_pop18plus,
        RANK() OVER (
            PARTITION BY state_desc, measure 
            ORDER BY data_value DESC
        ) as rank_in_state
    FROM preventive_services
)

-- Final output focusing on counties with low preventive service utilization
SELECT 
    state_desc,
    location_name,
    measure,
    ROUND(data_value, 1) as utilization_rate_pct,
    total_population,
    total_pop18plus,
    rank_in_state
FROM county_rankings
WHERE rank_in_state <= 5  -- Focus on bottom 5 counties in each state
ORDER BY 
    state_desc,
    measure,
    rank_in_state;

-- How it works:
-- 1. First CTE filters for preventive service measures and relevant columns
-- 2. Second CTE calculates rankings within each state for each measure
-- 3. Final query shows bottom 5 counties for each state and measure
--
-- Assumptions and Limitations:
-- - Assumes 2021 data is most recent and complete
-- - Limited to three key preventive services
-- - Rankings may be affected by counties with missing data
-- - Population size variations between counties not weighted in rankings
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Incorporate demographic factors (age, income) for deeper analysis
-- 3. Calculate service utilization gaps based on population size
-- 4. Cross-reference with provider availability data
-- 5. Add statistical significance testing between counties
-- 6. Include cost burden analysis where available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:04:19.046743
    - Additional Notes: Query focuses on identifying counties with lowest preventive healthcare utilization rates within each state, useful for healthcare resource planning and policy decisions. Note that the results are not population-weighted and may need adjustment for counties with small populations or incomplete data coverage.
    
    */