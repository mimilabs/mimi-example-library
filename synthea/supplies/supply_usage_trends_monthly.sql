-- Title: Supply Utilization Timeline Analysis for Resource Planning
--
-- Business Purpose:
-- This query analyzes the temporal patterns of medical supply usage to:
-- - Forecast future supply needs based on historical trends
-- - Identify seasonal variations in supply consumption
-- - Support data-driven budget planning for supply procurement
-- - Enable proactive inventory management

WITH monthly_supply_trends AS (
    -- Aggregate supply usage by month to identify patterns
    SELECT 
        DATE_TRUNC('month', date) as usage_month,
        description,
        COUNT(DISTINCT encounter) as unique_encounters,
        SUM(quantity) as total_quantity,
        COUNT(DISTINCT patient) as unique_patients
    FROM mimi_ws_1.synthea.supplies
    GROUP BY 1, 2
),

supply_momentum AS (
    -- Calculate month-over-month changes in usage
    SELECT 
        usage_month,
        description,
        total_quantity,
        unique_encounters,
        unique_patients,
        LAG(total_quantity) OVER (PARTITION BY description ORDER BY usage_month) as prev_month_quantity,
        ROUND(
            ((total_quantity - LAG(total_quantity) OVER (PARTITION BY description ORDER BY usage_month)) * 100.0 / 
            NULLIF(LAG(total_quantity) OVER (PARTITION BY description ORDER BY usage_month), 0)), 2
        ) as month_over_month_change
    FROM monthly_supply_trends
)

SELECT 
    usage_month,
    description,
    total_quantity,
    unique_encounters,
    unique_patients,
    prev_month_quantity,
    month_over_month_change,
    -- Flag significant changes in usage patterns
    CASE 
        WHEN month_over_month_change > 20 THEN 'Significant Increase'
        WHEN month_over_month_change < -20 THEN 'Significant Decrease'
        ELSE 'Stable'
    END as trend_indicator
FROM supply_momentum
WHERE usage_month >= DATE_ADD(months, -12, CURRENT_DATE())
ORDER BY usage_month DESC, total_quantity DESC;

-- How this query works:
-- 1. Creates monthly aggregations of supply usage
-- 2. Calculates month-over-month changes using window functions
-- 3. Identifies significant variations in usage patterns
-- 4. Focuses on the last 12 months of data for actionable insights

-- Assumptions and Limitations:
-- - Assumes supply usage data is consistently recorded
-- - Month-over-month comparison may be affected by seasonal variations
-- - 20% threshold for significant change is a configurable business rule
-- - Limited to quantity analysis without considering costs

-- Possible Extensions:
-- 1. Add seasonal adjustment factors based on historical patterns
-- 2. Incorporate supply categories or departments for hierarchical analysis
-- 3. Include minimum/maximum thresholds for inventory management
-- 4. Add forecasting calculations based on historical trends
-- 5. Include correlation analysis with specific procedures or departments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:43:00.306377
    - Additional Notes: This query tracks monthly supply consumption patterns and flags significant usage changes (>20% month-over-month). The 12-month lookback window is configurable based on planning needs. Results are most effective when supply data is consistently recorded across all encounters.
    
    */