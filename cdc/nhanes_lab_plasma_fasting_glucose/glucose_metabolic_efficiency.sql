-- nhanes_glucose_insulin_efficiency.sql
--
-- Business Purpose: 
-- - Evaluate population-level glucose and insulin homeostasis patterns
-- - Identify metabolic abnormalities indicating glucose regulation issues
-- - Support public health strategies targeting metabolic health improvement
--
-- Core query using glucose/insulin ratio as a basic metabolic efficiency indicator

WITH base_metrics AS (
    SELECT
        -- Calculate baseline metrics
        seqn,
        lbxglu as glucose_mgdl,
        lbxin1 as insulin_uuml,
        wtsafprp as sample_weight,
        -- Basic glucose/insulin ratio - higher values suggest better insulin sensitivity
        CASE 
            WHEN lbxin1 > 0 THEN lbxglu / lbxin1
            ELSE NULL 
        END as glucose_insulin_ratio
    FROM mimi_ws_1.cdc.nhanes_lab_plasma_fasting_glucose
    WHERE 
        -- Ensure valid glucose and insulin readings
        lbxglu IS NOT NULL 
        AND lbxin1 IS NOT NULL
        AND lbxglu > 0 
        AND lbxin1 > 0
)

SELECT
    -- Generate population-level efficiency metrics
    COUNT(*) as total_samples,
    
    -- Basic statistics for glucose/insulin ratio
    ROUND(AVG(glucose_insulin_ratio), 2) as avg_gi_ratio,
    ROUND(STDDEV(glucose_insulin_ratio), 2) as std_gi_ratio,
    
    -- Metabolic efficiency categories
    ROUND(100.0 * SUM(CASE WHEN glucose_insulin_ratio > 10 THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_high_efficiency,
    ROUND(100.0 * SUM(CASE WHEN glucose_insulin_ratio < 5 THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_low_efficiency,
        
    -- Key glucose metrics
    ROUND(AVG(glucose_mgdl), 1) as avg_glucose_mgdl,
    ROUND(AVG(insulin_uuml), 1) as avg_insulin_uuml

FROM base_metrics

-- Query Implementation Notes:
-- 1. Uses glucose/insulin ratio as a simplified metabolic efficiency indicator
-- 2. Filters out invalid/missing measurements
-- 3. Provides both raw averages and categorical breakdowns
-- 4. Incorporates basic sample validation
--
-- Assumptions and Limitations:
-- - Assumes fasting status is properly recorded
-- - Does not account for medication effects
-- - Simplified efficiency metrics may not capture all metabolic complexity
-- - Sample weights not applied in this basic version
--
-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, ethnicity)
-- 2. Include temporal trends across survey years
-- 3. Incorporate more sophisticated metabolic indices (HOMA-IR, etc.)
-- 4. Add confidence intervals using sample weights
-- 5. Compare against clinical reference ranges

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:38:30.795767
    - Additional Notes: Query focuses on population-level metabolic efficiency using glucose-to-insulin ratios as a proxy measure. Sample weights should be incorporated for more accurate population estimates. Cutoff values for efficiency categories (5 and 10) are simplified thresholds and may need adjustment based on clinical guidelines.
    
    */