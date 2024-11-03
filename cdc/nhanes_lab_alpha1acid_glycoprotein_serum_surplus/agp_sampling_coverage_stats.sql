-- agp_level_sampling_coverage.sql
--
-- Business Purpose:
-- Assess the sampling coverage and data quality of Alpha-1-Acid Glycoprotein (AGP) measurements
-- across different time periods to validate the representativeness of the dataset for
-- population health studies and identify potential data collection gaps.

WITH sample_metrics AS (
    -- Calculate basic metrics about sample coverage
    SELECT 
        YEAR(mimi_src_file_date) as data_year,
        COUNT(seqn) as total_samples,
        COUNT(CASE WHEN ssagp IS NOT NULL THEN 1 END) as valid_agp_readings,
        COUNT(CASE WHEN wtssagpp IS NOT NULL THEN 1 END) as pre_pandemic_weighted_samples,
        COUNT(CASE WHEN wtssgp2y IS NOT NULL THEN 1 END) as two_year_weighted_samples,
        ROUND(AVG(ssagp), 3) as avg_agp_level,
        ROUND(STDDEV(ssagp), 3) as std_dev_agp
    FROM mimi_ws_1.cdc.nhanes_lab_alpha1acid_glycoprotein_serum_surplus
    GROUP BY YEAR(mimi_src_file_date)
)

SELECT 
    data_year,
    total_samples,
    valid_agp_readings,
    ROUND(100.0 * valid_agp_readings / total_samples, 1) as completeness_rate,
    pre_pandemic_weighted_samples,
    two_year_weighted_samples,
    avg_agp_level,
    std_dev_agp
FROM sample_metrics
ORDER BY data_year DESC;

-- How this query works:
-- 1. Groups data by year from source file date
-- 2. Calculates key metrics including sample counts and AGP statistics
-- 3. Computes completeness rate as percentage of valid readings
-- 4. Shows distribution of different weight types (pre-pandemic vs 2-year)
-- 5. Provides basic statistical measures for AGP levels

-- Assumptions and Limitations:
-- - Uses mimi_src_file_date as proxy for temporal analysis
-- - Assumes NULL values in ssagp represent missing measurements
-- - Does not account for potential sampling methodology changes
-- - Simple averages don't account for complex survey weights

-- Possible Extensions:
-- 1. Add seasonal analysis by including month granularity
-- 2. Compare weighted vs unweighted population estimates
-- 3. Add quality control metrics (e.g., out of range values)
-- 4. Include geographic distribution if available
-- 5. Analyze coverage by demographic subgroups
-- 6. Add trend analysis across consecutive periods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:29:20.639323
    - Additional Notes: Query focuses on data quality assessment through sampling rates and measurement completeness metrics. May need optimization if analyzing very large datasets due to multiple COUNT operations. Consider adding WHERE clauses to filter specific time periods if performance issues arise.
    
    */