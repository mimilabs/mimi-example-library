
/* 
Title: Most Common Medical Devices Analysis
Business Purpose: Analyze the distribution and duration of medical device usage to:
- Understand which devices are most frequently used
- Track average usage duration for resource planning
- Identify potential trends in device utilization
*/

WITH device_metrics AS (
  -- Calculate duration and current status for each device
  SELECT 
    code,
    description,
    -- Check if device is currently in use
    CASE WHEN stop IS NULL THEN 'Active' ELSE 'Discontinued' END as device_status,
    -- Calculate duration in days
    CASE 
      WHEN stop IS NOT NULL THEN DATEDIFF(stop, start)
      ELSE DATEDIFF(CURRENT_DATE(), start)
    END as duration_days
  FROM mimi_ws_1.synthea.devices
  WHERE start IS NOT NULL
),

summary_stats AS (
  -- Aggregate metrics by device type
  SELECT
    code,
    description,
    COUNT(*) as total_devices,
    ROUND(AVG(duration_days),1) as avg_duration_days,
    COUNT(CASE WHEN device_status = 'Active' THEN 1 END) as active_devices,
    ROUND(COUNT(CASE WHEN device_status = 'Active' THEN 1 END) * 100.0 / COUNT(*), 1) as active_percentage
  FROM device_metrics
  GROUP BY code, description
)

-- Final output sorted by most common devices
SELECT
  code as device_code,
  description as device_name,
  total_devices,
  active_devices,
  active_percentage as active_devices_pct,
  avg_duration_days
FROM summary_stats
WHERE total_devices >= 10  -- Filter for commonly used devices
ORDER BY total_devices DESC
LIMIT 20;

/*
How it works:
1. First CTE calculates device status and duration for each record
2. Second CTE aggregates metrics by device type
3. Final query formats and filters results for analysis

Assumptions & Limitations:
- Assumes NULL stop date means device is still active
- Limited to devices with at least 10 instances for significance
- Duration calculation may be affected by data quality issues
- Synthetic data may not reflect real-world patterns

Possible Extensions:
1. Add temporal analysis to show trends over time:
   - Monthly/yearly device adoption rates
   - Seasonal patterns in device usage

2. Include patient demographics:
   - Age distribution for each device type
   - Geographic patterns in device usage

3. Add cost analysis:
   - Total cost of active devices
   - Cost per patient per device type

4. Enhanced filtering:
   - Filter by date ranges
   - Focus on specific device categories
   - Add encounter type analysis
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:55:26.884832
    - Additional Notes: Query assumes current active devices based on NULL stop dates. Minimum threshold of 10 devices may need adjustment based on data volume. Duration calculations include active devices which may skew average duration metrics for recently introduced devices.
    
    */