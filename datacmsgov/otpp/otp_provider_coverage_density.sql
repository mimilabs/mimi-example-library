-- Provider Availability and Coverage Analysis for Opioid Treatment Programs
--
-- Business Purpose:
-- - Identify potential gaps in OTP provider coverage by analyzing provider density
-- - Support strategic planning for new provider recruitment
-- - Enable patient access assessment based on provider operating status
-- - Guide resource allocation for opioid treatment services
--
-- Created Date: 2024-02-13

WITH current_providers AS (
    -- Get the most recent snapshot of providers
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY npi ORDER BY _input_file_date DESC) as rn
    FROM mimi_ws_1.datacmsgov.otpp
    WHERE npi IS NOT NULL
),

provider_metrics AS (
    -- Calculate key provider metrics and clean data
    SELECT 
        city,
        state,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT zip) as zip_codes_served,
        ROUND(COUNT(DISTINCT npi)::FLOAT / COUNT(DISTINCT zip), 2) as providers_per_zip
    FROM current_providers 
    WHERE rn = 1
      AND state IS NOT NULL
    GROUP BY city, state
)

SELECT 
    state,
    city,
    provider_count,
    zip_codes_served,
    providers_per_zip,
    -- Flag areas that might need attention
    CASE 
        WHEN providers_per_zip < 1 THEN 'Low Coverage'
        WHEN providers_per_zip >= 1 AND providers_per_zip < 2 THEN 'Moderate Coverage'
        ELSE 'Good Coverage'
    END as coverage_status
FROM provider_metrics
WHERE provider_count > 0
ORDER BY state, provider_count DESC;

-- How this query works:
-- 1. First CTE gets the most recent data for each provider using window functions
-- 2. Second CTE calculates provider density metrics at the city level
-- 3. Main query adds coverage status indicators and formats final output
--
-- Assumptions and Limitations:
-- - Assumes current provider status based on most recent _input_file_date
-- - Does not account for provider capacity or patient volume
-- - Coverage assessment is simplified and may need refinement based on local factors
-- - ZIP code based analysis may not perfectly reflect actual service areas
--
-- Possible Extensions:
-- 1. Add population data to calculate providers per capita
-- 2. Include distance analysis between providers
-- 3. Incorporate historical trend analysis for provider stability
-- 4. Add demographic data to assess coverage relative to need
-- 5. Include provider specialization or service type analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:30:34.414526
    - Additional Notes: Query focuses on provider density and coverage gaps at city/state level. Coverage status thresholds (Low/Moderate/Good) are arbitrary and should be adjusted based on regional healthcare standards and population needs. ZIP code based analysis may not reflect actual service coverage areas accurately.
    
    */