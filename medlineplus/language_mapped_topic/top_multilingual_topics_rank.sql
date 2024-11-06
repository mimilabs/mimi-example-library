-- most_engaging_multilingual_topics.sql

-- Business Purpose:
-- Identify the most engaging multilingual health topics based on translation frequency 
-- and language diversity. This helps prioritize high-value content for localization
-- and understand which medical topics have the broadest global reach.

-- Main Query
WITH topic_language_stats AS (
  -- Calculate translation metrics for each topic
  SELECT 
    topic_id,
    COUNT(DISTINCT language) as num_languages,
    COUNT(DISTINCT mapped_id) as num_translations,
    array_agg(DISTINCT language) as available_languages
  FROM mimi_ws_1.medlineplus.language_mapped_topic
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.medlineplus.language_mapped_topic)
  GROUP BY topic_id
),
ranked_topics AS (
  -- Rank topics by translation coverage
  SELECT 
    topic_id,
    num_languages,
    num_translations,
    available_languages,
    DENSE_RANK() OVER (ORDER BY num_languages DESC, num_translations DESC) as topic_rank
  FROM topic_language_stats
)
SELECT 
  topic_id,
  num_languages as languages_available,
  num_translations as total_translations,
  available_languages as language_list,
  topic_rank
FROM ranked_topics 
WHERE topic_rank <= 20
ORDER BY topic_rank, topic_id;

-- How it works:
-- 1. Creates temporary table with translation metrics per topic
-- 2. Ranks topics based on language coverage and translation count
-- 3. Returns top 20 topics with most comprehensive multilingual presence
-- 4. Uses latest source file date for current state analysis

-- Assumptions & Limitations:
-- - Topic popularity assumed to correlate with translation frequency
-- - Doesn't account for translation quality or content completeness
-- - Limited to most recent data snapshot
-- - Assumes all languages are equally important (no weighting)

-- Possible Extensions:
-- 1. Join with topic metadata to show topic names and categories
-- 2. Add time-based trending analysis
-- 3. Filter for specific language groups or regions
-- 4. Include quality metrics if available
-- 5. Compare against user engagement metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:13:45.527650
    - Additional Notes: Query focuses on current multilingual content reach rather than historical patterns. Consider adding topic metadata joins for more meaningful results. The array_agg function used for language_list may need optimization for very large datasets.
    
    */