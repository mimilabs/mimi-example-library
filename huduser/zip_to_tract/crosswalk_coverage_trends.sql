-- temporal_coverage_analysis.sql

-- Business Purpose: Analyze the temporal coverage and data freshness of the ZIP-tract crosswalk 
-- to ensure data quality and identify any potential gaps in geographic mapping updates.
-- This helps:
-- - Data governance teams monitor crosswalk completeness
-- - Analysts understand data currency for their geographic analyses
-- - Planning teams track geographic boundary changes over time

WITH coverage_metrics AS (
  -- Get the most recent data timestamp and summarize key metrics by source file date
  SELECT 
    mimi_src_file_date,
    COUNT(DISTINCT zip) AS unique_zips,
    COUNT(DISTINCT tract) AS unique_tracts,
    COUNT(*) AS total_mappings,
    ROUND(AVG(res_ratio), 3) AS avg_res_ratio,
    MAX(mimi_dlt_load_date) AS latest_load_date
  FROM mimi_ws_1.huduser.zip_to_tract
  GROUP BY mimi_src_file_date
),

year_over_year AS (
  -- Calculate year-over-year changes in coverage
  SELECT
    mimi_src_file_date,
    unique_zips,
    unique_tracts,
    total_mappings,
    avg_res_ratio,
    latest_load_date,
    LAG(unique_zips) OVER (ORDER BY mimi_src_file_date) AS prev_unique_zips,
    LAG(unique_tracts) OVER (ORDER BY mimi_src_file_date) AS prev_unique_tracts
  FROM coverage_metrics
)

SELECT
  mimi_src_file_date,
  unique_zips,
  unique_tracts,
  total_mappings,
  avg_res_ratio,
  latest_load_date,
  -- Calculate changes from previous period
  unique_zips - prev_unique_zips AS zip_change,
  unique_tracts - prev_unique_tracts AS tract_change,
  ROUND(100.0 * (unique_zips - prev_unique_zips) / prev_unique_zips, 2) AS zip_pct_change
FROM year_over_year
ORDER BY mimi_src_file_date DESC;

-- How it works:
-- 1. First CTE aggregates key metrics for each source file date
-- 2. Second CTE calculates prior period values using window functions
-- 3. Final query computes period-over-period changes

-- Assumptions & Limitations:
-- - Assumes regular annual updates in Q1
-- - Changes in metrics may reflect both actual geographic changes and data quality issues
-- - Does not account for changes in Census tract definitions between decades

-- Possible Extensions:
-- 1. Add quality checks for unexpected gaps between load dates
-- 2. Compare coverage against known ZIP/tract universe counts
-- 3. Add state-level breakdowns to identify regional patterns
-- 4. Track changes in residential vs business ratios over time
-- 5. Create alerts for significant coverage drops

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:00:11.916131
    - Additional Notes: Query focuses on tracking temporal quality and completeness metrics of the ZIP-tract mapping data. Could be scheduled to run after each quarterly update to monitor data freshness and identify potential coverage issues. Results are particularly useful for data governance and quality assurance teams.
    
    */