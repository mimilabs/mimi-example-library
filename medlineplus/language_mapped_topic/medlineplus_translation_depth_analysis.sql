-- medlineplus_language_translation_depth_analysis.sql
-- Business Purpose: Assess the multilingual content strategy and translation coverage for MedlinePlus
-- to understand linguistic diversity, content expansion potential, and global health information accessibility

WITH language_topic_summary AS (
    -- Aggregate translation statistics by language
    SELECT 
        language,
        COUNT(DISTINCT topic_id) AS unique_original_topics,
        COUNT(DISTINCT mapped_id) AS translated_topics,
        ROUND(COUNT(DISTINCT mapped_id) * 100.0 / NULLIF(COUNT(DISTINCT topic_id), 0), 2) AS translation_coverage_pct,
        MAX(mimi_src_file_date) AS latest_translation_update
    FROM mimi_ws_1.medlineplus.language_mapped_topic
    GROUP BY language
),
language_ranking AS (
    -- Rank languages by translation depth and recency
    SELECT 
        language,
        unique_original_topics,
        translated_topics,
        translation_coverage_pct,
        latest_translation_update,
        RANK() OVER (ORDER BY translated_topics DESC) AS translation_volume_rank,
        RANK() OVER (ORDER BY translation_coverage_pct DESC) AS translation_coverage_rank
    FROM language_topic_summary
)

SELECT 
    language,
    unique_original_topics,
    translated_topics,
    translation_coverage_pct,
    latest_translation_update,
    translation_volume_rank,
    translation_coverage_rank
FROM language_ranking
WHERE translated_topics > 10  -- Focus on languages with meaningful translation efforts
ORDER BY translated_topics DESC, translation_coverage_pct DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Aggregates translation statistics by language
-- 2. Calculates translation coverage percentage
-- 3. Ranks languages by volume and depth of translations
-- 4. Filters for languages with substantial translation efforts

-- Assumptions and Limitations:
-- - Assumes consistent topic identification across languages
-- - May not capture partial or incomplete translations
-- - Snapshot based on mimi_src_file_date

-- Possible Extensions:
-- 1. Add trending analysis of translation growth
-- 2. Integrate with user engagement metrics
-- 3. Compare translation efforts across healthcare domains

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:07:49.600478
    - Additional Notes: Analyzes multilingual content strategy for MedlinePlus, providing insights into translation coverage, volume, and recency across different languages. Focuses on languages with more than 10 translated topics.
    
    */