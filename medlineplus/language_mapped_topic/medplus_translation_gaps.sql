-- language_coverage_gaps.sql
-- 
-- Business Purpose:
-- Identify languages and topics that may be underserved in MedlinePlus translations
-- to support healthcare equity initiatives and inform content translation priorities.
-- This analysis helps stakeholders make data-driven decisions about where to focus
-- translation resources for maximum impact.

WITH topic_language_summary AS (
    -- Get the count of translations per topic
    SELECT 
        topic_id,
        COUNT(DISTINCT language) as num_languages,
        -- Create array of available languages for each topic
        COLLECT_SET(language) as available_languages
    FROM mimi_ws_1.medlineplus.language_mapped_topic
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.medlineplus.language_mapped_topic)
    GROUP BY topic_id
),

language_stats AS (
    -- Calculate overall language coverage statistics
    SELECT
        language,
        COUNT(DISTINCT topic_id) as topics_covered,
        -- Calculate percentage of total topics covered
        COUNT(DISTINCT topic_id) * 100.0 / (SELECT COUNT(DISTINCT topic_id) 
                                           FROM mimi_ws_1.medlineplus.language_mapped_topic) as coverage_percentage
    FROM mimi_ws_1.medlineplus.language_mapped_topic
    GROUP BY language
)

SELECT 
    ls.language,
    ls.topics_covered,
    ROUND(ls.coverage_percentage, 2) as coverage_percentage,
    -- Identify topics with low translation coverage
    (SELECT COUNT(*) 
     FROM topic_language_summary 
     WHERE num_languages <= 3) as topics_with_limited_translations,
    -- Calculate potential impact score
    ROUND((100 - ls.coverage_percentage) * ls.topics_covered / 100, 0) as translation_opportunity_score
FROM language_stats ls
ORDER BY translation_opportunity_score DESC;

-- How this query works:
-- 1. Creates a summary of topics and their language coverage
-- 2. Calculates statistics for each language's coverage
-- 3. Combines these metrics with an opportunity score to prioritize translations
--
-- Assumptions and limitations:
-- - Uses latest source file date for current state analysis
-- - Assumes all translations are equally important
-- - Does not account for topic popularity or medical urgency
-- - May not reflect regional language needs
--
-- Possible extensions:
-- 1. Add demographic data to weight language importance by population
-- 2. Include topic priority/urgency metrics
-- 3. Add trend analysis to show translation progress over time
-- 4. Incorporate user access patterns to prioritize high-demand content
-- 5. Add regional analysis for targeted translation efforts

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:19:48.427452
    - Additional Notes: Query focuses on translation coverage gaps and prioritization metrics. Note that the opportunity score calculation assumes equal weighting for all topics and languages. For production use, consider adding weighting factors based on population demographics or medical importance of topics.
    
    */