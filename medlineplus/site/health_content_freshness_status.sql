-- health_information_freshness.sql

-- Business Purpose:
-- - Monitor the freshness and update patterns of health information resources
-- - Identify potential stale or outdated content requiring review
-- - Support content quality assurance and maintenance prioritization
-- - Track source data update frequency patterns

WITH latest_updates AS (
    -- Get the most recent update date for each topic
    SELECT 
        topic_id,
        MAX(mimi_src_file_date) as latest_update,
        MIN(mimi_src_file_date) as first_update,
        COUNT(DISTINCT url) as resource_count
    FROM mimi_ws_1.medlineplus.site
    GROUP BY topic_id
),
update_metrics AS (
    -- Calculate update patterns and resource metrics
    SELECT 
        topic_id,
        latest_update,
        first_update,
        resource_count,
        DATEDIFF(day, first_update, latest_update) as days_between_updates,
        DATEDIFF(day, latest_update, CURRENT_DATE) as days_since_last_update
    FROM latest_updates
)

SELECT 
    um.topic_id,
    um.resource_count,
    um.latest_update,
    um.days_since_last_update,
    CASE 
        WHEN days_since_last_update > 365 THEN 'Review Required'
        WHEN days_since_last_update > 180 THEN 'Monitor'
        ELSE 'Current'
    END as content_status,
    um.days_between_updates as total_coverage_period_days
FROM update_metrics um
ORDER BY days_since_last_update DESC;

-- How it works:
-- 1. Creates a CTE to find the latest and first update dates for each topic
-- 2. Calculates key metrics about update patterns and resource counts
-- 3. Categorizes topics based on their update recency
-- 4. Orders results to highlight topics needing attention first

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date is a reliable proxy for content currency
-- - Does not account for the nature or significance of updates
-- - Simple categorization may not fit all use cases
-- - Does not consider seasonal or condition-specific update requirements

-- Possible Extensions:
-- 1. Add trending analysis of update frequencies over time
-- 2. Include topic metadata to prioritize by health condition severity
-- 3. Implement more sophisticated staleness criteria
-- 4. Add resource quality metrics beyond just count and timing
-- 5. Create alerts for topics exceeding update thresholds
-- 6. Compare update patterns across different types of health resources

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:10:57.019317
    - Additional Notes: Query focuses on content maintenance by tracking update patterns and flagging potentially outdated health information. Primary metrics include days since last update and total coverage period. The 365/180 day thresholds for content status are configurable based on organizational requirements.
    
    */