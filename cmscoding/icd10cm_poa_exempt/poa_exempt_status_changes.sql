-- poa_exempt_code_stability_analysis.sql
-- Purpose: Analyze the stability and changes in POA exempt codes across reporting periods
-- Business Value: Helps healthcare organizations:
--   1. Plan ahead for changes in coding requirements
--   2. Understand which codes consistently remain exempt
--   3. Identify potential training needs due to changes
--   4. Reduce compliance risk through better understanding of exemption patterns

WITH latest_two_periods AS (
  -- Get the two most recent reporting periods
  SELECT DISTINCT
    mimi_src_file_date
  FROM mimi_ws_1.cmscoding.icd10cm_poa_exempt
  ORDER BY mimi_src_file_date DESC
  LIMIT 2
),

code_status AS (
  -- Compare code presence between periods
  SELECT 
    e.code,
    e.description,
    MAX(e.mimi_src_file_date) as latest_period,
    MIN(e.mimi_src_file_date) as previous_period,
    COUNT(DISTINCT e.mimi_src_file_date) as period_count
  FROM mimi_ws_1.cmscoding.icd10cm_poa_exempt e
  JOIN latest_two_periods p
    ON e.mimi_src_file_date = p.mimi_src_file_date
  GROUP BY e.code, e.description
)

SELECT 
  code,
  description,
  CASE 
    WHEN period_count = 2 THEN 'Stable Exempt'
    WHEN latest_period > previous_period THEN 'Newly Added'
    ELSE 'Removed'
  END as exemption_status,
  latest_period,
  previous_period
FROM code_status
ORDER BY 
  exemption_status,
  code;

/* How it works:
1. Identifies the two most recent reporting periods
2. Analyzes each code's presence across these periods
3. Categorizes codes as:
   - Stable Exempt (present in both periods)
   - Newly Added (only in latest period)
   - Removed (only in previous period)
4. Provides temporal context with period dates

Assumptions and Limitations:
- Assumes at least two reporting periods exist in the data
- Only looks at the most recent change, not historical patterns
- Does not account for seasonal or temporary exemptions
- Focuses on binary presence/absence, not any underlying reasons for changes

Possible Extensions:
1. Add trend analysis across more than two periods
2. Include code prefix analysis to identify patterns in exempt categories
3. Compare against total ICD-10 code universe to calculate exemption rates
4. Add validation checks for unexpected patterns or anomalies
5. Include frequency analysis of changes by code category
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:14:22.492633
    - Additional Notes: The query focuses on temporal stability analysis by comparing the most recent two reporting periods. It helps identify which POA exempt codes are stable vs changing, which is valuable for compliance planning and workflow optimization. Note that the analysis is limited to binary presence/absence comparisons between only the two most recent periods.
    
    */