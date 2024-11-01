-- acculturation_proficiency_patterns.sql
-- 
-- Business Purpose:
-- This analysis examines acculturation levels through language proficiency patterns
-- to help healthcare organizations:
-- 1. Identify populations that may need language assistance services
-- 2. Optimize allocation of translation and interpretation resources
-- 3. Support cultural competency training initiatives
-- 4. Guide patient communication strategies

WITH language_proficiency AS (
    -- Get primary language proficiency metrics
    SELECT 
        acd110 as english_proficiency_level,
        CASE 
            WHEN acd110 IN (1,2) THEN 'Limited English'
            WHEN acd110 = 3 THEN 'Bilingual'
            WHEN acd110 IN (4,5) THEN 'English Dominant'
            ELSE 'Unknown'
        END as proficiency_category,
        COUNT(*) as respondent_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
    FROM mimi_ws_1.cdc.nhanes_qre_acculturation
    WHERE acd110 IS NOT NULL
    GROUP BY acd110
),

thought_language AS (
    -- Analyze thinking language patterns
    SELECT 
        acq050 as thinking_language,
        COUNT(*) as respondent_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
    FROM mimi_ws_1.cdc.nhanes_qre_acculturation
    WHERE acq050 IS NOT NULL
    GROUP BY acq050
)

-- Combine proficiency and thinking language patterns
SELECT 
    'Language Proficiency' as metric_type,
    proficiency_category as category,
    respondent_count,
    percentage
FROM language_proficiency
UNION ALL
SELECT 
    'Thinking Language' as metric_type,
    CASE 
        WHEN thinking_language = 1 THEN 'Only Spanish'
        WHEN thinking_language = 2 THEN 'More Spanish than English'
        WHEN thinking_language = 3 THEN 'Both Equally'
        WHEN thinking_language = 4 THEN 'More English than Spanish'
        WHEN thinking_language = 5 THEN 'Only English'
        ELSE 'Other'
    END as category,
    respondent_count,
    percentage
FROM thought_language
ORDER BY metric_type, percentage DESC;

-- How this query works:
-- 1. Creates a CTE for language proficiency levels, categorizing respondents
-- 2. Creates a CTE for thinking language patterns
-- 3. Unions the results to show both metrics side by side
-- 4. Calculates percentages for each category
--
-- Assumptions and Limitations:
-- - Assumes null values should be excluded from analysis
-- - Limited to English-Spanish language patterns
-- - Does not account for regional variations
-- - Cross-sectional analysis only (no temporal trends)
--
-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, region)
-- 2. Include correlation with healthcare utilization
-- 3. Compare language preferences across different social contexts
-- 4. Add temporal analysis if multiple survey years available
-- 5. Expand to include other language pairs beyond English-Spanish

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:42:30.370774
    - Additional Notes: Query focuses on two key acculturation metrics (language proficiency and thinking language) and presents them in a standardized percentage format. The categorization approach makes it particularly useful for healthcare resource planning, though it currently only captures English-Spanish dynamics. Consider regional deployment contexts when using results for resource allocation decisions.
    
    */