-- provider_language_accessibility.sql

-- Business Purpose: Analyze language capabilities across healthcare providers to:
-- 1. Assess accessibility for non-English speaking populations
-- 2. Identify gaps in language coverage by specialty and facility type
-- 3. Support diversity and inclusion initiatives in healthcare delivery
-- 4. Guide recruitment strategies for multilingual providers

WITH provider_languages AS (
    -- Parse languages array and clean data
    SELECT 
        npi,
        specialty,
        facility_type,
        CASE 
            WHEN languages IS NULL OR languages = ARRAY() THEN 1  -- Count as 1 language (English)
            ELSE SIZE(languages)  -- Use SIZE function for array length
        END as num_languages,
        CASE 
            WHEN languages IS NULL OR languages = ARRAY() THEN false
            ELSE true
        END as is_multilingual
    FROM mimi_ws_1.datahealthcaregov.provider_base
    WHERE last_updated_on >= DATE_SUB(CURRENT_DATE, 180) -- Last 6 months
),

language_summary AS (
    -- Calculate provider counts and language metrics
    SELECT 
        specialty,
        facility_type,
        COUNT(DISTINCT npi) as total_providers,
        SUM(CASE WHEN is_multilingual THEN 1 ELSE 0 END) as multilingual_providers,
        AVG(num_languages) as avg_languages_per_provider
    FROM provider_languages
    WHERE specialty IS NOT NULL
    GROUP BY specialty, facility_type
)

-- Final summary with language diversity metrics
SELECT 
    specialty,
    facility_type,
    total_providers,
    multilingual_providers,
    ROUND(avg_languages_per_provider, 2) as avg_languages_per_provider,
    ROUND(multilingual_providers * 100.0 / total_providers, 2) as pct_multilingual
FROM language_summary
WHERE total_providers >= 10
ORDER BY pct_multilingual DESC, total_providers DESC;

-- How it works:
-- 1. Creates base table of providers with language counts
-- 2. Calculates multilingual status and provider totals
-- 3. Generates summary metrics including % multilingual providers
-- 4. Filters for statistically significant provider counts (>=10)

-- Assumptions & Limitations:
-- 1. Assumes English as default when languages field is empty/null
-- 2. Limited to last 6 months of data for currency
-- 3. Requires minimum provider count to avoid skewed percentages
-- 4. Does not account for proficiency levels in languages

-- Possible Extensions:
-- 1. Add geographic dimension to identify regional language gaps
-- 2. Compare against local demographics for needs assessment
-- 3. Trend analysis over time to track diversity progress
-- 4. Cross-reference with patient satisfaction scores
-- 5. Include acceptance status to assess actual accessibility

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:45:58.195968
    - Additional Notes: Query calculates multilingual metrics for healthcare providers active in the last 6 months. Only includes specialties with 10+ providers to ensure statistical relevance. Default assumption is that all providers speak English when language data is missing. Results can be used for DEI initiatives and improving healthcare accessibility for non-English speaking populations.
    
    */