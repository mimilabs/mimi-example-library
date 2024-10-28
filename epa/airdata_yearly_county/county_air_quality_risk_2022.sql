
/*******************************************************************************
Title: Air Quality Health Risk Analysis by County
 
Business Purpose:
This query analyzes county-level air quality data to identify areas with the 
highest health risks based on:
1. Frequency of unhealthy air quality days
2. Maximum pollution levels
3. Persistence of dangerous conditions
4. Primary pollutant patterns

This helps:
- Target public health interventions
- Guide environmental policy decisions  
- Allocate air quality monitoring resources
*******************************************************************************/

WITH county_metrics AS (
  -- Calculate key health risk metrics for each county's most recent year
  SELECT 
    state,
    county,
    year,
    days_with_aqi,
    -- Sum all days with unhealthy or worse air quality
    (unhealthy_for_sensitive_groups_days + unhealthy_days + 
     very_unhealthy_days + hazardous_days) as total_unhealthy_days,
    max_aqi,
    -- Calculate percentage of monitored days that were unhealthy
    ROUND(100.0 * (unhealthy_for_sensitive_groups_days + unhealthy_days + 
           very_unhealthy_days + hazardous_days) / days_with_aqi, 1) as pct_unhealthy_days,
    -- Identify predominant pollutant
    GREATEST(days_co, days_no2, days_ozone, days_pm25, days_pm10) as max_pollutant_days,
    CASE GREATEST(days_co, days_no2, days_ozone, days_pm25, days_pm10)
      WHEN days_co THEN 'CO'
      WHEN days_no2 THEN 'NO2'
      WHEN days_ozone THEN 'Ozone'
      WHEN days_pm25 THEN 'PM2.5'
      WHEN days_pm10 THEN 'PM10'
    END as primary_pollutant
  FROM mimi_ws_1.epa.airdata_yearly_county
  WHERE year = 2022  -- Focus on most recent complete year
)

SELECT 
  state,
  county,
  days_with_aqi as monitored_days,
  total_unhealthy_days,
  pct_unhealthy_days,
  max_aqi,
  primary_pollutant,
  -- Assign risk categories based on multiple factors
  CASE 
    WHEN max_aqi >= 300 OR pct_unhealthy_days >= 25 THEN 'High Risk'
    WHEN max_aqi >= 150 OR pct_unhealthy_days >= 10 THEN 'Moderate Risk'
    ELSE 'Lower Risk'
  END as health_risk_category
FROM county_metrics
WHERE days_with_aqi >= 183  -- Require at least 6 months of monitoring
ORDER BY pct_unhealthy_days DESC, max_aqi DESC
LIMIT 20;

/*******************************************************************************
How it works:
1. Creates temp table with calculated health risk metrics for each county
2. Filters for most recent year and adequate monitoring coverage
3. Categorizes counties by health risk level
4. Returns top 20 highest risk areas based on unhealthy days percentage

Assumptions & Limitations:
- Requires at least 6 months of monitoring data for reliable assessment
- Weights all unhealthy categories equally in percentage calculations
- Risk categories use simplified thresholds that may need adjustment
- Most recent year may not be representative of long-term conditions

Possible Extensions:
1. Add year-over-year trend analysis
2. Include population exposure estimates
3. Break down risk by season or specific pollutant
4. Compare to state and national averages
5. Add geographic clustering analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:59:00.538960
    - Additional Notes: The query focuses on 2022 data and requires at least 6 months of monitoring data per county. Risk categorization thresholds (25% and 10% for unhealthy days, 300 and 150 for max AQI) may need adjustment based on specific regional or organizational standards. The analysis excludes historical trends and seasonal variations which could provide additional context for risk assessment.
    
    */