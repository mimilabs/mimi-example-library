-- observation_temporal_patterns.sql

-- Business Purpose:
-- - Analyze seasonal and temporal patterns in patient observations
-- - Support resource planning by identifying peak observation periods
-- - Enable proactive healthcare delivery by understanding timing patterns
-- - Guide staffing decisions based on observation volume trends

WITH daily_obs_counts AS (
    -- Aggregate observations by date and type
    SELECT 
        DATE_TRUNC('day', date) as obs_date,
        description,
        COUNT(*) as observation_count,
        COUNT(DISTINCT patient) as unique_patients
    FROM mimi_ws_1.synthea.observations
    WHERE date >= DATE_SUB(CURRENT_DATE(), 365)  -- Last 365 days
    GROUP BY DATE_TRUNC('day', date), description
),
rolling_avg AS (
    -- Calculate 7-day rolling averages
    SELECT 
        obs_date,
        description,
        observation_count,
        unique_patients,
        AVG(observation_count) OVER (
            PARTITION BY description 
            ORDER BY obs_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as rolling_7day_avg
    FROM daily_obs_counts
)
-- Final output with key metrics
SELECT 
    description,
    COUNT(DISTINCT obs_date) as days_with_observations,
    ROUND(AVG(observation_count), 2) as avg_daily_observations,
    ROUND(AVG(unique_patients), 2) as avg_daily_patients,
    ROUND(AVG(rolling_7day_avg), 2) as avg_7day_rolling,
    ROUND(STDDEV(observation_count), 2) as observation_variability
FROM rolling_avg
GROUP BY description
HAVING COUNT(DISTINCT obs_date) >= 180  -- Focus on frequently recorded observations
ORDER BY avg_daily_observations DESC
LIMIT 20;

-- How it works:
-- 1. Creates daily aggregates of observation counts by type
-- 2. Calculates 7-day rolling averages to smooth daily fluctuations
-- 3. Generates summary metrics including averages and variability
-- 4. Filters for frequently recorded observations (at least 180 days of data)

-- Assumptions and Limitations:
-- - Assumes consistent data collection across all days
-- - Limited to last 365 days of data
-- - May not capture long-term seasonal patterns
-- - Focuses only on observation frequency, not values
-- - Does not account for holidays or special events

-- Possible Extensions:
-- 1. Add day-of-week analysis to identify weekly patterns
-- 2. Include year-over-year comparisons for seasonal analysis
-- 3. Segment by patient demographics or conditions
-- 4. Add facility or provider location dimensions
-- 5. Incorporate observation value trends alongside frequency
-- 6. Add correlation analysis between different observation types
-- 7. Include cost or resource utilization metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:12:52.537006
    - Additional Notes: The query focuses on observation volume patterns over time, which is valuable for capacity planning and resource allocation. Note that the 365-day lookback period and 180-day minimum threshold might need adjustment based on specific business needs. The rolling 7-day average helps smooth out daily variations but may mask important daily spikes in activity.
    
    */