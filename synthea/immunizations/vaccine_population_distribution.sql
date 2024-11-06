-- Title: Immunization Patient Population Demographics and Distribution

-- Business Purpose:
-- This query provides strategic insights into patient immunization patterns
-- by analyzing the distribution of immunizations across different population segments.
-- Key objectives:
-- 1. Understand vaccine diversity within patient population
-- 2. Identify potential gaps in immunization coverage
-- 3. Support healthcare resource allocation and targeted vaccination strategies

WITH immunization_summary AS (
    -- Aggregate immunization data with patient demographics insights
    SELECT 
        description AS vaccine_type,
        COUNT(DISTINCT patient) AS unique_patients,
        COUNT(*) AS total_administrations,
        ROUND(AVG(base_cost), 2) AS average_vaccine_cost,
        MIN(date) AS earliest_administration,
        MAX(date) AS latest_administration
    FROM mimi_ws_1.synthea.immunizations
    WHERE description IS NOT NULL
    GROUP BY description
),

vaccine_popularity_rank AS (
    -- Rank vaccines by patient coverage and administration frequency
    SELECT 
        vaccine_type,
        unique_patients,
        total_administrations,
        average_vaccine_cost,
        RANK() OVER (ORDER BY unique_patients DESC) AS patient_coverage_rank,
        RANK() OVER (ORDER BY total_administrations DESC) AS administration_frequency_rank
    FROM immunization_summary
)

SELECT 
    vaccine_type,
    unique_patients,
    total_administrations,
    average_vaccine_cost,
    patient_coverage_rank,
    administration_frequency_rank
FROM vaccine_popularity_rank
ORDER BY unique_patients DESC, total_administrations DESC
LIMIT 20;

-- Query Mechanics:
-- 1. First CTE (immunization_summary) aggregates immunization data
-- 2. Second CTE (vaccine_popularity_rank) ranks vaccines by coverage
-- 3. Final SELECT presents ranked vaccine insights

-- Assumptions & Limitations:
-- - Uses synthetic data, not representative of real-world populations
-- - Limited to top 20 vaccine types
-- - Does not include patient demographic details beyond vaccination

-- Potential Extensions:
-- 1. Add patient age group segmentation
-- 2. Incorporate temporal trend analysis
-- 3. Compare vaccine costs across different patient segments
-- 4. Analyze seasonal vaccination patterns

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:41:09.564985
    - Additional Notes: Analyzes synthetic immunization dataset using ranking techniques to highlight vaccine coverage and frequency. Uses aggregate functions and window ranking to provide strategic population health insights.
    
    */