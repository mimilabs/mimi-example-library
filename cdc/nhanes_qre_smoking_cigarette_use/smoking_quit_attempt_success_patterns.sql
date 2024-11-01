-- Title: NHANES Smoking Quit Attempts Analysis and Success Patterns

-- Business Purpose:
-- This query analyzes smoking cessation attempts and success patterns to:
-- 1. Identify the frequency and duration of quit attempts
-- 2. Calculate success rates for different quit attempt durations
-- 3. Help inform smoking cessation program design and resource allocation
-- 4. Support public health interventions targeting specific smoker segments

WITH quit_attempts AS (
    -- Get base population of smokers who tried to quit
    SELECT 
        seqn,
        smq670 as attempted_quit_12m,  -- quit attempt in last 12 months
        smq848 as quit_attempt_count,  -- number of quit attempts
        smq852q as last_quit_duration, -- duration of last quit attempt
        smq852u as last_quit_unit,     -- unit for quit duration (days/weeks/months)
        smd030 as age_started_smoking,
        CASE WHEN smq040 = 1 THEN 'Every day'
             WHEN smq040 = 2 THEN 'Some days' 
             WHEN smq040 = 3 THEN 'Not at all'
             ELSE 'Unknown'
        END as current_smoking_status
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_cigarette_use
    WHERE smq670 IS NOT NULL 
),

standardized_durations AS (
    -- Convert all quit durations to days for consistent comparison
    SELECT 
        *,
        CASE 
            WHEN last_quit_unit = 1 THEN last_quit_duration         -- days
            WHEN last_quit_unit = 2 THEN last_quit_duration * 7     -- weeks to days
            WHEN last_quit_unit = 3 THEN last_quit_duration * 30    -- months to days
            WHEN last_quit_unit = 4 THEN last_quit_duration * 365   -- years to days
            ELSE NULL 
        END as quit_duration_days
    FROM quit_attempts
)

SELECT 
    current_smoking_status,
    COUNT(*) as total_respondents,
    
    -- Quit attempt metrics
    ROUND(AVG(quit_attempt_count), 1) as avg_quit_attempts,
    ROUND(AVG(quit_duration_days), 1) as avg_quit_duration_days,
    
    -- Success metrics
    COUNT(CASE WHEN quit_duration_days >= 30 THEN 1 END) as quit_30days_plus,
    COUNT(CASE WHEN current_smoking_status = 'Not at all' THEN 1 END) as successful_quitters,
    
    -- Age-related patterns
    ROUND(AVG(age_started_smoking), 1) as avg_age_started_smoking
    
FROM standardized_durations
WHERE quit_attempt_count > 0  -- Focus on those who made quit attempts
GROUP BY current_smoking_status
ORDER BY total_respondents DESC;

-- How this query works:
-- 1. First CTE identifies smokers who have attempted to quit and captures key cessation metrics
-- 2. Second CTE standardizes quit durations to days for consistent analysis
-- 3. Final SELECT aggregates the data to show patterns in quit attempts and success rates

-- Assumptions and Limitations:
-- 1. Self-reported data may have recall bias
-- 2. Quit duration conversions use approximate month (30 days) and year (365 days) lengths
-- 3. Success is defined as current "Not at all" smoking status
-- 4. Missing or null values are excluded from averages

-- Possible Extensions:
-- 1. Add demographic breakdowns (age groups, gender, etc.)
-- 2. Include analysis of cessation methods used
-- 3. Compare quit success rates across different time periods
-- 4. Analyze relationship between quit attempts and nicotine dependence levels
-- 5. Include cost analysis of failed quit attempts

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:27:53.138281
    - Additional Notes: Query focuses on quit attempt patterns and success rates among smokers, with standardized duration calculations. Best used in conjunction with demographic data for deeper insights. Memory usage may be high for large datasets due to multiple CTEs.
    
    */