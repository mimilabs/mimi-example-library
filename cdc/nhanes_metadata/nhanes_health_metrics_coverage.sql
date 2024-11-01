-- nhanes_health_indicator_analysis.sql
-- Business Purpose: Identifies key health indicator variables across NHANES survey years
-- to support population health analysis and trend monitoring. This helps:
-- - Healthcare organizations identify relevant metrics for population health management
-- - Researchers track availability of critical health measurements over time
-- - Program directors understand data coverage for health screening initiatives

SELECT 
    var_name,
    var_desc,
    data_file_name,
    begin_year,
    end_year,
    component,
    -- Count number of years this variable was collected
    (end_year - begin_year + 1) as collection_duration

FROM mimi_ws_1.cdc.nhanes_metadata
WHERE 
    -- Focus on key health indicator variables
    (LOWER(var_desc) LIKE '%blood pressure%'
    OR LOWER(var_desc) LIKE '%cholesterol%'
    OR LOWER(var_desc) LIKE '%glucose%'
    OR LOWER(var_desc) LIKE '%bmi%'
    OR LOWER(var_desc) LIKE '%weight%')
    
    -- Ensure we have recent data
    AND end_year >= 2015

ORDER BY
    collection_duration DESC,
    begin_year DESC,
    var_name;

-- How this works:
-- 1. Filters metadata for common health indicator variables using pattern matching
-- 2. Calculates how long each variable has been collected
-- 3. Prioritizes variables with longer collection history and recent data
-- 4. Orders results to highlight most consistently tracked metrics

-- Assumptions & Limitations:
-- - Assumes health indicators are identified by common terms in var_desc
-- - Limited to explicitly mentioned health metrics
-- - Recent data threshold set to 2015 may need adjustment
-- - Does not account for changes in measurement methods over time

-- Possible Extensions:
-- 1. Add category grouping to classify variables by health domain
-- 2. Include frequency of measurement from data_file_desc
-- 3. Cross-reference with specific disease monitoring requirements
-- 4. Expand to include social determinants of health variables
-- 5. Add filters for specific population segments or age groups

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:35:38.907621
    - Additional Notes: Query targets key health indicators like blood pressure, cholesterol, glucose, and BMI tracking across NHANES surveys. Best used for identifying longitudinal health measurement patterns and data availability for population health research. Consider adjusting the end_year filter (currently 2015) based on analysis needs.
    
    */