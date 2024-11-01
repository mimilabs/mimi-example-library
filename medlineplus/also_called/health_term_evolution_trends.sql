-- Title: Health Topics Naming Evolution Over Time
--
-- Business Purpose: 
-- This query analyzes how the alternative names for health topics have changed across time periods.
-- Understanding naming evolution helps:
-- - Track emerging terminology in healthcare
-- - Identify shifts in medical language
-- - Support content updates and terminology standardization
-- - Guide medical documentation and patient education materials

WITH time_periods AS (
  -- Create time buckets for analysis
  SELECT DISTINCT
    DATE_TRUNC('month', mimi_src_file_date) as period,
    topic_id,
    alias
  FROM mimi_ws_1.medlineplus.also_called
  WHERE mimi_src_file_date IS NOT NULL
),

new_terms AS (
  -- Identify new aliases that appear in each period
  SELECT 
    t1.period,
    t1.topic_id,
    t1.alias,
    COUNT(*) OVER (PARTITION BY t1.period) as new_terms_count
  FROM time_periods t1
  LEFT JOIN time_periods t2
  ON t1.topic_id = t2.topic_id 
  AND t1.alias = t2.alias 
  AND t2.period < t1.period
  WHERE t2.topic_id IS NULL
)

SELECT 
  period,
  new_terms_count,
  -- Sample of new terms introduced
  COLLECT_LIST(alias) as sample_new_terms,
  -- Count unique topics that received new terms
  COUNT(DISTINCT topic_id) as topics_with_new_terms
FROM new_terms
GROUP BY period, new_terms_count
ORDER BY period DESC;

-- How it works:
-- 1. Creates monthly time buckets for all records
-- 2. Identifies new aliases by comparing each period with all previous periods
-- 3. Aggregates results to show volume of new terms and examples per period
--
-- Assumptions and limitations:
-- - Assumes mimi_src_file_date represents when terms were first documented
-- - Does not track discontinued terms
-- - Sample size limited by COLLECT_LIST function
--
-- Possible extensions:
-- 1. Add trend analysis showing acceleration/deceleration of new term introduction
-- 2. Compare formal vs informal terminology evolution
-- 3. Add topic categorization to track terminology changes by medical specialty
-- 4. Include term persistence analysis (how long new terms remain in use)
-- 5. Cross-reference with external medical terminology standards

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:42:58.196044
    - Additional Notes: Query tracks introduction of new medical terminology over time. Best used with complete historical data to ensure accurate trend analysis. Results may be affected by data collection frequency in source files. Consider filtering specific date ranges if analyzing particular time periods.
    
    */