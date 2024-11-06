-- OTP Provider Recent Enrollment Activity Monitoring
--
-- Business Purpose:
-- - Monitor new provider enrollment activity in the past 90 days
-- - Identify potential network expansion opportunities
-- - Support provider outreach and onboarding initiatives
-- - Track program growth in key markets

WITH recent_enrollments AS (
    SELECT 
        state,
        city,
        COUNT(DISTINCT npi) as new_providers,
        MIN(medicare_id_effective_date) as earliest_enrollment,
        MAX(medicare_id_effective_date) as latest_enrollment
    FROM mimi_ws_1.datacmsgov.otpp
    WHERE medicare_id_effective_date >= DATEADD(day, -90, CURRENT_DATE())
    GROUP BY state, city
    HAVING COUNT(DISTINCT npi) >= 2  -- Focus on areas with multiple new providers
),

state_summary AS (
    SELECT 
        state,
        SUM(new_providers) as total_new_providers,
        COUNT(DISTINCT city) as cities_with_growth
    FROM recent_enrollments
    GROUP BY state
)

SELECT 
    r.state,
    r.city,
    r.new_providers,
    s.total_new_providers as state_total_providers,
    r.new_providers * 100.0 / s.total_new_providers as pct_of_state_growth,
    r.earliest_enrollment,
    r.latest_enrollment
FROM recent_enrollments r
JOIN state_summary s ON r.state = s.state
WHERE s.total_new_providers >= 3  -- Focus on states with meaningful growth
ORDER BY s.total_new_providers DESC, r.new_providers DESC;

-- How this query works:
-- 1. Identifies recent enrollments within the last 90 days
-- 2. Groups providers by state and city to find growth clusters
-- 3. Calculates state-level summaries
-- 4. Combines city and state metrics to show growth patterns
-- 5. Filters for meaningful growth patterns (multiple providers)

-- Assumptions and Limitations:
-- - Assumes medicare_id_effective_date represents actual enrollment timing
-- - Limited to 90-day lookback period
-- - Focuses only on areas with multiple new providers
-- - Does not account for provider departures/terminations
-- - May miss single-provider markets that are still significant

-- Possible Extensions:
-- 1. Add year-over-year comparison of enrollment patterns
-- 2. Include provider speciality analysis from provider names
-- 3. Add population demographics to identify underserved areas
-- 4. Compare growth rates to historical averages
-- 5. Include distance analysis between new providers
-- 6. Track provider retention after initial enrollment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:07:18.692920
    - Additional Notes: Query identifies geographic clusters of recent OTP provider enrollment activity, focusing on areas with multiple new providers joining within a 90-day window. Best used for quarterly network growth analysis and identifying emerging treatment hubs. May need adjustment of thresholds (90 days, minimum provider counts) based on specific monitoring needs.
    
    */