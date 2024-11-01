-- seasonal_extremes_analysis.sql
--
-- Business Purpose:
-- Analyze seasonal patterns in extreme air quality measurements to help:
-- 1. Environmental agencies plan seasonal enforcement and monitoring activities
-- 2. Healthcare organizations prepare for high-risk periods
-- 3. Communities develop targeted public health response strategies
--
-- The analysis focuses on identifying which seasons tend to have the highest
-- pollutant concentrations and most frequent extreme events.

WITH quarterly_metrics AS (
  -- Extract quarterly metrics for key air pollutants
  SELECT 
    year,
    CASE 
      WHEN MONTH(1st_max_date_time) IN (12,1,2) THEN 'Winter'
      WHEN MONTH(1st_max_date_time) IN (3,4,5) THEN 'Spring'
      WHEN MONTH(1st_max_date_time) IN (6,7,8) THEN 'Summer'
      WHEN MONTH(1st_max_date_time) IN (9,10,11) THEN 'Fall'
    END AS season,
    parameter_name,
    COUNT(DISTINCT CONCAT(state_code, county_code, site_num)) as monitor_count,
    AVG(1st_max_value) as avg_max_value,
    MAX(1st_max_value) as highest_max_value,
    SUM(primary_exceedance_count) as total_exceedances,
    AVG(exceptional_data_count) as avg_exceptional_events
  FROM mimi_ws_1.epa.airdata_yearly
  WHERE 
    -- Focus on recent years and key pollutants
    year >= 2018
    AND parameter_name IN (
      'Ozone',
      'PM2.5 - Local Conditions',
      'PM10 Total 0-10um STP',
      'Nitrogen dioxide (NO2)'
    )
    AND completeness_indicator = 'Y'
  GROUP BY 
    year,
    CASE 
      WHEN MONTH(1st_max_date_time) IN (12,1,2) THEN 'Winter'
      WHEN MONTH(1st_max_date_time) IN (3,4,5) THEN 'Spring'
      WHEN MONTH(1st_max_date_time) IN (6,7,8) THEN 'Summer'
      WHEN MONTH(1st_max_date_time) IN (9,10,11) THEN 'Fall'
    END,
    parameter_name
)

SELECT
  parameter_name,
  season,
  ROUND(AVG(monitor_count)) as avg_monitors,
  ROUND(AVG(avg_max_value),2) as typical_max_value,
  ROUND(MAX(highest_max_value),2) as extreme_max_value,
  SUM(total_exceedances) as total_exceedances,
  ROUND(AVG(avg_exceptional_events),1) as avg_exceptional_events,
  -- Calculate which season has most extreme values
  RANK() OVER (PARTITION BY parameter_name ORDER BY AVG(avg_max_value) DESC) as severity_rank
FROM quarterly_metrics
GROUP BY 
  parameter_name,
  season
ORDER BY 
  parameter_name,
  severity_rank;

-- How it works:
-- 1. Creates quarterly breakdown of measurements using date of maximum values
-- 2. Focuses on recent years (2018+) and key pollutants for actionable insights
-- 3. Calculates average and extreme values per season
-- 4. Ranks seasons by severity for each pollutant
--
-- Assumptions & Limitations:
-- - Uses first maximum date to determine season (could miss patterns in other peaks)
-- - Limited to monitors with complete data (completeness_indicator = 'Y')
-- - Recent years only (2018+) for current relevance
-- - Selected subset of critical pollutants
--
-- Possible Extensions:
-- 1. Add geographic dimension to identify regional seasonal patterns
-- 2. Include weather data correlation
-- 3. Expand to analyze specific times of day within seasons
-- 4. Add year-over-year trend analysis within seasons
-- 5. Include economic impact metrics by season

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:07:16.107064
    - Additional Notes: The query effectively segments and ranks pollution patterns by season, making it valuable for seasonal preparedness and public health planning. However, users should note that the seasonal classification is based on first maximum values only, which might not capture the full distribution of extreme events throughout each season. For more comprehensive insights, consider adjusting the date range beyond 2018 or modifying the pollutant selection based on specific regional concerns.
    
    */