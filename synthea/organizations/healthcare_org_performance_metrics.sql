-- Revenue_Utilization_Analysis.sql
-- Business Purpose: 
-- - Analyze the relationship between revenue and utilization across healthcare organizations
-- - Identify high-performing and potentially struggling facilities
-- - Support resource allocation and performance improvement initiatives
-- - Enable data-driven decisions for healthcare system optimization

WITH org_metrics AS (
    -- Calculate key performance metrics
    SELECT 
        name,
        city,
        state,
        revenue,
        utilization,
        revenue / NULLIF(utilization, 0) as revenue_per_util_unit,
        AVG(revenue) OVER (PARTITION BY state) as state_avg_revenue,
        AVG(utilization) OVER (PARTITION BY state) as state_avg_utilization
    FROM mimi_ws_1.synthea.organizations
    WHERE revenue > 0 AND utilization > 0
),
performance_categories AS (
    -- Categorize organizations by performance relative to state averages
    SELECT 
        *,
        CASE 
            WHEN revenue > state_avg_revenue AND utilization > state_avg_utilization 
                THEN 'High Performance'
            WHEN revenue < state_avg_revenue AND utilization < state_avg_utilization 
                THEN 'Underperforming'
            WHEN revenue > state_avg_revenue AND utilization < state_avg_utilization 
                THEN 'Efficient'
            ELSE 'High Utilization'
        END as performance_category
    FROM org_metrics
)
-- Final result set with key insights
SELECT 
    state,
    performance_category,
    COUNT(*) as facility_count,
    ROUND(AVG(revenue), 2) as avg_revenue,
    ROUND(AVG(utilization), 2) as avg_utilization,
    ROUND(AVG(revenue_per_util_unit), 2) as avg_revenue_per_util
FROM performance_categories
GROUP BY state, performance_category
ORDER BY state, avg_revenue DESC;

-- How it works:
-- 1. First CTE calculates key metrics and state-level averages
-- 2. Second CTE categorizes facilities based on performance vs state averages
-- 3. Final query aggregates results by state and performance category
-- 4. Results show distribution of facility performance types and their metrics

-- Assumptions and Limitations:
-- - Assumes revenue and utilization values are meaningful and comparable
-- - Does not account for facility size or type differences
-- - State averages may be skewed by outliers
-- - Requires non-zero revenue and utilization values

-- Possible Extensions:
-- 1. Add time-based trending analysis using mimi_src_file_date
-- 2. Include facility size normalization based on additional metrics
-- 3. Add geographic clustering analysis using lat/lon coordinates
-- 4. Incorporate seasonal variation analysis
-- 5. Create performance improvement opportunity scoring
-- 6. Add peer group comparisons within similar facility types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:31:42.632809
    - Additional Notes: The query focuses on performance categorization and could be sensitive to outliers in state-level data. Revenue per utilization unit calculations should be validated against business rules for meaningful interpretation. Zero values are excluded which may impact completeness of analysis.
    
    */