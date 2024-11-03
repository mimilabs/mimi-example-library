-- NHANES Laboratory Visit Scheduling Pattern Analysis
-- Business Purpose: Analyze exam session timing and fasting patterns to:
-- 1. Optimize laboratory staffing based on session distribution
-- 2. Identify opportunities to improve patient scheduling
-- 3. Support capacity planning by understanding session preferences

WITH exam_sessions AS (
    -- Calculate total fasting time in hours for each patient
    SELECT 
        seqn,
        phdsesn,
        phafsthr + (phafstmn/60.0) as total_fast_hours,
        CASE 
            WHEN phdsesn = 'Morning' THEN 1
            WHEN phdsesn = 'Afternoon' THEN 2
            WHEN phdsesn = 'Evening' THEN 3
            ELSE 4
        END as session_order
    FROM mimi_ws_1.cdc.nhanes_lab_fasting_questionnaire
    WHERE phdsesn IS NOT NULL
),

session_metrics AS (
    -- Calculate key metrics for each session type
    SELECT 
        phdsesn as session_type,
        COUNT(*) as visit_count,
        ROUND(AVG(total_fast_hours), 1) as avg_fast_hours,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_of_total
    FROM exam_sessions
    GROUP BY phdsesn, session_order
    ORDER BY session_order
)

SELECT 
    session_type,
    visit_count,
    avg_fast_hours,
    pct_of_total as percentage_of_visits,
    -- Create visual bar chart of distribution
    REPEAT('■', CAST(pct_of_total/2 AS INT)) as distribution
FROM session_metrics;

-- How this query works:
-- 1. First CTE normalizes the session data and calculates total fasting time
-- 2. Second CTE aggregates key metrics by session type
-- 3. Final select creates a formatted report with visual distribution

-- Assumptions and Limitations:
-- - Assumes session types are consistently recorded as Morning/Afternoon/Evening
-- - Does not account for seasonal or day-of-week variations
-- - Fasting times are self-reported by patients

-- Possible Extensions:
-- 1. Add temporal analysis by mimi_src_file_date to identify trends
-- 2. Cross-reference with specific lab test requirements
-- 3. Include analysis of non-water consumption patterns by session
-- 4. Compare fasting compliance rates across session types
-- 5. Evaluate impact of session timing on specific lab test results

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:30:22.460224
    - Additional Notes: Query provides insight into laboratory session scheduling patterns and associated fasting behaviors. While the visual distribution using unicode blocks works in most modern SQL clients, some environments may not display these characters correctly. The session_order logic assumes a standard three-session day structure - modify if different session definitions are used.
    
    */