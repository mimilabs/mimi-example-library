-- provider_service_continuity_analysis.sql

-- Business Purpose:
-- This query assesses provider service continuity and data freshness by examining
-- update patterns and identifying providers who may need directory verification.
-- Key business values:
-- - Maintain accurate provider directories for member experience
-- - Reduce compliance risks from outdated directory information
-- - Identify providers requiring outreach for information updates
-- - Support quality metrics for directory maintenance

WITH provider_update_status AS (
    -- Get most recent update for each provider
    SELECT 
        npi,
        provider_type,
        city,
        state,
        last_updated_on,
        DATEDIFF(CURRENT_DATE(), last_updated_on) as days_since_update,
        -- Flag providers needing verification (>90 days since update)
        CASE 
            WHEN DATEDIFF(CURRENT_DATE(), last_updated_on) > 90 THEN 1 
            ELSE 0 
        END as needs_verification
    FROM mimi_ws_1.datahealthcaregov.provider_addresses
    WHERE last_updated_on IS NOT NULL
),

summary_metrics AS (
    -- Calculate key metrics by provider type and location
    SELECT 
        provider_type,
        state,
        COUNT(DISTINCT npi) as provider_count,
        AVG(days_since_update) as avg_days_since_update,
        SUM(needs_verification) as providers_needing_verification,
        ROUND(SUM(needs_verification) * 100.0 / COUNT(*), 2) as pct_needs_verification
    FROM provider_update_status
    GROUP BY provider_type, state
)

-- Final output with prioritized verification needs
SELECT 
    provider_type,
    state,
    provider_count,
    avg_days_since_update,
    providers_needing_verification,
    pct_needs_verification
FROM summary_metrics
WHERE provider_count >= 10  -- Focus on provider types with meaningful presence
ORDER BY pct_needs_verification DESC, provider_count DESC
LIMIT 20;

-- How it works:
-- 1. Creates provider_update_status CTE to calculate days since last update
-- 2. Creates summary_metrics CTE to aggregate by provider type and state
-- 3. Produces final output prioritized by verification needs

-- Assumptions and Limitations:
-- - Assumes last_updated_on field is reliable and consistently populated
-- - Uses 90-day threshold for verification needs (adjust based on requirements)
-- - Limited to providers with valid last_updated_on dates
-- - Focuses on provider types with at least 10 providers for statistical relevance

-- Possible Extensions:
-- 1. Add month-over-month trending of verification needs
-- 2. Include phone number validity checks
-- 3. Add geocoding-based market analysis
-- 4. Incorporate provider specialty granularity
-- 5. Add compliance risk scoring based on multiple factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:06:05.515634
    - Additional Notes: Query focuses on directory maintenance metrics by monitoring update patterns. The 90-day threshold for verification needs is configurable based on specific compliance requirements. Consider adjusting the provider_count >= 10 filter based on market size and analysis needs.
    
    */