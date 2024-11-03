-- nhanes_heart_disease_risk.sql

-- Business Purpose:
-- - Assess population cardiovascular disease risk by analyzing lipid profiles and key markers
-- - Support preventive cardiology screening programs with evidence-based thresholds
-- - Enable health systems to identify high-risk populations for targeted interventions
-- - Provide baseline data for public health initiatives focused on heart disease prevention

-- Main Analysis
WITH lipid_metrics AS (
  SELECT 
    -- Calculate average values and risk thresholds
    COUNT(DISTINCT seqn) as total_patients,
    
    -- Cholesterol metrics
    AVG(lbxsch1) as avg_total_cholesterol_mgdl,
    COUNT(CASE WHEN lbxsch1 >= 240 THEN 1 END) as high_cholesterol_count,
    
    -- Triglyceride metrics  
    AVG(lbxstr) as avg_triglycerides_mgdl,
    COUNT(CASE WHEN lbxstr >= 150 THEN 1 END) as high_triglycerides_count,
    
    -- Additional cardiovascular risk markers
    AVG(lbxsua1) as avg_uric_acid_mgdl,
    AVG(lbxsgl) as avg_glucose_mgdl,
    
    -- Calculate risk percentages
    ROUND(COUNT(CASE WHEN lbxsch1 >= 240 THEN 1 END) * 100.0 / COUNT(*), 1) as pct_high_cholesterol,
    ROUND(COUNT(CASE WHEN lbxstr >= 150 THEN 1 END) * 100.0 / COUNT(*), 1) as pct_high_triglycerides
    
  FROM mimi_ws_1.cdc.nhanes_lab_standard_biochemistry_profile
  WHERE lbxsch1 IS NOT NULL 
    AND lbxstr IS NOT NULL
)
SELECT
  total_patients,
  avg_total_cholesterol_mgdl,
  high_cholesterol_count,
  avg_triglycerides_mgdl, 
  high_triglycerides_count,
  avg_uric_acid_mgdl,
  avg_glucose_mgdl,
  pct_high_cholesterol,
  pct_high_triglycerides
FROM lipid_metrics;

-- How this works:
-- 1. Creates a CTE to calculate key cardiovascular risk metrics
-- 2. Uses clinical thresholds (cholesterol >= 240, triglycerides >= 150) to identify high-risk cases
-- 3. Calculates both raw counts and percentages for risk factors
-- 4. Includes related markers (uric acid, glucose) for comprehensive risk assessment

-- Assumptions and Limitations:
-- - Uses standard clinical thresholds for risk categorization
-- - Assumes measurements are taken in fasting state (especially for triglycerides)
-- - Does not account for patient demographics or other risk factors
-- - Missing values are excluded from analysis

-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, ethnicity)
-- 2. Include HDL/LDL ratio analysis when available
-- 3. Create risk scoring system combining multiple markers
-- 4. Add temporal trend analysis across survey years
-- 5. Incorporate blood pressure and other cardiovascular risk factors
-- 6. Add BMI/obesity correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:25:32.503959
    - Additional Notes: Query focuses on population-level cardiovascular risk screening using lipid profiles and metabolic markers. The analysis uses standard clinical thresholds but may need adjustment based on specific demographic factors or regional guidelines. Results should be interpreted alongside other cardiovascular risk factors not captured in this dataset.
    
    */