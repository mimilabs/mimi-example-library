-- Glycohemoglobin Measurement Trends Over Time
--
-- Business Purpose:
-- This query analyzes temporal patterns in glycohemoglobin measurements to identify
-- potential shifts in testing practices and population health monitoring over time.
-- Understanding these trends helps healthcare organizations optimize screening programs
-- and resource allocation for diabetes management.

WITH yearly_metrics AS (
    -- Calculate key statistics by year
    SELECT 
        YEAR(mimi_src_file_date) as measurement_year,
        COUNT(DISTINCT seqn) as total_participants,
        COUNT(lbxgh) as tests_performed,
        ROUND(AVG(lbxgh), 2) as avg_glycohemoglobin,
        ROUND(STDDEV(lbxgh), 2) as std_dev
    FROM mimi_ws_1.cdc.nhanes_lab_glycohemoglobin
    WHERE lbxgh IS NOT NULL
    GROUP BY YEAR(mimi_src_file_date)
),

year_over_year AS (
    -- Calculate year-over-year changes
    SELECT 
        measurement_year,
        total_participants,
        tests_performed,
        avg_glycohemoglobin,
        std_dev,
        ROUND(100.0 * (avg_glycohemoglobin - LAG(avg_glycohemoglobin) 
            OVER (ORDER BY measurement_year)) / LAG(avg_glycohemoglobin) 
            OVER (ORDER BY measurement_year), 1) as pct_change_from_prev_year
    FROM yearly_metrics
)

SELECT 
    measurement_year,
    total_participants,
    tests_performed,
    avg_glycohemoglobin,
    std_dev,
    pct_change_from_prev_year
FROM year_over_year
ORDER BY measurement_year;

-- How this query works:
-- 1. First CTE aggregates data by year to get basic statistics
-- 2. Second CTE calculates year-over-year percentage changes
-- 3. Final output presents the trends chronologically

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date accurately reflects measurement timeframes
-- - Does not account for potential changes in testing methodologies
-- - Year-over-year comparisons may be affected by sampling variations

-- Possible Extensions:
-- 1. Add seasonal analysis by including quarter/month breakdowns
-- 2. Include confidence intervals for the averages
-- 3. Add forecasting components for future trend predictions
-- 4. Compare trends against major public health initiatives or policy changes
-- 5. Break down trends by data source using mimi_src_file_name

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:58:59.274667
    - Additional Notes: Query focuses on longitudinal analysis of glycohemoglobin testing patterns and may require sufficient historical data (multiple years) in mimi_src_file_date for meaningful trend analysis. Performance may be impacted when processing large datasets due to window functions used for year-over-year calculations.
    
    */