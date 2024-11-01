-- HEDIS_measure_rate_trends_and_outliers.sql

-- Purpose: Analyze key HEDIS measure trends over time and identify statistical outliers 
-- Business Value:
-- - Track year-over-year quality performance changes to spot emerging trends
-- - Identify measures with significant variation requiring attention
-- - Support data-driven quality improvement initiatives through outlier detection

WITH measure_stats AS (
  -- Calculate basic statistics for each measure and year
  SELECT
    hedis_year,
    measure_code,
    measure_name,
    COUNT(DISTINCT contract_number) as n_contracts,
    AVG(rate) as avg_rate,
    STDDEV(rate) as std_rate,
    PERCENTILE(rate, 0.25) as p25_rate,
    PERCENTILE(rate, 0.75) as p75_rate
  FROM mimi_ws_1.partcd.hedis_measures
  WHERE rate IS NOT NULL 
  GROUP BY 1,2,3
),

outliers AS (
  -- Identify statistical outliers using 1.5 * IQR method
  SELECT 
    h.*,
    m.avg_rate,
    m.std_rate,
    CASE WHEN h.rate < (m.p25_rate - 1.5*(m.p75_rate - m.p25_rate)) 
         OR h.rate > (m.p75_rate + 1.5*(m.p75_rate - m.p25_rate))
         THEN 1 ELSE 0 END as is_outlier
  FROM mimi_ws_1.partcd.hedis_measures h
  JOIN measure_stats m 
    ON h.hedis_year = m.hedis_year 
    AND h.measure_code = m.measure_code
)

SELECT
  measure_code,
  measure_name,
  hedis_year,
  ROUND(avg_rate,2) as average_rate,
  ROUND(std_rate,2) as std_deviation,
  COUNT(CASE WHEN is_outlier = 1 THEN 1 END) as n_outliers,
  ROUND(COUNT(CASE WHEN is_outlier = 1 THEN 1 END) * 100.0 / COUNT(*), 1) as pct_outliers
FROM outliers
GROUP BY 1,2,3,4,5
ORDER BY measure_code, hedis_year;

-- How it works:
-- 1. First CTE calculates summary statistics for each measure/year
-- 2. Second CTE identifies outliers using the interquartile range method
-- 3. Final query summarizes results showing trends and outlier counts

-- Assumptions & Limitations:
-- - Requires valid rate values (nulls excluded)
-- - Uses standard statistical outlier definition (1.5 * IQR)
-- - Treats each year independently
-- - Does not account for measure-specific acceptable ranges

-- Possible Extensions:
-- 1. Add geographic analysis of outliers
-- 2. Include year-over-year change calculations
-- 3. Focus on specific high-priority measures
-- 4. Add contract size weighting
-- 5. Implement measure-specific thresholds for outlier detection

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:42:14.082284
    - Additional Notes: Query uses IQR method for outlier detection which may need adjustment based on specific measure thresholds. Consider adding weights for contract size in future versions. Results are grouped by measure and year to show quality metric trends.
    
    */