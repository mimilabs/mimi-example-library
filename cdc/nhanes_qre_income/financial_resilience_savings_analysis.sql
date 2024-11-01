-- Title: NHANES Financial Self-Sufficiency Assessment
-- Business Purpose: Analyze the relationship between savings levels and income sources
-- to understand financial resilience patterns across the population. This helps identify
-- segments that may need targeted financial wellness programs or interventions.

WITH savings_categories AS (
  SELECT 
    CASE 
      WHEN inq300 = 1 THEN 'Over $20k'
      WHEN inq300 = 2 THEN 'Under $20k'
      WHEN inq244 = 1 THEN 'Over $5k'
      WHEN inq244 = 2 THEN 'Under $5k'
      ELSE 'Unknown'
    END as savings_level,
    -- Count income sources per respondent
    (CASE WHEN inq020 = 1 THEN 1 ELSE 0 END +
     CASE WHEN inq012 = 1 THEN 1 ELSE 0 END +
     CASE WHEN inq030 = 1 THEN 1 ELSE 0 END +
     CASE WHEN inq140 = 1 THEN 1 ELSE 0 END) as income_source_count,
    indfmmpc as poverty_category
  FROM mimi_ws_1.cdc.nhanes_qre_income
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cdc.nhanes_qre_income)
)

SELECT 
  savings_level,
  COUNT(*) as respondent_count,
  ROUND(AVG(income_source_count), 2) as avg_income_sources,
  -- Distribution across poverty categories
  COUNT(CASE WHEN poverty_category = 1 THEN 1 END) as monthly_income_under_130pct_poverty,
  COUNT(CASE WHEN poverty_category = 2 THEN 1 END) as monthly_income_130_350pct_poverty,
  COUNT(CASE WHEN poverty_category = 3 THEN 1 END) as monthly_income_over_350pct_poverty
FROM savings_categories
GROUP BY savings_level
ORDER BY savings_level;

-- How it works:
-- 1. Creates savings categories based on two survey questions about savings thresholds
-- 2. Counts active income sources per respondent (employment, self-employment, social security, investments)
-- 3. Aggregates results to show relationship between savings levels and income diversity
-- 4. Includes poverty level distribution for each savings category

-- Assumptions and Limitations:
-- - Uses most recent survey data only
-- - Assumes missing values indicate "no" for income sources
-- - Simplified savings categories may not capture full complexity
-- - Survey responses are self-reported and subject to recall bias

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, education, region)
-- 2. Trend analysis across multiple survey years
-- 3. Include transportation method to grocery stores as proxy for mobility/access
-- 4. Analyze relationship between savings and specific income source combinations
-- 5. Create risk scores based on savings levels and income diversity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:33:52.260724
    - Additional Notes: Query focuses on financial resilience by analyzing savings levels and income source diversity. Note that the savings thresholds changed in different survey cycles ($20k vs $5k), so results should be interpreted within the context of when the data was collected. Consider adding income range (ind235) analysis for more granular financial assessment.
    
    */