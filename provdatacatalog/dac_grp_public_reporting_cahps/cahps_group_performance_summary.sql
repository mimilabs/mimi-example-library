-- CAHPS Group Performance Analysis - Core Metrics
-- Purpose: Analyze healthcare provider group performance on CAHPS patient experience measures
--          to identify top performers and opportunities for improvement
-- Business Value: Helps identify best practices, benchmark performance, and improve patient satisfaction

WITH performance_stats AS (
  -- Calculate average performance rates and patient volumes by measure
  SELECT 
    measure_cd,
    measure_title,
    AVG(prf_rate) AS avg_performance,
    AVG(patient_count) AS avg_patient_count,
    COUNT(DISTINCT org_pac_id) AS group_count
  FROM mimi_ws_1.provdatacatalog.dac_grp_public_reporting_cahps
  WHERE fn IS NULL -- Exclude suppressed data
  GROUP BY measure_cd, measure_title
),

top_performers AS (
  -- Identify top performing groups for each measure
  SELECT 
    c.measure_cd,
    c.facility_name,
    c.prf_rate,
    c.patient_count,
    RANK() OVER (PARTITION BY c.measure_cd ORDER BY c.prf_rate DESC) as rank
  FROM mimi_ws_1.provdatacatalog.dac_grp_public_reporting_cahps c
  WHERE fn IS NULL
  AND c.patient_count >= 100 -- Focus on groups with significant volume
)

-- Combine measure statistics with top performers
SELECT 
  p.measure_cd,
  p.measure_title,
  ROUND(p.avg_performance, 2) AS avg_performance_rate,
  ROUND(p.avg_patient_count, 0) AS avg_patient_count,
  p.group_count AS participating_groups,
  t.facility_name AS top_performer,
  ROUND(t.prf_rate, 2) AS top_performance_rate
FROM performance_stats p
LEFT JOIN top_performers t ON p.measure_cd = t.measure_cd AND t.rank = 1
ORDER BY p.avg_performance DESC;

-- How this query works:
-- 1. Calculates average performance and volume metrics for each CAHPS measure
-- 2. Identifies the top performing group for each measure
-- 3. Combines the information to show both overall measure statistics and best performers

-- Assumptions and Limitations:
-- - Excludes data points with footnotes (suppressed data)
-- - Requires minimum patient count of 100 for top performer consideration
-- - Does not account for temporal trends (uses latest data only)
-- - Does not consider geographical variations

-- Possible Extensions:
-- 1. Add trending analysis by including mimi_src_file_date
-- 2. Include geographical analysis by adding facility location data
-- 3. Expand to show bottom performers for gap analysis
-- 4. Add statistical significance testing for performance differences
-- 5. Create peer group comparisons based on patient volume or facility type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:18:47.368361
    - Additional Notes: Query excludes groups with suppressed data (fn=1) and requires minimum patient count of 100 for top performer analysis. Performance metrics are rounded to 2 decimal places. Results show both aggregate measure statistics and individual top performers, making it useful for benchmarking and performance improvement initiatives.
    
    */