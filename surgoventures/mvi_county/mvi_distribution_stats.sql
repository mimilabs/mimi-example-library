-- comparing_mvi_across_counties_stats.sql

-- BUSINESS PURPOSE: 
-- This query calculates key statistical measures of maternal vulnerability across counties
-- to provide a comprehensive view of how MVI scores are distributed nationwide.
-- Understanding this distribution helps healthcare planners and policymakers:
-- 1. Establish meaningful thresholds for intervention
-- 2. Set realistic improvement targets
-- 3. Identify outlier counties that may need immediate attention
-- 4. Compare their county's performance against national benchmarks

WITH mvi_stats AS (
  SELECT 
    -- Calculate basic statistics
    COUNT(*) as total_counties,
    ROUND(AVG(mvi), 2) as avg_mvi,
    ROUND(STDDEV(mvi), 2) as std_dev_mvi,
    ROUND(MIN(mvi), 2) as min_mvi,
    ROUND(MAX(mvi), 2) as max_mvi,
    
    -- Calculate percentiles
    ROUND(PERCENTILE(mvi, 0.25), 2) as p25_mvi,
    ROUND(PERCENTILE(mvi, 0.50), 2) as median_mvi,
    ROUND(PERCENTILE(mvi, 0.75), 2) as p75_mvi
  FROM mimi_ws_1.surgoventures.mvi_county
),

county_classifications AS (
  SELECT
    -- Categorize counties based on their MVI scores
    COUNT(CASE WHEN mvi < (SELECT avg_mvi - std_dev_mvi FROM mvi_stats) THEN 1 END) as low_risk_counties,
    COUNT(CASE WHEN mvi > (SELECT avg_mvi + std_dev_mvi FROM mvi_stats) THEN 1 END) as high_risk_counties,
    COUNT(CASE WHEN mvi BETWEEN (SELECT avg_mvi - std_dev_mvi FROM mvi_stats) 
                            AND (SELECT avg_mvi + std_dev_mvi FROM mvi_stats) THEN 1 END) as typical_risk_counties
  FROM mimi_ws_1.surgoventures.mvi_county
)

SELECT 
  m.*,
  c.*,
  -- Calculate relative percentages
  ROUND(100.0 * c.low_risk_counties / m.total_counties, 1) as pct_low_risk,
  ROUND(100.0 * c.typical_risk_counties / m.total_counties, 1) as pct_typical_risk,
  ROUND(100.0 * c.high_risk_counties / m.total_counties, 1) as pct_high_risk
FROM mvi_stats m
CROSS JOIN county_classifications c;

-- HOW IT WORKS:
-- 1. First CTE calculates basic statistical measures for MVI scores
-- 2. Second CTE classifies counties into risk categories based on standard deviations
-- 3. Final SELECT combines the statistics and adds percentage calculations
-- 4. All numerical outputs are rounded for readability

-- ASSUMPTIONS & LIMITATIONS:
-- 1. Assumes normal-like distribution of MVI scores
-- 2. Uses standard deviation for classification, which may not be optimal for all use cases
-- 3. Missing counties (if any) are excluded from calculations
-- 4. Classifications are relative to the national distribution

-- POSSIBLE EXTENSIONS:
-- 1. Add state-level grouping to compare distributions within states
-- 2. Include population weighting to account for county size differences
-- 3. Add year-over-year comparison if temporal data becomes available
-- 4. Include additional risk factors or demographic breakdowns
-- 5. Add geographical clustering analysis to identify regional patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:13:09.645259
    - Additional Notes: The query provides a statistical overview of maternal vulnerability scores across U.S. counties, classifying them into risk categories based on standard deviations from the mean. It includes counts, percentiles, and proportional distributions that can be used for national benchmarking and risk assessment purposes.
    
    */