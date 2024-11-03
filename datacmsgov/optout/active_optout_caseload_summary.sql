-- Title: Medicare Opt-Out Provider Active Case Load Analysis

-- Business Purpose:
-- This query analyzes the current active opt-out provider caseload by calculating
-- how many providers are actively opted out vs pending opt-out or recently expired.
-- Understanding the active caseload helps administrators plan resources, assess
-- workload, and forecast staffing needs for processing opt-out requests.

WITH current_status AS (
    SELECT 
        -- Calculate status based on dates
        CASE 
            WHEN optout_effective_date > CURRENT_DATE() THEN 'Pending'
            WHEN optout_end_date < CURRENT_DATE() THEN 'Expired'
            ELSE 'Active'
        END AS opt_out_status,
        
        -- Calculate days remaining in opt-out period
        DATEDIFF(day, CURRENT_DATE(), optout_end_date) as days_remaining,
        
        specialty,
        state_code
    FROM mimi_ws_1.datacmsgov.optout
    -- Focus on recent records only
    WHERE mimi_src_file_date >= DATE_SUB(CURRENT_DATE(), 90)
),

status_summary AS (
    SELECT
        opt_out_status,
        COUNT(*) as provider_count,
        COUNT(DISTINCT specialty) as unique_specialties,
        COUNT(DISTINCT state_code) as states_affected,
        AVG(days_remaining) as avg_days_remaining
    FROM current_status
    GROUP BY opt_out_status
)

SELECT 
    opt_out_status,
    provider_count,
    unique_specialties,
    states_affected,
    ROUND(avg_days_remaining, 0) as avg_days_remaining,
    ROUND(100.0 * provider_count / SUM(provider_count) OVER(), 1) as percent_of_total
FROM status_summary
ORDER BY 
    CASE opt_out_status 
        WHEN 'Active' THEN 1
        WHEN 'Pending' THEN 2 
        WHEN 'Expired' THEN 3
    END;

-- How this query works:
-- 1. Creates a CTE to classify providers into status categories (Active/Pending/Expired)
-- 2. Calculates key metrics for each status group including counts and averages
-- 3. Computes percentages and formats final output for business review
--
-- Assumptions and limitations:
-- - Assumes data is current and complete in the source table
-- - Limited to last 90 days of source data to focus on recent patterns
-- - Does not account for providers with multiple opt-out periods
-- - Status classifications are simplified to three categories
--
-- Possible extensions:
-- - Add trend analysis comparing caseload changes month-over-month
-- - Include geographic distribution of active cases
-- - Add workload forecasting based on pending cases
-- - Incorporate complexity factors based on provider specialty
-- - Add alerts for high-volume status changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:59:30.198556
    - Additional Notes: Query focuses on current workload segmentation rather than historical trends. The 90-day lookback window may need adjustment based on data refresh patterns. Status categories are simplified and may need refinement for specific business needs. Consider monitoring performance with large datasets due to date calculations.
    
    */