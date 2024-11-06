-- MRF Data Update Frequency Analysis
-- ====================================================

-- Business Purpose:
-- This query analyzes how frequently healthcare issuers update their Machine Readable Files (MRFs)
-- to understand data freshness and maintenance patterns. This information helps:
-- 1. Identify issuers with regular vs. irregular update patterns
-- 2. Assess data quality and reliability
-- 3. Support decisions about data refresh scheduling
-- 4. Highlight potential compliance concerns

WITH update_stats AS (
  -- Calculate updates per issuer
  SELECT 
    issuer_id,
    state,
    COUNT(DISTINCT mimi_src_file_date) as update_count,
    MIN(mimi_src_file_date) as first_update,
    MAX(mimi_src_file_date) as last_update,
    DATEDIFF(MAX(mimi_src_file_date), MIN(mimi_src_file_date)) as date_range_days
  FROM mimi_ws_1.datahealthcaregov.mrf_xlsx
  GROUP BY issuer_id, state
),

issuer_metrics AS (
  -- Calculate update frequency metrics
  SELECT
    state,
    issuer_id,
    update_count,
    first_update,
    last_update,
    date_range_days,
    ROUND(CAST(date_range_days AS FLOAT) / update_count, 1) as avg_days_between_updates,
    CASE 
      WHEN date_range_days >= 30 AND update_count >= 4 THEN 'Regular Updater'
      WHEN date_range_days >= 30 AND update_count < 4 THEN 'Infrequent Updater'
      WHEN date_range_days < 30 THEN 'New Participant'
    END as update_pattern
  FROM update_stats
)

-- Final output with key metrics
SELECT 
  state,
  COUNT(DISTINCT issuer_id) as total_issuers,
  SUM(CASE WHEN update_pattern = 'Regular Updater' THEN 1 ELSE 0 END) as regular_updaters,
  SUM(CASE WHEN update_pattern = 'Infrequent Updater' THEN 1 ELSE 0 END) as infrequent_updaters,
  SUM(CASE WHEN update_pattern = 'New Participant' THEN 1 ELSE 0 END) as new_participants,
  ROUND(AVG(avg_days_between_updates), 1) as avg_update_interval_days
FROM issuer_metrics
GROUP BY state
ORDER BY total_issuers DESC;

-- How this query works:
-- 1. First CTE (update_stats) aggregates basic update statistics per issuer
-- 2. Second CTE (issuer_metrics) calculates update frequency metrics and categorizes update patterns
-- 3. Final query summarizes the metrics by state

-- Assumptions and limitations:
-- 1. Assumes mimi_src_file_date is a reliable indicator of actual file updates
-- 2. "Regular Updater" definition (4+ updates over 30+ days) may need adjustment based on business rules
-- 3. Does not account for potential data quality issues in the updates themselves
-- 4. Recent time period analysis may be needed to focus on current patterns

-- Possible extensions:
-- 1. Add trend analysis comparing update patterns across different time periods
-- 2. Include URL analysis to verify if updates represent meaningful content changes
-- 3. Correlate update patterns with technical contact domains
-- 4. Add specific compliance thresholds and flag violations
-- 5. Create a monitoring dashboard for tracking update patterns over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:34:32.800016
    - Additional Notes: The query categorizes issuers into Regular Updaters (4+ updates over 30+ days), Infrequent Updaters, and New Participants. These thresholds may need adjustment based on specific compliance requirements. Consider recent data subset analysis for current patterns.
    
    */