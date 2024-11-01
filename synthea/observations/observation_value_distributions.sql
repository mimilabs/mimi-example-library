-- observation_value_ranges_by_type.sql
--
-- Business Purpose:
-- - Analyze the distribution and range of observation values by type to establish normal ranges
-- - Support clinical decision making by identifying outlier values
-- - Enable quality control of data collection and recording processes
-- - Provide baseline metrics for population health management

WITH observation_stats AS (
    -- Calculate key statistics for each observation type
    SELECT 
        description,
        type,
        units,
        COUNT(*) as measurement_count,
        MIN(CAST(value AS FLOAT)) as min_value,
        MAX(CAST(value AS FLOAT)) as max_value,
        AVG(CAST(value AS FLOAT)) as avg_value,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(value AS FLOAT)) as median_value,
        COUNT(DISTINCT patient) as unique_patients
    FROM mimi_ws_1.synthea.observations
    WHERE 
        -- Focus on numeric values only
        TRY_CAST(value AS FLOAT) IS NOT NULL
        -- Exclude potentially problematic values
        AND value NOT LIKE '%[^0-9.]%'
        AND units IS NOT NULL
    GROUP BY 
        description,
        type,
        units
    HAVING COUNT(*) >= 100  -- Filter for frequently occurring observations
)

SELECT 
    description,
    type,
    units,
    measurement_count,
    ROUND(min_value, 2) as min_value,
    ROUND(max_value, 2) as max_value,
    ROUND(avg_value, 2) as avg_value,
    ROUND(median_value, 2) as median_value,
    unique_patients,
    -- Calculate measurement frequency per patient
    ROUND(CAST(measurement_count AS FLOAT) / unique_patients, 2) as avg_measurements_per_patient
FROM observation_stats
ORDER BY measurement_count DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to calculate statistics for each observation type
-- 2. Filters for numeric values only and excludes problematic data
-- 3. Calculates min, max, average, and median values
-- 4. Computes measurement frequency per patient
-- 5. Returns top 20 most frequent observations

-- Assumptions and limitations:
-- - Assumes values can be cast to float for numerical analysis
-- - Limited to observations with at least 100 measurements
-- - Focuses only on numeric observations with valid units
-- - May not capture all clinically relevant patterns
-- - Does not account for temporal trends

-- Possible extensions:
-- 1. Add time-based trending analysis
-- 2. Include age/gender stratification
-- 3. Add statistical outlier detection
-- 4. Compare against clinical reference ranges
-- 5. Add correlation analysis between different observation types
-- 6. Include seasonal variation analysis
-- 7. Add patient demographic breakdowns
-- 8. Implement abnormal value flagging

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:29:35.385585
    - Additional Notes: Query provides statistical distributions of observation values but requires numeric data validation and sufficient sample sizes (n>=100) for meaningful results. Best used for population-level health metrics analysis rather than individual patient assessments.
    
    */