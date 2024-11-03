-- air_quality_exceptional_events_impact.sql
-- 
-- Business Purpose:
-- Analyze the impact of exceptional events (like wildfires, dust storms) on air quality measurements
-- to help environmental agencies and policymakers:
-- 1. Quantify how exceptional events affect regulatory compliance
-- 2. Identify regions most impacted by these events
-- 3. Support evidence-based decisions for exceptional event exclusions
-- 4. Guide resource allocation for emergency response

SELECT 
    year,
    state_name,
    parameter_name,
    -- Count total monitoring sites
    COUNT(DISTINCT CONCAT(state_code, county_code, site_num)) as monitor_count,
    -- Analyze exceptional events
    SUM(exceptional_data_count) as total_exceptional_events,
    -- Calculate average impact per site
    ROUND(AVG(CASE 
        WHEN exceptional_data_count > 0 
        THEN exceptional_data_count 
    END), 2) as avg_events_per_affected_site,
    -- Compare means with/without events
    ROUND(AVG(CASE 
        WHEN event_type = 'Events Included' 
        THEN arithmetic_mean 
    END), 2) as mean_with_events,
    ROUND(AVG(CASE 
        WHEN event_type = 'Events Excluded' 
        THEN arithmetic_mean 
    END), 2) as mean_without_events,
    -- Calculate percent difference in means
    ROUND(100 * (
        AVG(CASE WHEN event_type = 'Events Included' THEN arithmetic_mean END) -
        AVG(CASE WHEN event_type = 'Events Excluded' THEN arithmetic_mean END)
    ) / NULLIF(AVG(CASE WHEN event_type = 'Events Excluded' THEN arithmetic_mean END), 0), 1) 
    as percent_difference_means
FROM mimi_ws_1.epa.airdata_yearly
WHERE 
    exceptional_data_count > 0
    AND year >= 2018  -- Focus on recent years
GROUP BY 
    year,
    state_name,
    parameter_name
HAVING 
    total_exceptional_events >= 10  -- Focus on significant impact
ORDER BY 
    year DESC,
    total_exceptional_events DESC
LIMIT 100;

-- How this query works:
-- 1. Identifies monitoring sites affected by exceptional events
-- 2. Calculates the frequency and magnitude of these events by state and pollutant
-- 3. Compares air quality measurements with and without exceptional events
-- 4. Focuses on recent years and significant impacts (10+ exceptional events)

-- Assumptions and limitations:
-- 1. Assumes exceptional events are properly documented and flagged in the data
-- 2. Limited to recent years (2018+) for relevance
-- 3. Only considers cases with 10+ exceptional events for significance
-- 4. May not capture all nuances of event impacts due to aggregation

-- Possible extensions:
-- 1. Add seasonal analysis to identify when exceptional events are most common
-- 2. Include geographic clustering to identify regional patterns
-- 3. Correlate with specific event types (wildfires, dust storms, etc.)
-- 4. Add economic impact estimates based on monitoring disruptions
-- 5. Compare with historical baselines to identify trending patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:54:07.233949
    - Additional Notes: Query focuses on exceptional air quality events with 10+ occurrences since 2018, providing metrics on their frequency and impact on air quality measurements. Important to note that the percent difference calculation may return NULL values when there are no readings without events for comparison.
    
    */