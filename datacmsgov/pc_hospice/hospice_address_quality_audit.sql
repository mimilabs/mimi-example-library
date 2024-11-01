-- Medicare Hospice Provider Address Verification and Data Quality Assessment
--
-- Business Purpose: Analyze the completeness and accuracy of Medicare hospice provider 
-- address information to:
-- - Identify providers with incomplete or potentially incorrect address data
-- - Support provider outreach and data quality improvement initiatives
-- - Ensure accurate provider directories for beneficiaries
-- - Enable reliable geographic analysis for network adequacy assessments

WITH address_quality AS (
  -- Calculate address completeness metrics per provider
  SELECT 
    organization_name,
    doing_business_as_name,
    npi,
    ccn,
    city,
    state,
    zip_code,
    -- Flag missing or incomplete address components
    CASE WHEN TRIM(address_line_1) IS NULL OR TRIM(address_line_1) = '' THEN 1 ELSE 0 END AS missing_address1,
    CASE WHEN TRIM(city) IS NULL OR TRIM(city) = '' THEN 1 ELSE 0 END AS missing_city,
    CASE WHEN TRIM(state) IS NULL OR TRIM(state) = '' THEN 1 ELSE 0 END AS missing_state,
    CASE WHEN TRIM(zip_code) IS NULL OR TRIM(zip_code) = '' THEN 1 ELSE 0 END AS missing_zip
  FROM mimi_ws_1.datacmsgov.pc_hospice
)

SELECT
  state,
  COUNT(*) as total_providers,
  SUM(missing_address1) as count_missing_address1,
  SUM(missing_city) as count_missing_city, 
  SUM(missing_state) as count_missing_state,
  SUM(missing_zip) as count_missing_zip,
  -- Calculate percentage of providers with complete addresses
  ROUND(100.0 * 
    COUNT(CASE WHEN missing_address1 = 0 AND missing_city = 0 
                AND missing_state = 0 AND missing_zip = 0 
          THEN 1 END) / COUNT(*), 2) as pct_complete_addresses,
  -- Identify providers with any missing address components
  COUNT(CASE WHEN missing_address1 = 1 OR missing_city = 1 
              OR missing_state = 1 OR missing_zip = 1 
        THEN 1 END) as providers_needing_update
FROM address_quality
GROUP BY state
ORDER BY providers_needing_update DESC;

-- How this works:
-- 1. Creates a CTE that evaluates address field completeness for each provider
-- 2. Aggregates results by state to show address quality metrics
-- 3. Calculates both counts and percentages of missing data
-- 4. Prioritizes states by number of providers needing updates

-- Assumptions and limitations:
-- - Assumes NULL or empty string indicates missing data
-- - Does not validate actual address accuracy/validity
-- - Does not check address format standardization
-- - Current state field is valid (not NULL/empty)

-- Possible extensions:
-- 1. Add validation for address format patterns
-- 2. Compare addresses against USPS database
-- 3. Analyze historical address changes over time
-- 4. Create provider-level detail report for follow-up
-- 5. Add geocoding validation checks
-- 6. Cross-reference with other CMS provider databases

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:14:10.329509
    - Additional Notes: Query focuses on address data quality monitoring and identifies gaps in provider location data. Best used for compliance reporting and data cleanup initiatives. Consider running this query periodically as part of data quality monitoring processes. Results can be used to prioritize provider outreach for address verification.
    
    */