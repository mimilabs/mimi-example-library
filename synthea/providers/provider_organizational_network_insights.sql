-- provider_organizational_network_mapping.sql
-- Business Purpose: 
-- - Map the interconnectivity of healthcare providers across organizations
-- - Identify key organizational networks and provider relationships
-- - Support strategic partnership and collaboration analysis

WITH provider_org_summary AS (
    -- Aggregate provider details by organization for high-level network insights
    SELECT 
        organization,
        COUNT(DISTINCT id) as total_providers,
        COUNT(DISTINCT speciality) as unique_specialties,
        ROUND(AVG(utilization), 2) as avg_provider_utilization,
        COUNT(DISTINCT CASE WHEN gender = 'FEMALE' THEN id END) as female_providers,
        COUNT(DISTINCT CASE WHEN gender = 'MALE' THEN id END) as male_providers
    FROM mimi_ws_1.synthea.providers
    GROUP BY organization
),
specialty_concentration AS (
    -- Analyze specialty concentration within each organization
    SELECT 
        organization,
        speciality,
        COUNT(DISTINCT id) as specialty_provider_count,
        ROUND(100.0 * COUNT(DISTINCT id) / SUM(COUNT(DISTINCT id)) OVER (PARTITION BY organization), 2) as specialty_percentage
    FROM mimi_ws_1.synthea.providers
    GROUP BY organization, speciality
)

-- Primary query to map organizational provider networks
SELECT 
    pos.organization,
    pos.total_providers,
    pos.unique_specialties,
    pos.avg_provider_utilization,
    pos.female_providers,
    pos.male_providers,
    sc.speciality,
    sc.specialty_provider_count,
    sc.specialty_percentage
FROM provider_org_summary pos
JOIN specialty_concentration sc ON pos.organization = sc.organization
WHERE sc.specialty_percentage > 10  -- Focus on significant specialty concentrations
ORDER BY pos.total_providers DESC, sc.specialty_percentage DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Creates a summary of providers by organization
-- 2. Calculates specialty concentration within organizations
-- 3. Joins summary data to provide comprehensive network view

-- Assumptions and Limitations:
-- - Uses synthetic data with potential representational constraints
-- - Focuses on organizations with >10% specialty representation
-- - Provides snapshot of provider network composition

-- Possible Extensions:
-- 1. Add geographic clustering analysis
-- 2. Incorporate patient treatment volume
-- 3. Include provider tenure and experience metrics

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:22:08.140316
    - Additional Notes: Analyzes healthcare provider networks by organization, focusing on specialty concentration and gender distribution. Useful for strategic planning and network analysis, but limited by synthetic dataset characteristics.
    
    */