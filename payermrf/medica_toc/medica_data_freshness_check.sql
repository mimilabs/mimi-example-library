-- medica_toc_data_freshness_monitoring.sql

-- Business Purpose:
-- This analysis monitors the freshness and completeness of Medica's Table of Contents data
-- by tracking file publication patterns and load dates. Understanding data currency and
-- identifying potential gaps in data feeds is critical for maintaining accurate price
-- transparency reporting and ensuring compliance with federal regulations.

WITH date_metrics AS (
  SELECT 
    DATE(mimi_src_file_date) as source_date,
    DATE(mimi_dlt_load_date) as load_date,
    COUNT(*) as record_count,
    COUNT(DISTINCT plan_id) as distinct_plans,
    COUNT(DISTINCT entity_name) as distinct_entities
  FROM mimi_ws_1.payermrf.medica_toc
  GROUP BY 
    DATE(mimi_src_file_date),
    DATE(mimi_dlt_load_date)
),

date_gaps AS (
  SELECT
    source_date,
    load_date,
    record_count,
    distinct_plans,
    distinct_entities,
    DATEDIFF(day, 
             LAG(source_date) OVER (ORDER BY source_date),
             source_date) as days_since_last_source,
    DATEDIFF(day, source_date, load_date) as source_to_load_lag
  FROM date_metrics
)

SELECT
  source_date,
  load_date,
  record_count,
  distinct_plans,
  distinct_entities,
  days_since_last_source,
  source_to_load_lag,
  CASE 
    WHEN days_since_last_source > 35 THEN 'WARNING: Large gap in source files'
    WHEN source_to_load_lag > 7 THEN 'WARNING: Delayed loading'
    WHEN record_count < LAG(record_count) OVER (ORDER BY source_date) * 0.9 
      THEN 'WARNING: Significant drop in records'
    ELSE 'OK'
  END as status
FROM date_gaps
ORDER BY source_date DESC
LIMIT 90;

-- How the Query Works:
-- 1. First CTE aggregates daily metrics from source files and load dates
-- 2. Second CTE calculates gaps between dates and loading delays
-- 3. Main query adds status warnings based on business rules
-- 4. Results show last 90 days of data currency metrics

-- Assumptions and Limitations:
-- - Assumes source files should arrive monthly (warns if gap > 35 days)
-- - Assumes loading should complete within 7 days
-- - Assumes record counts shouldn't drop by more than 10%
-- - Limited to examining the last 90 days of history

-- Possible Extensions:
-- 1. Add email alerts for warning conditions
-- 2. Compare metrics across different payers
-- 3. Add more sophisticated completeness checks (e.g., required fields)
-- 4. Create a dashboard showing historical trends
-- 5. Add checks for specific high-priority plans or entities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:31:53.878309
    - Additional Notes: This monitoring script tracks data currency and completeness metrics for Medica's MRF data feeds. Key alerts include: source file gaps >35 days, loading delays >7 days, and record count drops >10%. Results focus on last 90 days of history.
    
    */