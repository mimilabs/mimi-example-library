-- Medicare Provider Location-Based Network Gap Analysis
--
-- Business Purpose:
-- This analysis helps healthcare organizations identify geographic areas that may have gaps
-- in provider coverage for specific Medicare services. It supports:
-- - Strategic network development and provider recruitment
-- - Access to care improvement initiatives 
-- - Regional market expansion planning

WITH provider_counts AS (
    -- Get the latest snapshot of data
    SELECT DISTINCT
        LEFT(npi, 2) as state_prefix,
        COUNT(DISTINCT npi) as total_providers,
        SUM(CASE WHEN partb = 'Y' THEN 1 ELSE 0 END) as partb_providers,
        SUM(CASE WHEN dme = 'Y' THEN 1 ELSE 0 END) as dme_providers,
        SUM(CASE WHEN hha = 'Y' THEN 1 ELSE 0 END) as hha_providers,
        SUM(CASE WHEN pmd = 'Y' THEN 1 ELSE 0 END) as pmd_providers,
        SUM(CASE WHEN hospice = 'Y' THEN 1 ELSE 0 END) as hospice_providers
    FROM mimi_ws_1.datacmsgov.orderandreferring
    WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
    GROUP BY LEFT(npi, 2)
)

SELECT 
    state_prefix,
    total_providers,
    ROUND(partb_providers * 100.0 / total_providers, 1) as partb_pct,
    ROUND(dme_providers * 100.0 / total_providers, 1) as dme_pct,
    ROUND(hha_providers * 100.0 / total_providers, 1) as hha_pct,
    ROUND(pmd_providers * 100.0 / total_providers, 1) as pmd_pct,
    ROUND(hospice_providers * 100.0 / total_providers, 1) as hospice_pct
FROM provider_counts
ORDER BY total_providers DESC;

-- How this works:
-- 1. Uses NPI state prefix (first 2 digits) as a geographic identifier
-- 2. Calculates provider counts and service authorization percentages by state
-- 3. Shows distribution of service capabilities across regions
--
-- Assumptions and Limitations:
-- - NPI first 2 digits generally correspond to state of first registration
-- - Current snapshot analysis only - doesn't show historical trends
-- - Doesn't account for provider specialty or practice size
--
-- Possible Extensions:
-- 1. Add state names mapping for better readability
-- 2. Include month-over-month or year-over-year change analysis
-- 3. Add provider density calculations using state population data
-- 4. Create benchmarks for "healthy" service coverage ratios
-- 5. Include provider specialty analysis within geographic regions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:08:56.048697
    - Additional Notes: This query uses NPI prefix-based geographic analysis which may not perfectly align with current provider locations since NPIs are assigned based on initial registration location. For more accurate geographic analysis, consider supplementing with current practice location data if available.
    
    */