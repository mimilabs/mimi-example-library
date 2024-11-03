-- hypertension_mortality_trends.sql
-- Business Purpose: Analyze the relationship between hypertension and mortality outcomes
-- to understand hypertension's impact on survival time and inform cardiovascular health strategies.
-- The analysis helps healthcare organizations prioritize hypertension management programs
-- and allocate resources for preventive care.

WITH eligible_participants AS (
    -- Filter for eligible participants with valid mortality status
    SELECT *
    FROM mimi_ws_1.cdc.nhanes_mortality
    WHERE eligstat = 1 
    AND mortstat IS NOT NULL
),

survival_analysis AS (
    -- Calculate survival metrics for hypertensive vs non-hypertensive participants
    SELECT 
        hyperten,
        COUNT(*) as total_participants,
        COUNT(CASE WHEN mortstat = 1 THEN 1 END) as deceased_count,
        AVG(CASE WHEN mortstat = 1 THEN permth_int ELSE NULL END) as avg_months_to_death,
        -- Calculate mortality rate per 1000 participants
        (COUNT(CASE WHEN mortstat = 1 THEN 1 END) * 1000.0 / COUNT(*)) as mortality_rate_per_1000
    FROM eligible_participants
    GROUP BY hyperten
)

SELECT 
    CASE 
        WHEN hyperten = 1 THEN 'Hypertensive'
        WHEN hyperten = 0 THEN 'Non-hypertensive'
        ELSE 'Unknown'
    END as patient_group,
    total_participants,
    deceased_count,
    ROUND(avg_months_to_death, 2) as avg_survival_months,
    ROUND(mortality_rate_per_1000, 2) as mortality_rate_per_1000
FROM survival_analysis
WHERE hyperten IN (0, 1)
ORDER BY hyperten;

-- How it works:
-- 1. Filters for eligible participants from the NHANES mortality dataset
-- 2. Groups participants by hypertension status
-- 3. Calculates key metrics including total participants, deceased count, average survival time,
--    and mortality rate per 1000 participants
-- 4. Presents results in a clear, business-friendly format

-- Assumptions and Limitations:
-- - Assumes hypertension status is accurately recorded in death records
-- - Does not account for potential confounding factors (age, gender, other conditions)
-- - Limited to available follow-up period in the dataset
-- - Does not consider severity or duration of hypertension

-- Possible Extensions:
-- 1. Add age stratification to understand impact across age groups
-- 2. Include analysis of common comorbidities with hypertension
-- 3. Compare survival curves using time-based analysis
-- 4. Add geographic analysis if location data becomes available
-- 5. Include trend analysis across different NHANES survey periods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:49:27.350762
    - Additional Notes: Query focuses on key mortality metrics comparing hypertensive vs non-hypertensive participants. Most useful for healthcare organizations analyzing cardiovascular risk factors and planning intervention programs. Results can be directly used for mortality rate comparisons and resource allocation decisions.
    
    */