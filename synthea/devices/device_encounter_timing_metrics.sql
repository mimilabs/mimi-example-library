-- devices_clinical_workflow_impact.sql
--
-- Business Purpose:
-- Analyze the relationship between device usage and clinical encounters to:
-- - Identify bottlenecks in device-related clinical workflows
-- - Optimize scheduling of device-related procedures
-- - Improve resource allocation for device-dependent services
-- 
-- The analysis helps operations teams better align staffing and resources
-- with device-related clinical workflows.

WITH encounter_device_metrics AS (
    -- Calculate time between encounter and device start
    SELECT 
        d.encounter,
        d.description as device_type,
        COUNT(*) as device_count,
        AVG(DATEDIFF(d.start, e.start)) as avg_days_to_device_start
    FROM mimi_ws_1.synthea.devices d
    JOIN mimi_ws_1.synthea.encounters e ON d.encounter = e.id
    WHERE d.start >= '2020-01-01'
    AND d.start IS NOT NULL 
    AND e.start IS NOT NULL
    GROUP BY d.encounter, d.description
)

SELECT 
    device_type,
    COUNT(encounter) as total_encounters,
    ROUND(AVG(device_count), 2) as avg_devices_per_encounter,
    ROUND(AVG(avg_days_to_device_start), 2) as avg_days_from_encounter_to_device,
    ROUND(STDDEV(avg_days_to_device_start), 2) as days_stddev
FROM encounter_device_metrics
GROUP BY device_type
HAVING total_encounters >= 10
ORDER BY total_encounters DESC;

-- How it works:
-- 1. Creates a CTE that joins devices to encounters
-- 2. Calculates key timing metrics between encounter start and device placement
-- 3. Aggregates metrics by device type for meaningful patterns
-- 4. Filters for device types with sufficient volume (10+ encounters)
--
-- Assumptions & Limitations:
-- - Assumes encounter and device timestamps are accurate
-- - Limited to encounters with device placements
-- - May not capture all workflow complexities
-- - Synthetic data may not reflect real-world timing patterns
--
-- Possible Extensions:
-- - Add facility/location stratification
-- - Include provider specialty analysis
-- - Add seasonal/time-of-day patterns
-- - Incorporate procedure codes for more context
-- - Add resource utilization metrics
-- - Calculate device preparation time metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:19:24.425170
    - Additional Notes: The query measures the timing relationship between encounters and device placements, focusing on workflow efficiency metrics. Results are aggregated at the device type level with a minimum threshold of 10 encounters to ensure statistical relevance. Time differences are measured in days rather than hours due to Databricks SQL date handling limitations.
    
    */