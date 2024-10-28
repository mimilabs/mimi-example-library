
/* HEDIS Risk-Adjusted Performance Analysis
 
Purpose: Analyze Medicare Advantage plan performance on key HEDIS quality measures
by comparing observed vs expected outcomes and identifying outlier patterns.

This analysis helps:
- Evaluate plan quality and performance
- Identify areas needing improvement 
- Compare performance across different measures
- Track year-over-year trends
*/

WITH measure_summary AS (
  -- Calculate key performance metrics for each measure and year
  SELECT 
    hedis_year,
    measure_name,
    COUNT(DISTINCT contract_number) as num_contracts,
    SUM(observed_count) as total_observed,
    SUM(expected_count) as total_expected,
    ROUND(SUM(observed_count) / SUM(expected_count), 3) as observed_to_expected_ratio,
    SUM(outlier_member_count) as total_outliers,
    ROUND(AVG(outlier_member_count * 1.0 / member_count), 3) as avg_outlier_rate
  FROM mimi_ws_1.partcd.hedis_rau_measures
  GROUP BY hedis_year, measure_name
)

-- Generate final summary with performance rankings
SELECT
  hedis_year,
  measure_name,
  num_contracts,
  total_observed,
  total_expected,
  observed_to_expected_ratio,
  -- Rank measures by how much they deviate from expected
  RANK() OVER (PARTITION BY hedis_year ORDER BY ABS(observed_to_expected_ratio - 1)) as closest_to_expected_rank,
  total_outliers,
  avg_outlier_rate
FROM measure_summary
ORDER BY hedis_year DESC, observed_to_expected_ratio DESC;

/* How this query works:
1. Aggregates key metrics by measure and year
2. Calculates observed-to-expected ratios to assess performance
3. Identifies measures with highest deviation from expected
4. Shows outlier patterns across measures

Assumptions & Limitations:
- Assumes data quality and completeness across all contracts
- Does not account for measure-specific risk adjustment methodologies
- Outlier definitions may vary by measure
- Geographic variations not considered

Possible Extensions:
1. Add geographic analysis by joining contract location data
2. Trend analysis across multiple years
3. Drill down into specific measures or contracts
4. Compare performance by contract size/type
5. Add statistical significance testing
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:01:38.669769
    - Additional Notes: Query requires complete HEDIS data across all years being analyzed. Performance ratios may be skewed for measures with low expected counts or small sample sizes. Consider adding WHERE clauses to filter specific measurement years or measures if performance is slow on large datasets.
    
    */