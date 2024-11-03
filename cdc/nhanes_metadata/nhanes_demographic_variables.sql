-- nhanes_demographic_analysis.sql 
--
-- Business Purpose:
-- Analyzes demographic-related variables in NHANES metadata to understand:
-- - Available demographic variables for population segmentation
-- - Coverage of key social determinants of health (SDOH) factors
-- - Demographic data consistency across survey years
-- This enables:
-- - Population health stratification
-- - Health equity analysis
-- - Longitudinal demographic trend studies

SELECT 
  -- Get core demographic variable details
  var_name,
  var_desc,
  data_file_name,
  -- Format year range for readability
  concat(begin_year, '-', end_year) as survey_period,
  component
FROM mimi_ws_1.cdc.nhanes_metadata
WHERE
  -- Focus on demographic and SDOH variables
  (lower(data_file_desc) LIKE '%demographic%'
   OR lower(var_desc) LIKE '%age%' 
   OR lower(var_desc) LIKE '%gender%'
   OR lower(var_desc) LIKE '%race%'
   OR lower(var_desc) LIKE '%education%'
   OR lower(var_desc) LIKE '%income%'
   OR lower(var_desc) LIKE '%occupation%'
   OR lower(var_desc) LIKE '%insurance%')
  -- Exclude administrative/technical variables  
  AND lower(var_desc) NOT LIKE '%file%'
  AND lower(var_desc) NOT LIKE '%code%'
ORDER BY
  begin_year DESC,
  data_file_name,
  var_name;

-- How this query works:
-- 1. Filters metadata for demographic/SDOH variables using keyword matching
-- 2. Excludes technical variables to focus on analytically relevant fields
-- 3. Orders results chronologically and by data file for easy reference
--
-- Assumptions:
-- - Demographic variables are consistently named/described across survey years
-- - Key SDOH concepts can be identified through text pattern matching
-- - Administrative variables can be excluded via simple text patterns
--
-- Limitations:
-- - May miss relevant variables if descriptions use unexpected terminology
-- - Text matching approach could include some false positives
-- - Does not account for changes in variable definitions over time
--
-- Possible Extensions:
-- 1. Add variable counts by survey year to track demographic coverage changes
-- 2. Include validation of demographic variable consistency across years
-- 3. Cross-reference with codebooks to add variable value ranges/categories
-- 4. Group variables into demographic domains (identity, socioeconomic, etc.)
-- 5. Add filters for specific population segments or SDOH domains

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:26:15.016236
    - Additional Notes: Query focuses on identifying demographic and social determinants of health variables across NHANES surveys. The text pattern matching approach may need adjustment based on specific research needs and variable naming conventions in the metadata. Consider adding explicit component filtering if demographic variables are known to be in specific survey components.
    
    */