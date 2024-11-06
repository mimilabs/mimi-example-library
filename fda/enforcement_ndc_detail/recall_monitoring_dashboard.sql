-- Title: Drug Recall Timeline Monitoring Dashboard
-- Business Purpose:
-- This query creates a monitoring dashboard that tracks:
-- 1. Recent drug recall activity to enable rapid response
-- 2. Number of unique products affected within each recall event
-- 3. Patterns in recall timing to support resource planning
-- Key stakeholders: Drug Safety Teams, Supply Chain Managers, Quality Control

WITH recall_metrics AS (
    -- Get the latest distinct recall events and count affected products
    SELECT 
        e.recall_number,
        MIN(e.mimi_src_file_date) as first_reported_date,
        COUNT(DISTINCT e.package_ndc) as affected_packages,
        COUNT(DISTINCT e.product_ndc) as affected_products
    FROM mimi_ws_1.fda.enforcement_ndc_detail e
    GROUP BY e.recall_number
),
recent_recalls AS (
    -- Focus on recent recall activity
    SELECT 
        TRUNC(first_reported_date, 'MM') as report_month,
        COUNT(DISTINCT recall_number) as recall_events,
        SUM(affected_packages) as total_packages_affected,
        SUM(affected_products) as total_products_affected,
        ROUND(AVG(affected_products), 1) as avg_products_per_recall
    FROM recall_metrics
    WHERE first_reported_date >= DATE_SUB(CURRENT_DATE(), 12)
    GROUP BY TRUNC(first_reported_date, 'MM')
    ORDER BY report_month DESC
)

SELECT 
    report_month,
    recall_events,
    total_packages_affected,
    total_products_affected,
    avg_products_per_recall,
    -- Calculate month-over-month changes
    LAG(recall_events) OVER (ORDER BY report_month) as prev_month_recalls,
    ROUND(100.0 * (recall_events - LAG(recall_events) OVER (ORDER BY report_month)) 
        / LAG(recall_events) OVER (ORDER BY report_month), 1) as recall_change_pct
FROM recent_recalls;

-- How it works:
-- 1. First CTE aggregates recall events and counts affected products
-- 2. Second CTE focuses on recent activity and calculates monthly metrics
-- 3. Main query adds month-over-month trending analysis

-- Assumptions and limitations:
-- 1. Assumes mimi_src_file_date represents the recall reporting date
-- 2. Limited to last 12 months of data
-- 3. Does not account for recall severity or classification
-- 4. May include recalls that were later withdrawn

-- Possible extensions:
-- 1. Add recall classification analysis
-- 2. Include seasonal patterns analysis
-- 3. Add geographic distribution of recalls
-- 4. Incorporate recall reason categories
-- 5. Add alerts for significant month-over-month changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:39:37.651439
    - Additional Notes: Query provides a rolling 12-month view of drug recall activity with month-over-month trending. Performance may be impacted with large datasets due to window functions. Consider adding WHERE clauses on specific date ranges for faster execution in large environments.
    
    */