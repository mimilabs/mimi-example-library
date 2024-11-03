-- Title: NHANES Smoking Intensity and Addiction Pattern Analysis

-- Business Purpose:
-- This query analyzes smoking intensity and addiction patterns to:
-- 1. Identify high-risk populations based on cigarettes per day and time to first cigarette
-- 2. Assess smoking dependency levels for public health intervention planning
-- 3. Support targeted cessation program design
-- 4. Guide resource allocation for nicotine addiction treatment

SELECT 
    -- Categorize time to first cigarette as addiction severity indicator
    CASE 
        WHEN smq07_ = 1 THEN 'Within 5 minutes'
        WHEN smq07_ = 2 THEN '6-30 minutes'
        WHEN smq07_ = 3 THEN '31-60 minutes'
        WHEN smq07_ = 4 THEN 'After 60 minutes'
        ELSE 'Not specified'
    END AS time_to_first_cigarette,

    -- Create smoking intensity categories
    CASE 
        WHEN smd650 < 10 THEN 'Light (< 10/day)'
        WHEN smd650 BETWEEN 10 AND 20 THEN 'Moderate (10-20/day)'
        WHEN smd650 > 20 THEN 'Heavy (> 20/day)'
        ELSE 'Not specified'
    END AS smoking_intensity,

    -- Calculate summary statistics
    COUNT(*) as population_count,
    AVG(CAST(smd650 AS FLOAT)) as avg_cigarettes_per_day,
    AVG(CAST(smd641 AS FLOAT)) as avg_smoking_days_per_month,

    -- Calculate percentage for each category
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage_in_category

FROM mimi_ws_1.cdc.nhanes_qre_smoking_cigarette_use
WHERE 
    -- Focus on current smokers with valid responses
    smq040 = 1 -- Current smokers
    AND smd650 IS NOT NULL -- Valid cigarettes per day
    AND smq07_ IS NOT NULL -- Valid time to first cigarette
GROUP BY 
    CASE 
        WHEN smq07_ = 1 THEN 'Within 5 minutes'
        WHEN smq07_ = 2 THEN '6-30 minutes'
        WHEN smq07_ = 3 THEN '31-60 minutes'
        WHEN smq07_ = 4 THEN 'After 60 minutes'
        ELSE 'Not specified'
    END,
    CASE 
        WHEN smd650 < 10 THEN 'Light (< 10/day)'
        WHEN smd650 BETWEEN 10 AND 20 THEN 'Moderate (10-20/day)'
        WHEN smd650 > 20 THEN 'Heavy (> 20/day)'
        ELSE 'Not specified'
    END
ORDER BY 
    time_to_first_cigarette,
    smoking_intensity;

-- How this query works:
-- 1. Identifies current smokers using smq040
-- 2. Categorizes smoking intensity based on cigarettes per day (smd650)
-- 3. Classifies addiction severity using time to first cigarette (smq07_)
-- 4. Calculates population counts and percentages for each category
-- 5. Provides average cigarettes per day and smoking days per month

-- Assumptions and limitations:
-- 1. Assumes current smokers are accurately self-reporting
-- 2. Limited to respondents with valid responses for key metrics
-- 3. Does not account for seasonal variations in smoking patterns
-- 4. Cross-sectional nature limits longitudinal insights

-- Possible extensions:
-- 1. Add demographic breakdowns (age, gender, socioeconomic status)
-- 2. Include brand preferences and nicotine content correlation
-- 3. Analyze relationship with quit attempts and success rates
-- 4. Incorporate e-cigarette dual use patterns
-- 5. Add temporal trends across survey cycles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:11:31.223419
    - Additional Notes: Query calculates key addiction metrics based on the Fagerström Test criteria (time to first cigarette and cigarettes per day). Results can be used to estimate nicotine dependence levels in the population and identify high-risk groups for targeted interventions. Consider joining with demographic tables for more detailed analysis.
    
    */