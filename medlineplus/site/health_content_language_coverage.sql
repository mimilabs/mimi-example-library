-- Language_Coverage_Analysis.sql

-- Business Purpose:
-- Analyze the language coverage and accessibility of health information resources
-- Identify gaps in multilingual health content availability
-- Support strategic decisions for expanding language-specific health resources
-- Enable better service to diverse populations through targeted content development

-- Main Query
WITH language_metrics AS (
  SELECT
    topic_id,
    -- Count distinct base URLs to get unique sites
    COUNT(DISTINCT url) as total_sites,
    -- Count language variations
    COUNT(DISTINCT language_mapped_url) as language_variations,
    -- Calculate language coverage ratio
    ROUND(COUNT(DISTINCT language_mapped_url)::FLOAT / COUNT(DISTINCT url), 2) as language_coverage_ratio,
    -- Get latest data timestamp
    MAX(mimi_src_file_date) as latest_update
  FROM mimi_ws_1.medlineplus.site
  GROUP BY topic_id
)

SELECT
  lm.*,
  -- Categorize language coverage
  CASE 
    WHEN language_coverage_ratio = 1 THEN 'Single Language'
    WHEN language_coverage_ratio > 1 AND language_coverage_ratio <= 2 THEN 'Limited Multi-language'
    WHEN language_coverage_ratio > 2 THEN 'Extensive Multi-language'
  END as coverage_category
FROM language_metrics lm
WHERE total_sites > 0
ORDER BY language_coverage_ratio DESC, total_sites DESC
LIMIT 100;

-- How it works:
-- 1. Creates metrics per topic showing total unique sites and language variations
-- 2. Calculates a language coverage ratio (variations per base URL)
-- 3. Categorizes topics based on their language coverage
-- 4. Filters out topics with no sites and ranks by coverage

-- Assumptions and Limitations:
-- - Assumes language_mapped_url differences indicate distinct language versions
-- - Does not account for quality or completeness of translations
-- - Limited to currently mapped languages in the system
-- - May not capture all informal or regional language variations

-- Possible Extensions:
-- 1. Add time-based analysis to track language coverage trends
-- 2. Join with topic metadata to identify priority areas for translation
-- 3. Compare language coverage across different health categories
-- 4. Add geographic analysis of language needs vs. available content
-- 5. Create alerts for topics with low language coverage in high-priority areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:19:59.836332
    - Additional Notes: Query focuses on multilingual content distribution metrics across health topics. Some calculated ratios may need adjustment based on specific language pair requirements. Consider adding language-specific weightings for more accurate coverage assessment in production environments.
    
    */