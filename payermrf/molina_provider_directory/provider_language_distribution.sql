-- Title: Provider Languages and Cultural Competency Analysis
-- Business Purpose: Evaluate linguistic diversity and language capabilities across Molina's
-- provider network to assess cultural competency and language accessibility for members.
-- This analysis helps identify areas where additional language resources may be needed
-- and supports initiatives to reduce language barriers in healthcare delivery.

WITH provider_languages AS (
    -- Combine primary and secondary languages, removing nulls and duplicates
    SELECT 
        service_location_county,
        npi,
        provider_type,
        COALESCE(provider_languages1, 'Not Specified') as language,
        primary_specialty,
        accepting_new_patient_pgm_1
    FROM mimi_ws_1.payermrf.molina_provider_directory
    WHERE provider_languages1 IS NOT NULL
    UNION
    SELECT 
        service_location_county,
        npi,
        provider_type,
        COALESCE(provider_languages2, 'Not Specified') as language,
        primary_specialty,
        accepting_new_patient_pgm_1
    FROM mimi_ws_1.payermrf.molina_provider_directory
    WHERE provider_languages2 IS NOT NULL
)

SELECT 
    service_location_county,
    language,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT CASE WHEN accepting_new_patient_pgm_1 = 'Y' THEN npi END) as accepting_new_patients,
    COUNT(DISTINCT primary_specialty) as specialty_count,
    ROUND(COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER (PARTITION BY service_location_county), 2) as pct_of_county_providers
FROM provider_languages
GROUP BY service_location_county, language
HAVING COUNT(DISTINCT npi) > 5  -- Focus on more common language capabilities
ORDER BY service_location_county, provider_count DESC;

-- How the query works:
-- 1. Creates a CTE that combines primary and secondary language fields
-- 2. Deduplicates providers who speak multiple languages
-- 3. Calculates key metrics by county and language
-- 4. Filters for meaningful sample sizes
-- 5. Shows distribution of language capabilities across counties

-- Assumptions and limitations:
-- - Language fields are consistently populated
-- - Providers accurately report language capabilities
-- - Secondary languages may be underreported
-- - Small sample sizes in some counties may affect percentages
-- - Does not account for dialect variations

-- Possible extensions:
-- 1. Compare language availability to local demographic needs
-- 2. Add temporal analysis to track changes in language coverage
-- 3. Cross-reference with specialty coverage to identify gaps
-- 4. Include telehealth capabilities for language services
-- 5. Analyze correlation between languages and patient acceptance status

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:06:27.053217
    - Additional Notes: Query focuses on accessible providers (>5 per language/county) and may not reflect complete language coverage in areas with smaller provider populations. Language data reliability depends on accurate self-reporting by providers.
    
    */