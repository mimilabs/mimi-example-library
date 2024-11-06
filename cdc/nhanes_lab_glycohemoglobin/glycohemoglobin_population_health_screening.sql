-- Healthcare Population Glycohemoglobin Screening Analytics

-- Business Purpose:
-- Provide a strategic overview of glycohemoglobin measurement distribution
-- to support population health management, risk stratification, and 
-- potential preventive healthcare interventions.

WITH glyco_stats AS (
    SELECT 
        COUNT(*) as total_measurements,
        ROUND(AVG(lbxgh), 2) as mean_glycohemoglobin,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY lbxgh), 2) as median_glycohemoglobin,
        ROUND(MIN(lbxgh), 2) as min_glycohemoglobin,
        ROUND(MAX(lbxgh), 2) as max_glycohemoglobin,
        ROUND(STDDEV(lbxgh), 2) as std_dev_glycohemoglobin
    FROM mimi_ws_1.cdc.nhanes_lab_glycohemoglobin
),

risk_categorization AS (
    SELECT 
        CASE 
            WHEN lbxgh < 5.7 THEN 'Normal'
            WHEN lbxgh BETWEEN 5.7 AND 6.4 THEN 'Prediabetes'
            WHEN lbxgh >= 6.5 THEN 'Diabetes Risk'
        END as risk_category,
        COUNT(*) as category_count,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM mimi_ws_1.cdc.nhanes_lab_glycohemoglobin), 2) as category_percentage
    FROM mimi_ws_1.cdc.nhanes_lab_glycohemoglobin
    GROUP BY risk_category
)

SELECT 
    gs.*,
    rc.risk_category,
    rc.category_count,
    rc.category_percentage
FROM glyco_stats gs
CROSS JOIN risk_categorization rc
ORDER BY rc.category_percentage DESC;

-- Query Execution Overview:
-- 1. Calculates comprehensive glycohemoglobin statistical summary
-- 2. Segments population into clinical risk categories
-- 3. Provides percentage distribution across risk levels

-- Assumptions:
-- - Standard clinical glycohemoglobin risk thresholds used
-- - All measurements considered equally valid
-- - No demographic filtering applied

-- Potential Extensions:
-- 1. Add time-based trend analysis
-- 2. Incorporate demographic segmentation
-- 3. Compare against national health benchmarks

-- Business Insights:
-- Enables quick population health risk assessment
-- Supports preventive care strategy development
-- Provides snapshot of glycemic health status

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:24:03.824068
    - Additional Notes: Uses standard clinical thresholds for risk categorization. Requires careful interpretation as a snapshot of health measurement data without demographic context.
    
    */