-- allergy_demographics_analysis.sql

-- Business Purpose:
-- Analyze demographic patterns in allergy distribution to:
-- 1. Target preventive care and education programs effectively
-- 2. Optimize allergy specialist coverage across different patient segments
-- 3. Support population health management strategies

WITH current_allergies AS (
    -- Focus on active allergies (where stop is null)
    SELECT 
        patient,
        description,
        YEAR(start) as onset_year,
        CASE 
            WHEN description LIKE '%food%' THEN 'Food Allergy'
            WHEN description LIKE '%drug%' OR description LIKE '%medication%' THEN 'Drug Allergy'
            WHEN description LIKE '%environmental%' OR description LIKE '%pollen%' THEN 'Environmental Allergy'
            ELSE 'Other Allergy'
        END as allergy_category
    FROM mimi_ws_1.synthea.allergies
    WHERE stop IS NULL
)

SELECT 
    allergy_category,
    COUNT(DISTINCT patient) as patient_count,
    COUNT(*) as allergy_count,
    ROUND(COUNT(*) * 100.0 / COUNT(DISTINCT patient), 2) as avg_allergies_per_patient,
    MIN(onset_year) as earliest_onset_year,
    MAX(onset_year) as latest_onset_year
FROM current_allergies
GROUP BY allergy_category
ORDER BY patient_count DESC;

-- How it works:
-- 1. Creates a CTE to identify active allergies and categorize them
-- 2. Categorizes allergies into major groups using pattern matching
-- 3. Aggregates metrics by category to show distribution and trends
-- 4. Calculates key statistics including patient counts and averages

-- Assumptions and limitations:
-- 1. Assumes null stop dates indicate current active allergies
-- 2. Categories are simplified and may not capture all nuances
-- 3. Temporal analysis limited to year granularity
-- 4. Pattern matching for categories may need refinement based on actual data

-- Possible extensions:
-- 1. Add age group analysis to understand lifecycle patterns
-- 2. Include geographic distribution if location data available
-- 3. Analyze correlation with specific medical conditions
-- 4. Add trend analysis to track changes over time periods
-- 5. Include severity indicators if available in the data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:12:30.605353
    - Additional Notes: Query focuses on active allergies categorization and distribution patterns. Categories are defined through simple pattern matching which may need adjustment based on actual data patterns. The temporal analysis is limited to year-level granularity.
    
    */