-- COVID-19 Wastewater Surveillance Detection Reliability Analysis
--
-- Business Purpose:
-- Analyze the reliability and consistency of COVID-19 detection across wastewater testing sites
-- to help public health officials understand testing quality and make informed decisions about
-- resource allocation and surveillance strategy improvements.
--
-- This analysis focuses on detection rates and testing consistency to identify:
-- 1. Sites with highly reliable detection capabilities
-- 2. Jurisdictions that may need additional support or quality improvements
-- 3. Changes in detection reliability over time

WITH site_metrics AS (
    -- Calculate key reliability metrics for each testing site
    SELECT 
        wwtp_jurisdiction,
        key_plot_id,
        population_served,
        AVG(detect_prop_15d) as avg_detection_rate,
        COUNT(DISTINCT date_start) as number_of_testing_periods,
        MIN(first_sample_date) as monitoring_start_date,
        MAX(date_end) as latest_sample_date,
        COUNT(*) as total_samples
    FROM mimi_ws_1.cdc.nwss_covid
    WHERE detect_prop_15d IS NOT NULL
    GROUP BY wwtp_jurisdiction, key_plot_id, population_served
),
jurisdiction_summary AS (
    -- Aggregate metrics at jurisdiction level
    SELECT 
        wwtp_jurisdiction,
        COUNT(DISTINCT key_plot_id) as active_sites,
        SUM(population_served) as total_population_covered,
        AVG(avg_detection_rate) as jurisdiction_avg_detection_rate,
        AVG(number_of_testing_periods) as avg_testing_periods
    FROM site_metrics
    GROUP BY wwtp_jurisdiction
)

SELECT 
    j.wwtp_jurisdiction,
    j.active_sites,
    j.total_population_covered,
    ROUND(j.jurisdiction_avg_detection_rate, 2) as avg_detection_rate,
    ROUND(j.avg_testing_periods, 0) as avg_testing_periods,
    -- Identify top performing sites in each jurisdiction
    COUNT(CASE WHEN s.avg_detection_rate >= 90 THEN 1 END) as high_reliability_sites,
    -- Calculate percentage of sites with good detection rates
    ROUND(100.0 * COUNT(CASE WHEN s.avg_detection_rate >= 90 THEN 1 END) / j.active_sites, 1) as pct_reliable_sites
FROM jurisdiction_summary j
JOIN site_metrics s ON j.wwtp_jurisdiction = s.wwtp_jurisdiction
GROUP BY 
    j.wwtp_jurisdiction,
    j.active_sites,
    j.total_population_covered,
    j.jurisdiction_avg_detection_rate,
    j.avg_testing_periods
ORDER BY j.total_population_covered DESC;

-- How this query works:
-- 1. First CTE (site_metrics) calculates reliability metrics for each testing site
-- 2. Second CTE (jurisdiction_summary) aggregates these metrics by jurisdiction
-- 3. Final query joins these together to provide a comprehensive view of testing reliability
-- 4. Results are ordered by population covered to focus on highest-impact areas first

-- Assumptions and limitations:
-- 1. Assumes detect_prop_15d is the primary indicator of detection reliability
-- 2. Sites with NULL detection proportions are excluded
-- 3. Defines "high reliability" as >= 90% detection rate (this threshold can be adjusted)
-- 4. Does not account for seasonal variations in detection rates

-- Possible extensions:
-- 1. Add trend analysis to show how reliability has changed over time
-- 2. Include comparison of detection rates vs viral load (percentile) to validate results
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Include cost-benefit analysis by correlating population served with detection reliability
-- 5. Add seasonal adjustment factors to account for environmental impacts on detection rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:13:17.065944
    - Additional Notes: Query focuses on detection reliability metrics across testing sites and jurisdictions, providing insights into testing quality and coverage. The 90% threshold for high reliability sites is configurable based on specific program requirements. Population coverage calculations may include overlap in multi-jurisdiction areas.
    
    */