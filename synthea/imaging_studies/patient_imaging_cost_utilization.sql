-- Title: Patient Imaging Cost Impact Analysis
-- Business Purpose: Analyze the frequency and patterns of repeat imaging studies per patient
-- to identify potential cost-saving opportunities and optimize resource utilization.
-- This insight helps healthcare organizations reduce unnecessary duplicate imaging
-- and improve care coordination.

WITH PatientImagingFrequency AS (
    -- Calculate imaging frequency per patient
    SELECT 
        patient,
        COUNT(*) as total_studies,
        COUNT(DISTINCT DATE_TRUNC('month', date)) as distinct_months,
        MIN(date) as first_study_date,
        MAX(date) as last_study_date
    FROM mimi_ws_1.synthea.imaging_studies
    GROUP BY patient
),
RepeatImaging AS (
    -- Identify patients with multiple studies
    SELECT 
        patient,
        total_studies,
        distinct_months,
        DATEDIFF(last_study_date, first_study_date) as days_between_studies,
        CASE 
            WHEN total_studies > 5 THEN 'High Utilization'
            WHEN total_studies > 2 THEN 'Moderate Utilization'
            ELSE 'Normal Utilization'
        END as utilization_category
    FROM PatientImagingFrequency
    WHERE total_studies > 1
)

SELECT 
    utilization_category,
    COUNT(DISTINCT patient) as patient_count,
    AVG(total_studies) as avg_studies_per_patient,
    AVG(distinct_months) as avg_distinct_months,
    AVG(days_between_studies) as avg_days_between_studies,
    SUM(total_studies) as total_imaging_volume
FROM RepeatImaging
GROUP BY utilization_category
ORDER BY patient_count DESC;

-- How this query works:
-- 1. First CTE calculates basic frequency metrics per patient
-- 2. Second CTE identifies and categorizes patients with repeat imaging
-- 3. Final SELECT summarizes key metrics by utilization category

-- Assumptions and Limitations:
-- 1. Assumes all imaging studies are equally weighted (doesn't account for cost differences)
-- 2. Does not consider clinical necessity of repeat imaging
-- 3. Timeframe boundaries may affect utilization categories
-- 4. Synthetic data may not reflect real-world patterns accurately

-- Possible Extensions:
-- 1. Add cost analysis by incorporating modality-specific cost factors
-- 2. Include clinical context by joining with diagnosis or condition tables
-- 3. Add geographical or facility-level analysis
-- 4. Implement seasonal trend analysis
-- 5. Create patient risk stratification based on imaging patterns
-- 6. Compare imaging patterns across different specialties or departments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:37:52.009319
    - Additional Notes: Query provides comprehensive utilization patterns that can be directly tied to cost management initiatives. Note that the utilization categories (High/Moderate/Normal) may need adjustment based on specific organizational benchmarks or guidelines. Consider adjusting the thresholds (currently set at >5 and >2) to match facility-specific standards.
    
    */