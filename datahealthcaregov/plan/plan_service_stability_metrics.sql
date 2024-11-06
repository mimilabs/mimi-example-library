-- Healthcare.gov Plan Service Continuity Analysis
-- ================================================
-- Business Purpose: 
-- Analyze the consistency and longevity of health insurance plans to identify
-- stable market participants and assess service reliability for consumers.
-- This helps inform both consumer choice and market stability assessment.

WITH plan_continuity AS (
    -- Calculate the service duration for each plan
    SELECT 
        plan_id,
        plan_id_type,
        marketing_name,
        MIN(years) as first_year,
        MAX(years) as last_year,
        COUNT(DISTINCT years) as years_of_service,
        network,
        -- Flag if the plan is currently active (using latest year in data)
        CASE WHEN MAX(years) = (SELECT MAX(years) FROM mimi_ws_1.datahealthcaregov.plan)
             THEN 1 ELSE 0 END as is_current
    FROM mimi_ws_1.datahealthcaregov.plan
    GROUP BY plan_id, plan_id_type, marketing_name, network
),

service_metrics AS (
    -- Calculate service continuity metrics
    SELECT 
        network,
        COUNT(DISTINCT plan_id) as total_plans,
        AVG(years_of_service) as avg_years_of_service,
        COUNT(DISTINCT CASE WHEN is_current = 1 THEN plan_id END) as active_plans,
        COUNT(DISTINCT CASE WHEN years_of_service >= 3 THEN plan_id END) as stable_plans
    FROM plan_continuity
    GROUP BY network
)

SELECT 
    network,
    total_plans,
    ROUND(avg_years_of_service, 2) as avg_years_of_service,
    active_plans,
    stable_plans,
    ROUND(100.0 * stable_plans / NULLIF(total_plans, 0), 1) as stable_plan_percentage,
    ROUND(100.0 * active_plans / NULLIF(total_plans, 0), 1) as active_plan_percentage
FROM service_metrics
WHERE network IS NOT NULL
ORDER BY total_plans DESC;

-- How this query works:
-- 1. Creates a CTE to calculate service duration metrics for each plan
-- 2. Aggregates these metrics by network type
-- 3. Calculates key stability indicators including:
--    - Total number of plans
--    - Average years of service
--    - Number of currently active plans
--    - Number of stable plans (3+ years of service)
--    - Percentages for stable and active plans

-- Assumptions and limitations:
-- 1. Assumes plan_id is consistently used across years
-- 2. Defines "stable" plans as those with 3+ years of service
-- 3. Current year is determined by max year in the dataset
-- 4. Null networks are excluded from final results

-- Possible Extensions:
-- 1. Add geographical analysis by joining with plan service area data
-- 2. Include plan type analysis for different network configurations
-- 3. Incorporate premium data to analyze price stability
-- 4. Add year-over-year retention rate calculations
-- 5. Include market share analysis for stable vs non-stable plans

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:28:15.210123
    - Additional Notes: Query focuses on key stability metrics across healthcare networks and may require significant processing time for large datasets. Results are most meaningful when the data spans multiple years. Network NULL values are excluded to ensure data quality, which might impact completeness if significant portion of data has missing network values.
    
    */