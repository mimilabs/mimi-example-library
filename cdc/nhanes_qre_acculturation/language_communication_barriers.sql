-- healthcare_cultural_barriers_assessment.sql
--
-- Business Purpose:
-- This analysis identifies potential cultural and communication barriers in the healthcare system by:
-- 1. Quantifying the gap between home language and thinking language preferences
-- 2. Highlighting populations that may face challenges in healthcare communications
-- 3. Supporting development of targeted patient engagement strategies
--

WITH language_preferences AS (
    -- Categorize language patterns for each respondent
    SELECT 
        seqn,
        CASE 
            WHEN acq020 = 1 THEN 'Only Spanish'
            WHEN acq020 = 2 THEN 'More Spanish'
            WHEN acq020 = 3 THEN 'Both Equally'
            WHEN acq020 = 4 THEN 'More English'
            WHEN acq020 = 5 THEN 'Only English'
            ELSE 'Other/Unknown'
        END AS general_language,
        CASE 
            WHEN acq050 = 1 THEN 'Only Spanish'
            WHEN acq050 = 2 THEN 'More Spanish'
            WHEN acq050 = 3 THEN 'Both Equally'
            WHEN acq050 = 4 THEN 'More English'
            WHEN acq050 = 5 THEN 'Only English'
            ELSE 'Other/Unknown'
        END AS thinking_language
    FROM mimi_ws_1.cdc.nhanes_qre_acculturation
    WHERE acq020 IS NOT NULL 
    AND acq050 IS NOT NULL
)

SELECT 
    general_language,
    thinking_language,
    COUNT(*) as respondent_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM language_preferences
WHERE general_language != 'Other/Unknown'
AND thinking_language != 'Other/Unknown'
GROUP BY general_language, thinking_language
ORDER BY respondent_count DESC;

-- How This Query Works:
-- 1. Creates a CTE to standardize language preference categories
-- 2. Compares general language ability vs. thinking language
-- 3. Calculates distribution of respondents across language preference combinations
-- 4. Excludes unknown/invalid responses for clearer insights

-- Assumptions and Limitations:
-- 1. Focuses only on Spanish-English language dynamics
-- 2. Assumes language preferences are stable over time
-- 3. Does not account for regional variations
-- 4. Limited to self-reported data

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, region)
-- 2. Include temporal analysis using mimi_src_file_date
-- 3. Correlate with healthcare access metrics
-- 4. Expand analysis to include other languages using acd011a/b/c
-- 5. Create risk scoring for communication barriers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:20:42.915136
    - Additional Notes: Query focuses specifically on comparing general vs. thinking language preferences to identify potential healthcare communication gaps. Results may need additional context from healthcare access data for full impact assessment. Spanish-English bilingual focus may not fully represent other language communities.
    
    */