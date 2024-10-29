-- Provider Enrollment Quality Review and Validation
-- 
-- Business Purpose:
-- Identifies potential data quality issues and validates provider enrollment application
-- patterns to help optimize the Medicare provider enrollment process and improve
-- administrative efficiency. This analysis helps CMS contractors ensure data quality
-- and identify unusual patterns requiring additional review.

WITH provider_name_patterns AS (
  SELECT 
    -- Check for common data quality patterns
    COUNT(*) as total_applications,
    COUNT(CASE WHEN last_name IS NULL OR first_name IS NULL THEN 1 END) as missing_names,
    COUNT(CASE WHEN LENGTH(last_name) <= 2 THEN 1 END) as short_names,
    COUNT(CASE WHEN last_name LIKE '% %' THEN 1 END) as multi_word_lastnames,
    COUNT(DISTINCT npi) as unique_npis,
    COUNT(*) - COUNT(DISTINCT npi) as duplicate_npis,
    MIN(_input_file_date) as earliest_date,
    MAX(_input_file_date) as latest_date
  FROM mimi_ws_1.datacmsgov.pendingilt
),
npi_validation AS (
  SELECT
    -- Validate NPI format and patterns
    COUNT(CASE WHEN LENGTH(npi) != 10 THEN 1 END) as invalid_npi_length,
    COUNT(CASE WHEN npi RLIKE '^[0-9]+$' THEN NULL ELSE 1 END) as non_numeric_npis
  FROM mimi_ws_1.datacmsgov.pendingilt
)
SELECT 
  p.*,
  n.invalid_npi_length,
  n.non_numeric_npis,
  -- Calculate key metrics
  ROUND(p.missing_names * 100.0 / p.total_applications, 2) as pct_missing_names,
  ROUND(p.duplicate_npis * 100.0 / p.total_applications, 2) as pct_duplicate_npis,
  DATEDIFF(p.latest_date, p.earliest_date) as date_range_days
FROM provider_name_patterns p
CROSS JOIN npi_validation n;

-- How it works:
-- 1. Creates a CTE to analyze provider name patterns and identify potential data quality issues
-- 2. Creates a second CTE to validate NPI format and patterns
-- 3. Combines results to provide a comprehensive data quality assessment
-- 4. Calculates key metrics as percentages for easier interpretation

-- Assumptions and Limitations:
-- - Assumes NPI should be 10 digits
-- - Assumes last names should be more than 2 characters
-- - Does not validate against external NPI databases
-- - Limited to basic format validation without semantic checks

-- Possible Extensions:
-- 1. Add provider name standardization checks (e.g., common misspellings)
-- 2. Compare against historical patterns to identify unusual changes
-- 3. Add geographic analysis of data quality patterns
-- 4. Include trending analysis across multiple _input_file_dates
-- 5. Add validation against external provider directories or NPI databases

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:36:56.775442
    - Additional Notes: The query provides a comprehensive data quality assessment framework for Medicare provider enrollment applications, focusing on name patterns and NPI validation. The results can be used to identify systemic issues in application data and prioritize quality improvement efforts. Best used as part of regular data quality monitoring routines.
    
    */