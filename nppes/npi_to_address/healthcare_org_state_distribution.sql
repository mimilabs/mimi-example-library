-- Geographic Distribution of Healthcare Organization Types by State
-- 
-- Business Purpose:
-- This query analyzes the geographic distribution of healthcare organizations
-- across states to identify market concentration and potential service gaps.
-- Understanding where different types of healthcare organizations are located
-- helps inform market entry strategy, network adequacy assessments, and
-- identification of underserved areas.

WITH org_counts AS (
    -- Get counts of organizations by state
    SELECT 
        state_fips_biz,
        entity_type_code,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT h3_r8_biz) as location_count
    FROM mimi_ws_1.nppes.npi_to_address
    WHERE 
        state_fips_biz IS NOT NULL
        AND entity_type_code = '2' -- Organizations only
    GROUP BY state_fips_biz, entity_type_code
),

state_metrics AS (
    -- Calculate metrics per state
    SELECT
        state_fips_biz,
        provider_count,
        location_count,
        ROUND(CAST(provider_count AS FLOAT) / CAST(location_count AS FLOAT), 2) as avg_orgs_per_location,
        ROUND(CAST(provider_count AS FLOAT) / 
            SUM(provider_count) OVER (), 4) * 100 as pct_of_total_orgs
    FROM org_counts
)

-- Final output with ranked results
SELECT 
    state_fips_biz as state_fips,
    provider_count as total_organizations,
    location_count as unique_locations,
    avg_orgs_per_location,
    pct_of_total_orgs as market_share_pct,
    RANK() OVER (ORDER BY provider_count DESC) as state_rank_by_size
FROM state_metrics
ORDER BY provider_count DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE counts distinct organizations and locations by state
-- 2. Second CTE calculates key metrics including concentration ratios
-- 3. Final query ranks states by organizational presence
--
-- Assumptions and Limitations:
-- - Uses business address (not mailing address) for geographic assignment
-- - Focuses only on organizations (entity_type_code = 2), not individual providers
-- - Some organizations may have multiple locations in same state
-- - State FIPS codes must be populated for inclusion
--
-- Possible Extensions:
-- 1. Add time-series analysis to track market evolution
-- 2. Include specialty or taxonomy codes to analyze specific provider types
-- 3. Calculate Herfindahl-Hirschman Index (HHI) for market concentration
-- 4. Compare business vs mailing address distributions
-- 5. Add county-level analysis for more granular insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:17:27.892670
    - Additional Notes: The query focuses on state-level market analysis for healthcare organizations, calculating key metrics like provider density and market share. The results are sorted by organization count to highlight states with the highest concentration of healthcare entities. Note that individual providers (entity_type_code = 1) are excluded from this analysis, and results depend on complete state FIPS data.
    
    */