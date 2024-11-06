-- RxNorm Concept Language Distribution Analysis

-- Business Purpose:
-- This analysis examines the distribution of languages in RxNorm concepts to:
-- 1. Support internationalization of healthcare applications
-- 2. Identify coverage gaps in non-English drug terminology
-- 3. Guide localization efforts for clinical decision support systems
-- 4. Assess completeness of multilingual drug information

-- Core Query
WITH language_stats AS (
  SELECT 
    lat AS language,
    COUNT(DISTINCT rxcui) AS unique_concepts,
    COUNT(*) AS total_entries,
    COUNT(DISTINCT sab) AS source_count,
    -- Calculate percentage of active (non-suppressed) entries
    ROUND(100.0 * COUNT(CASE WHEN suppress = 'N' THEN 1 END) / COUNT(*), 2) AS active_percentage
  FROM mimi_ws_1.nlm.rxnconso
  WHERE cvf = '4096'  -- Focus on current prescribable content
  GROUP BY lat
)
SELECT 
  language,
  unique_concepts,
  total_entries,
  source_count,
  active_percentage,
  -- Calculate percentage share of total concepts
  ROUND(100.0 * unique_concepts / SUM(unique_concepts) OVER (), 2) AS concept_share_percentage
FROM language_stats
ORDER BY unique_concepts DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate language-level statistics
-- 2. Focuses on current prescribable content (CVF = '4096')
-- 3. Calculates key metrics per language:
--    - Unique concept count
--    - Total entry count
--    - Number of source vocabularies
--    - Percentage of active entries
-- 4. Computes relative share of concepts for each language

-- Assumptions and Limitations:
-- 1. Assumes CVF = '4096' represents current prescribable content
-- 2. Limited to point-in-time analysis (no historical trends)
-- 3. Does not account for concept relationships across languages
-- 4. Focuses on direct counts rather than semantic coverage

-- Possible Extensions:
-- 1. Add trend analysis by incorporating mimi_src_file_date
-- 2. Include term type (TTY) distribution within each language
-- 3. Compare language coverage across different source vocabularies (SAB)
-- 4. Analyze specific therapeutic categories by language
-- 5. Add quality metrics (e.g., completeness of translations)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:12:18.104187
    - Additional Notes: Query focuses on prescribable content only (CVF=4096) and provides a high-level view of language distribution. Consider adjusting the CVF filter if analysis of non-prescribable content is needed. Results are most useful for internationalization planning and identifying gaps in multilingual drug terminology coverage.
    
    */