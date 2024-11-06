-- Title: Imaging Study Patient Segmentation and Risk Characterization

-- Business Purpose:
-- Stratify patients based on their imaging study complexity and frequency
-- Identify patient segments with higher medical intervention potential
-- Support targeted care management and predictive health risk assessment strategies

WITH patient_imaging_profile AS (
    -- Aggregate patient-level imaging complexity metrics
    SELECT 
        patient,
        COUNT(DISTINCT id) as total_imaging_studies,
        COUNT(DISTINCT modality_code) as unique_modality_count,
        COUNT(DISTINCT bodysite_code) as unique_bodysite_count,
        MAX(date) as most_recent_imaging_date,
        
        -- Risk segmentation scoring logic
        CASE 
            WHEN COUNT(DISTINCT modality_code) >= 3 THEN 'High Complexity'
            WHEN COUNT(DISTINCT modality_code) = 2 THEN 'Moderate Complexity'
            ELSE 'Low Complexity'
        END as imaging_complexity_tier
    FROM mimi_ws_1.synthea.imaging_studies
    GROUP BY patient
),
risk_segment_summary AS (
    -- Calculate segment-level statistics for strategic insights
    SELECT 
        imaging_complexity_tier,
        COUNT(DISTINCT patient) as patient_count,
        ROUND(AVG(total_imaging_studies), 2) as avg_studies_per_patient,
        ROUND(AVG(unique_modality_count), 2) as avg_modalities_per_patient,
        ROUND(AVG(unique_bodysite_count), 2) as avg_bodysites_per_patient
    FROM patient_imaging_profile
    GROUP BY imaging_complexity_tier
)

-- Primary query to retrieve comprehensive patient imaging risk segments
SELECT * 
FROM risk_segment_summary
ORDER BY patient_count DESC;

-- Query Mechanics:
-- 1. Creates patient-level imaging complexity profile
-- 2. Segments patients into risk tiers based on imaging study diversity
-- 3. Aggregates segment-level statistics for strategic analysis

-- Assumptions and Limitations:
-- - Uses synthetic data with simulated patient imaging records
-- - Complexity scoring is a simplified heuristic approach
-- - No direct correlation with clinical outcomes

-- Potential Extensions:
-- 1. Incorporate patient age and gender into risk stratification
-- 2. Add temporal trend analysis of imaging complexity
-- 3. Link with encounter or diagnosis tables for deeper insights

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:12:37.169522
    - Additional Notes: Uses synthetic healthcare data to stratify patients based on imaging study complexity. Provides a foundational approach for identifying potential high-risk patient groups through imaging study diversity analysis.
    
    */