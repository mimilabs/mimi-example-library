-- CBSA Market Density Analysis for Healthcare Strategic Planning
-- 
-- Business Purpose:
-- This query analyzes population density and market concentration across CBSAs
-- to identify high-potential healthcare markets by examining residential ratios
-- and geographic distribution patterns. This information is valuable for:
-- - Healthcare facility location planning
-- - Market expansion strategies
-- - Network adequacy assessment
-- - Population health initiatives

WITH cbsa_metrics AS (
    -- Calculate market density metrics by CBSA
    SELECT 
        cbsa,
        COUNT(DISTINCT zip) as zip_count,
        AVG(res_ratio) as avg_residential_density,
        SUM(CASE WHEN res_ratio > 0.8 THEN 1 ELSE 0 END) as high_density_zips,
        MIN(usps_zip_pref_state) as primary_state
    FROM mimi_ws_1.huduser.zip_to_cbsa_mto
    WHERE cbsa != '99999' -- Exclude non-CBSA areas
    GROUP BY cbsa
),
ranked_markets AS (
    -- Rank markets based on density and coverage
    SELECT 
        cbsa,
        primary_state,
        zip_count,
        avg_residential_density,
        high_density_zips,
        -- Calculate a composite market score
        (avg_residential_density * zip_count + high_density_zips) as market_potential
    FROM cbsa_metrics
)

SELECT 
    rm.*,
    -- Calculate relative market share
    ROUND(market_potential / SUM(market_potential) OVER () * 100, 2) as market_share_pct
FROM ranked_markets rm
WHERE zip_count >= 10  -- Focus on markets with meaningful coverage
ORDER BY market_potential DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates ZIP codes by CBSA to calculate density metrics
-- 2. Second CTE creates a composite market score based on coverage and density
-- 3. Final query adds market share calculation and filters for relevant markets

-- Assumptions and Limitations:
-- - Assumes residential density correlates with healthcare service needs
-- - Does not account for demographic or economic factors
-- - Limited to geographic distribution analysis
-- - Current only for latest mapping (2024-03-20)

-- Possible Extensions:
-- 1. Add demographic overlay for age-adjusted market analysis
-- 2. Include competitor facility locations for gap analysis
-- 3. Incorporate drive time/distance metrics for accessibility
-- 4. Add temporal analysis to track market evolution
-- 5. Include state-level healthcare regulations and requirements

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:23:33.107660
    - Additional Notes: The market_potential calculation uses a simplified scoring model that may need adjustment based on specific business requirements. Consider local healthcare market factors and regulatory requirements when interpreting results. The minimum threshold of 10 ZIP codes per CBSA should be adjusted based on the specific market analysis needs.
    
    */