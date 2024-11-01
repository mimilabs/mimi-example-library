-- Medicare Advantage Plan Market Depth Analysis
-- 
-- Business Purpose:
-- This analysis helps Medicare Advantage organizations and market strategists understand:
-- 1. Market competitiveness through number of competing plans per county
-- 2. Organization market presence depth through multi-plan offerings
-- 3. Plan type diversity in markets to identify potential opportunities
--
-- The insights support:
-- - Market entry/expansion decisions
-- - Competition assessment
-- - Product portfolio optimization

WITH county_metrics AS (
    -- Calculate key market metrics at county level
    SELECT 
        state,
        county,
        COUNT(DISTINCT organization_name) as org_count,
        COUNT(DISTINCT CONCAT(contract_id, plan_id)) as plan_count,
        COUNT(DISTINCT type_of_medicare_health_plan) as plan_type_count
    FROM mimi_ws_1.partcd.landscape_medicare_advantage
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.landscape_medicare_advantage)
    GROUP BY state, county
)

SELECT 
    cm.state,
    cm.county,
    cm.org_count as organizations,
    cm.plan_count as total_plans,
    cm.plan_type_count as unique_plan_types,
    -- Calculate market concentration metrics
    ROUND(cm.plan_count::DECIMAL / cm.org_count, 1) as avg_plans_per_org,
    -- Categorize market competitiveness
    CASE 
        WHEN cm.org_count >= 10 THEN 'Highly Competitive'
        WHEN cm.org_count >= 5 THEN 'Competitive'
        WHEN cm.org_count >= 2 THEN 'Moderately Competitive'
        ELSE 'Limited Competition'
    END as market_competition_level
FROM county_metrics cm
-- Focus on markets with meaningful competition
WHERE cm.org_count > 1
ORDER BY 
    cm.plan_count DESC,
    cm.state,
    cm.county;

-- How This Query Works:
-- 1. Creates a CTE to aggregate market metrics at county level
-- 2. Joins with original table to add organization-specific metrics
-- 3. Calculates competition metrics and categorizes markets
-- 4. Filters to focus on markets with actual competition
--
-- Assumptions and Limitations:
-- - Uses latest data snapshot only
-- - Assumes all plans have equal market impact
-- - Does not consider plan enrollment numbers
-- - Does not account for parent company relationships
--
-- Possible Extensions:
-- 1. Add trend analysis by comparing multiple time periods
-- 2. Include premium ranges to assess price competition
-- 3. Add plan star ratings to evaluate quality competition
-- 4. Incorporate population demographics for market potential
-- 5. Add geographic clustering analysis for regional patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:17:28.732930
    - Additional Notes: Query focuses on competitive dynamics in Medicare Advantage markets at the county level. Most useful for market entry analysis and competitive intelligence. Note that results may be skewed for counties with special circumstances like PACE programs or employer-only plans.
    
    */