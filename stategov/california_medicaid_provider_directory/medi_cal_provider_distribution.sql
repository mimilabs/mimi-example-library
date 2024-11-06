
-- California Medicaid Provider Directory: Geographic Distribution Analysis
-- Business Purpose: Analyze Medi-Cal Fee-for-Service provider distribution to identify healthcare access patterns

WITH provider_summary AS (
    -- Aggregate provider counts by county, specialty, and provider type
    SELECT 
        county_name,
        fi_provider_type,
        fi_provider_specialty,
        COUNT(DISTINCT provider_number) AS total_providers,
        COUNT(DISTINCT CASE WHEN out_of_state_indicator = 'N' THEN provider_number END) AS in_state_providers,
        COUNT(DISTINCT CASE WHEN out_of_state_indicator = 'Y' THEN provider_number END) AS out_of_state_providers
    FROM mimi_ws_1.stategov.california_medicaid_provider_directory
    WHERE enroll_status_eff_dt IS NOT NULL
    GROUP BY county_name, fi_provider_type, fi_provider_specialty
),

county_population_ranking AS (
    -- Rank counties by provider density
    SELECT 
        county_name,
        total_providers,
        DENSE_RANK() OVER (ORDER BY total_providers DESC) AS provider_density_rank,
        ROUND(total_providers / (SELECT SUM(total_providers) FROM provider_summary) * 100, 2) AS percent_of_total_providers
    FROM (
        SELECT 
            county_name, 
            SUM(total_providers) AS total_providers
        FROM provider_summary
        GROUP BY county_name
    )
)

-- Main query: Comprehensive provider distribution insights
SELECT 
    ps.county_name,
    ps.fi_provider_type,
    ps.fi_provider_specialty,
    ps.total_providers,
    ps.in_state_providers,
    ps.out_of_state_providers,
    cpr.provider_density_rank,
    cpr.percent_of_total_providers
FROM provider_summary ps
JOIN county_population_ranking cpr ON ps.county_name = cpr.county_name
WHERE ps.total_providers > 0
ORDER BY cpr.provider_density_rank, ps.total_providers DESC
LIMIT 100;

-- Query Mechanics:
-- 1. Aggregates provider data by county, type, and specialty
-- 2. Calculates in-state vs out-of-state provider counts
-- 3. Ranks counties by provider density
-- 4. Provides percentage of total providers

-- Assumptions:
-- - Assumes current enrollment data is representative
-- - Focuses on enrolled Fee-for-Service providers
-- - Excludes providers with NULL enrollment status

-- Potential Extensions:
-- 1. Add geospatial analysis using latitude/longitude
-- 2. Trend analysis by comparing across multiple mimi_src_file_dates
-- 3. Integrate with beneficiary population data for access ratio
-- 4. Create provider specialty heat maps


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:55:35.023827
    - Additional Notes: Analysis provides county-level insights into Medi-Cal Fee-for-Service provider distribution, with ranking and percentage calculations. Requires careful interpretation given snapshot nature of the data.
    
    */