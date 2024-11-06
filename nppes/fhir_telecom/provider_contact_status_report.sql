-- provider_communication_status_monitoring.sql

-- Business Purpose: Monitor the current status and validity of provider communication channels
-- to ensure accurate and reliable contact information for care coordination. This helps
-- healthcare organizations maintain up-to-date provider directories and identify providers
-- who need to update their contact details.

WITH current_contacts AS (
    -- Get the most recent contact information for each provider and system type
    SELECT 
        npi,
        system,
        value,
        period_start,
        period_end,
        -- Flag if contact info appears outdated (no updates in over 2 years)
        CASE 
            WHEN period_start < DATE_SUB(CURRENT_DATE(), 730) 
            AND period_end IS NULL THEN 1 
            ELSE 0 
        END AS potentially_outdated
    FROM mimi_ws_1.nppes.fhir_telecom
    WHERE period_end IS NULL  -- Only active contact points
),

provider_summary AS (
    -- Summarize contact status per provider
    SELECT
        npi,
        COUNT(DISTINCT system) as contact_methods,
        SUM(potentially_outdated) as outdated_contacts,
        MAX(period_start) as latest_update
    FROM current_contacts
    GROUP BY npi
)

-- Generate final monitoring report
SELECT
    contact_methods,
    COUNT(DISTINCT npi) as provider_count,
    ROUND(AVG(outdated_contacts), 2) as avg_outdated_contacts,
    ROUND(100.0 * SUM(CASE WHEN outdated_contacts > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_providers_with_outdated_info,
    DATE_TRUNC('month', MAX(latest_update)) as most_recent_update
FROM provider_summary
GROUP BY contact_methods
ORDER BY contact_methods;

-- How this query works:
-- 1. Identifies active contact methods for each provider
-- 2. Flags potentially outdated contact information (no updates in 2+ years)
-- 3. Summarizes contact method status per provider
-- 4. Aggregates results to show distribution of contact methods and update patterns

-- Assumptions and limitations:
-- - Assumes period_end NULL indicates currently active contact information
-- - Uses 2 years as threshold for potentially outdated information
-- - Does not validate actual contact information format or functionality
-- - Limited to providers with at least one contact method listed

-- Possible extensions:
-- 1. Add geographic analysis by joining with provider location data
-- 2. Include contact method validation patterns (e.g., valid phone number format)
-- 3. Compare against specialty-specific communication requirements
-- 4. Track month-over-month changes in contact information
-- 5. Generate provider-specific outreach lists for updating outdated information

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:29:35.021848
    - Additional Notes: Query focuses on monitoring data currency rather than just availability. The 2-year threshold for outdated contacts is configurable and should be adjusted based on organizational requirements. Performance may be impacted with very large datasets due to multiple aggregations.
    
    */