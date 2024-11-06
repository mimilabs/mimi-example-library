-- file: allergy_clinical_complexity_analysis.sql
-- Business Purpose: 
-- Assess the clinical complexity of allergies by analyzing multi-allergy patients
-- Provides insights for:
--   1. Complex patient care management strategies
--   2. Potential risk stratification approaches
--   3. Targeted medical intervention planning

WITH patient_allergy_counts AS (
    -- Count allergies per patient to identify clinically complex cases
    SELECT 
        patient, 
        COUNT(DISTINCT code) as unique_allergy_count,
        COUNT(*) as total_allergy_records,
        MIN(start) as first_allergy_recorded,
        MAX(stop) as most_recent_allergy_resolution
    FROM mimi_ws_1.synthea.allergies
    WHERE stop IS NOT NULL  -- Focus on patients with resolved allergies
    GROUP BY patient
),
complexity_segments AS (
    -- Categorize patients by allergy complexity
    SELECT 
        patient,
        unique_allergy_count,
        total_allergy_records,
        CASE 
            WHEN unique_allergy_count = 1 THEN 'Low Complexity'
            WHEN unique_allergy_count BETWEEN 2 AND 3 THEN 'Moderate Complexity'
            WHEN unique_allergy_count > 3 THEN 'High Complexity'
        END as complexity_category,
        DATEDIFF(day, first_allergy_recorded, most_recent_allergy_resolution) as total_allergy_management_period
    FROM patient_allergy_counts
)

-- Primary analysis query
SELECT 
    complexity_category,
    COUNT(DISTINCT patient) as patient_count,
    ROUND(AVG(unique_allergy_count), 2) as avg_unique_allergies,
    ROUND(AVG(total_allergy_records), 2) as avg_total_allergy_records,
    ROUND(AVG(total_allergy_management_period), 2) as avg_management_days
FROM complexity_segments
GROUP BY complexity_category
ORDER BY patient_count DESC;

-- Query Mechanics:
-- 1. Identifies patients with multiple allergies
-- 2. Segments patients by allergy complexity
-- 3. Provides aggregated insights on patient groups

-- Assumptions:
-- - Assumes resolved allergies (stop date is not null)
-- - Complexity defined by unique allergy count
-- - Synthetic data may not reflect real-world distributions

-- Potential Extensions:
-- 1. Link with patient demographics for deeper insights
-- 2. Incorporate ICD/SNOMED codes for precise allergy classification
-- 3. Add temporal trend analysis of allergy complexity over time

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:06:43.607955
    - Additional Notes: Synthetic healthcare data analysis focusing on patient allergy complexity segmentation, suitable for exploring multi-dimensional patient risk profiles
    
    */