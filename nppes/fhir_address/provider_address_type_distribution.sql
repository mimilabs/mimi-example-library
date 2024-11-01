-- Title: Provider Address Type Analysis for Network Adequacy
-- Business Purpose: Analyzes the distribution of provider address types (work vs mailing)
-- to support network adequacy assessments and provider directory accuracy initiatives.
-- Understanding address patterns helps health plans maintain accurate provider directories
-- and ensure compliance with network adequacy requirements.

SELECT 
    -- Analyze address usage patterns
    use AS address_type,
    type AS physical_or_postal,
    state,
    
    -- Calculate provider counts and percentages
    COUNT(DISTINCT npi) as provider_count,
    ROUND(COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER (), 2) as percentage_of_total,
    
    -- Check for address completeness
    SUM(CASE WHEN line IS NULL OR city IS NULL OR postalCode IS NULL THEN 1 ELSE 0 END) as incomplete_addresses,
    
    -- Analyze currency of address information
    COUNT(CASE WHEN period_end IS NULL THEN 1 END) as active_addresses,
    COUNT(CASE WHEN period_end IS NOT NULL THEN 1 END) as inactive_addresses

FROM mimi_ws_1.nppes.fhir_address

WHERE country = 'US' -- Focus on US providers
AND period_start IS NOT NULL -- Ensure valid address records

GROUP BY 
    use,
    type,
    state

HAVING provider_count > 100 -- Focus on statistically significant patterns

ORDER BY 
    state,
    provider_count DESC;

-- How This Query Works:
-- 1. Groups provider addresses by type and state
-- 2. Calculates total providers and percentage distribution
-- 3. Identifies incomplete or potentially problematic addresses
-- 4. Tracks active vs inactive address records
-- 5. Filters for meaningful sample sizes

-- Assumptions and Limitations:
-- - Assumes address types are correctly coded in source data
-- - Limited to US addresses only
-- - Requires minimum provider count to reduce noise
-- - May include multiple addresses per provider
-- - Does not account for provider specialty or practice type

-- Possible Extensions:
-- 1. Add temporal analysis to track address changes over time
-- 2. Include provider specialty analysis
-- 3. Add geographic clustering analysis
-- 4. Compare against CMS network adequacy standards
-- 5. Incorporate provider directory verification timestamps
-- 6. Add distance calculations between work and mailing addresses

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:53:20.079228
    - Additional Notes: Query includes built-in data quality checks through incomplete_addresses counting and period validation. Consider adjusting the provider_count threshold (currently 100) based on specific analysis needs. The percentage calculation provides relative distribution insights across states and address types.
    
    */