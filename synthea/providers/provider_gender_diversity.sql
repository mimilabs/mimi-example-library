-- provider_gender_specialty_diversity.sql

-- Business Purpose:
-- - Assess gender diversity across medical specialties to support DEI initiatives
-- - Identify potential gender representation gaps in key specialties
-- - Enable data-driven recruitment strategies for balanced healthcare teams
-- - Support workforce development and mentorship program planning

WITH specialty_gender_metrics AS (
    -- Calculate provider counts and percentages by specialty and gender
    SELECT 
        speciality,
        gender,
        COUNT(*) as provider_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY speciality), 1) as gender_pct
    FROM mimi_ws_1.synthea.providers
    WHERE gender IS NOT NULL 
    AND speciality IS NOT NULL
    GROUP BY speciality, gender
),

specialty_stats AS (
    -- Get total providers and gender gap metrics by specialty
    SELECT 
        speciality,
        SUM(provider_count) as total_providers,
        MAX(CASE WHEN gender = 'F' THEN gender_pct ELSE 0 END) as female_pct,
        MAX(CASE WHEN gender = 'M' THEN gender_pct ELSE 0 END) as male_pct,
        ABS(MAX(CASE WHEN gender = 'F' THEN gender_pct ELSE 0 END) - 
            MAX(CASE WHEN gender = 'M' THEN gender_pct ELSE 0 END)) as gender_gap
    FROM specialty_gender_metrics
    GROUP BY speciality
)

-- Final output showing specialties with significant gender gaps
SELECT 
    speciality,
    total_providers,
    female_pct as female_percentage,
    male_pct as male_percentage,
    gender_gap as gender_gap_percentage,
    CASE 
        WHEN gender_gap >= 50 THEN 'High Disparity'
        WHEN gender_gap >= 25 THEN 'Moderate Disparity'
        ELSE 'Balanced'
    END as disparity_level
FROM specialty_stats
WHERE total_providers >= 10  -- Focus on specialties with meaningful sample sizes
ORDER BY gender_gap DESC;

-- How it works:
-- 1. First CTE calculates provider counts and percentages by specialty and gender
-- 2. Second CTE aggregates the metrics by specialty and calculates gender gaps
-- 3. Final query adds disparity categorization and filters for meaningful samples

-- Assumptions and Limitations:
-- - Assumes gender is binary (M/F) in the dataset
-- - Requires at least 10 providers per specialty for meaningful analysis
-- - Does not account for temporal changes in gender distribution
-- - Limited to specialties present in the synthetic dataset

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional diversity patterns
-- 2. Include organization-level diversity metrics
-- 3. Incorporate temporal trends to track diversity progress over time
-- 4. Add benchmarking against national or industry standards
-- 5. Include analysis of leadership positions within specialties

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:29:54.839831
    - Additional Notes: Query focuses on gender representation gaps across medical specialties with a minimum threshold of 10 providers per specialty. Results are categorized into disparity levels (High/Moderate/Balanced) based on percentage differences between genders. Best used for DEI planning and recruitment strategy development.
    
    */