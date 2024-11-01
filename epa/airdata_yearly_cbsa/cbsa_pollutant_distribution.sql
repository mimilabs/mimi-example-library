-- Title: CBSA Dominant Air Pollutant Analysis and Seasonal Impact

-- Business Purpose:
-- - Understand which pollutants are most prevalent in different metropolitan areas
-- - Support seasonal air quality management and resource allocation
-- - Guide targeted emission reduction strategies
-- - Inform public awareness campaigns about specific pollutant risks

WITH seasonal_pollutants AS (
    -- Calculate the percentage contribution of each pollutant type by CBSA and year
    SELECT 
        cbsa,
        year,
        days_with_aqi,
        ROUND(days_ozone * 100.0 / days_with_aqi, 1) as pct_ozone_days,
        ROUND(days_pm25 * 100.0 / days_with_aqi, 1) as pct_pm25_days,
        ROUND(days_pm10 * 100.0 / days_with_aqi, 1) as pct_pm10_days,
        ROUND(days_no2 * 100.0 / days_with_aqi, 1) as pct_no2_days,
        ROUND(days_co * 100.0 / days_with_aqi, 1) as pct_co_days,
        -- Determine dominant pollutant
        CASE 
            WHEN GREATEST(days_ozone, days_pm25, days_pm10, days_no2, days_co) = days_ozone THEN 'Ozone'
            WHEN GREATEST(days_ozone, days_pm25, days_pm10, days_no2, days_co) = days_pm25 THEN 'PM2.5'
            WHEN GREATEST(days_ozone, days_pm25, days_pm10, days_no2, days_co) = days_pm10 THEN 'PM10'
            WHEN GREATEST(days_ozone, days_pm25, days_pm10, days_no2, days_co) = days_no2 THEN 'NO2'
            WHEN GREATEST(days_ozone, days_pm25, days_pm10, days_no2, days_co) = days_co THEN 'CO'
        END as dominant_pollutant
    FROM mimi_ws_1.epa.airdata_yearly_cbsa
    WHERE year >= 2018  -- Focus on recent years
)

SELECT 
    cbsa,
    year,
    days_with_aqi as total_days_measured,
    dominant_pollutant,
    pct_ozone_days,
    pct_pm25_days,
    pct_pm10_days,
    pct_no2_days,
    pct_co_days
FROM seasonal_pollutants
WHERE days_with_aqi >= 300  -- Ensure sufficient data coverage
ORDER BY year DESC, days_with_aqi DESC, cbsa
LIMIT 100;

-- How it works:
-- 1. Creates a CTE to calculate percentage contribution of each pollutant
-- 2. Determines the dominant pollutant using CASE statement
-- 3. Filters for recent years and adequate data coverage
-- 4. Returns top 100 results sorted by year and measurement coverage

-- Assumptions and limitations:
-- - Assumes data completeness (minimum 300 days of measurements)
-- - Limited to last 5 years for current relevance
-- - Does not account for severity/concentration of pollutants
-- - Percentages might not sum to 100% due to rounding

-- Possible extensions:
-- 1. Add geographic grouping to identify regional patterns
-- 2. Include year-over-year trend analysis
-- 3. Correlate with weather data for deeper insights
-- 4. Add population exposure metrics
-- 5. Include economic impact analysis by pollutant type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:39:10.014153
    - Additional Notes: Query focuses on pollutant composition patterns across CBSAs with high data quality (300+ days). Best used for metropolitan areas with consistent monitoring data. Results limited to top 100 entries by default and requires recent data (2018+) to be present in the source table.
    
    */