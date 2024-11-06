-- provider_accessibility_metrics.sql
-- Business Purpose: Analyze healthcare provider accessibility and network composition
-- Key Insights: Understand provider availability, specialization, and patient acceptance patterns

WITH provider_summary AS (
    SELECT 
        specialty, 
        facility_type,
        accepting,
        COUNT(DISTINCT npi) AS total_providers,
        COUNT(DISTINCT CASE WHEN accepting = 'Yes' THEN npi END) AS accepting_providers,
        ROUND(COUNT(DISTINCT CASE WHEN accepting = 'Yes' THEN npi END) * 100.0 / COUNT(DISTINCT npi), 2) AS acceptance_rate
    FROM mimi_ws_1.datahealthcaregov.provider_base
    WHERE specialty IS NOT NULL
    GROUP BY specialty, facility_type, accepting
)

SELECT 
    specialty,           -- Primary categorization of healthcare providers
    facility_type,       -- Context of provider practice environment
    total_providers,     -- Total number of providers in each specialty and facility type
    accepting_providers, -- Number of providers currently accepting new patients
    acceptance_rate,     -- Percentage of providers open to new patients
    RANK() OVER (ORDER BY total_providers DESC) AS provider_volume_rank
FROM provider_summary
ORDER BY total_providers DESC, acceptance_rate DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Aggregates provider data by specialty and facility type
-- 2. Calculates provider counts and acceptance rates
-- 3. Ranks specialties by total provider volume
-- 4. Provides a comprehensive view of provider network accessibility

-- Key Assumptions:
-- - 'accepting' column accurately reflects current patient acceptance status
-- - Specialty and facility type classifications are consistent
-- - Data represents a comprehensive provider snapshot

-- Potential Extensions:
-- 1. Add geographic dimensions (state/county level analysis)
-- 2. Incorporate patient population data for provider-to-patient ratio
-- 3. Time-series analysis of provider network changes
-- 4. Integrate with quality metrics or patient satisfaction scores

-- Business Value:
-- - Identify underserved specialties or facility types
-- - Assess network accessibility for patient referrals
-- - Support strategic provider recruitment and network development

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:26:41.551730
    - Additional Notes: Query provides insights into provider network composition by analyzing specialty, facility type, and patient acceptance rates. Useful for strategic healthcare network planning and identifying potential access gaps.
    
    */