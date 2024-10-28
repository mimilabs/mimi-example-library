
/*******************************************************************************
Title: Medicare Contract Performance Trend Analysis
 
Business Purpose:
This query analyzes key performance trends across Medicare Advantage and 
Prescription Drug Plan contracts over time. It helps identify:
- Overall performance patterns
- Which organizations are consistently high/low performing
- Year-over-year changes in measure values
*******************************************************************************/

-- Main analysis query
WITH yearly_stats AS (
  -- Calculate average measure values by contract and year
  SELECT
    performance_year,
    contract_id,
    organization_type,
    contract_name,
    parent_organization,
    COUNT(DISTINCT measure_code) as num_measures,
    AVG(CAST(measure_value AS DOUBLE)) as avg_measure_value,
    MIN(CAST(measure_value AS DOUBLE)) as min_measure_value,
    MAX(CAST(measure_value AS DOUBLE)) as max_measure_value
  FROM mimi_ws_1.partcd.starrating_measure_value
  WHERE measure_value IS NOT NULL
    AND measure_value <> 'Not Available'
    AND performance_year >= 2020  -- Focus on recent years
  GROUP BY 1,2,3,4,5
)

SELECT 
  y.performance_year,
  y.organization_type,
  y.contract_name,
  y.parent_organization,
  y.num_measures,
  ROUND(y.avg_measure_value, 2) as avg_measure_score,
  -- Calculate year-over-year change
  ROUND(y.avg_measure_value - LAG(y.avg_measure_value) 
    OVER (PARTITION BY y.contract_id ORDER BY y.performance_year), 2) as yoy_change
FROM yearly_stats y
WHERE y.num_measures >= 5  -- Filter to contracts with sufficient measures
ORDER BY 
  y.parent_organization,
  y.contract_name,
  y.performance_year;

/*******************************************************************************
How this query works:
1. Creates yearly_stats CTE to aggregate measure values by contract/year
2. Calculates key statistics including measure counts and averages
3. Computes year-over-year changes in performance
4. Filters and formats results for analysis

Assumptions & Limitations:
- Assumes measure_value can be cast to numeric for averaging
- Limited to contracts with 5+ measures for more meaningful comparisons
- Recent years only (2020+) for current relevance
- Excludes null/unavailable values

Possible Extensions:
1. Add geographic region analysis
2. Break out by specific measure categories
3. Include statistical significance testing
4. Add rank ordering of contracts
5. Create visualization-ready aggregates
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:01:51.773377
    - Additional Notes: Query performs year-over-year trend analysis for Medicare contracts with sufficient data (5+ measures). The averaging of measure values assumes numeric consistency across different measure types, which may need validation. Performance calculations are limited to 2020 onwards for recent relevance.
    
    */