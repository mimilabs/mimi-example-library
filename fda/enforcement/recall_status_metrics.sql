-- recall_status_tracking.sql
-- 
-- Business Purpose:
-- - Monitor the current status of drug recalls to identify active safety concerns
-- - Track completion rates of recall actions across different severity levels
-- - Support operational oversight of recall management processes
-- - Enable risk assessment based on active vs resolved recalls

WITH recall_status_summary AS (
  -- Calculate summary metrics for recall statuses by classification
  SELECT 
    classification,
    status,
    COUNT(*) as recall_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY classification) as pct_of_class
  FROM mimi_ws_1.fda.enforcement
  WHERE classification IN ('I', 'II', 'III')  -- Focus on standard classifications
  AND status IS NOT NULL
  GROUP BY classification, status
),
active_recalls AS (
  -- Identify currently active recalls and their durations
  SELECT 
    classification,
    DATEDIFF(day, recall_initiation_date, CURRENT_DATE) as days_open,
    COUNT(*) as active_count
  FROM mimi_ws_1.fda.enforcement
  WHERE status = 'Ongoing'
  AND classification IN ('I', 'II', 'III')
  GROUP BY classification, DATEDIFF(day, recall_initiation_date, CURRENT_DATE)
)

SELECT 
  rs.classification,
  rs.status,
  rs.recall_count,
  ROUND(rs.pct_of_class, 1) as pct_of_classification,
  ar.active_count as current_active_recalls,
  ar.days_open as days_since_initiation
FROM recall_status_summary rs
LEFT JOIN active_recalls ar 
  ON rs.classification = ar.classification
ORDER BY 
  rs.classification,
  rs.recall_count DESC;

-- Query Operation:
-- 1. Creates a summary of recall counts by classification and status
-- 2. Calculates percentage distribution within each classification
-- 3. Separately analyzes currently active recalls and their durations
-- 4. Combines status summary with active recall metrics
-- 5. Orders results to show most common statuses within each classification

-- Assumptions & Limitations:
-- - Assumes 'Ongoing' status indicates active recalls
-- - Limited to Class I, II, and III recalls only
-- - Does not account for potential data lag in status updates
-- - Duration calculations based on current date may include weekends/holidays

-- Possible Extensions:
-- 1. Add time-based trending of status changes
-- 2. Include geographic distribution of active recalls
-- 3. Add product type analysis within status categories
-- 4. Incorporate target completion times by classification
-- 5. Add statistical analysis of typical resolution times

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:00:15.959308
    - Additional Notes: The query focuses on recall completion rates and durations, providing key operational metrics for recall management. Note that the days_open calculation assumes continuous calendar days and may need adjustment for business days in some contexts. The query also assumes standardized status values, particularly 'Ongoing' for active recalls.
    
    */