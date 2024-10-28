
/*******************************************************************************
Title: NWSS Mpox Wastewater Surveillance Core Analysis
 
Business Purpose:
This query analyzes mpox detection patterns in wastewater across different US
jurisdictions to help public health officials monitor disease spread and inform
response efforts. It provides a high-level overview of detection rates and
geographic distribution of mpox in wastewater samples.

Key metrics include:
- Number of sampling locations per jurisdiction
- Overall detection rates
- Population coverage
*******************************************************************************/

WITH recent_data AS (
  -- Get data from last 30 days to focus on current situation
  SELECT *
  FROM mimi_ws_1.cdc.nwss_mpox
  WHERE sample_collect_date >= DATE_SUB(CURRENT_DATE(), 30)
),

jurisdiction_summary AS (
  -- Aggregate metrics by jurisdiction
  SELECT 
    jurisdiction,
    COUNT(DISTINCT sewershed) as sampling_locations,
    SUM(pos_samples) as total_positive_samples,
    SUM(total_samples) as total_samples,
    SUM(population_served) as total_population_covered,
    ROUND(100.0 * SUM(pos_samples) / NULLIF(SUM(total_samples), 0), 1) as detection_rate
  FROM recent_data
  GROUP BY jurisdiction
)

-- Final output with key metrics and rankings
SELECT
  jurisdiction,
  sampling_locations,
  detection_rate as mpox_detection_rate_pct,
  total_population_covered,
  RANK() OVER (ORDER BY detection_rate DESC) as detection_rate_rank
FROM jurisdiction_summary
WHERE total_samples > 0
ORDER BY detection_rate DESC;

/*******************************************************************************
How it works:
1. Creates a CTE for recent data within last 30 days
2. Aggregates key metrics by jurisdiction
3. Calculates detection rates and rankings
4. Returns sorted results showing areas of highest concern

Assumptions & Limitations:
- Assumes data is regularly updated and complete
- Does not account for varying sampling frequencies between locations
- Population coverage may have some overlap in metro areas
- Detection rates may be affected by different testing methodologies

Possible Extensions:
1. Add trend analysis comparing current vs previous periods
2. Include geographic clustering analysis
3. Correlate with reported clinical cases
4. Add time series visualization
5. Break down by county level
6. Include demographic risk factors
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:30:52.047374
    - Additional Notes: Query provides jurisdiction-level summaries for last 30 days only. Zero-sample jurisdictions are filtered out. Population coverage numbers may include duplicates in overlapping sewersheds. Detection rates should be interpreted alongside sample counts for statistical significance.
    
    */