-- temporal_biomarker_trends_analysis.sql
-- Business Purpose: Analyze temporal trends in urine albumin and creatinine measurements 
-- to identify potential shifts in population kidney health markers over time.
-- This insight helps healthcare organizations:
-- 1. Plan preventive care programs
-- 2. Allocate resources for kidney disease management
-- 3. Benchmark their patient populations against national trends

WITH annual_stats AS (
    -- Calculate key statistics by year from source file dates
    SELECT 
        YEAR(mimi_src_file_date) as measurement_year,
        COUNT(DISTINCT seqn) as sample_size,
        -- Core biomarker averages
        AVG(urxuma1) as avg_albumin_ugml,
        AVG(urxucr1) as avg_creatinine_mgdl,
        AVG(urdact) as avg_albumin_creatinine_ratio,
        -- Data quality metrics
        COUNT(*) as total_measurements,
        SUM(CASE WHEN urxuma1 IS NOT NULL AND urxucr1 IS NOT NULL THEN 1 ELSE 0 END) as complete_measurements
    FROM mimi_ws_1.cdc.nhanes_lab_albumin_creatinine_urine
    WHERE mimi_src_file_date IS NOT NULL
    GROUP BY YEAR(mimi_src_file_date)
),
year_over_year_change AS (
    -- Calculate year-over-year changes
    SELECT 
        measurement_year,
        avg_albumin_ugml,
        avg_creatinine_mgdl,
        avg_albumin_creatinine_ratio,
        -- YoY changes as percentages
        (avg_albumin_ugml - LAG(avg_albumin_ugml) OVER (ORDER BY measurement_year)) / 
            LAG(avg_albumin_ugml) OVER (ORDER BY measurement_year) * 100 as albumin_yoy_change_pct,
        (avg_creatinine_mgdl - LAG(avg_creatinine_mgdl) OVER (ORDER BY measurement_year)) / 
            LAG(avg_creatinine_mgdl) OVER (ORDER BY measurement_year) * 100 as creatinine_yoy_change_pct,
        sample_size,
        (complete_measurements * 100.0 / total_measurements) as completion_rate
    FROM annual_stats
)

SELECT 
    measurement_year,
    sample_size,
    ROUND(avg_albumin_ugml, 2) as avg_albumin_ugml,
    ROUND(avg_creatinine_mgdl, 2) as avg_creatinine_mgdl,
    ROUND(avg_albumin_creatinine_ratio, 2) as avg_albumin_creatinine_ratio,
    ROUND(albumin_yoy_change_pct, 1) as albumin_yoy_change_pct,
    ROUND(creatinine_yoy_change_pct, 1) as creatinine_yoy_change_pct,
    ROUND(completion_rate, 1) as data_completion_rate_pct
FROM year_over_year_change
ORDER BY measurement_year;

-- How it works:
-- 1. First CTE (annual_stats) aggregates key measurements by year
-- 2. Second CTE (year_over_year_change) calculates temporal changes
-- 3. Final SELECT formats and presents the results with proper rounding

-- Assumptions and Limitations:
-- 1. Assumes mimi_src_file_date reflects actual measurement timeframes
-- 2. Does not account for demographic or geographic variations
-- 3. Simple averages may mask underlying distributions
-- 4. Year-over-year changes might be affected by sampling methodology changes

-- Possible Extensions:
-- 1. Add seasonal analysis by including month-level granularity
-- 2. Incorporate statistical significance testing for temporal changes
-- 3. Add demographic stratification to identify population-specific trends
-- 4. Include confidence intervals for the measurements
-- 5. Add outlier detection and handling logic

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:58:20.772029
    - Additional Notes: Query provides year-over-year trends of key kidney biomarkers with data quality metrics. Best used for long-term population health monitoring rather than short-term analysis due to potential data lag in source files. Performance may be impacted with very large datasets due to window functions.
    
    */