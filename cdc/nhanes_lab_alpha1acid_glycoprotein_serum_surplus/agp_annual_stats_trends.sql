-- analyze_alpha1_glycoprotein_trends_over_time.sql
-- 
-- Business Purpose:
-- Analyze temporal trends in Alpha-1-Acid Glycoprotein (AGP) levels to identify potential 
-- shifts in population inflammation markers over different time periods. This analysis helps
-- healthcare organizations and researchers understand changing patterns of systemic inflammation
-- which can inform population health management strategies.
--

WITH sample_periods AS (
  -- Group data into distinct time periods based on source file dates
  SELECT 
    YEAR(mimi_src_file_date) as measurement_year,
    COUNT(DISTINCT seqn) as total_participants,
    AVG(ssagp) as avg_agp_level,
    PERCENTILE(ssagp, 0.5) as median_agp_level,
    MIN(ssagp) as min_agp_level,
    MAX(ssagp) as max_agp_level,
    STDDEV(ssagp) as agp_stddev
  FROM mimi_ws_1.cdc.nhanes_lab_alpha1acid_glycoprotein_serum_surplus
  WHERE ssagp IS NOT NULL
  GROUP BY YEAR(mimi_src_file_date)
),

year_over_year AS (
  -- Calculate year-over-year changes
  SELECT 
    measurement_year,
    LAG(avg_agp_level) OVER (ORDER BY measurement_year) as prev_year_avg,
    ((avg_agp_level - LAG(avg_agp_level) OVER (ORDER BY measurement_year)) / 
     NULLIF(LAG(avg_agp_level) OVER (ORDER BY measurement_year), 0)) * 100 as yoy_change_pct
  FROM sample_periods
)

SELECT 
  sp.measurement_year,
  sp.total_participants,
  ROUND(sp.avg_agp_level, 2) as avg_agp_level,
  ROUND(sp.median_agp_level, 2) as median_agp_level,
  ROUND(sp.min_agp_level, 2) as min_agp_level,
  ROUND(sp.max_agp_level, 2) as max_agp_level,
  ROUND(sp.agp_stddev, 2) as agp_stddev,
  ROUND(yoy.yoy_change_pct, 1) as yoy_change_pct
FROM sample_periods sp
LEFT JOIN year_over_year yoy ON sp.measurement_year = yoy.measurement_year
ORDER BY sp.measurement_year;

--
-- How this query works:
-- 1. Groups AGP measurements by year using source file dates
-- 2. Calculates key statistical measures for each year
-- 3. Computes year-over-year changes in average AGP levels
-- 4. Joins results to present a comprehensive view of trends
--
-- Assumptions and Limitations:
-- - Assumes source file dates accurately represent measurement periods
-- - Does not account for sampling weights in the statistical calculations
-- - Year-over-year changes may be affected by changes in population sampling
-- - First year will have NULL yoy_change_pct due to no previous year data
--
-- Possible Extensions:
-- 1. Add seasonal analysis by including month-level granularity
-- 2. Incorporate sampling weights for more accurate population estimates
-- 3. Add statistical significance testing for year-over-year changes
-- 4. Include demographic stratification for subgroup analysis
-- 5. Add confidence intervals for the average AGP levels

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:38:21.618961
    - Additional Notes: Query tracks annual trends in Alpha-1-Acid Glycoprotein levels with year-over-year comparisons. Note that the first year in the dataset will show null values for year-over-year changes, and the analysis assumes uniform sampling across years. Statistical calculations do not incorporate NHANES sampling weights, which may affect population-level interpretations.
    
    */