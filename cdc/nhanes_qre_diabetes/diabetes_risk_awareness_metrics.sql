-- diabetes_risk_awareness_analysis.sql --

-- Business Purpose:
-- Analyze patient awareness and self-perception of diabetes risk by examining:
-- 1. Correlation between doctor-identified risk factors and patient self-awareness
-- 2. Key reasons patients believe they are at risk
-- 3. Alignment between medical risk assessment and patient perception
-- This insight helps healthcare providers improve risk communication and early intervention strategies

-- Main Query
WITH risk_perception AS (
    SELECT
        -- Basic risk awareness metrics
        COUNT(*) as total_respondents,
        SUM(CASE WHEN diq170 = 1 THEN 1 ELSE 0 END) as doctor_identified_risk,
        SUM(CASE WHEN diq172 = 1 THEN 1 ELSE 0 END) as self_identified_risk,
        
        -- Calculate alignment between medical and self-perception
        SUM(CASE WHEN diq170 = 1 AND diq172 = 1 THEN 1 ELSE 0 END) as aligned_risk_perception,
        
        -- Key reasons for self-perceived risk (top 3 most common)
        SUM(CASE WHEN diq175a = 1 THEN 1 ELSE 0 END) as family_history_count,
        SUM(CASE WHEN diq175b = 1 THEN 1 ELSE 0 END) as overweight_count,
        SUM(CASE WHEN diq175c = 1 THEN 1 ELSE 0 END) as poor_diet_count
        
    FROM mimi_ws_1.cdc.nhanes_qre_diabetes
    WHERE diq170 IS NOT NULL 
      AND diq172 IS NOT NULL
)

SELECT
    total_respondents,
    doctor_identified_risk,
    self_identified_risk,
    aligned_risk_perception,
    
    -- Calculate key metrics as percentages
    ROUND(100.0 * doctor_identified_risk / total_respondents, 1) as pct_doctor_identified_risk,
    ROUND(100.0 * self_identified_risk / total_respondents, 1) as pct_self_identified_risk,
    ROUND(100.0 * aligned_risk_perception / doctor_identified_risk, 1) as pct_risk_perception_alignment,
    
    -- Rank top reasons for self-perceived risk
    ROUND(100.0 * family_history_count / self_identified_risk, 1) as pct_family_history,
    ROUND(100.0 * overweight_count / self_identified_risk, 1) as pct_overweight,
    ROUND(100.0 * poor_diet_count / self_identified_risk, 1) as pct_poor_diet

FROM risk_perception;

-- How the Query Works:
-- 1. Creates a CTE to aggregate basic risk awareness metrics
-- 2. Calculates total counts for doctor-identified and self-identified risk
-- 3. Determines alignment between medical assessment and self-perception
-- 4. Analyzes most common reasons for self-perceived risk
-- 5. Converts raw counts to percentages for easier interpretation

-- Assumptions and Limitations:
-- 1. Assumes NULL values indicate non-response rather than no risk
-- 2. Limited to explicit risk factors captured in survey
-- 3. Does not account for temporal changes in risk perception
-- 4. Self-reported data may have inherent biases

-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, etc.)
-- 2. Include analysis of preventive actions taken by at-risk individuals
-- 3. Compare risk perception with actual diabetes diagnosis outcomes
-- 4. Analyze regional variations in risk awareness
-- 5. Track changes in risk perception over survey years

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:20:27.455568
    - Additional Notes: Query focuses on quantifying the gap between clinical risk assessment and patient self-awareness of diabetes risk. Useful for patient education program planning and risk communication strategy development. Best run on complete annual datasets to avoid seasonal bias.
    
    */