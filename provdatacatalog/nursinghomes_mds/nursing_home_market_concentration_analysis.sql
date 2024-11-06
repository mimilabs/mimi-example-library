-- nursing_home_market_concentration_analysis.sql
-- 
-- Business Purpose: Analyze nursing home market dynamics by examining provider distribution,
-- ownership concentration, and potential market entry opportunities across different states.
--
-- Key Business Insights:
-- 1. Identify states with high nursing home market fragmentation
-- 2. Understand regional variations in nursing home provider landscape
-- 3. Support strategic market expansion and investment decisions

WITH nursing_home_state_summary AS (
    -- Aggregate nursing home data by state to understand market structure
    SELECT 
        provider_state,
        COUNT(DISTINCT cms_certification_number_ccn) AS total_nursing_homes,
        COUNT(DISTINCT provider_name) AS unique_providers,
        ROUND(COUNT(DISTINCT provider_name) * 100.0 / COUNT(DISTINCT cms_certification_number_ccn), 2) AS provider_concentration_pct,
        AVG(four_quarter_average_score) AS avg_quality_score
    FROM mimi_ws_1.provdatacatalog.nursinghomes_mds
    WHERE provider_state IS NOT NULL
    GROUP BY provider_state
),
market_competitiveness AS (
    -- Calculate market competitiveness indicators
    SELECT 
        provider_state,
        total_nursing_homes,
        unique_providers,
        provider_concentration_pct,
        avg_quality_score,
        CASE 
            WHEN provider_concentration_pct < 25 THEN 'Highly Competitive'
            WHEN provider_concentration_pct BETWEEN 25 AND 50 THEN 'Moderately Concentrated'
            ELSE 'Low Competition'
        END AS market_competition_tier
    FROM nursing_home_state_summary
)

-- Primary query to highlight market opportunities and competitive landscape
SELECT 
    provider_state,
    total_nursing_homes,
    unique_providers,
    provider_concentration_pct,
    avg_quality_score,
    market_competition_tier
FROM market_competitiveness
ORDER BY total_nursing_homes DESC, provider_concentration_pct
LIMIT 50;

-- Query Mechanics:
-- 1. First CTE (nursing_home_state_summary) aggregates nursing home data by state
-- 2. Second CTE (market_competitiveness) adds market competition classification
-- 3. Main query ranks states by nursing home volume and market concentration
--
-- Key Assumptions:
-- - Data represents a consistent time period
-- - CCN uniquely identifies nursing home facilities
-- - Quality score is a valid proxy for market performance
--
-- Potential Extensions:
-- 1. Add urban vs rural market segmentation
-- 2. Incorporate patient volume or bed count metrics
-- 3. Trend analysis of market dynamics over multiple periods

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:57:58.072485
    - Additional Notes: Query provides strategic market insights by analyzing nursing home provider distribution across states, suitable for healthcare market research and investment strategy planning.
    
    */