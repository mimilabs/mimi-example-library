-- Healthcare Provider Geographic Distribution and Active Status Analysis
-- Business Purpose: Analyze the geographic distribution and active status of healthcare providers to support strategic planning, resource allocation, and market opportunity identification

WITH provider_state_summary AS (
    SELECT 
        extension_searchState AS provider_state,
        COUNT(DISTINCT id) AS total_providers,
        SUM(CASE WHEN active = 'true' THEN 1 ELSE 0 END) AS active_providers,
        ROUND(100.0 * SUM(CASE WHEN active = 'true' THEN 1 ELSE 0 END) / COUNT(DISTINCT id), 2) AS active_provider_percentage
    FROM mimi_ws_1.nppes.fhir_export
    WHERE extension_searchState IS NOT NULL
    GROUP BY extension_searchState
),
provider_state_rankings AS (
    SELECT 
        provider_state,
        total_providers,
        active_providers,
        active_provider_percentage,
        RANK() OVER (ORDER BY total_providers DESC) AS total_providers_rank,
        RANK() OVER (ORDER BY active_providers DESC) AS active_providers_rank
    FROM provider_state_summary
)

SELECT 
    provider_state,
    total_providers,
    active_providers,
    active_provider_percentage,
    total_providers_rank,
    active_providers_rank
FROM provider_state_rankings
WHERE total_providers > 100
ORDER BY total_providers DESC
LIMIT 25;

-- Query Mechanics:
-- 1. Aggregates provider data by state
-- 2. Calculates total and active provider counts
-- 3. Computes percentage of active providers
-- 4. Ranks states by total and active provider numbers
-- 5. Filters for states with more than 100 providers
-- 6. Limits output to top 25 states

-- Assumptions and Limitations:
-- - Uses 'true' as the active status indicator
-- - Excludes states with less than 100 providers
-- - Snapshot represents a specific point in time
-- - Does not account for provider specialties or recent changes

-- Potential Query Extensions:
-- 1. Add provider specialty breakdown
-- 2. Analyze trends over multiple time periods
-- 3. Integrate with demographic or healthcare access data
-- 4. Compare active vs. inactive provider ratios

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:07:41.043110
    - Additional Notes: Provides state-level analysis of healthcare provider counts, focusing on active vs. total providers. Useful for understanding geographic healthcare workforce distribution.
    
    */