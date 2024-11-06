-- nhanes_liver_health_population_insights.sql
-- Business Purpose: 
-- - Provide actionable insights into population liver health and metabolic risk
-- - Leverage NHANES biochemistry data to understand potential health vulnerabilities
-- - Support public health screening and risk stratification strategies

WITH liver_health_analysis AS (
    SELECT 
        -- Key demographics and health metric categorization
        seqn,
        lbxsatsi AS alt_level,
        lbxsal1 AS albumin_level,
        lbxsgl AS glucose_level,
        lbxsch1 AS cholesterol_level,
        
        -- Risk categorization logic for liver and metabolic health
        CASE 
            WHEN lbxsatsi > 50 THEN 'High Risk'
            WHEN lbxsatsi BETWEEN 30 AND 50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS alt_risk_category,
        
        CASE 
            WHEN lbxsal1 < 3.5 THEN 'Low Albumin'
            WHEN lbxsal1 BETWEEN 3.5 AND 5.0 THEN 'Normal'
            ELSE 'High Albumin'
        END AS albumin_status

    FROM mimi_ws_1.cdc.nhanes_lab_standard_biochemistry_profile
    WHERE 
        lbxsatsi IS NOT NULL 
        AND lbxsal1 IS NOT NULL
)

SELECT 
    alt_risk_category,
    albumin_status,
    COUNT(*) AS population_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_population,
    ROUND(AVG(alt_level), 2) AS avg_alt,
    ROUND(AVG(albumin_level), 2) AS avg_albumin,
    ROUND(AVG(glucose_level), 2) AS avg_glucose,
    ROUND(AVG(cholesterol_level), 2) AS avg_cholesterol

FROM liver_health_analysis
GROUP BY 
    alt_risk_category, 
    albumin_status
ORDER BY 
    population_count DESC
LIMIT 10;

-- Query Mechanics:
-- 1. Creates a CTE to calculate risk categories based on biochemistry markers
-- 2. Applies risk stratification logic for ALT and Albumin levels
-- 3. Aggregates population insights with percentage calculations
-- 4. Provides multi-dimensional view of liver and metabolic health risks

-- Assumptions and Limitations:
-- - Uses predefined thresholds for risk categorization
-- - Assumes data represents a representative population sample
-- - Limited by cross-sectional nature of NHANES data

-- Potential Query Extensions:
-- 1. Add age and gender stratification
-- 2. Compare risk profiles across different demographic groups
-- 3. Integrate with additional NHANES survey data for deeper insights

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:18:53.355415
    - Additional Notes: Provides multi-dimensional risk analysis for liver and metabolic health using NHANES biochemistry data. Includes risk categorization, population percentage calculations, and average marker levels. Requires careful interpretation of predefined risk thresholds.
    
    */