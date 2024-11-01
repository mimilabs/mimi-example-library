-- poa_exempt_utilization_analysis.sql
-- Purpose: Analyze POA exempt code utilization across time periods and categories to identify patterns 
-- that could impact medical coding workload and compliance requirements.
-- Business value: Helps organizations optimize coding resources and understand POA reporting exemption trends.

WITH latest_snapshot AS (
  -- Get the most recent data snapshot
  SELECT MAX(mimi_src_file_date) as latest_date
  FROM mimi_ws_1.cmscoding.icd10cm_poa_exempt
),

code_categories AS (
  -- Categorize codes based on their first 3 characters
  SELECT 
    LEFT(code, 3) as code_category,
    COUNT(*) as codes_in_category,
    CONCAT_WS('; ', COLLECT_SET(description)) as category_descriptions,
    MIN(mimi_src_file_date) as first_seen_date,
    MAX(mimi_src_file_date) as last_seen_date
  FROM mimi_ws_1.cmscoding.icd10cm_poa_exempt
  GROUP BY LEFT(code, 3)
)

SELECT
  code_category,
  codes_in_category,
  category_descriptions,
  first_seen_date,
  last_seen_date,
  -- Calculate how long this category has been exempt
  DATEDIFF(day, first_seen_date, last_seen_date) as days_exempt,
  -- Flag categories with recent changes
  CASE 
    WHEN last_seen_date = (SELECT latest_date FROM latest_snapshot) THEN 'Current'
    ELSE 'Historical'
  END as status
FROM code_categories
ORDER BY codes_in_category DESC, code_category
LIMIT 20;

/* How this query works:
1. Creates a CTE to identify the latest data snapshot
2. Groups ICD-10 codes into categories based on first 3 characters
3. Analyzes temporal patterns and provides category-level summaries
4. Identifies current vs historical exempt categories

Assumptions and Limitations:
- Assumes first 3 characters of ICD-10 codes represent meaningful categories
- Limited to top 20 categories by number of codes
- Does not account for seasonal variations in POA reporting requirements
- Temporal analysis depends on completeness of mimi_src_file_date values

Possible Extensions:
1. Add trending analysis to identify growing/shrinking categories
2. Compare against full ICD-10 code set to calculate exemption percentages
3. Include clinical specialty mapping for category classifications
4. Add quarterly/annual change detection logic
5. Incorporate complexity scoring based on description analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:23:19.616908
    - Additional Notes: This query aggregates POA exempt codes into clinical categories based on ICD-10 prefix patterns. The category_descriptions field may be truncated for categories with many descriptions due to string concatenation limits. Consider adding WHERE clauses to filter specific date ranges if the full historical analysis is not needed.
    
    */