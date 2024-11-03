-- Out-of-State Practice Analysis
-- Business Purpose: Identify healthcare providers operating across multiple states to:
-- - Understand multi-state practice patterns
-- - Support licensing and compliance monitoring
-- - Identify providers with broader geographic reach
-- - Inform network adequacy assessments for payers

WITH provider_state_counts AS (
    -- Count distinct states per provider, excluding null states
    SELECT 
        npi,
        mimi_src_file_date,
        COUNT(DISTINCT provider_secondary_practice_location_address__state_name) as state_count,
        COLLECT_SET(provider_secondary_practice_location_address__state_name) as state_list
    FROM mimi_ws_1.nppes.pl
    WHERE provider_secondary_practice_location_address__state_name IS NOT NULL
    GROUP BY npi, mimi_src_file_date
),

multi_state_providers AS (
    -- Filter for providers practicing in multiple states
    SELECT 
        npi,
        mimi_src_file_date,
        state_count,
        state_list
    FROM provider_state_counts
    WHERE state_count > 1
)

SELECT 
    mimi_src_file_date,
    COUNT(DISTINCT npi) as multi_state_providers,
    ROUND(AVG(state_count), 2) as avg_states_per_provider,
    MAX(state_count) as max_states_per_provider,
    -- Calculate distribution of providers by state count
    COUNT(CASE WHEN state_count = 2 THEN 1 END) as two_state_providers,
    COUNT(CASE WHEN state_count = 3 THEN 1 END) as three_state_providers,
    COUNT(CASE WHEN state_count > 3 THEN 1 END) as four_plus_state_providers
FROM multi_state_providers
GROUP BY mimi_src_file_date
ORDER BY mimi_src_file_date;

-- How this works:
-- 1. First CTE counts distinct states per provider for each snapshot date
-- 2. Second CTE filters for providers with multiple states
-- 3. Main query summarizes multi-state practice patterns over time
--
-- Assumptions:
-- - State names are standardized in the source data
-- - NULL state values are excluded as they may indicate incomplete data
-- - Each mimi_src_file_date represents a complete snapshot
--
-- Limitations:
-- - Does not account for temporary/seasonal practices
-- - Cannot distinguish between full practices vs. occasional consulting
-- - State borders may artificially split natural practice areas
--
-- Possible Extensions:
-- 1. Join with provider type/specialty data to analyze by specialty
-- 2. Add geographic region analysis (e.g., Northeast, Southeast)
-- 3. Include year-over-year growth rates
-- 4. Add distance calculations between practice locations
-- 5. Correlate with population density or healthcare demand metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:38:11.587015
    - Additional Notes: The query uses COLLECT_SET to gather state lists and tracks provider distribution across state boundaries over time. Performance may be impacted with very large datasets due to the grouping operations. Consider adding date filters if analyzing specific time periods.
    
    */