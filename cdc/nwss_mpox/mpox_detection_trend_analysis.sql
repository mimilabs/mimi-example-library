-- NWSS Mpox Temporal Detection Patterns Analysis
-- Business Purpose: Track changes in mpox detection rates over time to identify early warning 
-- signals and assess effectiveness of public health interventions by analyzing week-over-week 
-- trends in positive sample rates.

WITH weekly_metrics AS (
    -- Calculate weekly detection metrics for each sewershed
    SELECT 
        sewershed,
        DATE_TRUNC('week', sample_collect_date) as sample_week,
        fullgeoname as state,
        population_served,
        SUM(pos_samples) as weekly_positive_samples,
        SUM(total_samples) as weekly_total_samples,
        ROUND(100.0 * SUM(pos_samples) / NULLIF(SUM(total_samples), 0), 2) as weekly_detection_rate
    FROM mimi_ws_1.cdc.nwss_mpox
    WHERE sample_collect_date >= DATE_SUB(CURRENT_DATE, 90)
    GROUP BY sewershed, DATE_TRUNC('week', sample_collect_date), fullgeoname, population_served
),

detection_trends AS (
    -- Calculate week-over-week changes in detection rates
    SELECT 
        state,
        sample_week,
        COUNT(DISTINCT sewershed) as active_sites,
        SUM(population_served) as total_population_monitored,
        AVG(weekly_detection_rate) as avg_detection_rate,
        SUM(weekly_positive_samples) as total_positive_samples,
        LAG(AVG(weekly_detection_rate)) OVER (PARTITION BY state ORDER BY sample_week) as prev_week_rate
    FROM weekly_metrics
    GROUP BY state, sample_week
)

-- Final output showing significant changes in detection patterns
SELECT 
    state,
    sample_week,
    active_sites,
    total_population_monitored,
    avg_detection_rate,
    ROUND(avg_detection_rate - prev_week_rate, 2) as week_over_week_change,
    CASE 
        WHEN avg_detection_rate > prev_week_rate THEN 'Increasing'
        WHEN avg_detection_rate < prev_week_rate THEN 'Decreasing'
        ELSE 'Stable'
    END as trend_direction
FROM detection_trends
WHERE prev_week_rate IS NOT NULL
ORDER BY sample_week DESC, state;

-- How this works:
-- 1. First CTE aggregates data to weekly level for each sewershed
-- 2. Second CTE calculates state-level metrics and week-over-week changes
-- 3. Final query identifies significant changes and trends in detection rates

-- Assumptions and Limitations:
-- - Requires consistent weekly sampling for meaningful trend analysis
-- - Uses 90-day lookback period for recent trends
-- - Assumes data quality and reporting consistency across sites
-- - Does not account for variations in testing methods or detection thresholds

-- Possible Extensions:
-- 1. Add statistical significance testing for trend changes
-- 2. Incorporate seasonality adjustments
-- 3. Create alerts for sudden spikes in detection rates
-- 4. Add geographic clustering analysis
-- 5. Compare trends with reported clinical cases
-- 6. Add visualization recommendations for dashboard integration

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:15:28.361591
    - Additional Notes: This query focuses on 90-day temporal patterns in mpox detection rates, providing week-over-week comparisons at both sewershed and state levels. Best used for ongoing monitoring and early warning detection of significant changes in mpox presence across monitored populations. Requires at least 2 consecutive weeks of data for meaningful trend analysis.
    
    */