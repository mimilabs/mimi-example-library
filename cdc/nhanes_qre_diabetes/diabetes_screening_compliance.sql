-- diabetes_complication_screening_patterns.sql --

-- Business Purpose:
-- Analyze diabetes complication screening and prevention patterns to:
-- 1. Evaluate adherence to recommended screening protocols
-- 2. Identify gaps in preventive care
-- 3. Track vision and foot care monitoring practices
-- 4. Support care quality improvement initiatives

WITH screening_metrics AS (
  -- Get base population with diabetes
  SELECT 
    COUNT(*) as total_diabetic_patients,
    
    -- Eye exam compliance
    SUM(CASE WHEN diq360 = 1 THEN 1 ELSE 0 END) as recent_eye_exam_count,
    
    -- Foot exam patterns 
    AVG(CAST(did34_ AS FLOAT)) as avg_foot_checks_per_year,
    
    -- Vision impact
    SUM(CASE WHEN diq080 = 1 THEN 1 ELSE 0 END) as retinopathy_count,
    
    -- Self-monitoring practices
    SUM(CASE WHEN did260 > 0 THEN 1 ELSE 0 END) as blood_sugar_self_monitor_count,
    
    -- Professional monitoring
    SUM(CASE WHEN diq275 = 1 THEN 1 ELSE 0 END) as a1c_monitored_count
    
  FROM mimi_ws_1.cdc.nhanes_qre_diabetes
  WHERE diq010 = 1 -- Confirmed diabetes diagnosis
)

SELECT
  total_diabetic_patients,
  
  -- Calculate screening compliance rates
  ROUND(100.0 * recent_eye_exam_count / total_diabetic_patients, 1) as pct_eye_exam_compliant,
  ROUND(avg_foot_checks_per_year, 1) as avg_annual_foot_checks,
  ROUND(100.0 * retinopathy_count / total_diabetic_patients, 1) as pct_with_retinopathy,
  ROUND(100.0 * blood_sugar_self_monitor_count / total_diabetic_patients, 1) as pct_self_monitoring,
  ROUND(100.0 * a1c_monitored_count / total_diabetic_patients, 1) as pct_a1c_monitored

FROM screening_metrics;

-- How this works:
-- 1. Creates base metrics for diabetic population using a CTE
-- 2. Calculates key screening and monitoring percentages
-- 3. Focuses on major complication prevention measures
-- 4. Returns summary statistics as percentages

-- Assumptions and Limitations:
-- - Relies on self-reported survey data
-- - Missing data treated as non-compliance
-- - Time periods may vary across measures
-- - No severity or risk stratification

-- Possible Extensions:
-- 1. Add temporal trends by mimi_src_file_date
-- 2. Segment by age groups or risk factors
-- 3. Cross-reference with medication usage
-- 4. Compare against published guidelines
-- 5. Add geographical analysis if location data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:41:38.275249
    - Additional Notes: Query is focused on population-level screening compliance rates rather than individual patient tracking. Results are best used for identifying broad patterns in preventive care practices and potential areas for intervention. Consider adding risk stratification or demographic segmentation for more targeted insights.
    
    */