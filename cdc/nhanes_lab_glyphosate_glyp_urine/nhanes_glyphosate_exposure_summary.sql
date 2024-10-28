
/* 
NHANES Glyphosate Exposure Analysis
====================================

Business Purpose:
This query analyzes the distribution of urinary glyphosate levels in the U.S. population
using CDC NHANES data. Understanding glyphosate exposure is crucial for public health 
assessment and policy making regarding pesticide use and safety.

Created: 2024
*/

-- Main analysis of glyphosate levels
WITH clean_data AS (
  SELECT
    seqn,
    ssglyp as glyphosate_level,
    CASE 
      WHEN ssglypl = 'below_lod' THEN 'Below Detection'
      ELSE 'Detected'
    END as detection_status,
    mimi_src_file_date as sample_date
  FROM mimi_ws_1.cdc.nhanes_lab_glyphosate_glyp_urine
  WHERE ssglyp IS NOT NULL
),

summary_stats AS (
  SELECT
    -- Basic statistics
    COUNT(*) as total_samples,
    COUNT(CASE WHEN detection_status = 'Detected' THEN 1 END) as detected_samples,
    ROUND(AVG(glyphosate_level), 2) as mean_level,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY glyphosate_level), 2) as median_level,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY glyphosate_level), 2) as p75_level,
    ROUND(MAX(glyphosate_level), 2) as max_level,
    
    -- Detection rate
    ROUND(100.0 * COUNT(CASE WHEN detection_status = 'Detected' THEN 1 END) / COUNT(*), 1) as detection_rate,
    
    -- Time range
    MIN(sample_date) as earliest_sample,
    MAX(sample_date) as latest_sample
  FROM clean_data
)

SELECT 
  'Summary of Glyphosate Exposure Levels (ng/mL)' as metric_name,
  *
FROM summary_stats;

/*
How This Query Works:
--------------------
1. The clean_data CTE filters and standardizes the raw data
2. The summary_stats CTE calculates key statistical measures
3. The final SELECT presents the results in a clear format

Assumptions & Limitations:
-------------------------
- Assumes NULL values should be excluded
- Does not account for sample weights (not population-representative)
- Does not stratify by demographic factors
- Limited to available time period in the data

Possible Extensions:
-------------------
1. Add demographic analysis (if available through joins)
2. Incorporate sample weights for population-level estimates
3. Add trend analysis over time
4. Compare with health guidelines/regulatory limits
5. Add geographic analysis if location data available
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:37:54.513711
    - Additional Notes: Query provides population-level exposure metrics but does not incorporate NHANES survey weights (wtssbj2y, wtssgl2y, wtssch2y) which are necessary for true population-representative estimates. Consider adding weight calculations for more accurate population inference.
    
    */