-- observation_patient_compliance_tracking.sql

-- Business Purpose:
-- - Track patient compliance with recommended observation schedules
-- - Identify patients who may be overdue for important health screenings
-- - Support care coordination and patient engagement initiatives
-- - Calculate patient retention and follow-up completion rates

WITH patient_last_observation AS (
    -- Get each patient's most recent observation date
    SELECT 
        patient,
        MAX(date) as last_observation_date,
        MIN(date) as first_observation_date,
        COUNT(DISTINCT encounter) as total_encounters
    FROM mimi_ws_1.synthea.observations
    GROUP BY patient
),

observation_gaps AS (
    -- Calculate time gaps between observations for each patient
    SELECT 
        p.patient,
        p.last_observation_date,
        p.first_observation_date,
        p.total_encounters,
        DATEDIFF(CURRENT_DATE(), p.last_observation_date) as days_since_last_observation,
        p.total_encounters / 
            (DATEDIFF(p.last_observation_date, p.first_observation_date) / 365.0) as yearly_visit_rate
    FROM patient_last_observation p
)

-- Final analysis of patient compliance patterns
SELECT 
    CASE 
        WHEN days_since_last_observation <= 90 THEN 'Active (0-3 months)'
        WHEN days_since_last_observation <= 180 THEN 'Monitor (3-6 months)'
        WHEN days_since_last_observation <= 365 THEN 'Follow-up needed (6-12 months)'
        ELSE 'Inactive (>12 months)'
    END as patient_status,
    COUNT(DISTINCT patient) as patient_count,
    ROUND(AVG(yearly_visit_rate), 2) as avg_yearly_visits,
    ROUND(AVG(total_encounters), 1) as avg_total_encounters,
    ROUND(AVG(days_since_last_observation), 0) as avg_days_since_last_visit
FROM observation_gaps
GROUP BY 1
ORDER BY avg_days_since_last_visit;

-- How it works:
-- 1. First CTE gets the most recent observation date for each patient
-- 2. Second CTE calculates key metrics about observation patterns
-- 3. Final query segments patients into compliance categories and calculates summary statistics

-- Assumptions and limitations:
-- - Assumes regular observation schedule is desired for all patients
-- - Does not account for different observation requirements by condition or age
-- - Does not consider the type or importance of different observations
-- - Limited to observed timeframe in the dataset

-- Possible extensions:
-- 1. Add patient demographics to identify compliance patterns by age/gender
-- 2. Include specific observation types to track compliance with particular screenings
-- 3. Calculate compliance rates by provider or facility
-- 4. Add risk stratification based on observation gaps
-- 5. Create patient-specific compliance alerts based on condition-specific guidelines

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:15:56.160548
    - Additional Notes: This query provides insights into patient follow-up patterns and care continuity through observation tracking. It assumes all patients should have regular observations and may need adjustment for specialties or conditions with different follow-up schedules. The yearly visit rate calculation may be skewed for patients with very short observation periods.
    
    */