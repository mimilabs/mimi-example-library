-- provider_specialization_trends.sql
--
-- Business Purpose:
-- This query analyzes the distribution and trends of healthcare provider specializations
-- to help healthcare organizations:
-- - Understand the mix of provider types in their networks
-- - Identify potential gaps in specialized care coverage
-- - Support strategic planning for provider recruitment and network development
-- - Track changes in provider specialization over time

-- Main Query
WITH provider_specialization_summary AS (
    SELECT 
        provider_type,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT state) as states_present,
        COUNT(DISTINCT city) as cities_present,
        -- Calculate most recent data point
        MAX(last_updated_on) as latest_update
    FROM mimi_ws_1.datahealthcaregov.provider_addresses
    WHERE provider_type IS NOT NULL
    GROUP BY provider_type
),
ranked_specializations AS (
    SELECT 
        provider_type,
        provider_count,
        states_present,
        cities_present,
        latest_update,
        -- Calculate percentage of total providers
        ROUND(100.0 * provider_count / SUM(provider_count) OVER(), 2) as pct_of_total
    FROM provider_specialization_summary
)
SELECT 
    provider_type,
    provider_count,
    states_present,
    cities_present,
    pct_of_total,
    latest_update
FROM ranked_specializations
ORDER BY provider_count DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates key metrics for each provider type
-- 2. Second CTE calculates the percentage distribution
-- 3. Final output shows top 20 specializations by provider count
--
-- Assumptions and Limitations:
-- - Assumes provider_type classifications are standardized and accurate
-- - Limited to top 20 specializations for readability
-- - Does not account for providers with multiple specialties
-- - Currency of data depends on last_updated_on field accuracy
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis using mimi_src_file_date
-- 2. Include state-level specialization concentration analysis
-- 3. Add provider-to-population ratios using census data
-- 4. Compare specialization mix across different geographical regions
-- 5. Analyze correlation between provider types and urban/rural settings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:04:18.278970
    - Additional Notes: Query focuses on high-level specialty distribution metrics and could benefit from additional filters for data quality (e.g., handling NULL values in provider_type). Consider adding date range parameters if analyzing trends over specific time periods.
    
    */