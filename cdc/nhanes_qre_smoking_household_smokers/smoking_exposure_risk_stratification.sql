-- Title: Secondhand Smoke Exposure Risk Assessment
--
-- Business Purpose:
-- This analysis helps public health officials and healthcare organizations:
-- 1. Identify households with high secondhand smoke exposure risk
-- 2. Quantify the gap between total smokers and indoor smokers
-- 3. Assess weekly indoor smoking frequency
-- The insights support targeted interventions and policy development.

WITH exposure_metrics AS (
    SELECT
        -- Calculate exposure risk indicators
        seqn,
        smd460 as total_smokers,
        smd470 as indoor_smokers,
        smd480 as days_smoked_last_week,
        
        -- Create risk categories
        CASE 
            WHEN smd470 > 0 AND smd480 >= 5 THEN 'High Risk'
            WHEN smd470 > 0 AND smd480 BETWEEN 1 AND 4 THEN 'Medium Risk'
            WHEN smd470 > 0 AND smd480 = 0 THEN 'Low Risk'
            ELSE 'No Indoor Exposure'
        END as exposure_risk_level,
        
        -- Calculate outdoor-only smokers
        (COALESCE(smd460, 0) - COALESCE(smd470, 0)) as outdoor_only_smokers
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    WHERE smd460 IS NOT NULL  -- Focus on valid responses
)

SELECT 
    exposure_risk_level,
    COUNT(*) as household_count,
    AVG(total_smokers) as avg_total_smokers,
    AVG(indoor_smokers) as avg_indoor_smokers,
    AVG(days_smoked_last_week) as avg_smoking_days,
    AVG(outdoor_only_smokers) as avg_outdoor_only_smokers,
    
    -- Calculate percentage distribution
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as pct_of_households
FROM exposure_metrics
GROUP BY exposure_risk_level
ORDER BY 
    CASE exposure_risk_level
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
        ELSE 4
    END;

-- How this query works:
-- 1. Creates exposure_metrics CTE to calculate key risk indicators
-- 2. Categorizes households into risk levels based on indoor smoking frequency
-- 3. Aggregates metrics by risk level with relevant averages
-- 4. Includes distribution analysis for population-level insights

-- Assumptions and Limitations:
-- 1. Risk levels are defined based on days of indoor smoking
-- 2. Null values in total_smokers are excluded
-- 3. Does not account for ventilation or home size
-- 4. Self-reported data may have inherent biases

-- Possible Extensions:
-- 1. Add temporal analysis using mimi_src_file_date
-- 2. Include specific tobacco product type analysis
-- 3. Create risk scores weighted by number of smokers and frequency
-- 4. Add geographical analysis if location data becomes available
-- 5. Compare against health outcome data for validation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:53:34.191755
    - Additional Notes: Query calculates household secondhand smoke risk levels based on indoor smoking frequency and total vs indoor smoker ratios. Risk categories (High/Medium/Low) are determined by the combination of indoor smokers presence and weekly smoking frequency. The analysis supports public health risk assessment but should be used in conjunction with other health indicators for comprehensive evaluation.
    
    */