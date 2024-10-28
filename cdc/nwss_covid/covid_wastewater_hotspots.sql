
/*******************************************************************************
Title: COVID-19 Wastewater Surveillance Hotspot Analysis
 
Business Purpose:
This query identifies areas with concerning COVID-19 trends based on wastewater 
surveillance data by analyzing:
1. Recent high viral loads (percentile)
2. Rapid increases in viral concentration (ptc_15d)
3. High detection rates (detect_prop_15d)
4. Population impact (population_served)

This helps public health officials identify emerging hotspots and allocate 
resources effectively.
*******************************************************************************/

WITH recent_data AS (
  -- Get most recent 30 days of data for each location
  SELECT 
    wwtp_jurisdiction AS state,
    county_names,
    population_served,
    percentile AS current_viral_level_percentile,
    ptc_15d AS percent_change_15day,
    detect_prop_15d AS detection_rate,
    date_end
  FROM mimi_ws_1.cdc.nwss_covid
  WHERE date_end >= DATE_SUB(CURRENT_DATE(), 30)
),

hotspots AS (
  -- Identify concerning locations based on key metrics
  SELECT
    state,
    county_names,
    population_served,
    current_viral_level_percentile,
    percent_change_15day,
    detection_rate,
    date_end
  FROM recent_data
  WHERE current_viral_level_percentile >= 75  -- High viral levels
    AND percent_change_15day >= 100          -- Doubled or more in 15 days
    AND detection_rate >= 80                 -- High detection rate
)

SELECT 
  state,
  county_names,
  FORMAT_NUMBER(population_served, 0) as population_affected,
  ROUND(current_viral_level_percentile, 1) as viral_level_percentile,
  ROUND(percent_change_15day, 1) as viral_increase_percent,
  ROUND(detection_rate, 1) as detection_rate_percent,
  date_end as report_date
FROM hotspots
ORDER BY 
  population_served DESC,
  current_viral_level_percentile DESC;

/*******************************************************************************
How it works:
1. First CTE gets recent data within last 30 days
2. Second CTE filters for concerning locations based on three key metrics
3. Final query formats results and orders by population impact

Assumptions & Limitations:
- Assumes current data is available within last 30 days
- Threshold values (75th percentile, 100% increase, 80% detection) are examples
  and should be adjusted based on public health guidance
- Some locations may have missing/null values for metrics

Possible Extensions:
1. Add week-over-week trend analysis
2. Include geographic clustering of hotspots
3. Compare against historical patterns
4. Add vaccination rate correlation
5. Create risk scoring system combining multiple metrics
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:18:29.933867
    - Additional Notes: Query focuses on high-risk areas by combining three key surveillance metrics (viral levels, growth rate, and detection rate) with population impact. Threshold values (75th percentile, 100% increase, 80% detection) may need adjustment based on current public health guidelines. The 30-day window ensures focus on current trends while maintaining enough data for meaningful analysis.
    
    */