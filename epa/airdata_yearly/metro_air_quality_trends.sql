
/*******************************************************************************
Title: EPA Air Quality Annual Summary Analysis - Key Pollutant Trends
 
Business Purpose:
This query analyzes trends in key air pollutants across US cities, focusing on:
- PM2.5 and Ozone levels as critical air quality indicators
- Geographic distribution of pollution levels
- Compliance with air quality standards
- Year-over-year changes in major metropolitan areas

The insights support:
- Environmental policy decisions
- Public health assessments
- Urban planning initiatives
*******************************************************************************/

WITH key_pollutants AS (
  -- Filter for PM2.5 and Ozone, the most commonly monitored pollutants
  SELECT 
    year,
    state_name,
    city_name,
    cbsa_name,
    parameter_name,
    arithmetic_mean as avg_concentration,
    units_of_measure,
    primary_exceedance_count,
    observation_count,
    completeness_indicator
  FROM mimi_ws_1.epa.airdata_yearly
  WHERE parameter_name IN ('PM2.5 - Local Conditions', 'Ozone')
    AND year >= 2018  -- Focus on recent years
    AND completeness_indicator = 'Y' -- Only complete data
    AND cbsa_name IS NOT NULL -- Focus on metropolitan areas
)

SELECT 
  year,
  cbsa_name as metropolitan_area,
  parameter_name as pollutant,
  ROUND(AVG(avg_concentration), 2) as avg_annual_concentration,
  units_of_measure as units,
  SUM(primary_exceedance_count) as total_exceedances,
  SUM(observation_count) as total_observations
FROM key_pollutants
GROUP BY 
  year,
  metropolitan_area,
  pollutant,
  units_of_measure
HAVING total_observations > 100 -- Ensure sufficient data points
ORDER BY 
  metropolitan_area,
  pollutant,
  year DESC;

/*******************************************************************************
How the Query Works:
1. CTE filters for key pollutants and quality criteria
2. Main query aggregates data by metro area and year
3. Results show concentration trends and compliance issues

Assumptions & Limitations:
- Focuses only on PM2.5 and Ozone as key indicators
- Uses arithmetic mean for concentration levels
- Requires complete data indicators
- Limited to metropolitan areas
- Assumes recent data (2018+) is most relevant

Possible Extensions:
1. Add seasonal analysis by incorporating quarterly breakdowns
2. Compare against EPA standards with CASE statements
3. Calculate year-over-year change percentages
4. Include population exposure metrics
5. Add weather correlation analysis
6. Expand to include other pollutants
7. Add geographic clustering analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:52:50.956696
    - Additional Notes: Query aggregates EPA air quality data for PM2.5 and Ozone across metropolitan areas. Results are filtered for data completeness and minimum observation counts. Best used for year-over-year comparisons of major urban areas from 2018 onwards. Note that the 100 observation threshold may need adjustment based on specific analysis needs.
    
    */