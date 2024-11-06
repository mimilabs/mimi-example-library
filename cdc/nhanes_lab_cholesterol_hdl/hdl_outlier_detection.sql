-- hdl_outlier_detection_qa.sql

-- Business Purpose:
-- - Identify potential data quality issues and outliers in HDL cholesterol measurements
-- - Support data validation processes for clinical research and population health studies
-- - Enable quality control monitoring of NHANES lab data collection and processing
-- - Facilitate early detection of measurement or recording anomalies

WITH hdl_stats AS (
  -- Calculate basic statistics for HDL values
  SELECT
    COUNT(*) as total_records,
    AVG(lbdhdd) as mean_hdl,
    STDDEV(lbdhdd) as stddev_hdl,
    PERCENTILE(lbdhdd, 0.25) as q1_hdl,
    PERCENTILE(lbdhdd, 0.75) as q3_hdl
  FROM mimi_ws_1.cdc.nhanes_lab_cholesterol_hdl
  WHERE lbdhdd IS NOT NULL
),

outliers AS (
  -- Identify outliers using the Interquartile Range (IQR) method
  SELECT 
    seqn,
    lbdhdd as hdl_mg_dl,
    lbdhddsi as hdl_mmol_l,
    mimi_src_file_date,
    CASE
      WHEN lbdhdd < (q1_hdl - (1.5 * (q3_hdl - q1_hdl))) THEN 'Low Outlier'
      WHEN lbdhdd > (q3_hdl + (1.5 * (q3_hdl - q1_hdl))) THEN 'High Outlier'
      ELSE 'Normal Range'
    END as outlier_status
  FROM mimi_ws_1.cdc.nhanes_lab_cholesterol_hdl
  CROSS JOIN hdl_stats
  WHERE lbdhdd IS NOT NULL
)

-- Generate summary of outliers and data quality metrics
SELECT 
  outlier_status,
  COUNT(*) as record_count,
  ROUND(MIN(hdl_mg_dl), 1) as min_hdl,
  ROUND(MAX(hdl_mg_dl), 1) as max_hdl,
  ROUND(AVG(hdl_mg_dl), 1) as avg_hdl,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
FROM outliers
GROUP BY outlier_status
ORDER BY outlier_status;

-- How it works:
-- 1. First CTE calculates basic statistical measures for the HDL values
-- 2. Second CTE identifies outliers using the IQR method (1.5 * IQR rule)
-- 3. Final query summarizes the findings with key metrics and percentages

-- Assumptions and Limitations:
-- - Uses standard IQR method for outlier detection which may need adjustment for specific use cases
-- - Assumes NULL values should be excluded from analysis
-- - Does not account for demographic or clinical factors that might explain extreme values
-- - Focuses only on numerical validation, not clinical validity

-- Possible Extensions:
-- 1. Add temporal analysis to track outlier patterns over time
-- 2. Include demographic factors to identify population-specific outlier patterns
-- 3. Implement multiple outlier detection methods (e.g., z-score, modified z-score)
-- 4. Add cross-validation with other lab measurements
-- 5. Create alert thresholds for real-time monitoring
-- 6. Include visualization code for outlier distribution

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:58:02.490833
    - Additional Notes: Query uses IQR method for outlier detection which may be too sensitive for clinical data. Consider adjusting the multiplier (currently 1.5) based on domain expertise. Performance may be impacted with very large datasets due to window functions and percentile calculations.
    
    */