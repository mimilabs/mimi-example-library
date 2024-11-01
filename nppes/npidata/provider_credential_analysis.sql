-- provider_credential_distribution.sql
-- Title: Analysis of Provider Credentials and Educational Qualifications

-- Business Purpose:
-- This query analyzes the distribution of provider credentials and qualifications across
-- individual healthcare providers to:
-- 1. Assess the mix of clinical expertise in the healthcare workforce
-- 2. Support provider network adequacy and credentialing workflows
-- 3. Identify trends in professional qualifications
-- 4. Aid in provider directory quality management

-- Main Query
WITH current_active_providers AS (
    -- Get the most recent record for each individual provider
    SELECT 
        npi,
        provider_credential_text,
        provider_first_name,
        provider_last_name_legal_name,
        provider_gender_code,
        provider_enumeration_date,
        certification_date
    FROM mimi_ws_1.nppes.npidata
    WHERE entity_type_code = '1'  -- Individual providers only
    AND npi_deactivation_date IS NULL  -- Active providers
    -- Get latest record per provider
    QUALIFY ROW_NUMBER() OVER (PARTITION BY npi ORDER BY mimi_src_file_date DESC) = 1
),

credential_breakdown AS (
    -- Split and analyze credential text
    SELECT 
        CASE 
            WHEN provider_credential_text IS NULL THEN 'No Credentials Listed'
            WHEN TRIM(provider_credential_text) = '' THEN 'No Credentials Listed'
            ELSE provider_credential_text
        END AS credential_group,
        COUNT(*) as provider_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage,
        -- Calculate certification compliance
        SUM(CASE WHEN certification_date IS NOT NULL THEN 1 ELSE 0 END) as certified_count
    FROM current_active_providers
    GROUP BY 
        CASE 
            WHEN provider_credential_text IS NULL THEN 'No Credentials Listed'
            WHEN TRIM(provider_credential_text) = '' THEN 'No Credentials Listed'
            ELSE provider_credential_text
        END
)

-- Final output with ranked results
SELECT 
    credential_group,
    provider_count,
    ROUND(percentage, 2) as percentage_of_total,
    certified_count,
    ROUND(certified_count * 100.0 / provider_count, 2) as certification_rate
FROM credential_breakdown
WHERE provider_count >= 100  -- Filter for meaningful groupings
ORDER BY provider_count DESC
LIMIT 20;

-- How the Query Works:
-- 1. First CTE gets the most recent record for each active individual provider
-- 2. Second CTE groups and analyzes credential text, handling NULL/empty values
-- 3. Final output ranks credential groups by frequency and includes certification metrics
-- 4. Results show top 20 credential groupings with counts and percentages

-- Assumptions and Limitations:
-- 1. Assumes provider_credential_text is relatively standardized (may need cleaning)
-- 2. Only includes individual providers (entity_type_code = '1')
-- 3. Limited to active providers (npi_deactivation_date IS NULL)
-- 4. Groups with fewer than 100 providers are filtered out
-- 5. Credential text may contain multiple credentials that could be parsed further

-- Possible Extensions:
-- 1. Add temporal analysis to track credential trends over time
-- 2. Cross-reference with taxonomy codes to analyze specialty-credential relationships
-- 3. Add geographic dimension to analyze regional credential patterns
-- 4. Parse individual credentials from credential_text for more granular analysis
-- 5. Add gender analysis to examine credential distribution by gender
-- 6. Include provider age/experience analysis based on enumeration_date

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:30:43.864885
    - Additional Notes: Query focuses on credential distribution of active providers but may require additional data cleaning due to inconsistent credential text formatting. Performance may be impacted with very large datasets due to window functions and string operations. Consider adding indexes on npi and mimi_src_file_date for better performance.
    
    */