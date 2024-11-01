-- Geographic Clustering and Market Concentration Analysis for Home Health Systems
--
-- Business Purpose:
-- - Identify regional market concentration patterns for home health services
-- - Highlight areas with potential service monopolies or competition gaps
-- - Support strategic planning for market entry or expansion
-- - Inform regulatory compliance and antitrust considerations

WITH regional_stats AS (
    -- Calculate regional presence and market share metrics
    SELECT 
        home_health_care_org_state AS state,
        health_sys_name,
        COUNT(DISTINCT compendium_hh_id) as hh_count,
        COUNT(DISTINCT home_health_care_org_zip) as zip_coverage,
        home_health_care_org_type,
        -- Calculate percentage of state coverage for each health system
        COUNT(DISTINCT compendium_hh_id) * 100.0 / 
            SUM(COUNT(DISTINCT compendium_hh_id)) OVER (PARTITION BY home_health_care_org_state) 
            as market_share_pct
    FROM mimi_ws_1.ahrq.compendium_homehealth_linkage
    WHERE health_sys_name IS NOT NULL
    GROUP BY 
        home_health_care_org_state,
        health_sys_name,
        home_health_care_org_type
),

dominant_players AS (
    -- Identify market leaders in each state
    SELECT 
        state,
        health_sys_name,
        hh_count,
        zip_coverage,
        ROUND(market_share_pct, 2) as market_share_pct,
        home_health_care_org_type,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY market_share_pct DESC) as market_position
    FROM regional_stats
)

-- Final output with market concentration insights
SELECT 
    state,
    health_sys_name as dominant_provider,
    hh_count as total_locations,
    zip_coverage as unique_zip_codes,
    market_share_pct,
    home_health_care_org_type,
    CASE 
        WHEN market_share_pct >= 40 THEN 'High Concentration'
        WHEN market_share_pct >= 20 THEN 'Moderate Concentration'
        ELSE 'Competitive Market'
    END as market_structure
FROM dominant_players
WHERE market_position = 1
ORDER BY market_share_pct DESC;

-- How it works:
-- 1. First CTE (regional_stats) calculates basic metrics for each health system's presence in each state
-- 2. Second CTE (dominant_players) ranks health systems within each state by market share
-- 3. Final query focuses on market leaders and categorizes market concentration
--
-- Assumptions and limitations:
-- - Uses facility counts as proxy for market presence (revenue/volume data would be better)
-- - State-level analysis may mask local market dynamics
-- - Assumes current data represents stable market conditions
-- - Does not account for quality metrics or patient outcomes
--
-- Possible extensions:
-- 1. Add time-series analysis to track market concentration trends
-- 2. Include metropolitan statistical area (MSA) level analysis
-- 3. Cross-reference with quality metrics or patient outcome data
-- 4. Add financial performance metrics if available
-- 5. Integrate with competitor analysis at regional level

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:31:37.993593
    - Additional Notes: Query performs market concentration analysis at state level, identifying dominant health systems and their market share. Note that ZIP code coverage is used as a proxy for market presence, which may not fully reflect actual service volume or revenue share. Best used in conjunction with additional market analysis metrics for comprehensive market assessment.
    
    */