-- Provider Workload and Patient Care Capacity Analysis
--
-- Business Purpose:
-- - Analyze provider utilization patterns to identify high-demand areas and potential bottlenecks
-- - Support capacity planning and resource allocation decisions
-- - Identify opportunities for workload balancing across providers and specialties
-- - Guide staffing decisions and provider recruitment strategies
--
-- Created: 2024-02-14
-- Author: Healthcare Analytics Team

WITH provider_metrics AS (
    -- Calculate aggregate utilization metrics by specialty and location
    SELECT 
        speciality,
        state,
        city,
        COUNT(DISTINCT id) as provider_count,
        AVG(utilization) as avg_utilization,
        MAX(utilization) as max_utilization,
        MIN(utilization) as min_utilization
    FROM mimi_ws_1.synthea.providers
    WHERE utilization IS NOT NULL
    GROUP BY speciality, state, city
),
high_demand_areas AS (
    -- Identify locations with high average utilization
    SELECT 
        state,
        city,
        speciality,
        avg_utilization,
        provider_count
    FROM provider_metrics
    WHERE avg_utilization > (
        SELECT AVG(utilization) 
        FROM mimi_ws_1.synthea.providers
        WHERE utilization IS NOT NULL
    )
)
-- Final result combining key metrics
SELECT 
    h.state,
    h.city,
    h.speciality,
    h.provider_count,
    ROUND(h.avg_utilization, 2) as avg_utilization,
    CASE 
        WHEN h.avg_utilization >= 80 THEN 'Critical'
        WHEN h.avg_utilization >= 60 THEN 'High'
        ELSE 'Moderate'
    END as demand_level
FROM high_demand_areas h
ORDER BY h.avg_utilization DESC, h.provider_count
LIMIT 20;

-- How it works:
-- 1. First CTE calculates key utilization metrics by specialty and location
-- 2. Second CTE identifies areas with above-average utilization
-- 3. Final query adds demand level classification and formats results
--
-- Assumptions and Limitations:
-- - Assumes utilization is a reliable measure of provider workload
-- - Does not account for seasonal variations in demand
-- - Limited to areas with recorded utilization data
-- - Does not consider provider experience or efficiency levels
--
-- Possible Extensions:
-- 1. Add temporal analysis to identify peak demand periods
-- 2. Include organization-level metrics for network planning
-- 3. Incorporate distance calculations for accessibility analysis
-- 4. Add provider-to-population ratios using demographic data
-- 5. Include trend analysis using historical utilization patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:38:54.086285
    - Additional Notes: Query focuses on utilization metrics and may need adjustment of thresholds (60% and 80%) based on specific organizational standards. Consider adding filters for specific date ranges if analyzing seasonal patterns. The LIMIT 20 clause might need adjustment based on reporting needs.
    
    */