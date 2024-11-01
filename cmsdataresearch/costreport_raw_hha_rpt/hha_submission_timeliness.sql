-- hha_timely_submission_trends.sql
--
-- Business Purpose: Analyze Home Health Agency cost report submission timeliness to:
-- - Monitor average submission delays 
-- - Identify providers with consistent late submissions
-- - Support operational efficiency improvements
-- - Guide provider outreach and compliance programs

WITH submission_delays AS (
  -- Calculate days between fiscal year end and report receipt
  SELECT 
    prvdr_num,
    fy_end_dt,
    fi_rcpt_dt,
    DATEDIFF(fi_rcpt_dt, fy_end_dt) as days_to_submit,
    -- Flag if submission was within 150 days (typical deadline)
    CASE WHEN DATEDIFF(fi_rcpt_dt, fy_end_dt) <= 150 THEN 1 ELSE 0 END as is_timely
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
  WHERE fi_rcpt_dt IS NOT NULL 
    AND fy_end_dt IS NOT NULL
    AND YEAR(fy_end_dt) >= 2018
)

SELECT
  YEAR(fy_end_dt) as fiscal_year,
  COUNT(DISTINCT prvdr_num) as total_providers,
  ROUND(AVG(days_to_submit), 1) as avg_days_to_submit,
  ROUND(MIN(days_to_submit), 1) as min_days_to_submit,
  ROUND(MAX(days_to_submit), 1) as max_days_to_submit,
  ROUND(AVG(is_timely) * 100, 1) as pct_timely_submissions,
  COUNT(CASE WHEN days_to_submit > 365 THEN 1 END) as submissions_over_1yr
FROM submission_delays
GROUP BY fiscal_year
ORDER BY fiscal_year DESC;

-- How the query works:
-- 1. Creates CTE to calculate submission delays and timeliness flags
-- 2. Aggregates key metrics by fiscal year
-- 3. Focuses on recent years (2018+) with valid dates
-- 4. Calculates percentage of timely submissions and extreme delays

-- Assumptions and Limitations:
-- - Assumes 150 days as standard submission deadline
-- - Requires valid fiscal year end and receipt dates
-- - Limited to records from 2018 onwards
-- - Does not account for approved extensions
-- - May include resubmissions/amendments

-- Possible Extensions:
-- 1. Add provider-level trend analysis
-- 2. Break down by provider control type
-- 3. Include geographic analysis
-- 4. Compare against historical patterns
-- 5. Add correlation with report status codes
-- 6. Track resubmission patterns
-- 7. Include size/volume analysis
-- 8. Add seasonality analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:10:27.042735
    - Additional Notes: Query focuses on Medicare HHA cost report submission patterns and compliance rates. Filters for recent data (2018+) and requires valid submission dates. Results show year-over-year trends in submission delays and compliance rates. May need modification if different compliance thresholds are required or if analysis of older data is needed.
    
    */