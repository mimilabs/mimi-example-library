-- agp_longitudinal_weight_variance.sql
--
-- Business Purpose:
-- Analyze how sample weights affect the representation of Alpha-1-Acid Glycoprotein (AGP) 
-- measurements across different time periods. This helps assess the reliability of population-level
-- estimates and supports strategic decisions in public health interventions.
--
-- The analysis compares pre-pandemic weights with 2-year weights to understand potential
-- sampling biases and their impact on AGP level interpretations.

WITH weight_comparison AS (
  SELECT 
    -- Calculate basic statistics for both weight types
    COUNT(*) as total_samples,
    COUNT(CASE WHEN wtssagpp IS NOT NULL AND wtssgp2y IS NOT NULL THEN 1 END) as complete_weight_samples,
    
    -- AGP level statistics with different weights
    AVG(ssagp * wtssagpp) / AVG(wtssagpp) as weighted_agp_prepandemic,
    AVG(ssagp * wtssgp2y) / AVG(wtssgp2y) as weighted_agp_2year,
    
    -- Weight variation metrics
    STDDEV(wtssagpp) / AVG(wtssagpp) as prepandemic_weight_cv,
    STDDEV(wtssgp2y) / AVG(wtssgp2y) as twoyear_weight_cv,
    
    -- Time period analysis
    YEAR(mimi_src_file_date) as data_year
  FROM mimi_ws_1.cdc.nhanes_lab_alpha1acid_glycoprotein_serum_surplus
  WHERE ssagp IS NOT NULL
  GROUP BY YEAR(mimi_src_file_date)
)
SELECT 
  data_year,
  total_samples,
  complete_weight_samples,
  ROUND(weighted_agp_prepandemic, 3) as avg_agp_prepandemic,
  ROUND(weighted_agp_2year, 3) as avg_agp_2year,
  ROUND((weighted_agp_2year - weighted_agp_prepandemic) / weighted_agp_prepandemic * 100, 2) as weight_bias_pct,
  ROUND(prepandemic_weight_cv * 100, 2) as prepandemic_cv_pct,
  ROUND(twoyear_weight_cv * 100, 2) as twoyear_cv_pct
FROM weight_comparison
ORDER BY data_year;

-- How this query works:
-- 1. Creates a CTE to compute weighted statistics for AGP levels using both weight types
-- 2. Calculates coefficient of variation (CV) to assess weight dispersion
-- 3. Compares weighted averages between pre-pandemic and 2-year weights
-- 4. Groups results by year to show temporal changes
-- 5. Presents results with appropriate rounding for readability

-- Assumptions and limitations:
-- - Assumes weight values are properly calibrated for their respective time periods
-- - Non-null AGP values are required for meaningful comparisons
-- - Does not account for potential confounding factors in weight calculations
-- - Limited to available years in the dataset

-- Possible extensions:
-- 1. Add demographic stratification to weight analysis
-- 2. Include confidence intervals for weighted estimates
-- 3. Incorporate seasonal adjustments for weight comparisons
-- 4. Add quality control metrics for weight outliers
-- 5. Create visualization-ready output for trending analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:30:21.496680
    - Additional Notes: The query compares different sampling weight methodologies (pre-pandemic vs 2-year) to assess potential biases in AGP level estimates. Results are aggregated annually and include coefficient of variation metrics to evaluate sampling weight stability. Consider memory usage when working with large datasets as the query performs multiple aggregate calculations.
    
    */