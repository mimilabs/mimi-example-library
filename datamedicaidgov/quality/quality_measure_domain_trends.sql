
/*******************************************************
Quality Measure Trends by Domain and Population
*******************************************************/

/* Business Purpose: 
   Analyze year-over-year trends in healthcare quality measures across different domains
   and populations to identify areas needing improvement and track progress.
   This helps healthcare administrators and policymakers make data-driven decisions
   about resource allocation and intervention programs.
*/

WITH yearly_domain_stats AS (
  -- Calculate average rates by domain, population and year
  SELECT 
    ffy AS fiscal_year,
    domain,
    population,
    COUNT(DISTINCT measure_name) as num_measures,
    ROUND(AVG(state_rate), 2) as avg_rate,
    ROUND(AVG(median), 2) as avg_median_rate,
    COUNT(DISTINCT state) as reporting_states
  FROM mimi_ws_1.datamedicaidgov.quality
  WHERE 
    -- Focus on recent years with sufficient data
    ffy >= 2019
    -- Only include measures where higher rates are better
    AND measure_type LIKE '%Higher%better%'
    -- Exclude rows with null rates
    AND state_rate IS NOT NULL
  GROUP BY 1,2,3
)

SELECT
  fiscal_year,
  domain,
  population,
  num_measures,
  avg_rate,
  avg_median_rate,
  reporting_states,
  -- Calculate year-over-year change
  ROUND(avg_rate - LAG(avg_rate) 
    OVER (PARTITION BY domain, population ORDER BY fiscal_year), 2) as yoy_change
FROM yearly_domain_stats
ORDER BY 
  domain,
  population,
  fiscal_year;

/* How it works:
   1. Creates a CTE to aggregate quality measures by domain, population and year
   2. Calculates average rates and number of reporting states
   3. Computes year-over-year changes to show trends
   4. Orders results to show progression over time within each domain/population

   Assumptions & Limitations:
   - Only includes measures where "higher is better" for consistent comparison
   - Limited to recent years (2019+) for more relevant insights
   - Averages across measures may mask individual measure performance
   - Does not account for measure weightings or relative importance

   Possible Extensions:
   1. Add statistical significance testing for year-over-year changes
   2. Include measure-level detail for domains showing concerning trends
   3. Compare state performance against national benchmarks
   4. Add visualization-ready calculations (e.g., percent change)
   5. Segment analysis by specific populations or measure types
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:21:39.588462
    - Additional Notes: Query aggregates healthcare quality metrics by domain and population to show year-over-year trends since 2019. Note that it only includes measures where higher rates indicate better performance, which may exclude some important metrics. The YOY change calculation assumes consecutive year data is available for valid comparisons.
    
    */