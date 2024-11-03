-- Title: Medicare Contract Performance Measure Score Distribution Analysis

-- Business Purpose:
-- - Analyze the distribution of measure scores across contracts to identify performance benchmarks
-- - Highlight opportunities for quality improvement by finding measure gaps
-- - Support strategic planning by understanding measure performance patterns
-- - Enable targeted interventions in low-performing measure areas

-- Main Query
WITH measure_stats AS (
  SELECT
    measure_code,
    measure_desc,
    performance_year,
    -- Calculate distribution statistics for each measure
    COUNT(DISTINCT contract_id) as contract_count,
    AVG(CAST(measure_value_raw AS FLOAT)) as avg_score,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(measure_value_raw AS FLOAT)) as median_score,
    MIN(CAST(measure_value_raw AS FLOAT)) as min_score,
    MAX(CAST(measure_value_raw AS FLOAT)) as max_score
  FROM mimi_ws_1.partcd.starrating_measure_star
  WHERE 
    -- Focus on most recent complete year
    performance_year = (SELECT MAX(performance_year) FROM mimi_ws_1.partcd.starrating_measure_star)
    -- Ensure we have valid numeric scores
    AND measure_value_raw IS NOT NULL 
    AND TRIM(measure_value_raw) != ''
  GROUP BY 
    measure_code,
    measure_desc,
    performance_year
)

SELECT 
  measure_code,
  measure_desc,
  contract_count,
  ROUND(avg_score, 2) as average_score,
  ROUND(median_score, 2) as median_score,
  ROUND(min_score, 2) as minimum_score,
  ROUND(max_score, 2) as maximum_score,
  -- Calculate the performance spread
  ROUND(max_score - min_score, 2) as score_range
FROM measure_stats
-- Focus on measures with meaningful participation
WHERE contract_count >= 10
ORDER BY 
  -- Identify measures with largest performance gaps
  score_range DESC,
  measure_code;

-- How the Query Works:
-- 1. Creates CTE to calculate key statistics for each measure
-- 2. Focuses on most recent year's data
-- 3. Calculates mean, median, min, max scores
-- 4. Filters for measures with sufficient participation
-- 5. Orders results to highlight largest performance gaps

-- Assumptions and Limitations:
-- - Assumes measure_value_raw contains valid numeric data
-- - Limited to measures with 10+ participating contracts
-- - Does not account for measure weights or importance
-- - Does not segment by contract type or geography
-- - Statistical significance not evaluated

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Segment analysis by organization_type
-- 3. Add confidence intervals around averages
-- 4. Include measure domain categorization
-- 5. Add correlation analysis between related measures
-- 6. Calculate improvement opportunities based on gaps to benchmarks
-- 7. Create tier groupings based on score distributions
-- 8. Add geographic analysis of measure performance

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:55:56.344893
    - Additional Notes: Query provides statistical distribution analysis of star rating measure scores, focusing on performance gaps and variation across measures. Best used for identifying quality improvement opportunities and establishing performance benchmarks. Note that the query requires measures to have at least 10 participating contracts and valid numeric scores to be included in the analysis.
    
    */