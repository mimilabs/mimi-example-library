-- Specialty Group Practice Analysis for Medicare Network Planning
-- This query analyzes specialty distribution and geographic footprint of group practices
-- to support network adequacy planning and provider recruitment strategies.
-- Key metrics: practices by specialty concentration, multi-specialty vs single specialty,
-- and interstate presence.

WITH group_specialty_counts AS (
    -- Calculate specialty mix within each group practice
    SELECT 
        group_pac_id,
        group_legal_business_name,
        group_state_code,
        COUNT(DISTINCT individual_specialty_description) as specialty_count,
        COUNT(DISTINCT individual_pac_id) as provider_count,
        COUNT(DISTINCT individual_state_code) as state_coverage
    FROM mimi_ws_1.datacmsgov.revalidation
    WHERE record_type = 'Reassignment'
    GROUP BY 1,2,3
),

practice_classifications AS (
    -- Classify practices by size and specialty mix
    SELECT 
        *,
        CASE 
            WHEN specialty_count = 1 THEN 'Single Specialty'
            WHEN specialty_count BETWEEN 2 AND 4 THEN 'Limited Multi-Specialty'
            ELSE 'Comprehensive Multi-Specialty'
        END as practice_type,
        CASE
            WHEN provider_count < 5 THEN 'Small'
            WHEN provider_count BETWEEN 5 AND 20 THEN 'Medium'
            ELSE 'Large'
        END as practice_size
    FROM group_specialty_counts
)

SELECT 
    practice_type,
    practice_size,
    COUNT(DISTINCT group_pac_id) as practice_count,
    ROUND(AVG(provider_count), 2) as avg_providers_per_practice,
    ROUND(AVG(specialty_count), 2) as avg_specialties_per_practice,
    ROUND(AVG(state_coverage), 2) as avg_state_coverage,
    COUNT(CASE WHEN state_coverage > 1 THEN group_pac_id END) as multi_state_practices
FROM practice_classifications
GROUP BY 1,2
ORDER BY practice_type, practice_size;

-- HOW IT WORKS:
-- 1. First CTE aggregates provider and specialty data at the group practice level
-- 2. Second CTE applies classification logic based on practice characteristics
-- 3. Final query summarizes practice distributions and key metrics

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes current reassignments reflect active practice relationships
-- - Limited to Medicare-participating providers
-- - Does not account for practice locations within states
-- - Specialty counts may include subspecialties as separate specialties

-- POSSIBLE EXTENSIONS:
-- 1. Add temporal analysis of practice growth/consolidation
-- 2. Include revalidation due date clustering analysis
-- 3. Incorporate geographic market concentration metrics
-- 4. Add specialty-specific provider/patient ratios
-- 5. Compare practice characteristics across states/regions
-- 6. Include analysis of physician assistant employment patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:41:48.585215
    - Additional Notes: Query focuses on practice categorization by size and specialty mix with emphasis on multi-state operations. Results can be used for network planning and identifying areas for practice expansion or consolidation. Best run on the most recent data snapshot to reflect current practice configurations.
    
    */