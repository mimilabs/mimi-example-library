-- air_quality_monitoring_coverage.sql
-- Business Purpose: 
-- Evaluate the effectiveness and reliability of air quality monitoring networks across states
-- by analyzing monitor counts, observation completeness, and certification status.
-- This helps identify gaps in monitoring coverage and data quality issues that could
-- impact environmental policy decisions and public health assessments.

WITH monitor_metrics AS (
  -- Get latest year's monitoring statistics by state
  SELECT 
    state_name,
    year,
    COUNT(DISTINCT CONCAT(state_code, county_code, site_num)) as monitor_count,
    AVG(observation_percent) as avg_observation_pct,
    SUM(CASE WHEN completeness_indicator = 'Y' THEN 1 ELSE 0 END) as complete_monitors,
    SUM(CASE WHEN certification_indicator = 'Certified' THEN 1 ELSE 0 END) as certified_monitors,
    COUNT(*) as total_readings
  FROM mimi_ws_1.epa.airdata_yearly
  WHERE year = (SELECT MAX(year) FROM mimi_ws_1.epa.airdata_yearly)
  GROUP BY state_name, year
)

SELECT
  state_name,
  monitor_count,
  ROUND(avg_observation_pct, 1) as avg_observation_pct,
  ROUND(100.0 * complete_monitors / total_readings, 1) as pct_complete_readings,
  ROUND(100.0 * certified_monitors / total_readings, 1) as pct_certified_readings,
  total_readings
FROM monitor_metrics
WHERE monitor_count >= 5  -- Focus on states with meaningful monitoring presence
ORDER BY monitor_count DESC, avg_observation_pct DESC
LIMIT 20;

-- How this works:
-- 1. Creates a CTE to aggregate monitoring statistics at the state level
-- 2. Calculates key metrics including monitor counts and data quality indicators
-- 3. Filters for states with sufficient monitoring coverage
-- 4. Returns ranked results focusing on states with most extensive monitoring networks

-- Assumptions and Limitations:
-- - Assumes current year data is complete and representative
-- - Does not account for population or geographic size differences between states
-- - Monitor counts may include different types of pollutant measurements
-- - Some states may have strategic rather than comprehensive monitor placement

-- Possible Extensions:
-- 1. Add trend analysis comparing monitoring coverage changes over time
-- 2. Include population-adjusted metrics (monitors per million residents)
-- 3. Break down monitoring coverage by pollutant type
-- 4. Add geographic distribution analysis within states
-- 5. Compare monitoring coverage to EPA minimum requirements
-- 6. Analyze seasonal variations in monitoring completeness

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:05:29.826685
    - Additional Notes: Query focuses on monitoring infrastructure quality rather than pollution levels themselves, providing insights into data collection reliability. Consider state population and geographic size when interpreting results, as raw monitor counts may not reflect coverage adequacy. Best used for identifying potential gaps in air quality surveillance systems.
    
    */