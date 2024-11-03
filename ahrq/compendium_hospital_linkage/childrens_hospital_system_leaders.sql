-- Title: Children's Hospital Care Access and Resources Analysis

-- Business Purpose:
-- This analysis examines the distribution and resourcing of children's hospitals across health systems.
-- This helps healthcare executives and policymakers:
-- 1. Evaluate pediatric care access across different regions
-- 2. Identify resource allocation patterns in children's hospitals
-- 3. Support strategic planning for pediatric service expansion

WITH ChildrensHospitalMetrics AS (
    -- Get key metrics for children's hospitals and their health systems
    SELECT 
        h.health_sys_name,
        h.health_sys_state,
        COUNT(DISTINCT h.compendium_hospital_id) as total_childrens_hospitals,
        AVG(h.hos_beds) as avg_beds_per_hospital,
        SUM(h.hos_dsch) as total_discharges,
        AVG(CASE WHEN h.hos_net_revenue IS NOT NULL 
            THEN h.hos_net_revenue ELSE 0 END) as avg_net_revenue,
        COUNT(DISTINCT h.hospital_state) as num_states_served,
        -- Use array_join with collect_set instead of STRING_AGG
        array_join(collect_set(h.hospital_state), ', ') as states_served
    FROM mimi_ws_1.ahrq.compendium_hospital_linkage h
    WHERE h.hos_children = 1  -- Focus on children's hospitals only
    GROUP BY h.health_sys_name, h.health_sys_state
),
SystemRanking AS (
    -- Rank health systems by their children's hospital presence
    SELECT 
        *,
        RANK() OVER (ORDER BY total_childrens_hospitals DESC, total_discharges DESC) as system_rank
    FROM ChildrensHospitalMetrics
)
SELECT 
    health_sys_name,
    health_sys_state,
    total_childrens_hospitals,
    ROUND(avg_beds_per_hospital, 0) as avg_beds,
    total_discharges,
    ROUND(avg_net_revenue/1000000, 2) as avg_net_revenue_millions,
    num_states_served,
    states_served,
    system_rank
FROM SystemRanking
WHERE system_rank <= 10  -- Focus on top 10 systems
ORDER BY system_rank;

-- How the Query Works:
-- 1. First CTE filters for children's hospitals and aggregates key metrics by health system
-- 2. Second CTE ranks health systems based on number of children's hospitals and total discharges
-- 3. Final output shows top 10 health systems with their key pediatric care metrics
-- 4. Results include geographic reach through states_served column

-- Assumptions and Limitations:
-- 1. Assumes hos_children flag accurately identifies all children's hospitals
-- 2. Revenue figures may be missing for some hospitals
-- 3. Analysis is limited to current point in time snapshot
-- 4. Does not account for specialty pediatric services in non-children's hospitals

-- Possible Extensions:
-- 1. Add year-over-year trend analysis when multiple years are available
-- 2. Include comparative analysis with non-children's hospitals
-- 3. Add geographic distance analysis for pediatric care access
-- 4. Incorporate quality metrics and patient outcomes when available
-- 5. Add analysis of teaching status impact on pediatric care delivery

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:46:59.747053
    - Additional Notes: Query focuses on top health systems with children's hospitals, providing insights into market leadership and geographic distribution of pediatric care. Revenue calculations assume $0 for NULL values which may impact averages. The states_served field uses array functions which may have performance implications on very large datasets.
    
    */