-- provider_telehealth_accessibility_analysis.sql
-- Business Purpose: 
-- Analyze healthcare provider accessibility through telehealth-friendly criteria
-- Helps healthcare networks and insurers:
-- 1. Identify providers with comprehensive contact information
-- 2. Assess potential telehealth readiness across different provider types
-- 3. Support strategic network expansion and digital health initiatives

WITH provider_telehealth_readiness AS (
    SELECT 
        provider_type,
        state,
        COUNT(*) as total_providers,
        -- Measure provider contact completeness as a telehealth readiness indicator
        ROUND(
            100.0 * SUM(CASE WHEN phone IS NOT NULL AND length(phone) > 0 THEN 1 ELSE 0 END) / 
            COUNT(*), 
            2
        ) as contact_completeness_pct,
        -- Count unique cities to assess geographic distribution
        COUNT(DISTINCT city) as unique_city_count
    FROM mimi_ws_1.datahealthcaregov.provider_addresses
    WHERE 
        -- Exclude incomplete or potentially invalid records
        npi IS NOT NULL 
        AND state IS NOT NULL
    GROUP BY 
        provider_type, 
        state
)

SELECT 
    provider_type,
    state,
    total_providers,
    contact_completeness_pct,
    unique_city_count,
    -- Rank states by telehealth readiness within each provider type
    RANK() OVER (PARTITION BY provider_type ORDER BY contact_completeness_pct DESC) as telehealth_readiness_rank
FROM provider_telehealth_readiness
WHERE total_providers > 10  -- Focus on statistically significant populations
ORDER BY 
    provider_type, 
    telehealth_readiness_rank
LIMIT 100;

-- Query Mechanics:
-- 1. Creates CTE to calculate provider contact completeness
-- 2. Ranks states by telehealth readiness within provider types
-- 3. Filters for provider types with meaningful sample sizes

-- Assumptions & Limitations:
-- - Contact information completeness is a proxy for telehealth readiness
-- - Assumes phone number presence indicates potential telehealth capability
-- - Does not validate actual telehealth service offerings
-- - Limited to providers with complete NPI and state information

-- Potential Query Extensions:
-- 1. Add ZIP code density analysis
-- 2. Include last_updated_on for recency scoring
-- 3. Integrate with additional provider qualification datasets
-- 4. Create state-level telehealth readiness heat maps

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T20:54:05.738801
    - Additional Notes: Analyzes healthcare provider telehealth readiness by evaluating contact information completeness and geographic distribution. Requires careful interpretation as contact completeness is a proxy for telehealth capability, not a definitive measure.
    
    */