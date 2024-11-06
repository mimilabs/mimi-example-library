-- Title: Recent Tobacco Use Intensity Assessment
-- Business Purpose:
-- - Analyze the 5-day recent tobacco use patterns to identify active users
-- - Quantify daily consumption across different tobacco products
-- - Support immediate intervention programs by focusing on current users
-- - Enable healthcare cost projections based on active usage patterns

WITH recent_tobacco_use AS (
    -- Get users who have used any tobacco product in past 5 days
    SELECT 
        seqn,
        smq680 as used_tobacco_past_5days,
        smq710 as cigarette_days,
        smq720 as cigarettes_per_day,
        smq770 as cigar_days,
        smq780 as cigars_per_day,
        smq740 as pipe_days,
        smq750 as pipes_per_day,
        smq800 as chewing_tobacco_days,
        mimi_src_file_date
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_adult_recent_tobacco_use_youth_cigarettetobacco_use
    WHERE smq680 = 1  -- 1 indicates tobacco use in past 5 days
),

daily_consumption AS (
    -- Calculate average daily consumption across products
    SELECT
        mimi_src_file_date,
        COUNT(DISTINCT seqn) as active_users,
        AVG(CASE WHEN cigarette_days > 0 THEN cigarettes_per_day END) as avg_cigarettes_per_day,
        AVG(CASE WHEN cigar_days > 0 THEN cigars_per_day END) as avg_cigars_per_day,
        AVG(CASE WHEN pipe_days > 0 THEN pipes_per_day END) as avg_pipes_per_day,
        COUNT(CASE WHEN chewing_tobacco_days > 0 THEN 1 END) as chewing_tobacco_users
    FROM recent_tobacco_use
    GROUP BY mimi_src_file_date
)

SELECT 
    mimi_src_file_date,
    active_users,
    ROUND(avg_cigarettes_per_day, 1) as avg_cigarettes_per_day,
    ROUND(avg_cigars_per_day, 1) as avg_cigars_per_day,
    ROUND(avg_pipes_per_day, 1) as avg_pipes_per_day,
    chewing_tobacco_users,
    ROUND(chewing_tobacco_users * 100.0 / active_users, 1) as pct_chewing_tobacco
FROM daily_consumption
ORDER BY mimi_src_file_date DESC;

-- How this query works:
-- 1. Identifies active tobacco users from past 5 days
-- 2. Calculates average daily consumption for different products
-- 3. Provides trend analysis by survey date
-- 4. Segments users by product type

-- Assumptions and limitations:
-- - Self-reported data may underestimate actual usage
-- - 5-day window may not capture occasional users
-- - Missing values are excluded from averages
-- - Survey dates may not be continuous

-- Possible extensions:
-- 1. Add demographic breakdowns by age/gender
-- 2. Include nicotine replacement therapy usage
-- 3. Compare weekend vs weekday consumption
-- 4. Add confidence intervals for averages
-- 5. Create risk categories based on consumption levels
-- 6. Calculate estimated annual tobacco product consumption

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:13:32.809825
    - Additional Notes: Query focuses on current tobacco users (past 5 days) and their consumption patterns across multiple products. Results are aggregated by survey date to show trends in usage intensity. Performance may be impacted when analyzing large survey datasets due to multiple aggregations. Consider partitioning by mimi_src_file_date if performance optimization is needed.
    
    */