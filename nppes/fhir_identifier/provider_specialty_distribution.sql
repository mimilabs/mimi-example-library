-- provider_taxonomy_distribution.sql
-- Business Purpose: Analyze the distribution of provider specialties and multi-specialty providers 
-- to support network adequacy analysis and identify potential gaps in care coverage.
-- This analysis helps healthcare organizations optimize their provider networks and
-- ensure appropriate specialty coverage across different regions.

WITH provider_taxonomy AS (
    -- Get unique provider-taxonomy combinations where taxonomy is marked as primary
    SELECT DISTINCT 
        npi,
        extension_healthcareProviderTaxonomy as taxonomy_code,
        extension_providerPrimaryTaxonomySwitch as is_primary
    FROM mimi_ws_1.nppes.fhir_identifier
    WHERE extension_healthcareProviderTaxonomy IS NOT NULL
),

provider_counts AS (
    -- Calculate providers per taxonomy and multi-specialty indicators
    SELECT 
        taxonomy_code,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT CASE WHEN is_primary = 'Y' THEN npi END) as primary_specialty_count,
        COUNT(DISTINCT CASE WHEN is_primary = 'N' THEN npi END) as secondary_specialty_count
    FROM provider_taxonomy
    GROUP BY taxonomy_code
)

-- Final output with provider distribution metrics
SELECT 
    taxonomy_code,
    provider_count as total_providers,
    primary_specialty_count,
    secondary_specialty_count,
    ROUND(100.0 * primary_specialty_count / provider_count, 2) as primary_specialty_percentage,
    ROUND(100.0 * secondary_specialty_count / provider_count, 2) as secondary_specialty_percentage
FROM provider_counts
WHERE provider_count >= 100  -- Focus on more common specialties
ORDER BY provider_count DESC
LIMIT 100;

/* How this query works:
1. First CTE identifies unique provider-taxonomy relationships
2. Second CTE calculates various provider counts per taxonomy
3. Final query computes percentages and filters for meaningful results

Assumptions and limitations:
- Assumes taxonomy codes are standardized and valid
- Limited to specialties with at least 100 providers
- Does not account for geographic distribution
- Temporal aspects of specialty changes not considered

Possible extensions:
1. Add geographic analysis by joining with provider location data
2. Include temporal analysis to track specialty trends over time
3. Compare specialty distributions across different healthcare systems
4. Add taxonomy code descriptions for better readability
5. Analyze correlation between primary/secondary specialties
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:17:57.714490
    - Additional Notes: Query focuses on provider taxonomy distribution patterns with a minimum threshold of 100 providers per specialty. Results are limited to top 100 specialties by provider count. Consider adjusting the provider_count threshold and limit based on specific analysis needs.
    
    */