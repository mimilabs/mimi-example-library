-- allergy_duration_impact_analysis.sql
-- Business Purpose: 
-- This analysis helps healthcare organizations understand the duration and persistence of allergies
-- to better allocate resources, plan interventions, and improve patient care management.
-- Key business values:
-- 1. Resource planning based on long-term vs short-term allergy patterns
-- 2. Identification of chronic allergy management needs
-- 3. Support for population health management strategies

WITH active_allergies AS (
    -- Filter to get currently active allergies (no stop date or stop date in future)
    SELECT 
        patient,
        code,
        description,
        start,
        stop,
        DATEDIFF(COALESCE(stop, CURRENT_DATE()), start) as duration_days
    FROM mimi_ws_1.synthea.allergies
    WHERE stop IS NULL OR stop > CURRENT_DATE()
),

duration_categories AS (
    -- Categorize allergies by duration
    SELECT 
        description,
        COUNT(*) as patient_count,
        AVG(duration_days) as avg_duration_days,
        COUNT(CASE WHEN duration_days > 365 THEN 1 END) as chronic_cases,
        COUNT(CASE WHEN duration_days <= 365 THEN 1 END) as acute_cases
    FROM active_allergies
    GROUP BY description
)

SELECT 
    description,
    patient_count,
    ROUND(avg_duration_days, 0) as avg_duration_days,
    chronic_cases,
    acute_cases,
    ROUND((chronic_cases * 100.0 / patient_count), 1) as chronic_percentage
FROM duration_categories
WHERE patient_count >= 10  -- Focus on statistically significant allergies
ORDER BY patient_count DESC
LIMIT 20;

-- How it works:
-- 1. First CTE identifies currently active allergies and calculates their duration
-- 2. Second CTE categorizes allergies into chronic (>1 year) and acute cases
-- 3. Final query presents the results with key metrics for business decision-making

-- Assumptions and Limitations:
-- 1. Current date is used as end date for ongoing allergies
-- 2. Minimum threshold of 10 patients per allergy for statistical relevance
-- 3. One year (365 days) used as threshold for chronic vs acute classification
-- 4. Synthetic data may not perfectly reflect real-world allergy patterns

-- Possible Extensions:
-- 1. Add seasonal analysis to identify timing patterns
-- 2. Include demographic breakdowns for targeted interventions
-- 3. Calculate cost implications based on duration patterns
-- 4. Add risk stratification based on allergy persistence
-- 5. Incorporate encounter frequency analysis for resource planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:18:36.758693
    - Additional Notes: Query focuses on active allergies and their chronicity patterns. Minimum threshold of 10 patients per allergy type may exclude rare but significant allergies. Duration calculations are based on current date for ongoing conditions, which should be considered when interpreting results.
    
    */