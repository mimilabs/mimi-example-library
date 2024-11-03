-- provider_taxonomy_trends.sql
-- Title: Healthcare Provider Specialty and Subspecialty Trend Analysis
--
-- Business Purpose:
-- This query analyzes the evolution of healthcare provider specialties over time,
-- helping healthcare organizations and payers to:
-- - Identify emerging specialties and subspecialties
-- - Track provider workforce composition changes
-- - Support network adequacy planning
-- - Guide strategic recruitment and contracting decisions

WITH latest_records AS (
    -- Get the most recent record for each provider to avoid duplicates
    SELECT 
        npi,
        entity_type_code,
        CASE 
            WHEN entity_type_code = 1 THEN provider_first_name || ' ' || provider_last_name_legal_name
            ELSE provider_organization_name_legal_business_name
        END as provider_name,
        provider_business_practice_location_address_state_name as practice_state,
        provider_credential_text,
        provider_enumeration_date,
        mimi_src_file_date
    FROM mimi_ws_1.nppes.npidata
    WHERE npi_deactivation_date IS NULL
    QUALIFY ROW_NUMBER() OVER (PARTITION BY npi ORDER BY mimi_src_file_date DESC) = 1
)

-- Analyze provider distribution and credentials
SELECT 
    practice_state,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT CASE WHEN entity_type_code = 1 THEN npi END) as individual_providers,
    COUNT(DISTINCT CASE WHEN entity_type_code = 2 THEN npi END) as organization_providers,
    ROUND(AVG(DATEDIFF(CURRENT_DATE, provider_enumeration_date)/365.25), 1) as avg_years_active,
    COUNT(DISTINCT CASE 
        WHEN provider_credential_text LIKE '%MD%' THEN npi 
        WHEN provider_credential_text LIKE '%DO%' THEN npi
    END) as physician_count
FROM latest_records
WHERE practice_state IS NOT NULL
GROUP BY practice_state
HAVING provider_count >= 100
ORDER BY provider_count DESC
LIMIT 50;

-- How this query works:
-- 1. Creates a CTE to get the latest record for each provider
-- 2. Analyzes provider distribution by state
-- 3. Calculates key metrics including provider types and experience
-- 4. Identifies physician concentration using credential text
--
-- Assumptions and Limitations:
-- - Uses most recent provider record only
-- - Limited to active providers only
-- - Basic credential text analysis may miss some physicians
-- - State-level analysis may mask local variations
--
-- Possible Extensions:
-- 1. Add urban/rural distribution analysis
-- 2. Include provider age demographics
-- 3. Analyze provider-to-population ratios
-- 4. Track practice location changes over time
-- 5. Add specialty-specific analysis using taxonomy codes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:51:59.896221
    - Additional Notes: Query focuses on the state-level distribution of healthcare providers with key metrics like physician density and provider longevity. Credential analysis is simplified using string matching on MD/DO designations. Consider enhancing credential matching patterns for more comprehensive physician identification. Results are limited to states with at least 100 providers to ensure statistical relevance.
    
    */