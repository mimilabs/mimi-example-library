-- medicaid_quality_improvement_trends.sql

-- Business Purpose:
-- Identifies key quality measures showing significant improvement or decline over time
-- across states. This helps healthcare executives and policymakers:
-- 1. Track progress on strategic quality initiatives
-- 2. Identify successful interventions worth replicating
-- 3. Detect measures needing additional focus and resources
-- 4. Support data-driven quality improvement planning

WITH measure_trends AS (
  -- Calculate year-over-year changes for each measure and state
  SELECT 
    state,
    measure_name,
    measure_type,
    ffy,
    state_rate,
    LAG(state_rate) OVER (PARTITION BY state, measure_name ORDER BY ffy) as prev_year_rate,
    number_of_states_reporting,
    median
  FROM mimi_ws_1.datamedicaidgov.quality
  WHERE state_rate IS NOT NULL
    AND rate_used_in_calculating_state_mean_and_median = 'Yes'
    AND ffy >= 2018  -- Focus on recent years
),

significant_changes AS (
  -- Identify measures with notable changes (>5% year-over-year)
  SELECT 
    state,
    measure_name,
    measure_type,
    ffy as current_year,
    ffy - 1 as previous_year,
    state_rate as current_rate,
    prev_year_rate,
    ROUND(((state_rate - prev_year_rate) / prev_year_rate * 100), 1) as percent_change,
    number_of_states_reporting,
    median as national_median
  FROM measure_trends
  WHERE prev_year_rate IS NOT NULL
    AND ABS((state_rate - prev_year_rate) / prev_year_rate) > 0.05  -- 5% threshold
)

-- Final output showing most significant improvements and declines
SELECT 
  current_year,
  state,
  measure_name,
  measure_type,
  current_rate,
  prev_year_rate,
  percent_change,
  national_median,
  number_of_states_reporting,
  CASE 
    WHEN measure_type LIKE '%Higher%better%' AND percent_change > 0 THEN 'Positive Improvement'
    WHEN measure_type LIKE '%Higher%better%' AND percent_change < 0 THEN 'Concerning Decline'
    WHEN measure_type LIKE '%Lower%better%' AND percent_change < 0 THEN 'Positive Improvement'
    WHEN measure_type LIKE '%Lower%better%' AND percent_change > 0 THEN 'Concerning Decline'
    ELSE 'Neutral'
  END as trend_assessment
FROM significant_changes
ORDER BY ABS(percent_change) DESC
LIMIT 100;

-- How it works:
-- 1. Calculates year-over-year changes for each quality measure by state
-- 2. Identifies significant changes using a 5% threshold
-- 3. Classifies changes as improvements or declines based on measure type
-- 4. Returns top changes ranked by magnitude of change

-- Assumptions and Limitations:
-- 1. Assumes 5% change threshold is meaningful across all measure types
-- 2. Limited to measures with "Yes" for rate_used_in_calculating_state_mean_and_median
-- 3. Focuses on recent years (2018+) for relevance
-- 4. Requires at least two consecutive years of data for trend analysis

-- Possible Extensions:
-- 1. Add domain grouping to identify which areas show most improvement
-- 2. Include population breakdown to compare Medicaid vs CHIP trends
-- 3. Add statistical significance testing for changes
-- 4. Create rolling averages to smooth out year-to-year volatility
-- 5. Add comparison to national benchmarks or top performer thresholds

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:00:33.312397
    - Additional Notes: Query focuses on year-over-year changes exceeding 5% threshold, highlighting both improvements and declines. Useful for strategic planning but should be combined with statistical significance testing for more robust analysis. The 5% threshold may need adjustment based on measure-specific acceptable variation ranges.
    
    */