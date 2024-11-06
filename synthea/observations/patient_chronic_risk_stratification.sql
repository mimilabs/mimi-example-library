-- patient_chronic_condition_risk_stratification.sql
-- Business Purpose:
-- - Identify potential high-risk patients based on observation patterns
-- - Support early intervention and personalized care management
-- - Enable proactive health risk assessment across patient populations

WITH observation_risk_profile AS (
    -- Analyze key chronic condition indicators across patient observations
    SELECT 
        patient,
        MAX(CASE WHEN code IN ('271649006', '413350009') THEN 1 ELSE 0 END) AS has_hypertension,
        MAX(CASE WHEN code IN ('44054006', '73211009') THEN 1 ELSE 0 END) AS has_diabetes,
        
        -- Calculate metabolic risk indicators
        AVG(CASE 
            WHEN description LIKE '%cholesterol%' AND CAST(value AS DOUBLE) > 200 THEN 1 
            ELSE 0 
        END) AS cholesterol_risk,
        
        AVG(CASE 
            WHEN description LIKE '%blood glucose%' AND CAST(value AS DOUBLE) > 126 THEN 1 
            ELSE 0 
        END) AS glucose_risk,
        
        -- Aggregate observation summary metrics
        COUNT(DISTINCT code) AS unique_observation_types,
        COUNT(*) AS total_observations
    FROM 
        mimi_ws_1.synthea.observations
    GROUP BY 
        patient
)

SELECT 
    -- Develop a composite risk score for patient stratification
    patient,
    (has_hypertension * 2 + has_diabetes * 3 + cholesterol_risk * 1.5 + glucose_risk * 2) AS chronic_risk_score,
    CASE 
        WHEN (has_hypertension * 2 + has_diabetes * 3 + cholesterol_risk * 1.5 + glucose_risk * 2) > 4 THEN 'High Risk'
        WHEN (has_hypertension * 2 + has_diabetes * 3 + cholesterol_risk * 1.5 + glucose_risk * 2) BETWEEN 2 AND 4 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS risk_category,
    unique_observation_types,
    total_observations
FROM 
    observation_risk_profile
WHERE 
    total_observations > 5  -- Ensures sufficient observation data
ORDER BY 
    chronic_risk_score DESC
LIMIT 1000;

-- How the Query Works:
-- 1. Creates a risk profile for each patient based on chronic condition indicators
-- 2. Develops a composite risk score using weighted risk factors
-- 3. Categorizes patients into risk levels for targeted interventions

-- Assumptions and Limitations:
-- - Uses synthetic data with standardized codes
-- - Risk scoring is simplified and should not replace clinical judgment
-- - Lacks comprehensive patient medical history context

-- Possible Extensions:
-- 1. Incorporate age and gender-specific risk adjustments
-- 2. Add more specific chronic condition codes
-- 3. Integrate with patient demographic data for more nuanced risk stratification

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:09:35.200844
    - Additional Notes: Uses synthetic healthcare data to create a composite risk scoring mechanism for patient health risk assessment. Requires careful validation and should not be used as a standalone clinical diagnostic tool.
    
    */