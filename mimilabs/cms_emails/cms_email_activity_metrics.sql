
/*******************************************************************************
Title: CMS Email Communication Analysis - Core Metrics
 
Business Purpose:
This query analyzes key patterns in CMS email communications to help understand:
- Email volume and trends over time
- Most active senders
- Popular subject themes
- Communication patterns

This helps optimize email communication strategy and engagement.
*******************************************************************************/

WITH daily_metrics AS (
  -- Calculate daily email volumes and unique senders
  SELECT 
    DATE_TRUNC('day', date) AS email_date,
    COUNT(*) AS email_count,
    COUNT(DISTINCT sender_email) AS unique_senders,
    COUNT(DISTINCT subject) AS unique_subjects
  FROM mimi_ws_1.mimilabs.cms_emails
  GROUP BY DATE_TRUNC('day', date)
),

sender_metrics AS (
  -- Analyze sender activity
  SELECT
    sender_name,
    sender_email,
    COUNT(*) AS emails_sent,
    COUNT(DISTINCT subject) AS unique_subjects_used
  FROM mimi_ws_1.mimilabs.cms_emails 
  GROUP BY sender_name, sender_email
)

-- Combine metrics into final summary
SELECT
  -- Time-based metrics
  dm.email_date,
  dm.email_count AS daily_emails,
  dm.unique_senders,
  dm.unique_subjects,
  
  -- Top sender metrics
  sm.sender_name AS most_active_sender,
  sm.emails_sent AS sender_email_count,
  sm.unique_subjects_used
FROM daily_metrics dm
LEFT JOIN sender_metrics sm 
  ON sm.emails_sent = (
    SELECT MAX(emails_sent) 
    FROM sender_metrics
  )
ORDER BY dm.email_date DESC
LIMIT 100;

/*******************************************************************************
How it works:
1. Creates daily rollup of email volumes and unique metrics
2. Analyzes sender patterns separately
3. Combines both views for holistic analysis

Assumptions & Limitations:
- Assumes email dates are populated and accurate
- Limited to available fields (no recipient or engagement data)
- Shows most recent 100 days only
- One sender may have multiple email addresses

Possible Extensions:
1. Add subject line categorization/analysis
2. Include content length metrics
3. Add time-of-day analysis
4. Calculate week-over-week or month-over-month trends
5. Add sender domain analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:04:20.134122
    - Additional Notes: Query provides daily email activity metrics and sender analysis, focusing on volume trends and sender patterns. Results are limited to most recent 100 days. Best used for high-level communication pattern analysis but lacks engagement metrics and recipient data.
    
    */