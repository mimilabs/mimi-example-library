-- Title: Recent Provider Deactivation Status Check
-- 
-- Business Purpose:
-- - Quickly verify provider status by identifying recent deactivations
-- - Support credentialing and enrollment teams in maintaining accurate provider rosters
-- - Enable rapid response to provider status changes for network management
-- - Facilitate immediate compliance updates for active provider lists

WITH recent_deactivations AS (
    -- Get the most recent deactivations within the last 90 days
    SELECT 
        npi,
        deactivation_date,
        mimi_src_file_date
    FROM mimi_ws_1.nppes.deactivated
    WHERE deactivation_date >= DATEADD(day, -90, CURRENT_DATE)
),

summary_stats AS (
    -- Calculate key metrics for recent deactivations
    SELECT 
        COUNT(DISTINCT npi) as total_recent_deactivations,
        MIN(deactivation_date) as earliest_recent_deactivation,
        MAX(deactivation_date) as latest_recent_deactivation,
        MAX(mimi_src_file_date) as most_recent_data_update
    FROM recent_deactivations
)

-- Combine results into a business-friendly format
SELECT 
    'Last 90 Days' as time_period,
    total_recent_deactivations,
    earliest_recent_deactivation,
    latest_recent_deactivation,
    most_recent_data_update as data_freshness,
    DATEDIFF(day, most_recent_data_update, CURRENT_DATE) as days_since_last_update
FROM summary_stats;

-- How this query works:
-- 1. First CTE filters for recent deactivations within 90 days
-- 2. Second CTE calculates summary statistics
-- 3. Final SELECT formats results for business users
--
-- Assumptions and Limitations:
-- - Assumes data is regularly updated in the source system
-- - 90-day window is configurable based on business needs
-- - Does not include detailed provider information
-- - Data freshness depends on mimi_src_file_date updates
--
-- Possible Extensions:
-- 1. Add weekly or monthly trending of deactivation counts
-- 2. Include provider specialty or type information
-- 3. Add alerts for unusual spikes in deactivations
-- 4. Compare against historical baseline periods
-- 5. Add provider location or organization affiliation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:53:43.526066
    - Additional Notes: Query provides a quick snapshot of provider deactivations in the last 90 days with data freshness metrics. The 90-day lookback period can be adjusted by modifying the DATEADD function parameter. Results include total deactivations and date ranges to help credentialing teams maintain current provider rosters.
    
    */