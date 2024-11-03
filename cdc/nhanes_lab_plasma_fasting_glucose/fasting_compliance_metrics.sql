-- nhanes_glycemic_compliance_analysis.sql
-- 
-- Business Purpose:
-- - Evaluate patient compliance with fasting requirements for glucose testing
-- - Identify cases where fasting protocols may have been violated 
-- - Support quality assurance of laboratory testing procedures
-- - Enable more accurate analysis by filtering for truly fasted samples
--
-- Key metrics:
-- - Distribution of fasting times
-- - Identification of potentially non-compliant samples
-- - Impact of fasting duration on glucose measurements

WITH fasting_compliance AS (
    SELECT
        -- Round fasting duration to nearest hour for grouping
        FLOOR(phafsthr) as fasting_hours,
        -- Count samples in each fasting duration bucket
        COUNT(*) as sample_count,
        -- Calculate average glucose for each fasting duration
        AVG(lbxglu) as avg_glucose_mgdl,
        -- Flag potentially non-compliant samples (< 8 hours fasting)
        SUM(CASE WHEN phafsthr < 8 THEN 1 ELSE 0 END) as non_compliant_samples,
        -- Basic stats on glucose by fasting duration
        MIN(lbxglu) as min_glucose,
        MAX(lbxglu) as max_glucose
    FROM mimi_ws_1.cdc.nhanes_lab_plasma_fasting_glucose
    WHERE 
        -- Filter for valid glucose and fasting duration values
        lbxglu IS NOT NULL 
        AND phafsthr IS NOT NULL
        AND phafsthr > 0
        AND phafsthr <= 24  -- Remove unlikely fasting times
    GROUP BY FLOOR(phafsthr)
)

SELECT
    fasting_hours,
    sample_count,
    ROUND(avg_glucose_mgdl, 1) as avg_glucose_mgdl,
    non_compliant_samples,
    ROUND(min_glucose, 1) as min_glucose_mgdl,
    ROUND(max_glucose, 1) as max_glucose_mgdl,
    -- Calculate percentage of total samples
    ROUND(100.0 * sample_count / SUM(sample_count) OVER (), 1) as pct_of_samples
FROM fasting_compliance
ORDER BY fasting_hours;

-- Query Operation:
-- 1. Groups samples by fasting duration (rounded to nearest hour)
-- 2. Calculates key statistics for each fasting duration group
-- 3. Identifies potentially non-compliant samples
-- 4. Provides distribution analysis of fasting times
--
-- Assumptions and Limitations:
-- - Assumes fasting times are accurately reported
-- - Standard fasting requirement is typically 8-12 hours
-- - Extreme fasting times (>24 hours) are excluded as likely errors
-- - Does not account for other factors affecting glucose levels
--
-- Possible Extensions:
-- 1. Add comparison across different survey years
-- 2. Include demographic breakdowns of compliance
-- 3. Correlate compliance with insulin levels
-- 4. Add statistical tests for glucose differences by fasting duration
-- 5. Create risk-adjusted compliance metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:39:23.384880
    - Additional Notes: Query focuses on quality control aspects of glucose testing by analyzing fasting duration patterns. Particularly useful for data validation and identifying potential protocol violations that could affect study results. Consider adding error bounds or confidence intervals for more robust compliance reporting.
    
    */