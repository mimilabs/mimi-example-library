-- device_continuity_monitoring.sql
--
-- Business Purpose:
-- Analyze gaps in device usage and transitions between devices to:
-- - Identify potential care continuity issues
-- - Support device replacement planning
-- - Reduce risks of device coverage lapses
-- - Monitor device transition patterns

-- Main Query
WITH sequential_devices AS (
    SELECT 
        patient,
        description,
        start,
        stop,
        LEAD(start) OVER (PARTITION BY patient ORDER BY start) as next_device_start
    FROM mimi_ws_1.synthea.devices
    WHERE stop IS NOT NULL  -- Focus on completed device episodes
),

gap_analysis AS (
    SELECT 
        patient,
        description as current_device,
        start as current_start,
        stop as current_stop,
        next_device_start,
        -- Calculate gap in days between devices
        DATEDIFF(day, stop, next_device_start) as days_between_devices
    FROM sequential_devices
    WHERE next_device_start IS NOT NULL
)

SELECT 
    current_device,
    COUNT(*) as transition_count,
    AVG(days_between_devices) as avg_gap_days,
    MAX(days_between_devices) as max_gap_days,
    MIN(days_between_devices) as min_gap_days,
    -- Flag concerning gaps (e.g., more than 30 days)
    SUM(CASE WHEN days_between_devices > 30 THEN 1 ELSE 0 END) as concerning_gaps
FROM gap_analysis
GROUP BY current_device
HAVING COUNT(*) >= 5  -- Focus on devices with meaningful transition patterns
ORDER BY avg_gap_days DESC;

-- How it works:
-- 1. Creates sequential_devices CTE to pair each device usage with the next one
-- 2. Calculates gaps between device usage in gap_analysis CTE
-- 3. Aggregates results to show device transition patterns and identify potential care gaps

-- Assumptions and Limitations:
-- - Assumes sequential device usage indicates a continuation of care
-- - 30-day threshold for concerning gaps is arbitrary and should be adjusted based on clinical context
-- - Limited to completed device episodes (where stop date exists)
-- - Requires minimum of 5 transitions for meaningful analysis

-- Possible Extensions:
-- 1. Add patient demographic analysis to identify at-risk populations
-- 2. Include specific device types or categories for targeted analysis
-- 3. Implement seasonal analysis of device transitions
-- 4. Add correlation with patient outcomes
-- 5. Create alerts for patients approaching typical device transition times

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:21:29.593391
    - Additional Notes: Query focuses on temporal gaps between sequential device usage, which could help identify potential care continuity issues. The 30-day threshold and 5-transition minimum are configurable parameters that should be adjusted based on specific medical context and organizational requirements.
    
    */