-- topic_translation_trends.sql
--
-- Business Purpose:
-- Track quarterly trends in topic translations to measure progress in content localization
-- efforts and identify acceleration or slowdown in translation activities across languages. 
-- This helps inform resource allocation for translation teams and content strategy.

WITH quarterly_translations AS (
  -- Get the quarterly snapshots of translation activity
  SELECT 
    DATE_TRUNC('quarter', mimi_src_file_date) as snapshot_quarter,
    language,
    COUNT(DISTINCT topic_id) as translated_topics,
    COUNT(DISTINCT mapped_id) as translation_variants,
    COUNT(DISTINCT mapped_url) as active_urls
  FROM mimi_ws_1.medlineplus.language_mapped_topic
  GROUP BY 1, 2
),
qoq_change AS (
  -- Calculate quarter-over-quarter changes
  SELECT 
    snapshot_quarter,
    language,
    translated_topics,
    translation_variants,
    active_urls,
    translated_topics - LAG(translated_topics) OVER (
      PARTITION BY language 
      ORDER BY snapshot_quarter
    ) as topic_change
  FROM quarterly_translations
)
SELECT 
  snapshot_quarter,
  language,
  translated_topics,
  translation_variants,
  active_urls,
  topic_change,
  CASE 
    WHEN topic_change > 0 THEN 'Growing'
    WHEN topic_change < 0 THEN 'Shrinking'
    ELSE 'Stable'
  END as translation_momentum
FROM qoq_change
WHERE snapshot_quarter >= DATE_TRUNC('quarter', DATEADD(year, -1, CURRENT_DATE))
ORDER BY snapshot_quarter DESC, translated_topics DESC;

-- How this works:
-- 1. Creates quarterly snapshots of translation metrics
-- 2. Calculates changes between quarters for each language
-- 3. Categorizes translation momentum based on changes
-- 4. Filters to last year of data for actionable insights

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date represents when translations became available
-- - Does not account for translation quality or content complexity
-- - Quarter-over-quarter comparison may miss seasonal patterns

-- Possible Extensions:
-- 1. Add year-over-year growth rates
-- 2. Include topic categories to identify focus areas
-- 3. Compare against target translation goals
-- 4. Add quality metrics if available
-- 5. Create projections for translation completion timelines

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:10:43.159814
    - Additional Notes: Query focuses on quarterly translation velocity and momentum tracking. Note that results are most meaningful when there's at least 4-5 quarters of historical data to establish trends. The momentum categorization thresholds could be adjusted based on business targets.
    
    */