-- Site Description Uniqueness and Reference Value Analysis
-- 
-- Business Purpose:
-- - Identify unique, high-value reference descriptions that can serve as standard templates
-- - Analyze description patterns to establish quality benchmarks
-- - Support standardization efforts across medical knowledge bases
-- - Provide insights for description optimization and governance

-- Main Query
WITH description_stats AS (
  -- Calculate frequency and recency metrics for each description
  SELECT 
    description,
    COUNT(DISTINCT site_id) as site_count,
    COUNT(*) as total_occurrences,
    MAX(mimi_src_file_date) as latest_update,
    MIN(mimi_src_file_date) as first_appearance,
    AVG(LENGTH(description)) as avg_length
  FROM mimi_ws_1.medlineplus.standard_description
  GROUP BY description
),
ranked_descriptions AS (
  -- Rank descriptions by frequency and identify potential reference templates
  SELECT 
    description,
    site_count,
    total_occurrences,
    latest_update,
    first_appearance,
    avg_length,
    -- Calculate description value score based on usage and consistency
    (site_count * LOG(2 + total_occurrences) * 
     CASE WHEN avg_length BETWEEN 50 AND 200 THEN 1.2 ELSE 1 END) as reference_value_score
  FROM description_stats
)
SELECT 
  description,
  site_count,
  total_occurrences,
  latest_update,
  first_appearance,
  ROUND(avg_length, 1) as avg_length,
  ROUND(reference_value_score, 2) as reference_value_score
FROM ranked_descriptions
WHERE site_count >= 2  -- Focus on descriptions used multiple times
ORDER BY reference_value_score DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE aggregates key metrics for each unique description
-- 2. Second CTE calculates a reference value score considering:
--    - Number of distinct sites using the description
--    - Total usage frequency
--    - Optimal description length (bonus for 50-200 characters)
-- 3. Final output shows top 20 descriptions by reference value score

-- Assumptions and Limitations:
-- - Assumes descriptions with multiple uses are more valuable as templates
-- - Score calculation is a heuristic and may need adjustment based on domain expertise
-- - Limited to analyzing text patterns, not semantic meaning
-- - Current timestamp used for recency calculations

-- Possible Extensions:
-- 1. Add text similarity clustering to group related descriptions
-- 2. Incorporate domain-specific keywords or terminology analysis
-- 3. Create separate scores for different medical specialties or site types
-- 4. Add trend analysis to track description evolution over time
-- 5. Compare descriptions against external style guides or standards

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:48:46.060398
    - Additional Notes: The reference value score calculation may need tuning based on specific use cases. The current weights (site_count * log(occurrences) * length_bonus) prioritize descriptions that are frequently reused and have optimal length. Consider adjusting these parameters or adding domain-specific factors for different analysis needs.
    
    */