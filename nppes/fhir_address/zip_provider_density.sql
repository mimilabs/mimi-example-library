-- Title: Provider ZIP Code Population Analysis for Market Assessment

-- Business Purpose: Analyzes provider density by ZIP code to identify
-- potential market opportunities, assess competition levels, and support
-- strategic planning for healthcare organizations. This helps in
-- understanding local market dynamics and identifying areas for expansion
-- or consolidation.

-- Main Query
WITH provider_counts AS (
    -- Get distinct provider counts by ZIP code
    SELECT 
        postalCode,
        state,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT CASE WHEN use = 'work' THEN npi END) as active_providers
    FROM mimi_ws_1.nppes.fhir_address
    WHERE 
        postalCode IS NOT NULL 
        AND LENGTH(postalCode) >= 5
        AND country = 'US'
        AND period_end IS NULL  -- Current addresses only
    GROUP BY postalCode, state
),
zip_rankings AS (
    -- Rank ZIP codes by provider density within each state
    SELECT 
        postalCode,
        state,
        provider_count,
        active_providers,
        RANK() OVER (PARTITION BY state ORDER BY provider_count DESC) as state_rank
    FROM provider_counts
)
SELECT 
    postalCode,
    state,
    provider_count,
    active_providers,
    state_rank,
    ROUND(active_providers * 100.0 / provider_count, 1) as active_provider_pct
FROM zip_rankings
WHERE state_rank <= 10  -- Top 10 ZIPs per state
ORDER BY state, state_rank;

-- How the Query Works:
-- 1. First CTE calculates provider counts per ZIP code, including total and active providers
-- 2. Second CTE ranks ZIP codes within each state based on provider density
-- 3. Final output shows top 10 ZIP codes per state with provider statistics

-- Assumptions and Limitations:
-- - Assumes current addresses (period_end IS NULL)
-- - Limited to US addresses only
-- - Requires valid ZIP codes
-- - Does not account for ZIP code population or geographic size
-- - May include both individual and organizational providers

-- Possible Extensions:
-- 1. Add demographic data to calculate providers per capita
-- 2. Include provider specialty analysis for market gaps
-- 3. Add year-over-year growth analysis
-- 4. Incorporate facility type analysis
-- 5. Add geographic radius analysis for market coverage

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:42:41.179246
    - Additional Notes: Query focuses on ZIP-level market analysis for provider distribution but may need additional data sources (demographics, market size) for complete market assessment. Performance could be impacted for large datasets due to window functions and multiple aggregations.
    
    */