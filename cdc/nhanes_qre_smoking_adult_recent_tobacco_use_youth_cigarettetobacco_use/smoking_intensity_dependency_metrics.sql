-- Title: NHANES Daily Cigarette Consumption and Time-to-First-Smoke Analysis

-- Business Purpose:
-- - Quantify smoking intensity patterns by analyzing cigarettes per day and wake-to-smoke intervals
-- - Support healthcare resource planning by identifying heavy smokers and high-dependency patterns
-- - Enable targeted intervention strategies based on smoking intensity metrics
-- - Provide baseline data for smoking cessation program design

WITH daily_smoking_patterns AS (
    -- Get core smoking intensity metrics
    SELECT 
        seqn,
        CASE 
            WHEN smq650 BETWEEN 1 AND 10 THEN 'Light (1-10)'
            WHEN smq650 BETWEEN 11 AND 20 THEN 'Moderate (11-20)'
            WHEN smq650 > 20 THEN 'Heavy (>20)'
            ELSE 'Non-daily/None'
        END AS consumption_category,
        CASE 
            WHEN smq077 = 1 THEN 'Within 5 minutes'
            WHEN smq077 = 2 THEN '6-30 minutes'
            WHEN smq077 = 3 THEN '31-60 minutes'
            WHEN smq077 = 4 THEN 'After 60 minutes'
            ELSE 'Unknown'
        END AS time_to_first_smoke,
        smq650 as cigarettes_per_day,
        smq640 as days_smoked_last_30
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_adult_recent_tobacco_use_youth_cigarettetobacco_use
    WHERE smq650 IS NOT NULL 
    AND smq077 IS NOT NULL
)

SELECT 
    consumption_category,
    time_to_first_smoke,
    COUNT(*) as smoker_count,
    ROUND(AVG(cigarettes_per_day), 1) as avg_cigarettes_per_day,
    ROUND(AVG(days_smoked_last_30), 1) as avg_smoking_days_per_month,
    -- Calculate estimated monthly cigarette consumption
    ROUND(AVG(cigarettes_per_day * days_smoked_last_30), 0) as est_monthly_cigarettes
FROM daily_smoking_patterns
GROUP BY consumption_category, time_to_first_smoke
HAVING consumption_category != 'Non-daily/None'
ORDER BY 
    CASE consumption_category 
        WHEN 'Light (1-10)' THEN 1 
        WHEN 'Moderate (11-20)' THEN 2 
        WHEN 'Heavy (>20)' THEN 3 
    END,
    CASE time_to_first_smoke
        WHEN 'Within 5 minutes' THEN 1
        WHEN '6-30 minutes' THEN 2
        WHEN '31-60 minutes' THEN 3
        WHEN 'After 60 minutes' THEN 4
        ELSE 5
    END;

-- How the Query Works:
-- 1. Creates a CTE to categorize smokers by consumption level and time-to-first-smoke
-- 2. Calculates key metrics including average daily consumption and smoking frequency
-- 3. Estimates monthly cigarette consumption for different smoker segments
-- 4. Orders results by smoking intensity and dependency indicators

-- Assumptions and Limitations:
-- - Assumes valid responses for cigarettes per day (smq650) and time to first smoke (smq077)
-- - Does not account for seasonal variations in smoking patterns
-- - Self-reported data may underestimate actual consumption
-- - Monthly estimates assume consistent daily consumption

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, socioeconomic status)
-- 2. Include quit attempt correlation analysis
-- 3. Incorporate brand preferences by consumption category
-- 4. Add year-over-year trend analysis
-- 5. Calculate estimated annual healthcare costs by consumption category

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:10:29.540910
    - Additional Notes: Query focuses on quantitative smoking behavior metrics by combining daily consumption with time-to-first-smoke dependency indicator. Results can be used for healthcare resource allocation and intervention program design. Note that the monthly consumption estimates assume consistent daily smoking patterns, which may not reflect actual behavior variations.
    
    */