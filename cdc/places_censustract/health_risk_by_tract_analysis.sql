
/*******************************************************************************
Title: Health Risk Factor Analysis by Census Tract

Business Purpose:
This query analyzes key health risk factors and outcomes across census tracts
to identify areas that may need targeted public health interventions. It focuses
on obesity, diabetes, and physical inactivity as critical health indicators that
often correlate with other health issues.

Created: 2024-02-21
*******************************************************************************/

-- Main query to analyze health risk distributions across census tracts
WITH health_measures AS (
  SELECT 
    state_desc,
    county_name,
    location_name,
    measure,
    data_value,
    total_population,
    ROUND(data_value * total_population / 100, 0) AS estimated_affected_people
  FROM mimi_ws_1.cdc.places_censustract
  WHERE year = 2021  -- Using most recent complete year
    AND category = 'Health Risk Behaviors'
    AND measure IN (
      'Obesity among adults aged >= 18 years',
      'Diagnosed diabetes among adults aged >= 18 years',
      'Physical inactivity among adults aged >= 18 years'
    )
)

SELECT
  state_desc,
  county_name,
  measure,
  -- Calculate key statistics
  COUNT(DISTINCT location_name) AS tract_count,
  ROUND(AVG(data_value), 1) AS avg_prevalence_pct,
  ROUND(MIN(data_value), 1) AS min_prevalence_pct,
  ROUND(MAX(data_value), 1) AS max_prevalence_pct,
  SUM(estimated_affected_people) AS total_estimated_affected
FROM health_measures
GROUP BY state_desc, county_name, measure
HAVING COUNT(DISTINCT location_name) > 10  -- Focus on areas with sufficient data
ORDER BY state_desc, county_name, measure;

/*******************************************************************************
How this query works:
1. Creates a CTE to select relevant health measures and calculate affected population
2. Aggregates data by state, county and measure to show distribution
3. Includes only areas with sufficient census tracts for meaningful analysis
4. Provides both percentage-based and population-based metrics

Assumptions and Limitations:
- Uses 2021 data as the most recent complete year
- Focuses on three key health risk factors
- Assumes data_value (prevalence %) can be applied to total population
- Excludes areas with 10 or fewer census tracts for statistical relevance

Possible Extensions:
1. Add year-over-year trend analysis
2. Include correlation analysis with socioeconomic factors
3. Add geographic clustering analysis
4. Expand to include more health measures
5. Add demographic breakdowns where available
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:17:14.625793
    - Additional Notes: Query aggregates three key health risk factors (obesity, diabetes, physical inactivity) at the census tract level. The estimated_affected_people calculation is an approximation based on total population and should be used directionally rather than as precise counts. Results are filtered to areas with >10 census tracts to ensure statistical relevance.
    
    */