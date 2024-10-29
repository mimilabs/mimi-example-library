-- TITLE: Geographic Market Opportunity Analysis for Home Health Services

-- BUSINESS PURPOSE:
-- Identify high-potential geographic markets for home health services by analyzing:
-- - Market concentration/competition by region
-- - Service coverage gaps
-- - Population access to home health services
-- - Regional variations in provider density
-- This helps inform market entry, expansion, and partnership strategies.

WITH provider_counts AS (
    -- Get provider counts and key metrics by geographic area
    SELECT 
        state_code,
        city,
        COUNT(DISTINCT provider_ccn) as num_providers,
        COUNT(DISTINCT type_of_control) as ownership_types,
        SUM(total_medicare_title_xviii_visits) as total_medicare_visits,
        SUM(total_total_visits) as total_visits,
        AVG(total_current_assets) as avg_provider_assets
    FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha
    WHERE fiscal_year_end_date >= '2019-01-01'
    GROUP BY state_code, city
),

market_metrics AS (
    -- Calculate market concentration and opportunity metrics
    SELECT
        state_code,
        city,
        num_providers,
        ownership_types,
        total_medicare_visits,
        total_visits,
        avg_provider_assets,
        -- Calculate market share concentration
        (total_medicare_visits * 1.0) / NULLIF(total_visits, 0) as medicare_market_share,
        -- Calculate visits per provider as proxy for capacity
        (total_visits * 1.0) / NULLIF(num_providers, 0) as visits_per_provider
    FROM provider_counts
)

-- Final output with market opportunity scoring
SELECT 
    state_code,
    city,
    num_providers,
    ownership_types as provider_type_diversity,
    ROUND(medicare_market_share, 2) as medicare_share,
    ROUND(visits_per_provider, 0) as annual_visits_per_provider,
    ROUND(avg_provider_assets, 0) as avg_provider_assets,
    -- Market opportunity score (higher = more opportunity)
    ROUND(
        (CASE 
            WHEN num_providers = 0 THEN 100  -- Unserved markets
            WHEN num_providers < 3 THEN 80   -- Underserved markets
            WHEN visits_per_provider > 10000 THEN 60  -- High utilization markets
            ELSE 40
        END +
        CASE
            WHEN medicare_market_share > 0.8 THEN 20  -- Medicare-dependent
            WHEN medicare_market_share < 0.4 THEN 40  -- Diverse payer mix
            ELSE 30
        END) / 100.0, 
    2) as market_opportunity_score
FROM market_metrics
WHERE num_providers > 0  -- Exclude areas with no providers
ORDER BY market_opportunity_score DESC, total_visits DESC
LIMIT 100;

-- HOW IT WORKS:
-- 1. First CTE gets provider counts and volume metrics by geography
-- 2. Second CTE calculates market concentration metrics
-- 3. Final query scores markets based on:
--    - Provider density
--    - Market concentration
--    - Service volumes
--    - Payer mix diversity

-- ASSUMPTIONS & LIMITATIONS:
-- - Uses recent fiscal year data only (2019+)
-- - Market boundaries based on city/state (may not reflect true service areas)
-- - Does not account for demographics or population health needs
-- - Limited to metrics available in cost reports

-- POSSIBLE EXTENSIONS:
-- 1. Add demographic data to assess population needs
-- 2. Include quality metrics in opportunity scoring
-- 3. Analyze temporal trends in market dynamics
-- 4. Add competitor financial strength metrics
-- 5. Include distance/drive time analysis
-- 6. Segment markets by urban/rural designation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:21:15.162860
    - Additional Notes: Query focuses on identifying market expansion opportunities through geographic analysis of provider density and service volumes. Note that results are most meaningful when filtered to specific regions of interest and may need adjustment of scoring weights based on business strategy. Market definitions using city boundaries may not reflect actual service areas in rural regions.
    
    */