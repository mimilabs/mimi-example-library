-- Title: Provider Qualification Geographic Distribution Analysis

-- Business Purpose:
-- This query analyzes the geographic patterns in healthcare provider qualifications to:
-- 1. Identify regions with highest concentrations of specific credentials
-- 2. Support healthcare workforce planning and development initiatives
-- 3. Highlight potential qualification gaps in different areas

WITH provider_credentials AS (
    -- Get latest qualification for each provider
    SELECT 
        npi,
        code_text,
        period_start,
        period_end,
        -- Extract first 2 digits of NPI which indicates geographic region
        LEFT(npi::string, 2) as region_code
    FROM mimi_ws_1.nppes.fhir_qualification
    WHERE period_end IS NULL  -- Focus on current qualifications
        OR period_end > current_date()
),

regional_summary AS (
    -- Summarize qualifications by region
    SELECT 
        region_code,
        code_text,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER(PARTITION BY region_code) as pct_of_region
    FROM provider_credentials
    GROUP BY region_code, code_text
)

-- Final output with regional qualification distribution
SELECT 
    region_code,
    code_text,
    provider_count,
    ROUND(pct_of_region, 2) as percentage_in_region
FROM regional_summary
WHERE provider_count >= 10  -- Filter for meaningful patterns
ORDER BY region_code, provider_count DESC;

-- How this works:
-- 1. First CTE extracts current qualifications and maps to geographic regions
-- 2. Second CTE calculates distribution statistics by region
-- 3. Final query presents results filtered for significance

-- Assumptions and Limitations:
-- - Uses first 2 digits of NPI as proxy for geographic region
-- - Focuses only on active/current qualifications
-- - Minimum threshold of 10 providers per credential/region for meaningful analysis
-- - Does not account for providers with multiple practice locations

-- Possible Extensions:
-- 1. Add year-over-year trend analysis by region
-- 2. Include specialty-specific qualification analysis
-- 3. Cross-reference with population demographics for needs assessment
-- 4. Add credential density calculations (providers per capita)
-- 5. Incorporate facility type analysis for workforce distribution

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:21:38.531255
    - Additional Notes: Script relies on NPI prefix as geographic identifier which may not be fully accurate for all regions. Consider validating region codes against official NPI registry data for production use. Minimum threshold of 10 providers may need adjustment based on specific regional population densities.
    
    */