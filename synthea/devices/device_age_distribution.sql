-- device_patient_age_segmentation.sql

-- Business Purpose:
-- Analyze medical device usage patterns across different patient age groups to:
-- - Improve age-specific device inventory management
-- - Support targeted patient care programs
-- - Guide clinical staff training needs by demographic segments
-- - Enable more precise device-related cost forecasting

WITH patient_devices AS (
    -- Get patient demographic info and device details
    SELECT 
        d.patient,
        d.code,
        d.description,
        d.start,
        CASE 
            WHEN YEAR(d.start) - YEAR(p.birthdate) < 18 THEN 'Pediatric'
            WHEN YEAR(d.start) - YEAR(p.birthdate) BETWEEN 18 AND 64 THEN 'Adult'
            ELSE 'Geriatric'
        END AS age_group
    FROM mimi_ws_1.synthea.devices d
    JOIN mimi_ws_1.synthea.patients p ON d.patient = p.id
    WHERE d.start IS NOT NULL
),

age_group_summary AS (
    -- Calculate device usage metrics by age group
    SELECT 
        age_group,
        description,
        COUNT(*) as device_count,
        COUNT(DISTINCT patient) as unique_patients,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY age_group), 2) as pct_within_age_group
    FROM patient_devices
    GROUP BY age_group, description
)

SELECT 
    age_group,
    description,
    device_count,
    unique_patients,
    pct_within_age_group
FROM age_group_summary
WHERE device_count > 10  -- Filter for significant usage patterns
ORDER BY age_group, device_count DESC;

-- How this query works:
-- 1. First CTE joins devices and patients tables to get demographic information
-- 2. Calculates age group based on year difference between device start and birth date
-- 3. Second CTE aggregates device usage metrics by age group
-- 4. Final output shows device distribution patterns across age segments

-- Assumptions and Limitations:
-- - Uses year difference for age calculation (not exact age)
-- - Age groups are simplified into three categories
-- - Analysis is based on device start dates only
-- - Minimum threshold of 10 devices for meaningful patterns

-- Possible Extensions:
-- 1. Add gender analysis within age groups
-- 2. Include device duration analysis
-- 3. Incorporate seasonal trends analysis
-- 4. Add geographic segmentation
-- 5. Include device complication rates by age group
-- 6. Add cost analysis dimension
-- 7. Compare against diagnosis patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:41:00.781839
    - Additional Notes: Query performs demographic analysis of device usage across age groups. Note that age calculation is approximate using year difference rather than exact dates. Results are filtered to show only patterns with more than 10 device instances to ensure statistical relevance.
    
    */