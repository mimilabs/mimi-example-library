-- medica_plan_market_share_analysis.sql

-- Business Purpose:
-- Analyzes Medica's market share and dominance across different plan market types
-- to identify key business segments, potential growth opportunities, and competitive positioning.
-- This analysis helps strategic planning and market expansion decisions by revealing
-- where Medica has strong presence versus areas for potential growth.

WITH market_segment_metrics AS (
    -- Calculate metrics for each plan market type
    SELECT 
        plan_market_type,
        COUNT(DISTINCT plan_id) as plan_count,
        COUNT(DISTINCT entity_name) as entity_count,
        COUNT(*) as total_offerings,
        COUNT(DISTINCT mimi_src_file_name) as data_source_count
    FROM mimi_ws_1.payermrf.medica_toc
    WHERE plan_market_type IS NOT NULL
    GROUP BY plan_market_type
),

market_share_calc AS (
    -- Calculate market share percentages
    SELECT 
        plan_market_type,
        plan_count,
        entity_count,
        total_offerings,
        data_source_count,
        ROUND(100.0 * plan_count / SUM(plan_count) OVER(), 2) as plan_share_pct,
        ROUND(100.0 * total_offerings / SUM(total_offerings) OVER(), 2) as offering_share_pct
    FROM market_segment_metrics
)

-- Final result set with market segment analysis
SELECT 
    plan_market_type as market_segment,
    plan_count as unique_plans,
    entity_count as participating_entities,
    total_offerings as total_market_offerings,
    data_source_count as data_sources,
    plan_share_pct as market_share_by_plans,
    offering_share_pct as market_share_by_offerings
FROM market_share_calc
ORDER BY total_offerings DESC;

-- How it works:
-- 1. First CTE aggregates key metrics by plan market type
-- 2. Second CTE calculates market share percentages
-- 3. Final query presents the results in a business-friendly format

-- Assumptions and limitations:
-- - Assumes plan_market_type is a reliable indicator of market segments
-- - Market share calculations are based on plan counts and offerings, not revenue or membership
-- - Data completeness depends on source file coverage
-- - Null plan_market_type values are excluded

-- Possible extensions:
-- 1. Add trend analysis by incorporating mimi_src_file_date
-- 2. Include geographic distribution by parsing location field
-- 3. Add plan_id_type distribution analysis to understand market reporting patterns
-- 4. Compare metrics across different entity_types within each market segment
-- 5. Add revenue or member data if available for more accurate market share calculation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:15:09.163389
    - Additional Notes: Query focuses on market segment distribution and relative market share across Medica's plan types. Does not account for temporal changes or actual revenue/membership numbers. Market share calculations are based on plan counts rather than business performance metrics.
    
    */