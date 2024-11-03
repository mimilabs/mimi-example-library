-- Medicare Advantage Network and Coverage Type Analysis
--
-- Business Purpose:
-- This analysis helps healthcare providers and network managers understand:
-- 1. Which plan types dominate different markets
-- 2. Financial accessibility through MOOP analysis
-- 3. Network design patterns across organizations
-- Supports decisions around network participation and expansion strategy

WITH plan_type_summary AS (
    -- Aggregate core plan characteristics by organization and type
    SELECT 
        organization_name,
        type_of_medicare_health_plan,
        COUNT(DISTINCT concat(contract_id, plan_id)) as total_plans,
        AVG(innetwork_moop_amount) as avg_moop,
        COUNT(DISTINCT state) as states_served,
        COUNT(DISTINCT county) as counties_served
    FROM mimi_ws_1.partcd.landscape_medicare_advantage
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.landscape_medicare_advantage)
    GROUP BY 1, 2
),

org_rankings AS (
    -- Identify market leaders by footprint
    SELECT 
        organization_name,
        SUM(total_plans) as total_plans,
        SUM(counties_served) as total_counties,
        CONCAT_WS(', ',
            COLLECT_LIST(CONCAT(type_of_medicare_health_plan, ' (', CAST(total_plans AS STRING), ')')))
            as plan_type_mix
    FROM plan_type_summary
    GROUP BY 1
)

SELECT 
    p.organization_name,
    p.type_of_medicare_health_plan,
    p.total_plans,
    ROUND(p.avg_moop, 2) as avg_moop_amount,
    p.states_served,
    p.counties_served,
    o.total_counties as org_total_counties,
    o.plan_type_mix
FROM plan_type_summary p
JOIN org_rankings o ON p.organization_name = o.organization_name
WHERE o.total_counties >= 100  -- Focus on organizations with significant presence
ORDER BY o.total_counties DESC, p.total_plans DESC
LIMIT 20;

-- How this query works:
-- 1. Creates summary metrics for each organization's plan types
-- 2. Calculates organization-wide footprint and plan mix
-- 3. Joins these views to show both plan-type and org-level insights
-- 4. Filters to focus on organizations with significant market presence

-- Assumptions and Limitations:
-- - Uses most recent data snapshot only
-- - Treats all counties equally (doesn't account for population)
-- - MOOP amounts are simple averages
-- - Focuses only on organizations with broad geographic presence

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include premium analysis alongside network characteristics
-- 3. Add population-weighted market penetration metrics
-- 4. Compare rural vs urban county presence
-- 5. Analyze correlation between network type and star ratings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:04:02.609718
    - Additional Notes: The query focuses on organizations with 100+ counties coverage and uses CONCAT_WS/COLLECT_LIST for plan type aggregation. Results include both organization-level metrics and plan type breakdowns, with emphasis on network reach and MOOP analysis. Best used for strategic network planning and market positioning analysis.
    
    */