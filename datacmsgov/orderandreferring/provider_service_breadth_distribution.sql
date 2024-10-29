-- Medicare Provider Multi-Service Referral Pattern Analysis
--
-- Business Purpose:
-- Analyzes providers who can refer across multiple service types to:
-- - Identify key referral network nodes for care coordination
-- - Support population health management initiatives
-- - Guide value-based care partnership strategies
--
-- Created: 2024
-- Database: Databricks SQL

WITH provider_service_counts AS (
  -- Calculate number of referral services each provider is authorized for
  SELECT 
    npi,
    first_name,
    last_name,
    -- Sum boolean fields to get total services count
    (CASE WHEN partb = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN dme = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN hha = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN pmd = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN hospice = 'Y' THEN 1 ELSE 0 END) as service_count
  FROM mimi_ws_1.datacmsgov.orderandreferring
  WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
)

SELECT 
  service_count,
  COUNT(*) as provider_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM provider_service_counts
GROUP BY service_count
ORDER BY service_count DESC;

-- How the Query Works:
-- 1. Creates CTE to calculate total services each provider can refer for
-- 2. Uses most recent data snapshot via MAX(_input_file_date)
-- 3. Counts providers at each service level and calculates percentages
-- 4. Results show distribution of providers by breadth of referral capabilities

-- Assumptions & Limitations:
-- - All service authorizations are equally weighted
-- - Based on current snapshot only, no historical trending
-- - Does not account for geographic distribution
-- - Assumes 'Y' is the only positive indicator value

-- Possible Extensions:
-- 1. Add geographic analysis by joining with provider location data
-- 2. Trend analysis across multiple _input_file_dates
-- 3. Specialty-specific breakdowns of referral patterns
-- 4. Focus on specific high-value service combinations
-- 5. Network adequacy analysis for specific service types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:17:26.570370
    - Additional Notes: Query focuses on measuring the distribution of providers based on their service authorization breadth, useful for network planning and care coordination efforts. Note that percentages in results indicate provider concentration at each service level, which can help identify potential network gaps or oversaturation.
    
    */