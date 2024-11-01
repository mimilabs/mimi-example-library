-- nhanes_insulin_fasting_analysis.sql
--
-- Business Purpose:
-- - Analyze the relationship between fasting duration and insulin levels
-- - Identify optimal fasting windows for insulin testing
-- - Support clinical protocol development for insulin measurement standardization
-- - Provide insights for patient preparation guidelines
--
-- This analysis helps healthcare providers optimize test timing and improves
-- the accuracy of insulin measurements in clinical settings.

WITH fasting_segments AS (
    -- Convert fasting time to total minutes and create meaningful segments
    SELECT 
        seqn,
        lbxin as insulin_level,
        (phafsthr * 60 + phafstmn) as total_fasting_minutes,
        CASE 
            WHEN (phafsthr * 60 + phafstmn) < 480 THEN 'Under 8 hours'
            WHEN (phafsthr * 60 + phafstmn) <= 720 THEN '8-12 hours'
            ELSE 'Over 12 hours'
        END as fasting_segment
    FROM mimi_ws_1.cdc.nhanes_lab_insulin
    WHERE lbxin IS NOT NULL 
    AND phafsthr IS NOT NULL
    AND phafstmn IS NOT NULL
)

SELECT 
    fasting_segment,
    COUNT(*) as sample_size,
    ROUND(AVG(insulin_level), 2) as avg_insulin_level,
    ROUND(STDDEV(insulin_level), 2) as std_dev_insulin,
    ROUND(MIN(insulin_level), 2) as min_insulin,
    ROUND(MAX(insulin_level), 2) as max_insulin,
    ROUND(PERCENTILE(insulin_level, 0.25), 2) as p25_insulin,
    ROUND(PERCENTILE(insulin_level, 0.5), 2) as median_insulin,
    ROUND(PERCENTILE(insulin_level, 0.75), 2) as p75_insulin,
    ROUND(AVG(total_fasting_minutes)/60, 1) as avg_fasting_hours
FROM fasting_segments
GROUP BY fasting_segment
ORDER BY 
    CASE fasting_segment 
        WHEN 'Under 8 hours' THEN 1
        WHEN '8-12 hours' THEN 2
        ELSE 3
    END;

-- How this query works:
-- 1. Creates fasting segments by converting hours and minutes to total minutes
-- 2. Categorizes fasting duration into clinically relevant segments
-- 3. Calculates key statistical measures for insulin levels within each segment
-- 4. Provides comprehensive view of insulin distribution by fasting duration

-- Assumptions and Limitations:
-- - Assumes fasting times are accurately reported
-- - Does not account for other factors affecting insulin (diet, medications)
-- - Limited to available fasting duration data
-- - Outliers are included in the analysis

-- Possible Extensions:
-- 1. Add trend analysis across multiple years
-- 2. Include demographic stratification
-- 3. Correlate with glucose levels
-- 4. Add quality control flags for extreme values
-- 5. Compare against clinical guidelines
-- 6. Add seasonal variation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:35:15.902115
    - Additional Notes: Query provides vital insights for clinical protocol development by analyzing the relationship between fasting duration and insulin levels. Note that the PERCENTILE function used requires Databricks Runtime 7.0 or higher. Consider modifying statistical calculations if using different SQL platforms.
    
    */