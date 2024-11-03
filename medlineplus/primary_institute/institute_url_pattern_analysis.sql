-- Institute Website Structure Impact Analysis
-- Business Purpose: Evaluate the website URL patterns of primary institutes
-- to understand their digital presence strategy and accessibility to health information
-- This insight helps identify standardization opportunities and assess user experience

WITH url_patterns AS (
  SELECT 
    institute,
    url,
    -- Extract domain structure patterns
    CASE 
      WHEN url LIKE '%.gov%' THEN 'Government'
      WHEN url LIKE '%.edu%' THEN 'Educational'
      WHEN url LIKE '%.org%' THEN 'Organization'
      WHEN url LIKE '%.com%' THEN 'Commercial'
      ELSE 'Other'
    END as domain_type,
    -- Check for common web features
    CASE 
      WHEN url LIKE '%health%' THEN 1 
      ELSE 0 
    END as has_health_term,
    COUNT(DISTINCT topic_id) as topics_covered
  FROM mimi_ws_1.medlineplus.primary_institute
  WHERE url IS NOT NULL
  GROUP BY institute, url
)

SELECT 
  domain_type,
  COUNT(DISTINCT institute) as institute_count,
  SUM(topics_covered) as total_topics,
  ROUND(AVG(has_health_term) * 100, 2) as pct_health_in_url,
  -- Calculate average topics per institute by domain
  ROUND(AVG(topics_covered), 2) as avg_topics_per_institute
FROM url_patterns
GROUP BY domain_type
ORDER BY institute_count DESC;

-- How it works:
-- 1. Creates a CTE that analyzes URL patterns for each institute
-- 2. Categorizes domains into government, educational, organizational, or commercial
-- 3. Checks for health-related terms in URLs
-- 4. Aggregates metrics by domain type to reveal digital presence patterns

-- Assumptions and Limitations:
-- - URLs are consistently formatted and valid
-- - Domain type is a reliable indicator of institute type
-- - Health term presence is a meaningful signal
-- - Current snapshot may not reflect historical changes

-- Possible Extensions:
-- 1. Add temporal analysis to track URL structure changes over time
-- 2. Include deeper URL pattern analysis (subdomains, path structure)
-- 3. Cross-reference with topic categories to identify specialty focus
-- 4. Add geographic analysis based on country-specific domains
-- 5. Compare mobile-friendly vs desktop-only URL structures

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:09:54.878178
    - Additional Notes: Query focuses on digital infrastructure patterns of medical institutes. Consider running during off-peak hours if analyzing large datasets as URL pattern matching operations can be resource-intensive. Results may need manual validation for edge cases in URL formats.
    
    */