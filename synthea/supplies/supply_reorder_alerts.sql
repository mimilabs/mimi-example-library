-- Title: Medical Supply Reorder Point Analysis

-- Business Purpose:
-- This query identifies critical supply items that need reordering based on:
-- - Current usage rates and remaining quantities
-- - Historical consumption patterns
-- - Minimum safety stock thresholds
-- The insights help prevent stockouts while optimizing inventory capital

-- Main Query
WITH daily_usage AS (
    -- Calculate average daily usage per supply item
    SELECT 
        code,
        description,
        SUM(quantity) as total_quantity,
        COUNT(DISTINCT date) as days_with_usage,
        SUM(quantity) / COUNT(DISTINCT date) as avg_daily_usage
    FROM mimi_ws_1.synthea.supplies
    WHERE date >= DATE_SUB(CURRENT_DATE(), 90) -- Last 90 days
    GROUP BY code, description
),

latest_supply_dates AS (
    -- Get most recent usage date for each supply
    SELECT
        code,
        MAX(date) as last_used_date
    FROM mimi_ws_1.synthea.supplies
    GROUP BY code
)

SELECT 
    du.code,
    du.description,
    du.avg_daily_usage,
    du.total_quantity,
    du.days_with_usage,
    ls.last_used_date,
    DATEDIFF(CURRENT_DATE(), ls.last_used_date) as days_since_last_use,
    -- Calculate estimated days until reorder needed (assuming 30-day safety stock)
    ROUND((du.total_quantity / NULLIF(du.avg_daily_usage, 0)) - 30) as days_until_reorder
FROM daily_usage du
JOIN latest_supply_dates ls ON du.code = ls.code
WHERE du.avg_daily_usage > 0
ORDER BY days_until_reorder ASC;

-- How it works:
-- 1. Creates a CTE to calculate average daily usage metrics for each supply item
-- 2. Creates a CTE to identify the most recent usage date for each supply
-- 3. Joins these together to provide a comprehensive view of supply usage patterns
-- 4. Calculates days until reorder point based on current usage rates
-- 5. Orders results to highlight items needing attention first

-- Assumptions and Limitations:
-- - Assumes consistent usage patterns over the 90-day lookback period
-- - Does not account for seasonal variations in supply usage
-- - Assumes a 30-day safety stock requirement
-- - Does not consider supplier lead times or order minimums
-- - Does not incorporate actual current inventory levels (not in dataset)

-- Possible Extensions:
-- 1. Add seasonality adjustments based on historical patterns
-- 2. Incorporate cost data to prioritize high-value items
-- 3. Group supplies by category or department
-- 4. Add trend analysis to detect changing usage patterns
-- 5. Create supply-specific safety stock calculations based on criticality

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:23:05.106248
    - Additional Notes: Query focuses on time-sensitive reordering needs by analyzing usage patterns over a 90-day window. Safety stock threshold of 30 days is hardcoded and may need adjustment based on specific facility requirements. Does not reflect actual inventory levels since they're not available in the dataset.
    
    */