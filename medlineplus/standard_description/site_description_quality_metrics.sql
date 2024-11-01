-- Site Profile Completeness and Data Quality Assessment for MedlinePlus
-- Business Purpose:
-- - Evaluate the completeness and quality of site descriptions in MedlinePlus
-- - Identify potential gaps in site documentation
-- - Support data governance and standardization initiatives
-- - Enable better decision-making around site data maintenance

WITH description_metrics AS (
  -- Calculate key metrics about description content
  SELECT 
    CASE 
      WHEN description IS NULL THEN 'Missing'
      WHEN TRIM(description) = '' THEN 'Empty'
      WHEN LENGTH(description) < 20 THEN 'Very Short'
      WHEN LENGTH(description) < 50 THEN 'Short'
      WHEN LENGTH(description) > 200 THEN 'Detailed'
      ELSE 'Standard'
    END AS description_category,
    COUNT(*) as site_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage,
    MIN(LENGTH(description)) as min_length,
    AVG(LENGTH(description)) as avg_length,
    MAX(LENGTH(description)) as max_length,
    MIN(mimi_src_file_date) as earliest_date,
    MAX(mimi_src_file_date) as latest_date
  FROM mimi_ws_1.medlineplus.standard_description
  GROUP BY 
    CASE 
      WHEN description IS NULL THEN 'Missing'
      WHEN TRIM(description) = '' THEN 'Empty'
      WHEN LENGTH(description) < 20 THEN 'Very Short'
      WHEN LENGTH(description) < 50 THEN 'Short'
      WHEN LENGTH(description) > 200 THEN 'Detailed'
      ELSE 'Standard'
    END
)

SELECT 
  description_category,
  site_count,
  ROUND(percentage, 2) as percentage,
  min_length,
  ROUND(avg_length, 0) as avg_length,
  max_length,
  earliest_date,
  latest_date
FROM description_metrics
ORDER BY 
  CASE description_category
    WHEN 'Missing' THEN 1
    WHEN 'Empty' THEN 2
    WHEN 'Very Short' THEN 3
    WHEN 'Short' THEN 4
    WHEN 'Standard' THEN 5
    WHEN 'Detailed' THEN 6
  END;

-- How this query works:
-- 1. Creates categories for different description lengths and completeness
-- 2. Calculates statistics for each category including counts and percentages
-- 3. Includes temporal range to understand data currency
-- 4. Orders results by severity of potential data quality issues

-- Assumptions and Limitations:
-- - Assumes description length is a proxy for content quality
-- - Does not assess the semantic quality of descriptions
-- - Categories are based on arbitrary length thresholds
-- - Time range analysis assumes mimi_src_file_date is reliable

-- Possible Extensions:
-- 1. Add pattern matching to identify specific content elements
-- 2. Compare against industry standard description requirements
-- 3. Track quality metrics over time to identify trends
-- 4. Cross-reference with other tables to assess impact of description quality
-- 5. Add specific content validation rules for different site types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:32:33.898459
    - Additional Notes: Query provides data quality metrics across 6 categories (Missing, Empty, Very Short, Short, Standard, Detailed) with temporal analysis. Consider adjusting length thresholds based on specific organizational requirements. Results are useful for data governance reporting and identifying areas needing documentation improvement.
    
    */