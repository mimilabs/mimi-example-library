-- nhanes_air_quality_response_trends.sql
--
-- Business Purpose:
-- - Identify temporal trends in air quality response behaviors to inform public health strategies
-- - Track effectiveness of air quality awareness campaigns over time
-- - Support policy decisions around air quality alert systems and public education
--
-- Key metrics:
-- - Year-over-year changes in behavioral response rates
-- - Changes in specific protective actions taken
-- - Temporal patterns in public health awareness and action

WITH yearly_trends AS (
  -- Extract year from file date and calculate response metrics
  SELECT 
    YEAR(mimi_src_file_date) as survey_year,
    COUNT(DISTINCT seqn) as total_respondents,
    COUNT(DISTINCT CASE WHEN paq685 = 1 THEN seqn END) as changed_behavior,
    -- Calculate percentage who changed behavior
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN paq685 = 1 THEN seqn END) / 
          NULLIF(COUNT(DISTINCT seqn), 0), 2) as pct_changed_behavior
  FROM mimi_ws_1.cdc.nhanes_qre_air_quality
  GROUP BY YEAR(mimi_src_file_date)
),

year_over_year AS (
  -- Calculate year-over-year changes
  SELECT 
    survey_year,
    total_respondents,
    pct_changed_behavior,
    pct_changed_behavior - LAG(pct_changed_behavior) 
      OVER (ORDER BY survey_year) as yoy_change
  FROM yearly_trends
)

SELECT 
  y.*,
  CASE 
    WHEN yoy_change > 0 THEN 'Increased'
    WHEN yoy_change < 0 THEN 'Decreased'
    ELSE 'No Change'
  END as trend_direction,
  -- Add contextual interpretation
  CASE 
    WHEN yoy_change > 5 THEN 'Significant Increase'
    WHEN yoy_change BETWEEN 0 AND 5 THEN 'Moderate Increase'
    WHEN yoy_change BETWEEN -5 AND 0 THEN 'Moderate Decrease'
    WHEN yoy_change < -5 THEN 'Significant Decrease'
    ELSE 'Stable'
  END as trend_magnitude
FROM year_over_year y
ORDER BY survey_year;

-- How it works:
-- 1. First CTE extracts year and calculates basic response metrics
-- 2. Second CTE computes year-over-year changes
-- 3. Main query adds trend interpretation and contextual analysis
--
-- Assumptions:
-- - mimi_src_file_date represents the survey year
-- - paq685 = 1 indicates changed behavior
-- - Null values are excluded from percentage calculations
--
-- Limitations:
-- - Doesn't account for seasonal variations within years
-- - Assumes linear trends between survey years
-- - Doesn't control for demographic or geographic factors
--
-- Possible Extensions:
-- 1. Add seasonal analysis by including month-level trends
-- 2. Incorporate specific behavior changes (paq690a-k)
-- 3. Add confidence intervals for trend analysis
-- 4. Include demographic breakdowns of trends
-- 5. Add geographic analysis if location data becomes available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:06:57.867189
    - Additional Notes: This query focuses on temporal trends analysis, tracking year-over-year changes in public response to air quality alerts. The analysis uses percent changes and trend categorization to provide actionable insights for public health strategies. Note that the effectiveness of the analysis depends on consistent data collection across survey years and proper date recording in mimi_src_file_date.
    
    */