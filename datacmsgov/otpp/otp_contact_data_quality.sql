-- OTP Provider Address Quality Analysis
-- 
-- Business Purpose:
-- - Assess data quality and completeness of provider contact information
-- - Support provider directory accuracy and maintenance
-- - Enable effective patient-provider communication
-- - Identify providers needing contact info updates

WITH address_metrics AS (
  SELECT 
    _input_file_date,
    -- Count total providers
    COUNT(*) as total_providers,
    
    -- Address completeness metrics
    SUM(CASE WHEN address_line_1 IS NULL OR TRIM(address_line_1) = '' THEN 1 ELSE 0 END) as missing_address_1,
    SUM(CASE WHEN city IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END) as missing_city,
    SUM(CASE WHEN state IS NULL OR TRIM(state) = '' THEN 1 ELSE 0 END) as missing_state,
    SUM(CASE WHEN zip IS NULL OR TRIM(zip) = '' THEN 1 ELSE 0 END) as missing_zip,
    
    -- Phone completeness
    SUM(CASE WHEN phone IS NULL OR TRIM(phone) = '' THEN 1 ELSE 0 END) as missing_phone,
    
    -- Providers with complete core contact info
    SUM(CASE 
      WHEN address_line_1 IS NOT NULL 
        AND city IS NOT NULL 
        AND state IS NOT NULL 
        AND zip IS NOT NULL 
        AND phone IS NOT NULL 
      THEN 1 ELSE 0 END) as complete_contact_info
  FROM mimi_ws_1.datacmsgov.otpp
  GROUP BY _input_file_date
)

SELECT
  _input_file_date as report_date,
  total_providers,
  -- Calculate percentages of missing data
  ROUND((missing_address_1 * 100.0 / total_providers), 2) as pct_missing_address,
  ROUND((missing_city * 100.0 / total_providers), 2) as pct_missing_city,
  ROUND((missing_state * 100.0 / total_providers), 2) as pct_missing_state,
  ROUND((missing_zip * 100.0 / total_providers), 2) as pct_missing_zip,
  ROUND((missing_phone * 100.0 / total_providers), 2) as pct_missing_phone,
  -- Calculate percentage of providers with complete info
  ROUND((complete_contact_info * 100.0 / total_providers), 2) as pct_complete_contact
FROM address_metrics
ORDER BY _input_file_date DESC;

-- How this query works:
-- 1. Creates a CTE to calculate raw counts of missing data elements
-- 2. Calculates percentages in the main query
-- 3. Orders results by date to show most recent metrics first

-- Assumptions and Limitations:
-- - Assumes NULL or empty string indicates missing data
-- - Does not validate format/accuracy of provided data
-- - Does not check for data consistency across weeks
-- - Simple presence/absence check rather than detailed validation

-- Possible Extensions:
-- 1. Add phone number format validation
-- 2. Add ZIP code format validation
-- 3. Add trending analysis over time
-- 4. Include address standardization metrics
-- 5. Add geocoding success rate metrics
-- 6. Compare data quality across states/regions
-- 7. Add provider name standardization analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:01:36.692195
    - Additional Notes: Query focuses on completeness metrics for critical provider contact information, generating percentages of missing data elements. Results are grouped by input file date to track quality trends over time. Query could be resource-intensive on very large datasets due to multiple COUNT operations.
    
    */