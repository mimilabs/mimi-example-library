-- device_type_complexity_analysis.sql
-- Business Purpose: 
-- Analyze medical device complexity and lifecycle characteristics to:
-- - Understand device diversity and technological sophistication
-- - Support medical device inventory and procurement strategies
-- - Provide insights for medical technology investment decisions

WITH device_complexity_metrics AS (
    SELECT 
        code,
        description,
        -- Calculate total usage instances and average device duration
        COUNT(*) AS total_device_instances,
        AVG(DATEDIFF(day, start, stop)) AS avg_device_duration_days,
        
        -- Calculate complexity proxy by device description length
        LENGTH(description) AS description_complexity_score,
        
        -- Identify unique device count to measure variety
        COUNT(DISTINCT udi) AS unique_device_count
    FROM mimi_ws_1.synthea.devices
    WHERE stop IS NOT NULL  -- Ensure complete device lifecycle
    GROUP BY code, description
),
device_sophistication_ranking AS (
    SELECT 
        code,
        description,
        total_device_instances,
        avg_device_duration_days,
        description_complexity_score,
        unique_device_count,
        
        -- Create a composite sophistication score
        ROUND(
            (description_complexity_score * 0.3) + 
            (LOG(total_device_instances) * 0.4) + 
            (LOG(avg_device_duration_days + 1) * 0.3),
            2
        ) AS device_sophistication_index
    FROM device_complexity_metrics
)

SELECT 
    code,
    description,
    total_device_instances,
    avg_device_duration_days,
    unique_device_count,
    device_sophistication_index,
    
    -- Rank devices by sophistication
    DENSE_RANK() OVER (ORDER BY device_sophistication_index DESC) AS sophistication_rank
FROM device_sophistication_ranking
ORDER BY device_sophistication_index DESC
LIMIT 25;

-- Query Mechanics:
-- 1. Aggregates device usage metrics
-- 2. Calculates a composite sophistication index
-- 3. Ranks devices based on technological complexity proxy

-- Assumptions and Limitations:
-- - Sophistication index is a synthetic measure
-- - Assumes longer/more complex descriptions indicate higher technological complexity
-- - Limited by synthetic dataset characteristics

-- Potential Extensions:
-- 1. Incorporate cost data if available
-- 2. Add patient demographic segmentation
-- 3. Implement time-series analysis of device evolution

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:14:14.517399
    - Additional Notes: Generates a composite device sophistication index by analyzing device usage instances, duration, and description complexity. Requires careful interpretation due to synthetic dataset limitations.
    
    */