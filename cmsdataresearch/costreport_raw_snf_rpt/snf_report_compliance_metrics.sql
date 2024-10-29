-- snf_submission_compliance.sql
--
-- Business Purpose:
-- Analyze SNF cost report submission patterns and compliance rates across fiscal years
-- to identify potential risks in reporting quality and completeness.
-- This helps payors and regulators assess data reliability and target compliance initiatives.

-- Get submission compliance metrics by fiscal year
WITH fiscal_periods AS (
  SELECT 
    DATE_TRUNC('year', fy_bgn_dt) AS fiscal_year,
    COUNT(DISTINCT prvdr_num) as total_facilities,
    SUM(CASE WHEN initl_rpt_sw = 'Y' THEN 1 ELSE 0 END) as initial_reports,
    SUM(CASE WHEN last_rpt_sw = 'Y' THEN 1 ELSE 0 END) as final_reports,
    AVG(DATEDIFF(DAY, fy_end_dt, fi_rcpt_dt)) as avg_submission_lag
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_rpt
  WHERE fy_bgn_dt >= '2015-01-01' 
    AND fy_end_dt <= CURRENT_DATE
    AND rpt_stus_cd IS NOT NULL
  GROUP BY DATE_TRUNC('year', fy_bgn_dt)
)

SELECT
  fiscal_year,
  total_facilities,
  initial_reports,
  final_reports,
  -- Calculate compliance rates
  ROUND(initial_reports * 100.0 / total_facilities, 1) as initial_submission_rate,
  ROUND(final_reports * 100.0 / total_facilities, 1) as final_submission_rate,
  avg_submission_lag as avg_days_to_submit
FROM fiscal_periods
ORDER BY fiscal_year DESC;

-- How this query works:
-- 1. Creates fiscal_periods CTE to aggregate metrics by fiscal year
-- 2. Counts distinct facilities and categorizes report submissions
-- 3. Calculates average submission lag time
-- 4. Computes compliance rates as percentages
-- 5. Returns sorted results for trend analysis

-- Assumptions and limitations:
-- - Assumes fiscal years start January 1st for simplification
-- - Limited to complete fiscal years with valid status codes
-- - Does not account for facility size or complexity
-- - Submission lag calculations may include outliers

-- Possible extensions:
-- 1. Add geographic analysis by linking provider numbers to regions
-- 2. Include breakdown by provider control type
-- 3. Add statistical analysis of submission patterns
-- 4. Create compliance risk scoring based on submission history
-- 5. Compare submission timeliness against regulatory deadlines

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:24:53.691663
    - Additional Notes: Query focuses on reporting compliance metrics but may need adjustment of date ranges based on actual data availability. Consider adding error handling for null dates and implementing fiscal year adjustments for facilities with non-calendar fiscal years.
    
    */