-- hdl_cholesterol_trend_monitoring.sql

-- Business Purpose:
-- - Track temporal changes in HDL cholesterol measurements across NHANES survey periods
-- - Support public health monitoring and intervention planning
-- - Enable identification of shifts in population cardiovascular health
-- - Provide insights for healthcare resource allocation and policy decisions

-- Main Query
WITH yearly_stats AS (
  -- Extract year from file date and calculate key metrics per year
  SELECT 
    YEAR(mimi_src_file_date) as survey_year,
    COUNT(DISTINCT seqn) as participant_count,
    ROUND(AVG(lbdhdd), 1) as avg_hdl_mgdl,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lbdhdd), 1) as median_hdl_mgdl,
    ROUND(MIN(lbdhdd), 1) as min_hdl_mgdl,
    ROUND(MAX(lbdhdd), 1) as max_hdl_mgdl
  FROM mimi_ws_1.cdc.nhanes_lab_cholesterol_hdl
  WHERE lbdhdd IS NOT NULL
  GROUP BY YEAR(mimi_src_file_date)
)

SELECT 
  survey_year,
  participant_count,
  avg_hdl_mgdl,
  median_hdl_mgdl,
  min_hdl_mgdl,
  max_hdl_mgdl,
  -- Calculate year-over-year change in average HDL
  ROUND(avg_hdl_mgdl - LAG(avg_hdl_mgdl) OVER (ORDER BY survey_year), 1) as yoy_change_mgdl
FROM yearly_stats
ORDER BY survey_year;

-- How the Query Works:
-- 1. Creates a CTE to aggregate HDL cholesterol data by survey year
-- 2. Calculates key statistical measures including mean, median, min, and max
-- 3. Computes year-over-year changes in average HDL levels
-- 4. Returns results ordered chronologically

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date reflects the actual survey year
-- - Excludes NULL HDL values from calculations
-- - Does not account for sampling weights or survey design
-- - Year-over-year changes may be affected by differences in sample composition

-- Possible Extensions:
-- 1. Add confidence intervals for the yearly averages
-- 2. Include demographic stratification (requires joining with demographic tables)
-- 3. Add statistical tests for trend significance
-- 4. Incorporate risk category analysis based on HDL thresholds
-- 5. Compare trends across different NHANES cycles or geographic regions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:50:34.405345
    - Additional Notes: The query focuses on temporal analysis of HDL cholesterol levels across NHANES survey periods, calculating year-over-year changes and key statistics. Note that the results depend heavily on the accuracy of mimi_src_file_date as a proxy for survey year, and the analysis does not incorporate NHANES survey weights which could affect population-level interpretations.
    
    */