-- medica_network_coverage_analysis.sql
-- 
-- Business Purpose:
-- This analysis evaluates Medica's network coverage by examining provider distribution 
-- and market presence across different entity types. The insights help identify
-- potential network gaps and opportunities for network expansion.
--
-- The results support strategic decisions around:
-- - Network adequacy assessments
-- - Provider recruitment priorities 
-- - Market expansion planning
--

WITH provider_summary AS (
    -- Get distinct provider counts by entity type and market
    SELECT 
        entity_type,
        plan_market_type,
        COUNT(DISTINCT entity_name) as provider_count,
        COUNT(DISTINCT plan_id) as associated_plans
    FROM mimi_ws_1.payermrf.medica_toc
    WHERE entity_type IS NOT NULL 
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.payermrf.medica_toc)
    GROUP BY entity_type, plan_market_type
),

market_metrics AS (
    -- Calculate market presence metrics
    SELECT
        plan_market_type,
        COUNT(DISTINCT entity_name) as total_providers,
        COUNT(DISTINCT plan_id) as total_plans,
        COUNT(DISTINCT entity_type) as entity_type_count
    FROM mimi_ws_1.payermrf.medica_toc 
    GROUP BY plan_market_type
)

-- Combine provider and market metrics for comprehensive view
SELECT 
    ps.entity_type,
    ps.plan_market_type,
    ps.provider_count,
    ps.associated_plans,
    ROUND(100.0 * ps.provider_count / mm.total_providers, 2) as pct_of_market_providers,
    ROUND(100.0 * ps.associated_plans / mm.total_plans, 2) as pct_of_market_plans
FROM provider_summary ps
JOIN market_metrics mm ON ps.plan_market_type = mm.plan_market_type
ORDER BY ps.plan_market_type, ps.provider_count DESC;

-- How This Query Works:
-- 1. Creates provider_summary CTE to get provider counts by entity type and market
-- 2. Creates market_metrics CTE to calculate overall market presence metrics
-- 3. Joins the CTEs to produce comparative metrics showing relative market coverage
--
-- Assumptions & Limitations:
-- - Assumes entity_name uniquely identifies providers
-- - Limited to most recent data snapshot
-- - Does not account for provider specialties or service types
-- - Geographic distribution not considered
--
-- Possible Extensions:
-- 1. Add geographic analysis using location data
-- 2. Trend analysis by comparing across mimi_src_file_dates
-- 3. Provider concentration analysis by plan type
-- 4. Network adequacy scoring based on provider ratios
-- 5. Competition analysis if other payer data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:24:03.303635
    - Additional Notes: Query provides network coverage metrics across markets/entity types using latest data snapshot. Consider adding filters for specific markets or date ranges if analyzing large datasets. Market presence percentages may need validation against external provider directories.
    
    */