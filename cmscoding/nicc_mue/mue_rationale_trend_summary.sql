-- TITLE: Medicare MUE Rationale Distribution and Trends Analysis

-- PURPOSE: 
-- This query analyzes the distribution and trends of MUE rationales to understand:
-- 1. The most common justifications for service limits
-- 2. How rationales vary across service types
-- 3. Changes in rationale patterns over time
-- This helps identify policy patterns and supports medical billing compliance strategies.

WITH rationale_summary AS (
  -- Get the base counts and percentages for each rationale
  SELECT 
    mue_rationale,
    service_type,
    COUNT(*) as code_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total,
    MIN(mimi_src_file_date) as first_seen_date,
    MAX(mimi_src_file_date) as last_seen_date
  FROM mimi_ws_1.cmscoding.nicc_mue
  WHERE mue_rationale IS NOT NULL
  GROUP BY mue_rationale, service_type
),

top_rationales AS (
  -- Identify the top rationales by frequency
  SELECT 
    mue_rationale,
    SUM(code_count) as total_codes,
    CONCAT_WS(', ', COLLECT_SET(service_type)) as affected_services,
    MIN(first_seen_date) as earliest_appearance,
    MAX(last_seen_date) as latest_appearance
  FROM rationale_summary
  GROUP BY mue_rationale
  HAVING SUM(code_count) > 100  -- Focus on significant patterns
)

SELECT 
  tr.mue_rationale,
  tr.total_codes,
  tr.affected_services,
  -- Calculate the duration this rationale has been in use
  DATEDIFF(day, tr.earliest_appearance, tr.latest_appearance) as days_active,
  -- Show example codes for each rationale
  (SELECT CONCAT_WS(', ', COLLECT_LIST(hcpcs_cpt_code))
   FROM (
     SELECT DISTINCT hcpcs_cpt_code 
     FROM mimi_ws_1.cmscoding.nicc_mue 
     WHERE mue_rationale = tr.mue_rationale
     LIMIT 3
   ) t
  ) as example_codes
FROM top_rationales tr
ORDER BY tr.total_codes DESC;

-- HOW IT WORKS:
-- 1. First CTE aggregates data by rationale and service type
-- 2. Second CTE identifies significant rationales and their patterns
-- 3. Main query enriches the analysis with temporal metrics and examples
-- 4. Results show the most common justifications for service limits

-- ASSUMPTIONS AND LIMITATIONS:
-- 1. Assumes rationale text is consistently formatted across records
-- 2. Focuses only on rationales with >100 associated codes
-- 3. Limited to available date range in the source data
-- 4. Does not account for seasonal variations

-- POSSIBLE EXTENSIONS:
-- 1. Add trend analysis to show how rationales change over time
-- 2. Include correlation with MUE values to show strictness by rationale
-- 3. Compare rationale distributions across different service settings
-- 4. Add financial impact analysis using claims data
-- 5. Create rationale categories for higher-level pattern analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:03:33.026458
    - Additional Notes: Query focuses on identifying and analyzing significant MUE rationales (>100 codes) across service types. The COLLECT_SET and CONCAT_WS functions are used for string aggregation, which is more efficient than traditional string concatenation for large datasets. Days_active calculation helps track the longevity and stability of different rationales.
    
    */