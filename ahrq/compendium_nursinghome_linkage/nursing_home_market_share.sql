-- corporate_parent_concentration.sql

-- Business Purpose:
-- Analyze market concentration of corporate parents in the nursing home sector
-- Helps identify dominant players and potential market consolidation
-- Critical for strategic planning, M&A due diligence, and market competition analysis
-- Provides insights for investors, regulators, and healthcare strategists

WITH parent_metrics AS (
    -- Calculate key metrics for each corporate parent
    SELECT 
        corp_parent_name,
        corp_parent_type,
        COUNT(DISTINCT compendium_nh_id) as num_facilities,
        COUNT(DISTINCT nursing_home_state) as states_present,
        COLLECT_SET(nursing_home_state) as state_array,
        -- Calculate market share percentage
        ROUND(COUNT(DISTINCT compendium_nh_id) * 100.0 / 
            (SELECT COUNT(DISTINCT compendium_nh_id) FROM mimi_ws_1.ahrq.compendium_nursinghome_linkage 
             WHERE corp_parent_name IS NOT NULL), 2) as market_share_pct
    FROM mimi_ws_1.ahrq.compendium_nursinghome_linkage
    WHERE corp_parent_name IS NOT NULL
    GROUP BY corp_parent_name, corp_parent_type
)

SELECT 
    corp_parent_name,
    corp_parent_type,
    num_facilities,
    states_present,
    ARRAY_JOIN(state_array, ', ') as state_list,
    market_share_pct,
    -- Create cumulative market share for concentration analysis
    SUM(market_share_pct) OVER (ORDER BY num_facilities DESC) as cumulative_market_share
FROM parent_metrics
WHERE num_facilities >= 5  -- Focus on significant players
ORDER BY num_facilities DESC
LIMIT 20;

-- How it works:
-- 1. Creates a CTE to calculate metrics for each corporate parent
-- 2. Aggregates facility counts and geographic presence
-- 3. Uses COLLECT_SET and ARRAY_JOIN instead of STRING_AGG for state list
-- 4. Calculates market share percentages
-- 5. Adds cumulative market share for concentration analysis
-- 6. Filters for significant players and returns top 20

-- Assumptions and Limitations:
-- 1. Assumes corporate parent information is accurately recorded
-- 2. Limited to facilities with known corporate parents
-- 3. Market share based on facility count, not bed capacity or revenue
-- 4. Snapshot view that may not reflect recent ownership changes
-- 5. Geographic presence treated equally across states

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include bed capacity data for weighted market share
-- 3. Add geographic concentration indices (HHI) by state
-- 4. Compare health system vs corporate owner concentration
-- 5. Incorporate quality metrics for size-quality correlation analysis
-- 6. Add financial metrics if available
-- 7. Create state-level market concentration views

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:33:18.695233
    - Additional Notes: Query analyzes market concentration by calculating facility counts, geographic presence, and cumulative market share for major corporate parents in the nursing home sector. Useful for antitrust analysis, market research, and competitive intelligence. Results are limited to organizations with 5+ facilities to focus on significant market players.
    
    */