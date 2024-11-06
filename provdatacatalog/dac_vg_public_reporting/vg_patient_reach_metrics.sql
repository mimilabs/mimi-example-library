-- vg_population_reach_analytics.sql

-- Business Purpose:
-- Analyze the population reach and impact of virtual groups by examining total patient counts
-- and measure coverage. This helps:
-- - Assess the scale and scope of virtual group care delivery
-- - Identify opportunities for population health management
-- - Understand which virtual groups are serving larger patient populations
-- - Support resource allocation and strategic planning decisions

WITH patient_metrics AS (
    -- Calculate total patient reach and measure counts per virtual group
    SELECT 
        virtual_group_id,
        COUNT(DISTINCT measure_cd) as measure_count,
        SUM(patient_count) as total_patients_served,
        MAX(mimi_src_file_date) as latest_report_date
    FROM mimi_ws_1.provdatacatalog.dac_vg_public_reporting
    WHERE patient_count IS NOT NULL
    GROUP BY virtual_group_id
),

ranked_groups AS (
    -- Identify virtual groups with significant patient populations
    SELECT 
        virtual_group_id,
        measure_count,
        total_patients_served,
        latest_report_date,
        ROW_NUMBER() OVER (ORDER BY total_patients_served DESC) as patient_volume_rank
    FROM patient_metrics
    WHERE total_patients_served > 0
)

-- Final output combining volume and coverage metrics
SELECT 
    r.virtual_group_id,
    r.measure_count as number_of_measures_reported,
    r.total_patients_served,
    r.patient_volume_rank,
    ROUND(r.total_patients_served / r.measure_count, 2) as avg_patients_per_measure,
    r.latest_report_date
FROM ranked_groups r
WHERE r.patient_volume_rank <= 20  -- Focus on top 20 groups by volume
ORDER BY r.total_patients_served DESC;

-- How it works:
-- 1. First CTE aggregates patient counts and measure coverage by virtual group
-- 2. Second CTE ranks virtual groups by total patient volume
-- 3. Final query combines metrics and focuses on top groups by volume
-- 4. Results show comprehensive view of population reach per virtual group

-- Assumptions and Limitations:
-- - Patient counts are deduplicated within measures but may overlap across measures
-- - Only includes measures with reported patient counts
-- - Rankings may change over time as new data is reported
-- - Patient volume is used as a proxy for organizational impact/reach

-- Possible Extensions:
-- 1. Add year-over-year growth analysis of patient populations
-- 2. Include geographical analysis if location data becomes available
-- 3. Break down patient volumes by measure type/category
-- 4. Compare virtual group sizes with traditional practice group volumes
-- 5. Add quality performance correlation with patient volume

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:46:35.779004
    - Additional Notes: Query focuses on patient population metrics and service coverage across virtual groups, providing insights into organizational scale. Results are limited to top 20 groups by volume and require non-null patient counts. Average patients per measure may be affected by measure overlap within groups.
    
    */