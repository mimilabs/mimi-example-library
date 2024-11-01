-- medicaid_quality_measure_disparity_analysis.sql

-- Business Purpose:
-- Analyzes disparities in healthcare quality between states by identifying measures
-- where performance varies significantly across regions. This helps policymakers and
-- healthcare administrators target interventions to reduce geographic inequities in care.
-- The analysis focuses on measures where higher rates indicate better performance.

WITH measure_stats AS (
  -- Calculate the coefficient of variation (CV) for each measure to quantify disparity
  SELECT 
    measure_name,
    measure_abbreviation,
    domain,
    ffy,
    COUNT(DISTINCT state) as reporting_states,
    AVG(state_rate) as avg_rate,
    STDDEV(state_rate) as std_dev,
    (STDDEV(state_rate) / NULLIF(AVG(state_rate), 0)) * 100 as coefficient_of_variation
  FROM mimi_ws_1.datamedicaidgov.quality
  WHERE measure_type LIKE '%Higher%better%'
    AND state_rate IS NOT NULL 
    AND rate_used_in_calculating_state_mean_and_median = 'Yes'
    AND ffy = '2022' -- Most recent complete year
  GROUP BY measure_name, measure_abbreviation, domain, ffy
  HAVING COUNT(DISTINCT state) >= 25 -- Ensure sufficient state representation
)

SELECT 
  domain,
  measure_name,
  measure_abbreviation,
  ROUND(avg_rate, 1) as average_rate,
  ROUND(std_dev, 1) as standard_deviation,
  ROUND(coefficient_of_variation, 1) as cv_percent,
  reporting_states
FROM measure_stats 
WHERE coefficient_of_variation > 20 -- Focus on measures with high variation
ORDER BY coefficient_of_variation DESC
LIMIT 10;

-- How it works:
-- 1. Creates CTE to calculate statistical measures of disparity for each quality measure
-- 2. Filters for measures where higher rates are better and data is valid
-- 3. Calculates coefficient of variation (CV) to normalize disparity across measures
-- 4. Returns top 10 measures with highest disparities across states

-- Assumptions and Limitations:
-- - Assumes 2022 data is most complete and representative
-- - Limited to measures with at least 25 reporting states
-- - Only analyzes measures where higher rates indicate better performance
-- - CV may not be ideal for all types of measures
-- - Does not account for demographic or socioeconomic factors

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of disparities
-- 2. Include geographic region grouping analysis
-- 3. Incorporate population-specific analysis (Medicaid vs CHIP)
-- 4. Add correlations with state-level social determinants of health
-- 5. Create visualization-ready output for mapping disparities
-- 6. Include both "higher is better" and "lower is better" measures with appropriate normalization

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:06:35.439155
    - Additional Notes: The query focuses on geographic disparities in healthcare quality measures by calculating coefficient of variation across states. It requires at least 25 reporting states per measure and filters for 2022 data. The CV threshold of 20% for highlighting significant disparities may need adjustment based on specific analysis needs.
    
    */