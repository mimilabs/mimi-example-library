-- cbsa_residential_matching_quality.sql

-- Business Purpose: Assess the quality and completeness of CBSA to ZIP code mappings
-- by analyzing score distributions and identifying potential data quality issues.
-- This helps validate geographic coverage for market analysis and resource allocation.

-- Main Query
WITH scoring_summary AS (
  SELECT 
    cbsa,
    COUNT(DISTINCT zip) as zip_count,
    ROUND(AVG(score), 2) as avg_match_score,
    ROUND(MIN(score), 2) as min_match_score,
    ROUND(MAX(score), 2) as max_match_score,
    -- Count high quality matches (score > 75)
    SUM(CASE WHEN score > 75 THEN 1 ELSE 0 END) as strong_matches,
    -- Count potential issues (score < 25)
    SUM(CASE WHEN score < 25 THEN 1 ELSE 0 END) as weak_matches
  FROM mimi_ws_1.huduser.cbsa_to_zip_otm
  WHERE cbsa != '99999' -- Exclude non-CBSA areas
  GROUP BY cbsa
)
SELECT 
  s.*,
  ROUND(strong_matches * 100.0 / zip_count, 1) as pct_strong_matches,
  ROUND(weak_matches * 100.0 / zip_count, 1) as pct_weak_matches
FROM scoring_summary s
WHERE zip_count >= 10 -- Focus on CBSAs with meaningful ZIP coverage
ORDER BY avg_match_score DESC;

-- How it works:
-- 1. Creates a summary for each CBSA showing ZIP code coverage and match quality metrics
-- 2. Calculates average, min, and max scores to understand the range of matching quality
-- 3. Identifies strong (>75) and weak (<25) matches to flag potential issues
-- 4. Filters to CBSAs with at least 10 ZIP codes for statistical relevance
-- 5. Orders by average match score to highlight best/worst performing areas

-- Assumptions and Limitations:
-- - Score thresholds (75/25) are arbitrary and may need adjustment
-- - Excludes CBSAs with fewer than 10 ZIP codes
-- - Does not account for population or geographic size variations
-- - Current version focuses on residential scoring only

-- Possible Extensions:
-- 1. Add temporal analysis by including mimi_src_file_date
-- 2. Compare residential vs business matching patterns
-- 3. Include state-level aggregation for regional patterns
-- 4. Add population weighting for more accurate quality assessment
-- 5. Create flagging system for CBSAs needing review based on match patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:48:38.075343
    - Additional Notes: Query focuses on matching quality metrics between CBSAs and ZIP codes, helping identify areas where geographic mappings may need review or improvement. Only includes CBSAs with 10+ ZIP codes and excludes non-CBSA areas (99999). Score thresholds of 75 and 25 are configurable based on business needs.
    
    */