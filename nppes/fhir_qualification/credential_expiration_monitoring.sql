-- Title: Provider Qualification Currency Analysis

-- Business Purpose:
-- This query examines the currency and validity status of healthcare provider credentials to:
-- 1. Identify providers with soon-to-expire qualifications requiring renewal
-- 2. Support compliance monitoring and credential management
-- 3. Enable proactive outreach for credential renewal

WITH qualification_status AS (
    -- Calculate days until expiration and status for each qualification
    SELECT 
        npi,
        code_text,
        period_start,
        period_end,
        DATEDIFF(period_end, CURRENT_DATE()) as days_until_expiration,
        CASE 
            WHEN period_end < CURRENT_DATE() THEN 'Expired'
            WHEN DATEDIFF(period_end, CURRENT_DATE()) <= 90 THEN 'Expiring Soon'
            ELSE 'Active'
        END as credential_status
    FROM mimi_ws_1.nppes.fhir_qualification
    WHERE period_end IS NOT NULL
)

SELECT 
    credential_status,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(*) as qualification_count,
    ROUND(AVG(days_until_expiration)) as avg_days_until_expiration,
    MIN(days_until_expiration) as min_days_until_expiration,
    MAX(days_until_expiration) as max_days_until_expiration
FROM qualification_status
GROUP BY credential_status
ORDER BY 
    CASE credential_status 
        WHEN 'Expired' THEN 1
        WHEN 'Expiring Soon' THEN 2
        WHEN 'Active' THEN 3
    END;

-- How the Query Works:
-- 1. Creates a CTE to categorize qualifications based on expiration status
-- 2. Calculates days until expiration for each credential
-- 3. Groups results by status to show counts and timing metrics
-- 4. Orders results to prioritize expired and soon-to-expire credentials

-- Assumptions and Limitations:
-- 1. Assumes period_end dates are accurately maintained
-- 2. Defines "Expiring Soon" as within 90 days
-- 3. Only includes records with non-null end dates
-- 4. Does not account for renewal processes in progress

-- Possible Extensions:
-- 1. Add specialty-specific expiration monitoring
-- 2. Include geographic analysis of expiration patterns
-- 3. Create provider-level alerts for multiple expiring credentials
-- 4. Add trending analysis to predict future renewal volumes
-- 5. Incorporate specific regulatory compliance requirements by credential type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:43:44.949476
    - Additional Notes: Query focuses on operational risk management by monitoring credential expiration status. The 90-day threshold for 'Expiring Soon' status is configurable based on organizational needs. Results can be used to drive automated notification systems and compliance workflows.
    
    */