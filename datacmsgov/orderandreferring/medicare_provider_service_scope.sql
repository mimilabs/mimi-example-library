-- Medicare Order/Referring Provider Service Scope Analysis
--
-- Business Purpose:
-- Identifies providers with broad service authorization scope to support:
-- - Network development targeting for health plans
-- - Referral network optimization
-- - Value-based care program provider recruitment
-- The analysis highlights providers who can deliver comprehensive care coordination
-- across multiple service types (Part B, DME, Home Health, etc.)

WITH provider_service_count AS (
    -- Calculate total number of services each provider can order/refer
    SELECT 
        npi,
        first_name,
        last_name,
        (CASE WHEN partb = 'Y' THEN 1 ELSE 0 END +
         CASE WHEN dme = 'Y' THEN 1 ELSE 0 END +
         CASE WHEN hha = 'Y' THEN 1 ELSE 0 END +
         CASE WHEN pmd = 'Y' THEN 1 ELSE 0 END +
         CASE WHEN hospice = 'Y' THEN 1 ELSE 0 END) as service_count
    FROM mimi_ws_1.datacmsgov.orderandreferring
    WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
)

SELECT 
    service_count,
    COUNT(*) as provider_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percent_of_total,
    -- Get sample providers for each service count level
    FIRST(CONCAT(first_name, ' ', last_name)) as sample_provider
FROM provider_service_count
GROUP BY service_count
ORDER BY service_count DESC;

-- How this query works:
-- 1. Creates a CTE to calculate total services each provider can order/refer
-- 2. Groups providers by their service count
-- 3. Calculates distribution and provides a sample provider at each level
-- 4. Uses most recent data snapshot via _input_file_date filter

-- Assumptions & Limitations:
-- - All service types are weighted equally
-- - Current snapshot only - doesn't show historical trends
-- - Provider specialties not considered
-- - Geographic distribution not analyzed
-- - Only shows one sample provider per service count level

-- Possible Extensions:
-- 1. Add geographic analysis by joining with NPI registry data
-- 2. Trend analysis across multiple _input_file_dates
-- 3. Filter for specific high-value service combinations
-- 4. Compare service scope patterns by provider specialty
-- 5. Create provider targeting lists for network development

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:32:39.493115
    - Additional Notes: Query shows distribution of Medicare providers by number of authorized services (Part B, DME, HHA, etc.) they can order/refer. The results indicate provider versatility with percentage breakdowns and sample providers at each service level. Uses most recent data snapshot only.
    
    */