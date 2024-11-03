-- nhanes_bp_cholesterol_prevention.sql
-- Business Purpose: Analyze preventive healthcare behaviors and early intervention patterns
-- among individuals who have not yet been diagnosed with hypertension or high cholesterol.
-- This insight helps identify opportunities for population health management and 
-- preventive care programs.

WITH preventive_metrics AS (
    SELECT 
        -- Calculate percentages of people taking preventive actions
        COUNT(*) as total_respondents,
        
        -- Blood pressure monitoring patterns
        SUM(CASE WHEN bpq010 = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_bp_check_6months,
        SUM(CASE WHEN bpq057 = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_borderline_hypertension,
        
        -- Early cholesterol awareness
        SUM(CASE WHEN bpq060 = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_ever_cholesterol_checked,
        
        -- Proactive lifestyle modifications
        SUM(CASE WHEN bpd110a = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_self_diet_changes,
        SUM(CASE WHEN bpd110b = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_self_weight_management,
        SUM(CASE WHEN bpd110c = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_self_exercise_increase

    FROM mimi_ws_1.cdc.nhanes_qre_blood_pressure_cholesterol
    -- Focus on those without diagnosed conditions
    WHERE bpq020 = '2'  -- No hypertension diagnosis
    AND bpq080 = '2'    -- No high cholesterol diagnosis
)

SELECT 
    total_respondents,
    ROUND(pct_bp_check_6months, 1) as pct_regular_bp_monitoring,
    ROUND(pct_borderline_hypertension, 1) as pct_pre_hypertension,
    ROUND(pct_ever_cholesterol_checked, 1) as pct_cholesterol_screening,
    ROUND(pct_self_diet_changes, 1) as pct_dietary_modification,
    ROUND(pct_self_weight_management, 1) as pct_weight_management,
    ROUND(pct_self_exercise_increase, 1) as pct_exercise_increase
FROM preventive_metrics;

/* How it works:
1. Filters for individuals without diagnosed conditions
2. Calculates percentages for various preventive health behaviors
3. Rounds results for readability
4. Provides a comprehensive view of prevention-oriented healthcare engagement

Assumptions and Limitations:
- Assumes accurate self-reporting of medical history and behaviors
- Limited to most recent survey period
- Does not account for demographic variations
- May not capture all forms of preventive health behaviors

Possible Extensions:
1. Add demographic stratification (age groups, gender, etc.)
2. Trend analysis across multiple survey periods
3. Geographic variation analysis
4. Correlation with social determinants of health
5. Risk stratification based on preventive behavior patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:50:42.953972
    - Additional Notes: Query specifically targets the pre-diagnosis population and their health behaviors, making it valuable for preventive healthcare program planning. Note that the percentages are calculated only for respondents without existing diagnoses, which should be considered when comparing results with other analyses of the same dataset.
    
    */