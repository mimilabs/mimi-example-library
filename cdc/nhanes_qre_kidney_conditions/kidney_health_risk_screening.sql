-- File: nhanes_kidney_health_screening_indicators.sql
-- Business Purpose: Develop a comprehensive kidney health screening risk profile that identifies participants with multiple potential kidney health risk factors, enabling targeted preventive healthcare interventions and population health management strategies.

WITH kidney_health_risk_profile AS (
    SELECT 
        seqn,
        -- Core kidney condition flags
        MAX(CASE WHEN kiq022 = 1 THEN 1 ELSE 0 END) AS weak_kidney_flag,
        MAX(CASE WHEN kiq025 = 1 THEN 1 ELSE 0 END) AS dialysis_flag,
        MAX(CASE WHEN kiq026 = 1 THEN 1 ELSE 0 END) AS kidney_stone_history_flag,
        MAX(CASE WHEN kiq029 = 1 THEN 1 ELSE 0 END) AS recent_kidney_stone_flag,
        
        -- Urinary symptom complexity indicators
        CASE 
            WHEN MAX(CASE WHEN kiq042 = 1 THEN 1 ELSE 0 END) = 1 
             AND MAX(CASE WHEN kiq044 = 1 THEN 1 ELSE 0 END) = 1 
             AND MAX(CASE WHEN kiq046 = 1 THEN 1 ELSE 0 END) = 1 
            THEN 3  -- High complexity urinary symptoms
            WHEN MAX(CASE WHEN kiq042 = 1 THEN 1 ELSE 0 END) = 1 
             OR MAX(CASE WHEN kiq044 = 1 THEN 1 ELSE 0 END) = 1 
             OR MAX(CASE WHEN kiq046 = 1 THEN 1 ELSE 0 END) = 1 
            THEN 2  -- Moderate complexity urinary symptoms
            ELSE 1  -- Low/No urinary symptoms
        END AS urinary_symptom_complexity,

        -- Nocturnal urination risk
        CASE 
            WHEN MAX(CAST(kiq480 AS INT)) >= 3 THEN 'High Risk'
            WHEN MAX(CAST(kiq480 AS INT)) BETWEEN 2 AND 3 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS nocturnal_urination_risk
    
    FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions
    GROUP BY seqn
)

-- Primary query generating risk stratification profile
SELECT 
    COUNT(*) AS total_participants,
    SUM(weak_kidney_flag) AS weak_kidney_count,
    SUM(dialysis_flag) AS dialysis_count,
    SUM(kidney_stone_history_flag) AS kidney_stone_count,
    
    -- Risk stratification metrics
    ROUND(100.0 * SUM(weak_kidney_flag) / COUNT(*), 2) AS weak_kidney_prevalence,
    ROUND(100.0 * SUM(dialysis_flag) / COUNT(*), 2) AS dialysis_prevalence,
    
    -- Urinary symptom complexity distribution
    ROUND(100.0 * SUM(CASE WHEN urinary_symptom_complexity = 3 THEN 1 ELSE 0 END) / COUNT(*), 2) AS high_complexity_percentage,
    
    -- Nocturnal urination risk distribution
    COUNT(CASE WHEN nocturnal_urination_risk = 'High Risk' THEN 1 END) AS high_nocturnal_risk_count,
    COUNT(CASE WHEN nocturnal_urination_risk = 'Moderate Risk' THEN 1 END) AS moderate_nocturnal_risk_count
    
FROM kidney_health_risk_profile;

-- Query Mechanics:
-- 1. Creates a comprehensive risk profile for each participant
-- 2. Aggregates multiple kidney health indicators
-- 3. Generates population-level kidney health metrics

-- Assumptions & Limitations:
-- - Self-reported survey data may contain reporting biases
-- - No clinical confirmation of conditions
-- - Snapshot of participant health at survey time

-- Potential Extensions:
-- 1. Add demographic segmentation (age, gender)
-- 2. Link with other NHANES clinical datasets
-- 3. Create predictive risk scoring model

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:18:04.955766
    - Additional Notes: Query provides comprehensive kidney health risk assessment using NHANES survey data, focusing on multi-factor risk stratification and population-level health insights.
    
    */