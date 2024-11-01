-- baseline_agp_distribution_analysis.sql
--
-- Business Purpose:
-- Establish baseline distribution statistics for Alpha-1-Acid Glycoprotein (AGP) 
-- levels to support clinical research and population health initiatives.
-- AGP is a key inflammatory marker that can indicate various health conditions.
-- Understanding its distribution helps set reference ranges and identify outliers.

WITH agp_stats AS (
  -- Calculate key distribution metrics for AGP levels
  SELECT 
    COUNT(*) as total_samples,
    ROUND(AVG(ssagp), 3) as mean_agp,
    ROUND(PERCENTILE(ssagp, 0.5), 3) as median_agp,
    ROUND(STDDEV(ssagp), 3) as std_dev_agp,
    ROUND(MIN(ssagp), 3) as min_agp,
    ROUND(MAX(ssagp), 3) as max_agp,
    ROUND(PERCENTILE(ssagp, 0.25), 3) as p25_agp,
    ROUND(PERCENTILE(ssagp, 0.75), 3) as p75_agp
  FROM mimi_ws_1.cdc.nhanes_lab_alpha1acid_glycoprotein_serum_surplus
  WHERE ssagp IS NOT NULL
),
reference_ranges AS (
  -- Define clinical reference ranges based on distribution
  SELECT 
    *,
    mean_agp - (2 * std_dev_agp) as lower_reference_limit,
    mean_agp + (2 * std_dev_agp) as upper_reference_limit,
    p75_agp - p25_agp as interquartile_range
  FROM agp_stats
)
SELECT 
  total_samples,
  mean_agp,
  median_agp,
  std_dev_agp,
  min_agp,
  max_agp,
  p25_agp,
  p75_agp,
  ROUND(lower_reference_limit, 3) as lower_reference_limit,
  ROUND(upper_reference_limit, 3) as upper_reference_limit,
  ROUND(interquartile_range, 3) as interquartile_range
FROM reference_ranges;

-- How this query works:
-- 1. First CTE calculates basic distribution statistics for AGP levels
-- 2. Second CTE establishes reference ranges using 2 standard deviations
-- 3. Final SELECT formats and presents the results

-- Assumptions and Limitations:
-- - Assumes normal distribution for reference range calculations
-- - Does not account for demographic variations
-- - Treats all samples equally (no weighting applied)
-- - Does not consider temporal changes in AGP levels

-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, etc.)
-- 2. Incorporate sample weights for population-level estimates
-- 3. Compare distributions across different time periods
-- 4. Add flags for clinically significant thresholds
-- 5. Calculate percentage of samples outside reference ranges

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:55:05.572943
    - Additional Notes: The query establishes population-level reference ranges for Alpha-1-Acid Glycoprotein using standard statistical methods. Note that it uses unweighted calculations which may not fully represent the U.S. population. The 2-standard deviation approach for reference ranges assumes normal distribution of values.
    
    */