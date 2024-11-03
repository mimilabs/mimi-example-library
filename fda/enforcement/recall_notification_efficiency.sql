-- drug_recall_timelines.sql
-- Business Purpose: 
-- - Analyze FDA drug recall response effectiveness and notification timelines
-- - Identify delays between initiation and reporting of recalls
-- - Support process improvement for rapid recall communication
-- - Help optimize public safety notification protocols

WITH recall_timing AS (
    -- Calculate key timing metrics for each recall
    SELECT 
        recall_number,
        initial_firm_notification,
        recall_initiation_date,
        report_date,
        status,
        classification,
        DATEDIFF(report_date, recall_initiation_date) as days_to_report,
        CASE 
            WHEN initial_firm_notification LIKE '%Letter%' THEN 'Letter'
            WHEN initial_firm_notification LIKE '%Phone%' THEN 'Phone'
            WHEN initial_firm_notification LIKE '%Press%' THEN 'Press Release'
            WHEN initial_firm_notification LIKE '%Email%' THEN 'Email'
            ELSE 'Other'
        END as notification_method
    FROM mimi_ws_1.fda.enforcement
    WHERE recall_initiation_date IS NOT NULL 
    AND report_date IS NOT NULL
)

SELECT 
    notification_method,
    classification,
    COUNT(*) as recall_count,
    ROUND(AVG(days_to_report), 1) as avg_days_to_report,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY days_to_report) as median_days_to_report,
    MIN(days_to_report) as min_days_to_report,
    MAX(days_to_report) as max_days_to_report
FROM recall_timing
GROUP BY notification_method, classification
HAVING COUNT(*) >= 5
ORDER BY classification, avg_days_to_report DESC;

-- How it works:
-- 1. Creates a CTE to calculate timing metrics and standardize notification methods
-- 2. Uses DATEDIFF to calculate days between initiation and FDA report
-- 3. Aggregates timing statistics by notification method and recall classification
-- 4. Filters for statistically meaningful groups (5+ recalls)
-- 5. Orders results to highlight patterns in reporting timelines

-- Assumptions and Limitations:
-- - Assumes recall_initiation_date and report_date are valid and meaningful
-- - Notification method categorization may oversimplify complex communication strategies
-- - Does not account for holidays or weekends in day calculations
-- - Limited to recalls with complete timing data

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of reporting timelines
-- 2. Include product type and reason for recall in the analysis
-- 3. Calculate compliance with target reporting windows
-- 4. Add geographic analysis of notification speed
-- 5. Correlate notification method effectiveness with recall scope (product_quantity)
-- 6. Compare voluntary vs. mandated recall timelines

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:53:12.340601
    - Additional Notes: The query focuses on measuring the time gap between recall initiation and public notification across different communication methods and recall classifications. Note that the PERCENTILE_CONT function may have different behavior across database systems, and the notification method categorization is simplified to five major categories.
    
    */