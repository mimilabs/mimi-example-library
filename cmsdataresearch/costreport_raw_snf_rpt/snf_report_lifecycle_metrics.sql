-- snf_status_lifecycle_analysis.sql
--
-- Business Purpose:
-- Analyze the lifecycle of SNF cost reports by examining their status progression from initial to final submissions.
-- This analysis helps:
-- 1. Understand the typical timeline for report finalization
-- 2. Identify facilities with prolonged reporting cycles
-- 3. Support resource planning for report processing
-- 4. Assess data completeness for downstream analytics

WITH report_lifecycle AS (
  -- Get the full reporting timeline for each provider
  SELECT 
    prvdr_num,
    fy_bgn_dt,
    fy_end_dt,
    rpt_stus_cd,
    initl_rpt_sw,
    last_rpt_sw,
    fi_rcpt_dt,
    npr_dt,
    -- Calculate days between key milestones
    DATEDIFF(fi_rcpt_dt, fy_end_dt) as days_to_submission,
    DATEDIFF(npr_dt, fi_rcpt_dt) as processing_duration,
    -- Flag reports in different stages
    CASE 
      WHEN initl_rpt_sw = '1' THEN 'Initial'
      WHEN last_rpt_sw = '1' THEN 'Final'
      ELSE 'Intermediate'
    END as report_stage
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_rpt
  WHERE fy_end_dt IS NOT NULL 
    AND fi_rcpt_dt IS NOT NULL
),

summary_metrics AS (
  -- Calculate key metrics by report stage
  SELECT
    report_stage,
    COUNT(*) as report_count,
    AVG(days_to_submission) as avg_days_to_submission,
    PERCENTILE(days_to_submission, 0.5) as median_days_to_submission,
    AVG(processing_duration) as avg_processing_duration,
    COUNT(CASE WHEN days_to_submission > 90 THEN 1 END) as late_submissions
  FROM report_lifecycle
  GROUP BY report_stage
)

SELECT
  report_stage,
  report_count,
  ROUND(avg_days_to_submission, 1) as avg_days_to_submission,
  median_days_to_submission,
  ROUND(avg_processing_duration, 1) as avg_processing_duration,
  late_submissions,
  ROUND(100.0 * late_submissions / report_count, 1) as late_submission_pct
FROM summary_metrics
ORDER BY 
  CASE report_stage 
    WHEN 'Initial' THEN 1 
    WHEN 'Intermediate' THEN 2 
    WHEN 'Final' THEN 3 
  END;

-- How this query works:
-- 1. Creates a CTE to extract key lifecycle dates and calculate duration metrics
-- 2. Categorizes reports into stages (Initial, Intermediate, Final)
-- 3. Aggregates metrics by report stage to show patterns in submission timing
-- 4. Presents summary statistics including late submission rates

-- Assumptions and limitations:
-- 1. Assumes fi_rcpt_dt and fy_end_dt are reliable indicators of submission timing
-- 2. Does not account for amended reports or corrections
-- 3. Late submissions defined as >90 days after fiscal year end
-- 4. Missing dates are excluded from analysis

-- Possible extensions:
-- 1. Add trend analysis by fiscal year to identify changing patterns
-- 2. Include provider control type to compare submission patterns by ownership
-- 3. Analyze geographic variations in reporting timeliness
-- 4. Create alerts for providers with consistently late submissions
-- 5. Calculate compliance rates by fiscal intermediary

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:14:25.557715
    - Additional Notes: Query focuses on report processing timelines rather than just statuses. Consider indexing fi_rcpt_dt and fy_end_dt columns for better performance on large datasets. The 90-day threshold for late submissions is configurable based on specific compliance requirements.
    
    */