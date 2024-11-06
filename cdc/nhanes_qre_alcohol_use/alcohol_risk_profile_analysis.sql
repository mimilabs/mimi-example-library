-- nhanes_alcohol_high_risk_drinking_profile.sql
-- Business Purpose: Identify high-risk drinking population segments to inform public health interventions and resource allocation strategies
-- Assess prevalence, frequency, and intensity of potentially hazardous alcohol consumption patterns

WITH alcohol_risk_profile AS (
    SELECT 
        seqn,
        -- Categorize drinking frequency and intensity
        CASE 
            WHEN alq120q >= 52 THEN 'Very Frequent Drinker'
            WHEN alq120q BETWEEN 12 AND 51 THEN 'Moderate Drinker'
            WHEN alq120q BETWEEN 1 AND 11 THEN 'Occasional Drinker'
            ELSE 'Non-Drinker'
        END AS drinking_frequency,
        
        CASE 
            WHEN alq130 >= 5 THEN 'High Volume Consumption'
            WHEN alq130 BETWEEN 3 AND 4 THEN 'Moderate Volume Consumption'
            WHEN alq130 BETWEEN 1 AND 2 THEN 'Low Volume Consumption'
            ELSE 'Minimal Consumption'
        END AS drinking_volume,
        
        -- Binge drinking indicator
        CASE 
            WHEN alq141q >= 52 THEN 'Frequent Binge Drinker'
            WHEN alq141q BETWEEN 12 AND 51 THEN 'Occasional Binge Drinker'
            WHEN alq141q > 0 THEN 'Rare Binge Drinker'
            ELSE 'No Binge Drinking'
        END AS binge_drinking_pattern,
        
        alq130 AS avg_daily_drinks,
        alq141q AS days_binge_drinking_per_year
    
    FROM mimi_ws_1.cdc.nhanes_qre_alcohol_use
)

SELECT 
    drinking_frequency,
    drinking_volume,
    binge_drinking_pattern,
    COUNT(*) AS population_segment_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_total
FROM alcohol_risk_profile
GROUP BY 
    drinking_frequency, 
    drinking_volume, 
    binge_drinking_pattern
ORDER BY 
    population_segment_count DESC
LIMIT 15;

-- Query Mechanics:
-- 1. Creates risk profile categories based on drinking frequency, volume, and binge patterns
-- 2. Aggregates population segments to understand distribution of drinking behaviors
-- 3. Calculates relative proportions of each drinking risk profile

-- Assumptions and Limitations:
-- - Self-reported survey data may underreport actual consumption
-- - Categorical thresholds are approximations based on standard public health definitions
-- - Does not account for individual health variations or long-term consequences

-- Potential Extensions:
-- 1. Incorporate demographic crosswalks (age, gender, socioeconomic status)
-- 2. Link with health outcome tables to assess correlation between drinking patterns and health risks
-- 3. Time-series analysis across multiple NHANES survey cycles to track trend changes

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:07:30.748537
    - Additional Notes: Query segments alcohol consumption patterns into risk categories, useful for public health intervention planning. Relies on self-reported survey data, so results should be interpreted with caution regarding potential underreporting.
    
    */