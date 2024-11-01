-- patient_allergy_summary_metrics.sql
-- Business Purpose: Provide key metrics around patient allergy patterns to inform:
--   1. Resource allocation for allergy specialists
--   2. Medication inventory planning
--   3. Risk assessment for patient populations
--   4. Clinical protocol development

-- Main Query
WITH current_allergies AS (
    -- Focus on active allergies (where stop is null or in future)
    SELECT 
        patient,
        description,
        start,
        stop
    FROM mimi_ws_1.synthea.allergies
    WHERE stop IS NULL OR stop > CURRENT_DATE()
),

patient_allergy_counts AS (
    -- Calculate per-patient allergy metrics
    SELECT 
        patient,
        COUNT(*) as num_allergies,
        MIN(start) as earliest_allergy_date,
        MAX(start) as latest_allergy_date
    FROM current_allergies
    GROUP BY patient
)

SELECT 
    -- Core summary metrics
    COUNT(DISTINCT patient) as total_patients_with_allergies,
    AVG(num_allergies) as avg_allergies_per_patient,
    PERCENTILE(num_allergies, 0.5) as median_allergies_per_patient,
    MAX(num_allergies) as max_allergies_per_patient,
    
    -- Time-based metrics
    AVG(DATEDIFF(latest_allergy_date, earliest_allergy_date)) as avg_days_between_first_last_allergy,
    
    -- Risk segments
    COUNT(CASE WHEN num_allergies >= 3 THEN 1 END) as patients_with_multiple_allergies,
    ROUND(COUNT(CASE WHEN num_allergies >= 3 THEN 1 END) * 100.0 / COUNT(*), 1) as multiple_allergy_patient_pct
FROM patient_allergy_counts;

-- How this query works:
-- 1. Filters for current/active allergies
-- 2. Calculates per-patient metrics
-- 3. Aggregates into summary statistics focused on business-relevant metrics

-- Assumptions and Limitations:
-- - Treats null stop dates as currently active allergies
-- - Focuses on current state rather than historical trends
-- - Does not segment by allergy type or severity
-- - Assumes one patient can have multiple allergies

-- Possible Extensions:
-- 1. Add seasonality analysis to support staffing plans
-- 2. Segment metrics by age groups or demographics
-- 3. Add trending over time to identify growing allergy types
-- 4. Compare metrics across different facilities or regions
-- 5. Add severity analysis for risk stratification

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:24:20.199764
    - Additional Notes: Query provides high-level metrics around patient allergy patterns including average allergies per patient and risk segmentation. Best suited for operational planning and resource allocation. Does not include temporal trends or severity analysis.
    
    */