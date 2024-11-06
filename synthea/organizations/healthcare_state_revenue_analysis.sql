-- Healthcare_Organization_Service_Area_Analysis.sql
-- Business Purpose:
-- - Analyze healthcare organizations by their primary service areas
-- - Identify organizations with multi-state presence
-- - Support strategic market expansion and partnership decisions

WITH ServiceAreaMetrics AS (
    SELECT 
        state,                     -- Grouping by state for regional analysis
        COUNT(DISTINCT id) as org_count,                 -- Total unique organizations
        ROUND(AVG(revenue), 2) as avg_revenue,           -- Average organizational revenue
        ROUND(AVG(utilization), 2) as avg_utilization,   -- Average resource utilization
        ROUND(SUM(revenue), 2) as total_state_revenue,   -- Total revenue per state
        COUNT(DISTINCT city) as city_coverage            -- Number of cities served
    FROM mimi_ws_1.synthea.organizations
    WHERE revenue IS NOT NULL AND utilization IS NOT NULL
    GROUP BY state
)

SELECT 
    state,
    org_count,
    avg_revenue,
    avg_utilization,
    total_state_revenue,
    city_coverage,
    RANK() OVER (ORDER BY total_state_revenue DESC) as state_revenue_rank
FROM ServiceAreaMetrics
ORDER BY total_state_revenue DESC
LIMIT 20;

-- Query Mechanics:
-- 1. Creates a CTE to aggregate organizational metrics by state
-- 2. Calculates key performance indicators
-- 3. Ranks states by total revenue
-- 4. Limits output to top 20 states for digestible insights

-- Assumptions:
-- - Revenue and utilization are meaningful comparative metrics
-- - Multi-state presence suggests organizational complexity
-- - Higher revenue doesn't always indicate better performance

-- Potential Extensions:
-- - Add latitude/longitude clustering
-- - Incorporate patient volume data
-- - Compare urban vs rural organizational characteristics

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:16:45.513632
    - Additional Notes: Analyzes healthcare organization metrics by state, focusing on revenue distribution and organizational presence. Useful for strategic market analysis but dependent on synthetic data limitations.
    
    */