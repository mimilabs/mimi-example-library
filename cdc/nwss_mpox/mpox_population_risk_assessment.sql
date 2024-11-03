-- NWSS Mpox Population Risk Assessment Analysis
-- Business Purpose: Analyze mpox exposure risk by identifying sewersheds with both high population density 
-- and consistent viral detection patterns to help public health officials prioritize targeted interventions
-- and resource allocation in vulnerable communities.

WITH recent_detections AS (
  -- Get most recent 30 days of data for each sewershed
  SELECT 
    sewershed,
    fullgeoname,
    counties,
    population_served,
    AVG(percent_detections) as avg_detection_rate,
    COUNT(*) as num_samples,
    MAX(sample_collect_date) as latest_sample_date
  FROM mimi_ws_1.cdc.nwss_mpox
  WHERE sample_collect_date >= DATE_SUB(CURRENT_DATE(), 30)
  GROUP BY sewershed, fullgeoname, counties, population_served
),

risk_scores AS (
  -- Calculate risk scores based on detection rates and population
  SELECT
    fullgeoname,
    counties,
    population_served,
    avg_detection_rate,
    num_samples,
    latest_sample_date,
    CASE 
      WHEN avg_detection_rate >= 75 AND population_served >= 500000 THEN 'High'
      WHEN avg_detection_rate >= 50 OR population_served >= 250000 THEN 'Medium'
      ELSE 'Low'
    END as risk_level
  FROM recent_detections
  WHERE num_samples >= 3 -- Ensure sufficient sampling frequency
)

-- Generate final risk assessment report
SELECT
  fullgeoname,
  counties,
  FORMAT_NUMBER(population_served, 0) as population_served,
  ROUND(avg_detection_rate, 1) as avg_detection_pct,
  risk_level,
  num_samples as samples_last_30days,
  latest_sample_date
FROM risk_scores
WHERE risk_level IN ('High', 'Medium')
ORDER BY 
  CASE risk_level 
    WHEN 'High' THEN 1 
    WHEN 'Medium' THEN 2
    ELSE 3 
  END,
  population_served DESC;

/* How this query works:
1. First CTE gets recent detection data by sewershed
2. Second CTE calculates risk levels based on detection rates and population
3. Final query filters and formats results for high/medium risk areas

Assumptions and limitations:
- Requires at least 3 samples in last 30 days for reliable assessment
- Risk thresholds are illustrative and should be adjusted based on public health guidance
- Population served may span multiple jurisdictions
- Does not account for demographic risk factors

Possible extensions:
1. Add demographic data overlay for more nuanced risk assessment
2. Include trend analysis comparing to previous 30-day periods
3. Add geographic clustering analysis to identify regional patterns
4. Incorporate local COVID-19 case rates for combined risk assessment
5. Add reporting of resource allocation recommendations based on risk levels
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:01:03.707660
    - Additional Notes: Query categorizes sewershed risk levels based on a combination of population size and virus detection rates over the past 30 days. Risk thresholds (75% for high, 50% for medium) and population thresholds (500k for high, 250k for medium) may need adjustment based on current epidemiological guidance. Minimum sample requirement of 3 tests per location ensures statistical reliability.
    
    */