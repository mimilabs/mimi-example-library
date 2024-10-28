
/*******************************************************************************
Title: Air Quality Health Risk Analysis by CBSA
 
Business Purpose:
- Identify metropolitan areas with concerning air quality trends
- Support public health planning and environmental policy decisions
- Help prioritize areas needing air quality improvement interventions

Core metrics analyzed:
- Days with unhealthy air quality levels
- Most problematic pollutants
- Year-over-year air quality changes
*******************************************************************************/

WITH yearly_metrics AS (
  -- Calculate key health risk metrics per CBSA per year
  SELECT 
    year,
    cbsa,
    days_with_aqi,
    -- Sum all days with concerning air quality
    (unhealthy_for_sensitive_groups_days + unhealthy_days + 
     very_unhealthy_days + hazardous_days) as total_unhealthy_days,
    -- Calculate % of measured days with health risks
    ROUND(100.0 * (unhealthy_for_sensitive_groups_days + unhealthy_days + 
           very_unhealthy_days + hazardous_days) / days_with_aqi, 1) as pct_unhealthy_days,
    -- Identify primary pollutant concern
    GREATEST(days_co, days_no2, days_ozone, days_pm25, days_pm10) as max_pollutant_days,
    CASE GREATEST(days_co, days_no2, days_ozone, days_pm25, days_pm10)
      WHEN days_co THEN 'CO'
      WHEN days_no2 THEN 'NO2' 
      WHEN days_ozone THEN 'Ozone'
      WHEN days_pm25 THEN 'PM2.5'
      WHEN days_pm10 THEN 'PM10'
    END as primary_pollutant
  FROM mimi_ws_1.epa.airdata_yearly_cbsa
  WHERE year >= 2019  -- Focus on recent years
)

SELECT
  cbsa,
  year,
  days_with_aqi as monitored_days,
  total_unhealthy_days,
  pct_unhealthy_days,
  primary_pollutant,
  max_pollutant_days as days_primary_pollutant
FROM yearly_metrics
WHERE total_unhealthy_days > 30  -- Focus on areas with significant issues
ORDER BY year DESC, total_unhealthy_days DESC
LIMIT 20;

/*******************************************************************************
How the Query Works:
1. Creates CTE to calculate health risk metrics per CBSA/year
2. Sums days with any unhealthy air quality level
3. Calculates percentage of monitored days with health risks
4. Identifies the most frequent problematic pollutant
5. Filters and sorts to highlight areas of greatest concern

Assumptions & Limitations:
- Assumes consistent monitoring across CBSAs
- Combines different levels of health risk into single metric
- Recent data (2019+) most relevant for current planning
- May miss seasonal patterns due to annual aggregation

Possible Extensions:
1. Add year-over-year trend analysis
2. Break down by specific health risk levels
3. Include population exposure metrics
4. Add geographic grouping for regional patterns
5. Incorporate seasonal analysis
6. Compare against national averages
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:54:23.232271
    - Additional Notes: Query only shows CBSAs with 30+ unhealthy days per year, focusing on 2019 onwards. Results are limited to top 20 most affected areas. Primary pollutant identification assumes single pollutant dominance and may not reflect complex multi-pollutant scenarios.
    
    */