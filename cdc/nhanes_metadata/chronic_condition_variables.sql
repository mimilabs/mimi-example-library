-- nhanes_condition_prevalence_metadata.sql
--
-- Business Purpose: 
-- Identifies variables related to common chronic conditions across NHANES surveys
-- to enable population health prevalence analysis. This helps:
-- - Population health managers assess condition monitoring capabilities
-- - Research teams identify variables for longitudinal disease studies
-- - Health systems evaluate data coverage for key conditions

-- Main Query
SELECT DISTINCT
    var_name,
    var_desc,
    data_file_name,
    begin_year,
    end_year,
    component
FROM mimi_ws_1.cdc.nhanes_metadata
WHERE 
    -- Focus on key chronic conditions
    (LOWER(var_desc) LIKE '%diabetes%'
    OR LOWER(var_desc) LIKE '%hypertension%'
    OR LOWER(var_desc) LIKE '%heart disease%'
    OR LOWER(var_desc) LIKE '%asthma%')
    
    -- Include only recent survey years
    AND begin_year >= 2015
    
    -- Exclude administrative variables
    AND NOT LOWER(var_desc) LIKE '%code%'
    AND NOT LOWER(var_desc) LIKE '%comment%'

ORDER BY 
    begin_year DESC,
    component,
    var_name;

-- How it works:
-- 1. Filters metadata for major chronic condition variables
-- 2. Focuses on recent surveys (2015+) for current relevance
-- 3. Excludes administrative fields to focus on clinical content
-- 4. Orders results chronologically and by component for easy review

-- Assumptions & Limitations:
-- - Assumes condition-related variables contain condition names in descriptions
-- - Limited to explicitly mentioned conditions in variable descriptions
-- - May miss related clinical measurements not directly mentioning conditions
-- - Text matching may include some false positives

-- Possible Extensions:
-- 1. Add additional chronic conditions (obesity, cancer, etc.)
-- 2. Include related biomarker and lab variables
-- 3. Cross-reference with actual prevalence data
-- 4. Add filters for specific data collection methods
-- 5. Group variables by condition for easier analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:52:23.865771
    - Additional Notes: The query focuses on identifying NHANES variables related to major chronic conditions from 2015 onwards. It excludes administrative codes and provides a clean view of condition-specific measurements. Consider expanding the condition list or adjusting the year range based on specific research needs.
    
    */