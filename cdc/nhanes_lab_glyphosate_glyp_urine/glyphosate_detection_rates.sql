-- NHANES Glyphosate Detection Rate Analysis
-- =============================================

-- Business Purpose: This query calculates the detection rate of glyphosate in urine samples
-- across different NHANES survey periods to understand population exposure prevalence.
-- High detection rates may indicate widespread exposure and inform public health policies.

WITH detection_analysis AS (
  -- Categorize measurements by detection status using comment codes
  SELECT 
    mimi_src_file_name,
    COUNT(*) as total_samples,
    COUNT(CASE WHEN ssglypl = 0 THEN 1 END) as detected_samples,
    COUNT(CASE WHEN ssglypl IN (1, 2) THEN 1 END) as below_lod_samples
  FROM mimi_ws_1.cdc.nhanes_lab_glyphosate_glyp_urine
  GROUP BY mimi_src_file_name
)

SELECT
  mimi_src_file_name as survey_period,
  total_samples,
  detected_samples,
  below_lod_samples,
  ROUND(100.0 * detected_samples / total_samples, 1) as detection_rate_pct,
  ROUND(AVG(detected_samples) OVER (), 0) as avg_detected_per_period
FROM detection_analysis
ORDER BY mimi_src_file_name;

-- Query Operation:
-- 1. Groups samples by survey period (source file)
-- 2. Counts total samples and categorizes them as detected or below limit of detection
-- 3. Calculates detection rate percentage and average detections per period
-- 4. Orders results chronologically by survey period

-- Assumptions and Limitations:
-- - Comment code 0 indicates valid detection
-- - Comment codes 1,2 indicate below limit of detection
-- - Survey weights not incorporated in this basic analysis
-- - Detection limits may vary between survey periods

-- Possible Extensions:
-- 1. Add confidence intervals for detection rates
-- 2. Incorporate survey weights for population-representative estimates
-- 3. Compare detection rates across different demographic groups
-- 4. Analyze trends in detection limits over time
-- 5. Map detection rates to geographic regions if available
-- 6. Create visualizations of detection rate trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:48:30.554544
    - Additional Notes: This query focuses on basic detection rates without population weighting. For regulatory or epidemiological use cases, the analysis should be extended to incorporate NHANES survey weights (wtssbj2y, wtssgl2y, wtssch2y) to ensure population representativeness.
    
    */