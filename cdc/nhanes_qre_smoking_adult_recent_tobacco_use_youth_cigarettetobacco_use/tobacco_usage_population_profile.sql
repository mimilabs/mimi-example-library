-- Title: Nicotine Use Epidemiology and Public Health Risk Assessment

-- Business Purpose:
-- - Quantify multi-dimensional tobacco use patterns across population segments
-- - Enable public health strategic planning by identifying high-risk tobacco consumption profiles
-- - Support targeted prevention and intervention program design
-- - Provide actionable insights for healthcare policy makers and researchers

WITH tobacco_usage_profile AS (
    SELECT 
        seqn,
        CASE 
            WHEN smq620 = 1 THEN 'Ever Tried Smoking'
            ELSE 'Never Smoked'
        END AS smoking_experience,
        COALESCE(smd630, 0) AS age_first_cigarette,
        COALESCE(smq640, 0) AS smoking_days_past_30,
        COALESCE(smq650, 0) AS cigarettes_per_day,
        CASE 
            WHEN smq640 >= 20 THEN 'Heavy Smoker'
            WHEN smq640 BETWEEN 1 AND 19 THEN 'Occasional Smoker'
            ELSE 'Non-Smoker'
        END AS smoking_intensity_category,
        COALESCE(smq670, 0) AS quit_attempt_past_year
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_adult_recent_tobacco_use_youth_cigarettetobacco_use
)

SELECT
    smoking_experience,
    smoking_intensity_category,
    COUNT(*) AS population_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS population_percentage,
    ROUND(AVG(age_first_cigarette), 2) AS mean_age_first_cigarette,
    ROUND(AVG(cigarettes_per_day), 2) AS mean_cigarettes_per_day,
    SUM(quit_attempt_past_year) AS total_quit_attempts
FROM tobacco_usage_profile
GROUP BY 
    smoking_experience, 
    smoking_intensity_category
ORDER BY 
    population_count DESC
LIMIT 10;

-- Query Mechanics:
-- 1. Create CTE to transform raw survey data into analyzable tobacco use profile
-- 2. Categorize smoking experience and intensity
-- 3. Compute population-level tobacco use statistics
-- 4. Provide percentage-based insights for easy interpretation

-- Assumptions/Limitations:
-- - Self-reported survey data may contain recall bias
-- - Represents snapshot of population at specific survey time
-- - Relies on respondent's honest and accurate reporting

-- Potential Extensions:
-- 1. Add demographic segmentation (age, gender, ethnicity)
-- 2. Incorporate time-series analysis
-- 3. Integrate with healthcare utilization data
-- 4. Create predictive risk models for tobacco-related health interventions

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:07:37.800291
    - Additional Notes: Query provides epidemiological overview of tobacco use patterns, categorizing smoking intensity and quit attempts. Designed for public health research and strategic planning with NHANES survey data.
    
    */