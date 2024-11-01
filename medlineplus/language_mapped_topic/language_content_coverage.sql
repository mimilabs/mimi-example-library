-- engagement_by_language.sql
--
-- Business Purpose:
-- Analyze user engagement opportunities by measuring the volume of translated content
-- available in each language. This helps identify which languages have the most 
-- comprehensive coverage and potential reach for patient education initiatives.
--
-- The analysis supports:
-- 1. Content strategy planning
-- 2. Resource allocation for translations
-- 3. Market opportunity assessment
-- 4. Patient engagement initiatives

WITH language_metrics AS (
  -- Get latest data snapshot and calculate key metrics per language
  SELECT 
    language,
    COUNT(DISTINCT topic_id) as unique_topics,
    COUNT(DISTINCT mapped_id) as translated_versions,
    COUNT(DISTINCT mapped_url) as unique_urls,
    MAX(mimi_src_file_date) as latest_update
  FROM mimi_ws_1.medlineplus.language_mapped_topic
  GROUP BY language
),
ranked_languages AS (
  -- Rank languages by content volume
  SELECT
    language,
    unique_topics,
    translated_versions,
    unique_urls,
    latest_update,
    RANK() OVER (ORDER BY unique_topics DESC) as coverage_rank
  FROM language_metrics
)
SELECT
  language,
  unique_topics,
  translated_versions,
  unique_urls,
  latest_update,
  coverage_rank,
  ROUND(100.0 * unique_topics / MAX(unique_topics) OVER (), 1) as pct_of_max_coverage
FROM ranked_languages
ORDER BY coverage_rank
LIMIT 20;

-- How this works:
-- 1. First CTE aggregates metrics by language from the most recent data
-- 2. Second CTE ranks languages by number of unique topics
-- 3. Final query adds percentage calculations and formats output
--
-- Assumptions:
-- - Higher topic counts indicate better coverage and engagement potential
-- - All mapped_urls are valid and accessible
-- - Language codes are standardized
--
-- Limitations:
-- - Does not account for topic importance/popularity
-- - No insight into translation quality
-- - May include inactive/archived content
--
-- Possible Extensions:
-- 1. Add temporal analysis to track translation growth
-- 2. Compare against population demographics
-- 3. Include topic category analysis
-- 4. Add quality metrics like URL validity checks
-- 5. Cross-reference with engagement metrics if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:26:21.173781
    - Additional Notes: Query focuses on content availability metrics across languages, useful for strategic planning and resource allocation. Note that results are limited to top 20 languages by default and calculations assume equal importance for all topics. Consider adjusting the LIMIT clause based on specific reporting needs.
    
    */