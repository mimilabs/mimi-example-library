-- nhanes_insulin_temporal_trends.sql
--
-- Business Purpose:
-- - Track longitudinal changes in insulin levels across NHANES survey cycles
-- - Identify potential public health trends in metabolic health
-- - Support policy planning for diabetes prevention initiatives
-- - Evaluate effectiveness of public health interventions over time
--
-- The query analyzes year-over-year changes in insulin measurements
-- while accounting for sampling weights to ensure population representativeness

WITH yearly_stats AS (
    -- Extract year from file name and calculate weighted statistics
    SELECT 
        SUBSTR(mimi_src_file_name, 1, 4) AS survey_year,
        COUNT(DISTINCT seqn) as sample_size,
        -- Using weighted averages to account for survey design
        AVG(lbxin * wtsafprp) / AVG(wtsafprp) as weighted_mean_insulin,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lbxin) as median_insulin,
        -- Calculate proportion of high insulin (>25 uU/mL) as a marker of insulin resistance
        SUM(CASE WHEN lbxin > 25 THEN wtsafprp ELSE 0 END) / SUM(wtsafprp) * 100 as pct_high_insulin
    FROM mimi_ws_1.cdc.nhanes_lab_insulin
    WHERE lbxin IS NOT NULL 
        AND wtsafprp > 0
    GROUP BY SUBSTR(mimi_src_file_name, 1, 4)
)

SELECT 
    survey_year,
    sample_size,
    ROUND(weighted_mean_insulin, 2) as avg_insulin_uU_mL,
    ROUND(median_insulin, 2) as median_insulin_uU_mL,
    ROUND(pct_high_insulin, 1) as pct_high_insulin,
    -- Calculate year-over-year change
    ROUND(weighted_mean_insulin - LAG(weighted_mean_insulin) 
        OVER (ORDER BY survey_year), 2) as yoy_change
FROM yearly_stats
ORDER BY survey_year;

-- Notes on Query Operation:
-- 1. Extracts survey year from source file name
-- 2. Applies sampling weights (wtsafprp) for population representation
-- 3. Calculates key metrics: mean, median, and high insulin prevalence
-- 4. Computes year-over-year changes in population insulin levels

-- Assumptions and Limitations:
-- - Assumes file naming convention includes year information
-- - Requires valid sampling weights for accurate population estimates
-- - Does not account for changes in measurement methods across surveys
-- - High insulin threshold (25 uU/mL) is a simplified marker of insulin resistance

-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, ethnicity)
-- 2. Include confidence intervals for estimates
-- 3. Incorporate additional metabolic markers (glucose, HbA1c)
-- 4. Add seasonal analysis within years
-- 5. Compare trends against national diabetes prevalence data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:56:11.455841
    - Additional Notes: Query requires consistent file naming pattern in mimi_src_file_name column for accurate year extraction. The weighted average calculations depend on valid wtsafprp values. Consider adjusting the high insulin threshold (25 uU/mL) based on specific clinical guidelines or research requirements.
    
    */