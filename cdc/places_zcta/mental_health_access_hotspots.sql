-- Title: Mental Health and Access to Care Geographic Analysis
-- Business Purpose: Analyze the geographic distribution of mental health challenges 
-- and healthcare access barriers to help healthcare organizations identify high-need
-- areas for expanding mental health services and improving care accessibility.

WITH mental_health_data AS (
    -- Get mental health prevalence and access measures by ZCTA
    SELECT 
        location_name as zcta,
        measure,
        data_value,
        total_population,
        total_pop18plus,
        geolocation,
        CAST(REGEXP_EXTRACT(geolocation, 'Point\\((.*?) (.*?)\\)', 2) AS DOUBLE) as latitude,
        CAST(REGEXP_EXTRACT(geolocation, 'Point\\((.*?) (.*?)\\)', 1) AS DOUBLE) as longitude
    FROM mimi_ws_1.cdc.places_zcta
    WHERE year = 2023
    AND measure IN (
        'Mental health not good for >=14 days among adults aged >=18 years',
        'Depression among adults aged >=18 years',
        'Taking medicine for mental health among adults aged >=18 years',
        'Cost prevented medical care among adults aged 18-64 years'
    )
),

summary_stats AS (
    -- Calculate key statistics for each ZCTA
    SELECT 
        zcta,
        total_population,
        total_pop18plus,
        latitude,
        longitude,
        MAX(CASE WHEN measure LIKE '%Mental health not good%' THEN data_value END) as poor_mental_health_pct,
        MAX(CASE WHEN measure LIKE '%Depression%' THEN data_value END) as depression_pct,
        MAX(CASE WHEN measure LIKE '%Taking medicine%' THEN data_value END) as mental_health_meds_pct,
        MAX(CASE WHEN measure LIKE '%Cost prevented%' THEN data_value END) as cost_barrier_pct
    FROM mental_health_data
    GROUP BY zcta, total_population, total_pop18plus, latitude, longitude
)

-- Generate final analysis with combined metrics
SELECT 
    zcta,
    total_population,
    total_pop18plus,
    ROUND(poor_mental_health_pct, 1) as poor_mental_health_pct,
    ROUND(depression_pct, 1) as depression_pct,
    ROUND(mental_health_meds_pct, 1) as mental_health_meds_pct,
    ROUND(cost_barrier_pct, 1) as cost_barrier_pct,
    ROUND((poor_mental_health_pct + depression_pct + cost_barrier_pct)/3, 1) as composite_need_score,
    latitude,
    longitude
FROM summary_stats
WHERE total_population > 1000
ORDER BY (poor_mental_health_pct + depression_pct + cost_barrier_pct)/3 DESC
LIMIT 100;

-- How this query works:
-- 1. Extracts mental health and access measures from the PLACES dataset
-- 2. Parses geographic coordinates from the geolocation field
-- 3. Calculates key mental health statistics per ZCTA
-- 4. Creates a composite need score based on mental health and access metrics
-- 5. Filters for populated areas and ranks by highest need

-- Assumptions and limitations:
-- - Uses 2023 data only
-- - Limited to ZCTAs with population > 1000
-- - Assumes equal weighting in composite score calculation
-- - Does not account for state-level variations in healthcare systems
-- - Geographic coordinates are approximate ZCTA centroids

-- Possible extensions:
-- 1. Add demographic factors (age, income) for more detailed analysis
-- 2. Include temporal trends by comparing multiple years
-- 3. Calculate distance to nearest mental health facilities
-- 4. Incorporate state-level mental health resources data
-- 5. Add statistical clustering analysis to identify hot spots
-- 6. Compare urban vs rural areas using population density

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:48:18.234014
    - Additional Notes: Query identifies geographic areas with high mental health needs by combining multiple indicators (poor mental health days, depression rates, and cost barriers to care) into a composite score. The analysis is particularly useful for healthcare resource planning and mental health service expansion initiatives. Note that the composite score methodology could be adjusted based on specific organizational priorities.
    
    */