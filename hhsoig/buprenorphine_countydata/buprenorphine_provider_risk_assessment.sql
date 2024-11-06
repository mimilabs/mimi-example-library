
-- Buprenorphine Provider Capacity Risk Assessment
-- Business Purpose: 
-- Identify high-risk counties with low buprenorphine treatment capacity 
-- and high opioid misuse indicators to prioritize healthcare intervention strategies

WITH county_risk_profile AS (
    -- Categorize counties based on treatment capacity and need
    SELECT 
        state,
        county,
        total_number_of_waivered_providers,
        patient_capacity,
        patient_capacity_rate,
        high_need_for_treatment_services,
        lowtono_patient_capacity,
        
        -- Calculate a composite risk score
        CASE 
            WHEN high_need_for_treatment_services = 1 AND lowtono_patient_capacity = 0 
            THEN 'Critical Risk'
            WHEN high_need_for_treatment_services = 1 AND lowtono_patient_capacity < 20 
            THEN 'High Risk'
            WHEN high_need_for_treatment_services = 1 AND lowtono_patient_capacity BETWEEN 20 AND 40 
            THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS treatment_access_risk_category
    
    FROM mimi_ws_1.hhsoig.buprenorphine_countydata
)

SELECT 
    treatment_access_risk_category,
    COUNT(DISTINCT county) AS affected_counties,
    ROUND(AVG(patient_capacity), 2) AS avg_patient_capacity,
    ROUND(AVG(patient_capacity_rate), 2) AS avg_patient_capacity_rate
FROM county_risk_profile
WHERE treatment_access_risk_category != 'Low Risk'
GROUP BY treatment_access_risk_category
ORDER BY 
    CASE treatment_access_risk_category
        WHEN 'Critical Risk' THEN 1
        WHEN 'High Risk' THEN 2
        WHEN 'Moderate Risk' THEN 3
    END

-- Query Mechanics:
-- 1. Creates a risk profile by combining provider capacity and treatment need
-- 2. Categorizes counties into risk levels based on treatment capacity and opioid misuse indicators
-- 3. Aggregates county-level insights to identify systemic access challenges

-- Key Assumptions:
-- - Uses April 2018 dataset snapshot
-- - Relies on three public health indicators for defining high-need areas
-- - Patient capacity is a proxy for treatment accessibility

-- Potential Extensions:
-- 1. Join with demographic data to understand population-level impacts
-- 2. Compare risk categories across different states
-- 3. Track changes in risk profile over time with updated datasets


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:32:59.717594
    - Additional Notes: Uses 2018 dataset to categorize counties by buprenorphine treatment capacity and opioid misuse risk. Provides a high-level view of treatment access challenges, but may not reflect current conditions.
    
    */