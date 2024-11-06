-- care_plan_patient_complexity_analysis.sql
-- Business Purpose: Analyze patient care plan complexity and care coordination
-- to understand healthcare resource utilization and patient management strategies

WITH care_plan_complexity AS (
    SELECT 
        patient,
        COUNT(DISTINCT id) AS total_care_plans,
        COUNT(DISTINCT code) AS unique_care_plan_types,
        
        -- Calculate care plan complexity score
        CASE 
            WHEN COUNT(DISTINCT id) <= 1 THEN 'Low Complexity'
            WHEN COUNT(DISTINCT id) BETWEEN 2 AND 3 THEN 'Medium Complexity'
            ELSE 'High Complexity'
        END AS patient_complexity_level,
        
        -- Calculate total care plan duration
        ROUND(AVG(DATEDIFF(stop, start)), 2) AS avg_care_plan_duration_days,
        
        -- Identify most frequent care plan reasons
        MODE(reasondescription) AS most_common_care_plan_reason
    FROM 
        mimi_ws_1.synthea.careplans
    WHERE 
        stop IS NOT NULL  -- Ensure completed care plans
    GROUP BY 
        patient
)

SELECT 
    patient_complexity_level,
    COUNT(*) AS patient_count,
    ROUND(AVG(total_care_plans), 2) AS avg_care_plans_per_complexity,
    ROUND(AVG(unique_care_plan_types), 2) AS avg_unique_care_plan_types,
    ROUND(AVG(avg_care_plan_duration_days), 2) AS avg_duration_days,
    most_common_care_plan_reason
FROM 
    care_plan_complexity
GROUP BY 
    patient_complexity_level,
    most_common_care_plan_reason
ORDER BY 
    patient_count DESC
LIMIT 10;

-- Query Mechanics:
-- 1. Creates a CTE to calculate patient-level care plan complexity
-- 2. Aggregates complexity metrics by patient complexity level
-- 3. Provides insights into patient care management strategies

-- Assumptions and Limitations:
-- - Assumes completed care plans represent meaningful patient interactions
-- - Uses synthetic data with potential limitations in real-world representation
-- - Complexity scoring is a simplified heuristic approach

-- Potential Extensions:
-- 1. Add age/demographic segmentation
-- 2. Incorporate readmission or health outcome data
-- 3. Analyze care plan complexity by specialty or condition type

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:45:56.622979
    - Additional Notes: Query provides a multi-dimensional view of patient care complexity, using synthetic healthcare data to demonstrate patient management strategies and resource utilization patterns
    
    */