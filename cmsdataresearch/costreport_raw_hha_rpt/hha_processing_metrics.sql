-- hha_reimbursement_review_patterns.sql
--
-- Business Purpose: Analyze Home Health Agency cost report review and reimbursement patterns to:
-- - Track the timeline between submission and final NPR (Notice of Program Reimbursement)
-- - Identify agencies with pending or delayed reimbursement determinations
-- - Support operational efficiency in cost report processing
-- - Highlight potential bottlenecks in the reimbursement cycle

WITH report_timeline AS (
  -- Calculate key processing intervals for each cost report
  SELECT 
    prvdr_num,
    fy_bgn_dt,
    fy_end_dt,
    fi_rcpt_dt,
    npr_dt,
    rpt_stus_cd,
    DATEDIFF(fi_rcpt_dt, fy_end_dt) as days_to_submission,
    DATEDIFF(npr_dt, fi_rcpt_dt) as days_to_npr,
    CASE 
      WHEN npr_dt IS NULL AND fi_rcpt_dt IS NOT NULL THEN DATEDIFF(CURRENT_DATE, fi_rcpt_dt)
      ELSE NULL 
    END as days_pending
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
  WHERE fy_end_dt >= '2018-01-01'  -- Focus on recent fiscal years
    AND fi_rcpt_dt IS NOT NULL     -- Only include received reports
),

processing_metrics AS (
  -- Calculate summary statistics for processing times
  SELECT
    YEAR(fy_end_dt) as fiscal_year,
    COUNT(*) as total_reports,
    COUNT(CASE WHEN npr_dt IS NOT NULL THEN 1 END) as completed_reports,
    ROUND(AVG(days_to_submission), 1) as avg_submission_days,
    ROUND(AVG(days_to_npr), 1) as avg_npr_days,
    ROUND(AVG(days_pending), 1) as avg_pending_days,
    COUNT(CASE WHEN days_pending > 180 THEN 1 END) as reports_pending_over_180days
  FROM report_timeline
  GROUP BY YEAR(fy_end_dt)
  ORDER BY fiscal_year DESC
)

SELECT
  fiscal_year,
  total_reports,
  completed_reports,
  ROUND(100.0 * completed_reports / total_reports, 1) as completion_rate,
  avg_submission_days,
  avg_npr_days,
  avg_pending_days,
  reports_pending_over_180days,
  ROUND(100.0 * reports_pending_over_180days / total_reports, 1) as pct_long_pending
FROM processing_metrics;

-- How this query works:
-- 1. Creates a CTE to calculate key processing intervals for each cost report
-- 2. Aggregates the data by fiscal year to show processing metrics
-- 3. Calculates completion rates and pending report statistics
-- 4. Focuses on recent years to show current operational patterns

-- Assumptions and limitations:
-- - Assumes fi_rcpt_dt represents start of processing
-- - Null NPR dates indicate pending status
-- - Limited to reports from 2018 forward
-- - Does not account for report amendments or resubmissions

-- Possible extensions:
-- 1. Add geographic analysis to identify regional processing variations
-- 2. Include provider control type to compare processing times by ownership
-- 3. Create aging buckets for pending reports
-- 4. Add trending analysis for processing times
-- 5. Include fiscal intermediary performance comparison

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:24:09.301824
    - Additional Notes: Query tracks critical operational metrics for HHA cost report processing timelines and reimbursement cycles. Does not account for report resubmissions or amendments. Processing time calculations may be affected by holidays and weekends. Consider fiscal intermediary workload patterns when interpreting results.
    
    */