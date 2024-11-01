-- Title: NHANES Adult Waist-to-Hip Analysis - Cardiometabolic Risk Assessment
-- Business Purpose: This query analyzes waist-to-hip ratios and related body measurements
-- to assess cardiometabolic risk factors in the adult population, supporting
-- preventive healthcare strategies and population health management initiatives.

WITH base_measurements AS (
    -- Filter for valid adult measurements
    SELECT 
        seqn,
        bmxwaist as waist_cm,
        bmxhip as hip_cm,
        bmxht as height_cm,
        bmxwt as weight_kg,
        bmxbmi as bmi,
        CASE 
            WHEN bmxwaist > 0 AND bmxhip > 0 
            THEN ROUND(bmxwaist / bmxhip, 2)
            ELSE NULL 
        END as waist_hip_ratio
    FROM mimi_ws_1.cdc.nhanes_exam_body_measures
    WHERE bmxwaist > 0 
    AND bmxhip > 0 
    AND bmxbmi > 0
)

SELECT 
    -- Calculate risk categories based on WHO guidelines
    CASE 
        WHEN waist_hip_ratio > 0.90 THEN 'High Risk'
        WHEN waist_hip_ratio BETWEEN 0.80 AND 0.90 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END as risk_category,
    
    -- Generate summary statistics
    COUNT(*) as population_count,
    ROUND(AVG(waist_hip_ratio), 3) as avg_whr,
    ROUND(AVG(waist_cm), 1) as avg_waist_cm,
    ROUND(AVG(hip_cm), 1) as avg_hip_cm,
    ROUND(AVG(bmi), 1) as avg_bmi,
    
    -- Calculate percentage of total
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_of_total

FROM base_measurements
GROUP BY 
    CASE 
        WHEN waist_hip_ratio > 0.90 THEN 'High Risk'
        WHEN waist_hip_ratio BETWEEN 0.80 AND 0.90 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END
ORDER BY 
    risk_category;

-- How this works:
-- 1. Creates a CTE with validated measurements for adults
-- 2. Calculates waist-to-hip ratio (WHR) for each individual
-- 3. Categorizes risk levels based on WHO guidelines
-- 4. Generates summary statistics by risk category
-- 5. Includes population distribution percentages

-- Assumptions and Limitations:
-- - Uses WHO guidelines for waist-to-hip ratio risk categories
-- - Excludes records with missing or zero measurements
-- - Does not differentiate by gender (which could be relevant for WHR thresholds)
-- - Assumes measurements are accurate and properly recorded

-- Possible Extensions:
-- 1. Add gender-specific risk categories
-- 2. Include age group stratification
-- 3. Add trend analysis across survey years
-- 4. Incorporate waist circumference absolute thresholds
-- 5. Add correlation with other health indicators
-- 6. Include geographical distribution of risk categories

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:09:17.411757
    - Additional Notes: The query focuses on waist-to-hip ratio as a key cardiometabolic risk indicator, using WHO standard thresholds. Consider adjusting risk thresholds (0.90) based on specific population characteristics or clinical guidelines. The analysis excludes records with zero/null measurements which may impact population-level statistics.
    
    */