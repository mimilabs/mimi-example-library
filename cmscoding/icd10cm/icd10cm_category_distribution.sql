
/*******************************************************************************
Title: Basic Analysis of ICD-10-CM Diagnostic Codes Distribution
 
Business Purpose:
- Analyze the distribution and characteristics of ICD-10-CM diagnostic codes
- Identify high-level disease categories based on code prefixes
- Track changes in diagnostic codes over time
- Support healthcare analytics, medical billing, and clinical research

Created: 2024-02-14
*******************************************************************************/

-- Get distribution of ICD codes by their major categories (first letter)
-- along with examples and temporal information
WITH category_stats AS (
  SELECT 
    LEFT(code, 1) as category_prefix,
    COUNT(*) as code_count,
    MIN(code) as example_code,
    MAX(mimi_src_file_date) as latest_update
  FROM mimi_ws_1.cmscoding.icd10cm
  GROUP BY LEFT(code, 1)
)

SELECT
  cs.category_prefix,
  cs.code_count,
  cs.example_code,
  i.description as example_description,
  cs.latest_update,
  -- Calculate percentage of total codes
  ROUND(100.0 * cs.code_count / SUM(cs.code_count) OVER(), 2) as pct_of_total
FROM category_stats cs
LEFT JOIN mimi_ws_1.cmscoding.icd10cm i 
  ON cs.example_code = i.code
  AND i.mimi_src_file_date = cs.latest_update
ORDER BY cs.code_count DESC;

/*******************************************************************************
How this query works:
1. Groups ICD codes by their first character (major disease category)
2. Calculates statistics for each category including count and example
3. Joins back to get descriptions for example codes
4. Computes percentage distribution across categories

Assumptions & Limitations:
- Uses first character as proxy for major disease categories
- Shows only one example per category
- Assumes latest source file date represents most current codes
- Does not account for code deprecation/retirement

Possible Extensions:
1. Add trend analysis to show how categories change over time:
   - Compare code counts across different mimi_src_file_dates
   
2. Deeper hierarchy analysis:
   - Break down by first 3 characters for subcategories
   - Analyze code length distribution
   
3. Description text analysis:
   - Common terms/phrases in descriptions
   - Categorize by medical specialty
   
4. Validation checks:
   - Identify invalid or deprecated codes
   - Find codes with multiple versions/descriptions

5. Specific disease focus:
   - Filter for particular conditions
   - Create specialty-specific code lists
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:27:21.671210
    - Additional Notes: Query provides high-level overview of ICD-10-CM code distribution across major diagnostic categories. Best used for initial data exploration and reporting on code hierarchy structure. Note that category prefix analysis is a simplified view and may not fully represent clinical groupings used in practice.
    
    */