-- county_air_quality_seasonal_patterns.sql

-- Business Purpose:
-- This query analyzes seasonal patterns in air quality across US counties to help businesses and
-- organizations understand when air quality issues are most likely to occur. This information is
-- valuable for:
-- 1. Healthcare providers planning resource allocation
-- 2. Outdoor event planners and tourism businesses
-- 3. School districts making outdoor activity decisions
-- 4. Public health departments designing targeted interventions

WITH seasonal_metrics AS (
  -- Calculate the proportion of different air quality days for each state and county
  SELECT 
    state,
    county,
    year,
    days_with_aqi,
    -- Calculate percentages of each air quality category
    ROUND(100.0 * good_days / days_with_aqi, 1) as pct_good_days,
    ROUND(100.0 * moderate_days / days_with_aqi, 1) as pct_moderate_days,
    -- Calculate main pollutant distributions
    ROUND(100.0 * days_ozone / days_with_aqi, 1) as pct_ozone_days,
    ROUND(100.0 * days_pm25 / days_with_aqi, 1) as pct_pm25_days,
    ROUND(100.0 * (days_co + days_no2 + days_pm10) / days_with_aqi, 1) as pct_other_pollutants
  FROM mimi_ws_1.epa.airdata_yearly_county
  WHERE year >= 2018  -- Focus on recent years for more relevant patterns
    AND days_with_aqi >= 300  -- Ensure sufficient data coverage
)

SELECT 
  state,
  COUNT(DISTINCT county) as num_counties,
  -- Average metrics across counties
  ROUND(AVG(pct_good_days), 1) as avg_pct_good_days,
  ROUND(AVG(pct_moderate_days), 1) as avg_pct_moderate_days,
  -- Primary pollutant patterns
  ROUND(AVG(pct_ozone_days), 1) as avg_pct_ozone_days,
  ROUND(AVG(pct_pm25_days), 1) as avg_pct_pm25_days,
  ROUND(AVG(pct_other_pollutants), 1) as avg_pct_other_pollutants
FROM seasonal_metrics
GROUP BY state
HAVING num_counties >= 3  -- Focus on states with sufficient county coverage
ORDER BY avg_pct_good_days DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to calculate percentages of different air quality categories and pollutants
-- 2. Aggregates data at the state level while counting counties and averaging percentages
-- 3. Filters for states with adequate data coverage
-- 4. Orders results by states with the best air quality (highest percentage of good days)

-- Assumptions and limitations:
-- 1. Assumes data completeness for counties with 300+ days of measurements
-- 2. Limited to recent years (2018 onwards) for current relevance
-- 3. State-level aggregation may mask significant county-level variations
-- 4. Doesn't account for population exposure or demographic factors

-- Possible extensions:
-- 1. Add year-over-year trend analysis to identify seasonal pattern changes
-- 2. Include population-weighted averages for more accurate impact assessment
-- 3. Break down analysis by urban vs rural counties
-- 4. Correlate with weather data to understand climate impacts on air quality
-- 5. Add geographic regions (Northeast, Southeast, etc.) for regional comparison

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:01:08.848711
    - Additional Notes: Query focuses on the relative composition of air quality days and pollutant types at the state level, providing insights into which states have better overall air quality and what their main pollution challenges are. The 300-day threshold for data completeness and 3-county minimum ensure statistical reliability but may exclude some states with limited monitoring coverage.
    
    */