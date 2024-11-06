-- endpoint_provider_affiliation_network.sql
-- Business Purpose: Analyze provider-organization relationships through HIE endpoints
-- to identify key healthcare networks and potential consolidation patterns.
-- This information is valuable for:
-- - Healthcare market analysis and competitive intelligence
-- - Understanding provider referral networks
-- - Identifying opportunities for network expansion or partnership

WITH org_size AS (
    -- Calculate organization size by counting affiliated providers
    SELECT 
        affiliation_legal_business_name,
        COUNT(DISTINCT npi) as provider_count
    FROM mimi_ws_1.nppes.endpoint
    WHERE affiliation_legal_business_name IS NOT NULL
    GROUP BY affiliation_legal_business_name
),

provider_endpoints AS (
    -- Get count of endpoints per provider to understand connectivity
    SELECT 
        npi,
        COUNT(DISTINCT endpoint) as endpoint_count
    FROM mimi_ws_1.nppes.endpoint
    GROUP BY npi
)

SELECT 
    e.affiliation_legal_business_name,
    e.affiliation_address_state,
    -- Organization size metrics
    o.provider_count,
    COUNT(DISTINCT e.endpoint_type) as unique_endpoint_types,
    -- Provider connectivity metrics
    AVG(pe.endpoint_count) as avg_endpoints_per_provider,
    -- Location spread
    COUNT(DISTINCT e.affiliation_address_postal_code) as unique_zip_codes
FROM mimi_ws_1.nppes.endpoint e
LEFT JOIN org_size o 
    ON e.affiliation_legal_business_name = o.affiliation_legal_business_name
LEFT JOIN provider_endpoints pe 
    ON e.npi = pe.npi
WHERE e.affiliation_legal_business_name IS NOT NULL
GROUP BY 
    e.affiliation_legal_business_name,
    e.affiliation_address_state,
    o.provider_count
HAVING o.provider_count >= 10
ORDER BY o.provider_count DESC
LIMIT 100;

-- How it works:
-- 1. Creates temp table of organization sizes based on provider count
-- 2. Creates temp table of provider endpoint counts
-- 3. Joins these together to analyze organization networks
-- 4. Filters for organizations with 10+ providers
-- 5. Orders by size to focus on major players

-- Assumptions and Limitations:
-- - Organizations are identified by exact name match
-- - Only includes active endpoints
-- - May miss some relationships due to data quality
-- - Limited to current snapshot, no historical trending

-- Possible Extensions:
-- 1. Add temporal analysis to track network growth
-- 2. Include specialty mix analysis
-- 3. Add geographic concentration metrics
-- 4. Compare endpoint types across organization sizes
-- 5. Analyze cross-organization provider relationships

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:59:32.842240
    - Additional Notes: Query provides insights into healthcare organization networks based on provider affiliations and endpoint connectivity. The 10+ provider filter may need adjustment based on market size, and organization name matching could benefit from fuzzy matching or standardization to account for variations in business names.
    
    */