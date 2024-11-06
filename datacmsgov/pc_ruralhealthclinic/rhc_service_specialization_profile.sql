
-- rhc_service_specialization_profile.sql
-- Business Purpose:
-- Analyze Rural Health Clinic (RHC) service complexity and specialization
-- Key Insights:
-- - Understand diverse provider type distributions
-- - Identify multi-state operational clinics
-- - Assess organizational structure variety

WITH rhc_specialization_summary AS (
    -- Aggregate provider types and organizational characteristics
    SELECT 
        provider_type_code,
        provider_type_text,
        organization_type_structure,
        proprietary_nonprofit,
        
        -- Count distinct clinics per provider type
        COUNT(DISTINCT enrollment_id) AS total_clinics,
        
        -- Multi-state operational clinics
        COUNT(DISTINCT enrollment_state) AS state_coverage,
        
        -- Organizational diversity metrics
        COUNT(DISTINCT associate_id) AS unique_provider_entities,
        
        -- Percentage of proprietary vs non-profit
        ROUND(
            100.0 * SUM(CASE WHEN proprietary_nonprofit = 'P' THEN 1 ELSE 0 END) / 
            COUNT(*), 
            2
        ) AS proprietary_percentage,
        
        ROUND(
            100.0 * SUM(CASE WHEN proprietary_nonprofit = 'N' THEN 1 ELSE 0 END) / 
            COUNT(*), 
            2
        ) AS nonprofit_percentage

    FROM 
        mimi_ws_1.datacmsgov.pc_ruralhealthclinic
    
    -- Focus on active, meaningful enrollment records
    WHERE 
        provider_type_code IS NOT NULL
        AND enrollment_state IS NOT NULL
    
    GROUP BY 
        provider_type_code, 
        provider_type_text, 
        organization_type_structure, 
        proprietary_nonprofit
)

-- Rank provider types by clinic count and complexity
SELECT 
    provider_type_text,
    total_clinics,
    state_coverage,
    unique_provider_entities,
    proprietary_percentage,
    nonprofit_percentage,
    
    -- Complexity score based on multi-state presence and provider diversity
    ROUND(
        LOG(total_clinics) * state_coverage * 
        (unique_provider_entities / total_clinics), 
        2
    ) AS service_complexity_score

FROM 
    rhc_specialization_summary

ORDER BY 
    service_complexity_score DESC, 
    total_clinics DESC

LIMIT 25;

-- Query Mechanics:
-- 1. Creates CTE to aggregate provider type characteristics
-- 2. Calculates multi-dimensional metrics about RHC services
-- 3. Generates a service complexity ranking

-- Assumptions:
-- - Assumes data represents current Medicare enrollment
-- - Complexity score is a synthetic metric
-- - Focuses on provider type distribution

-- Potential Extensions:
-- 1. Add geographic filtering
-- 2. Integrate with owner/CCN data
-- 3. Time-series analysis of provider type evolution


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:04:56.001309
    - Additional Notes: Query provides insights into Rural Health Clinic service complexity by analyzing provider types, organizational structures, and multi-state operations. Uses a synthetic complexity scoring mechanism to rank provider types based on clinic count, state coverage, and provider entity diversity.
    
    */