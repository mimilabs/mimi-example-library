-- COVID-19 Wastewater Surveillance First Detection Analysis
--
-- Business Purpose:
-- Track where COVID-19 is first detected in wastewater systems to enable early warning
-- and rapid public health response. This analysis helps identify:
-- 1. Communities that show earliest detection of COVID-19 in wastewater
-- 2. The lag time between first detection and peak levels
-- 3. Geographic patterns of initial COVID spread through wastewater detection

WITH first_detections AS (
    -- Get the first significant detection for each location
    SELECT 
        wwtp_jurisdiction,
        key_plot_id,
        county_names,
        population_served,
        first_sample_date,
        MIN(date_start) as first_detection_date,
        MIN(percentile) as initial_percentile,
        MAX(percentile) as max_percentile
    FROM mimi_ws_1.cdc.nwss_covid
    WHERE detect_prop_15d > 0.5  -- Focusing on meaningful detection levels
    GROUP BY 1,2,3,4,5
),

detection_metrics AS (
    -- Calculate time to peak and detection patterns
    SELECT 
        wwtp_jurisdiction as state,
        county_names,
        population_served,
        first_sample_date,
        first_detection_date,
        initial_percentile,
        max_percentile,
        DATEDIFF(day, first_detection_date, first_sample_date) as days_to_detection
    FROM first_detections
    WHERE first_detection_date IS NOT NULL
)

-- Final summary focusing on most recent detection patterns
SELECT 
    state,
    COUNT(DISTINCT county_names) as counties_monitored,
    SUM(population_served) as total_population_covered,
    AVG(days_to_detection) as avg_days_to_detection,
    AVG(initial_percentile) as avg_initial_percentile,
    AVG(max_percentile) as avg_max_percentile
FROM detection_metrics
WHERE first_detection_date >= DATE_SUB(CURRENT_DATE(), 90)  -- Last 90 days
GROUP BY state
HAVING counties_monitored > 0
ORDER BY avg_days_to_detection;

-- How this works:
-- 1. First CTE identifies the initial detection date for each location
-- 2. Second CTE calculates key metrics about detection timing and patterns
-- 3. Final query summarizes results by state for recent detections

-- Assumptions and limitations:
-- 1. Assumes detection_prop_15d > 0.5 represents meaningful viral presence
-- 2. Limited to last 90 days of data for current relevance
-- 3. Does not account for testing frequency variations
-- 4. Population served estimates may have some uncertainty

-- Possible extensions:
-- 1. Add seasonal pattern analysis of first detections
-- 2. Include demographic data to analyze detection patterns by community characteristics
-- 3. Correlate detection timing with local public health measures
-- 4. Add geographic clustering analysis of initial detections
-- 5. Include variant detection timing analysis when available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:37:42.864049
    - Additional Notes: Query focuses on early warning signals by analyzing the timing and patterns of initial COVID-19 detections in wastewater systems across jurisdictions. The 90-day window makes it particularly useful for identifying recent emergence patterns. Consider adjusting the detection threshold (0.5) based on local testing sensitivity parameters.
    
    */