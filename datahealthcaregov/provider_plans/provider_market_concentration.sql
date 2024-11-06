-- provider_plan_market_concentration.sql
-- Business Purpose: Analyze healthcare provider market concentration and insurance plan penetration
-- Identify key providers with extensive plan participation and market reach

WITH provider_plan_summary AS (
    -- Aggregate provider participation across insurance plans
    SELECT 
        npi,
        provider_type,
        COUNT(DISTINCT plan_id) AS total_plan_count,
        COUNT(DISTINCT CASE WHEN network_tier = 'Preferred' THEN plan_id END) AS preferred_plan_count,
        MAX(years) AS most_recent_year
    FROM mimi_ws_1.datahealthcaregov.provider_plans
    GROUP BY npi, provider_type
),
market_concentration_metrics AS (
    -- Calculate market penetration and concentration indicators
    SELECT 
        provider_type,
        
        -- Overall market presence metrics
        COUNT(DISTINCT npi) AS total_providers,
        AVG(total_plan_count) AS avg_plan_participation,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_plan_count) AS plan_participation_75th_percentile,
        
        -- Preferred network participation
        AVG(preferred_plan_count) AS avg_preferred_plan_participation,
        MAX(total_plan_count) AS max_plan_participation
    FROM provider_plan_summary
    GROUP BY provider_type
)

-- Final output: Market concentration insights by provider type
SELECT 
    provider_type,
    total_providers,
    ROUND(avg_plan_participation, 2) AS avg_plan_participation,
    ROUND(plan_participation_75th_percentile, 2) AS plan_participation_75th_percentile,
    ROUND(avg_preferred_plan_participation, 2) AS avg_preferred_plan_participation,
    max_plan_participation
FROM market_concentration_metrics
ORDER BY total_providers DESC, avg_plan_participation DESC;

/*
Query Mechanics:
- Creates a summary of provider plan participation
- Calculates market concentration metrics by provider type
- Provides insights into network breadth and depth

Assumptions:
- Assumes consistent data quality across provider types
- Uses current data snapshot for analysis

Potential Extensions:
1. Add geographic segmentation
2. Include time-series analysis of plan participation
3. Integrate with pricing or quality metrics
4. Develop provider network competitiveness scoring
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:27:44.241077
    - Additional Notes: Analyzes healthcare provider participation across insurance plans, focusing on market penetration and network depth by provider type. Requires careful interpretation due to potential data snapshot limitations.
    
    */