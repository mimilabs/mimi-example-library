-- Provider Specialty Concentration Analysis for Medicare Group Practices
--
-- Business Purpose:
-- Analyzes the distribution and concentration of provider specialties within group practices
-- to identify:
-- - Specialty-focused vs multi-specialty practices
-- - Market opportunities for specialty coverage
-- - Potential gaps in specialty care access
-- Key stakeholders: Network managers, Provider relations, Market expansion teams

WITH specialty_groups AS (
    -- Calculate specialty concentrations per group practice
    SELECT 
        group_legal_business_name,
        group_state_code,
        individual_specialty_description,
        COUNT(DISTINCT individual_pac_id) as specialty_provider_count,
        COUNT(DISTINCT individual_pac_id) * 100.0 / 
            SUM(COUNT(DISTINCT individual_pac_id)) OVER (PARTITION BY group_legal_business_name) 
            as specialty_percentage
    FROM mimi_ws_1.datacmsgov.revalidation
    WHERE group_legal_business_name IS NOT NULL
    AND record_type = 'Reassignment' 
    GROUP BY 1,2,3
),

practice_classifications AS (
    -- Classify practices based on specialty concentration
    SELECT 
        group_legal_business_name,
        group_state_code,
        COUNT(DISTINCT individual_specialty_description) as distinct_specialties,
        MAX(specialty_percentage) as highest_specialty_concentration,
        CASE 
            WHEN MAX(specialty_percentage) >= 75 THEN 'Single Specialty Focused'
            WHEN COUNT(DISTINCT individual_specialty_description) >= 5 THEN 'Large Multi-Specialty'
            ELSE 'Small Multi-Specialty'
        END as practice_type
    FROM specialty_groups
    GROUP BY 1,2
)

SELECT 
    p.practice_type,
    p.group_state_code,
    COUNT(DISTINCT p.group_legal_business_name) as practice_count,
    ROUND(AVG(p.distinct_specialties),1) as avg_specialties_per_practice,
    ROUND(AVG(p.highest_specialty_concentration),1) as avg_top_specialty_concentration
FROM practice_classifications p
GROUP BY 1,2
ORDER BY 1,2;

-- How it works:
-- 1. First CTE calculates the provider count and percentage for each specialty within practices
-- 2. Second CTE classifies practices based on specialty mix and concentration
-- 3. Final query aggregates results by practice type and state for strategic analysis

-- Assumptions & Limitations:
-- - Assumes current reassignments reflect actual practice patterns
-- - Limited to Medicare-enrolled providers only
-- - Does not account for practice size variations
-- - Classification thresholds (75% for single specialty, 5+ for large multi) are configurable

-- Possible Extensions:
-- 1. Add temporal analysis to track practice evolution over time
-- 2. Include provider counts in size classifications
-- 3. Add geographic market analysis at county/MSA level
-- 4. Compare specialty mix to local population needs
-- 5. Analyze correlation with revalidation patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:17:16.751768
    - Additional Notes: Query provides practice-level specialty mix analysis using 75% threshold for single-specialty classification and 5+ specialties for large multi-specialty designation. These thresholds may need adjustment based on specific market conditions or business requirements. Results are most meaningful when analyzed alongside local market demographics and access needs.
    
    */