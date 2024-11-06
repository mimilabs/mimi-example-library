-- care_plan_readmission_risk.sql
-- Business Purpose: 
-- Analyze the relationship between multiple care plans and patient readmissions
-- to identify high-risk patients who may need additional support
-- This helps care managers prioritize interventions and reduce readmission rates

WITH patient_care_plan_history AS (
    -- Get care plan history per patient with time between plans
    SELECT 
        patient,
        COUNT(*) as total_care_plans,
        COUNT(DISTINCT description) as unique_care_plan_types,
        DATEDIFF(MAX(start), MIN(start)) as care_plan_span_days,
        SUM(CASE WHEN stop IS NOT NULL THEN 1 ELSE 0 END) as completed_plans
    FROM mimi_ws_1.synthea.careplans
    GROUP BY patient
),

repeated_encounters AS (
    -- Identify patients with multiple encounters close together
    SELECT 
        patient,
        COUNT(DISTINCT encounter) as encounter_count,
        COUNT(DISTINCT encounter) / 
            (DATEDIFF(MAX(start), MIN(start))/30.0) as encounters_per_month
    FROM mimi_ws_1.synthea.careplans
    GROUP BY patient
    HAVING COUNT(DISTINCT encounter) > 1
)

SELECT 
    h.patient,
    h.total_care_plans,
    h.unique_care_plan_types,
    h.care_plan_span_days,
    h.completed_plans,
    e.encounter_count,
    ROUND(e.encounters_per_month, 2) as encounters_per_month,
    CASE 
        WHEN e.encounters_per_month > 2 
        AND h.total_care_plans > 3 THEN 'High Risk'
        WHEN e.encounters_per_month > 1 
        OR h.total_care_plans > 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as readmission_risk_level
FROM patient_care_plan_history h
JOIN repeated_encounters e ON h.patient = e.patient
WHERE h.care_plan_span_days > 0
ORDER BY e.encounters_per_month DESC, h.total_care_plans DESC
LIMIT 1000;

-- How this works:
-- 1. First CTE aggregates care plan history metrics per patient
-- 2. Second CTE calculates encounter frequency metrics
-- 3. Main query joins these together and applies risk stratification logic
-- 4. Results show patients ranked by encounter frequency and care plan count

-- Assumptions and Limitations:
-- - Assumes multiple encounters/care plans indicate higher readmission risk
-- - Risk levels are simplified for demonstration purposes
-- - Limited to patients with at least 2 encounters
-- - Doesn't account for specific conditions or demographics

-- Possible Extensions:
-- 1. Add condition/diagnosis data to refine risk assessment
-- 2. Incorporate patient demographics and social determinants
-- 3. Create time-based windows for more precise readmission analysis
-- 4. Add actual readmission outcomes for model validation
-- 5. Calculate risk scores using more sophisticated algorithms

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:01:25.875568
    - Additional Notes: Query focuses on identifying high-risk patients based on care plan patterns and encounter frequency. Risk stratification is simplified using basic thresholds. For production use, thresholds should be calibrated based on actual readmission data and clinical guidelines.
    
    */