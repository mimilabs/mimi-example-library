-- Title: Fasting Pattern Analysis for OGTT Test Scheduling
--
-- Business Purpose:
-- - Analyze patient fasting patterns to optimize OGTT test scheduling
-- - Identify optimal time slots for conducting OGTT tests
-- - Improve patient compliance and resource utilization
-- - Support operational efficiency in clinical settings

WITH fasting_patterns AS (
  -- Calculate fasting duration in decimal hours
  SELECT 
    CAST(phafsthr AS FLOAT) + (CAST(phafstmn AS FLOAT)/60) as total_fasting_hours,
    FLOOR(gtdscmmn/60) as test_hour,
    COUNT(*) as patient_count,
    -- Calculate compliance rate based on min 8 hours fasting requirement
    SUM(CASE WHEN phafsthr >= 8 THEN 1 ELSE 0 END) as compliant_count
  FROM mimi_ws_1.cdc.nhanes_lab_oral_glucose_tolerance_test
  WHERE phafsthr IS NOT NULL 
    AND gtdscmmn IS NOT NULL
  GROUP BY FLOOR(gtdscmmn/60), CAST(phafsthr AS FLOAT) + (CAST(phafstmn AS FLOAT)/60)
)

SELECT 
  test_hour,
  COUNT(*) as total_appointments,
  ROUND(AVG(total_fasting_hours), 1) as avg_fasting_hours,
  ROUND(SUM(compliant_count) * 100.0 / SUM(patient_count), 1) as compliance_rate_pct,
  -- Calculate earliest and latest fasting start times
  ROUND(MIN(total_fasting_hours), 1) as min_fasting_hours,
  ROUND(MAX(total_fasting_hours), 1) as max_fasting_hours
FROM fasting_patterns
GROUP BY test_hour
ORDER BY test_hour;

-- How the Query Works:
-- 1. Creates a CTE to calculate total fasting hours and group by test hour
-- 2. Determines compliance based on 8-hour minimum fasting requirement
-- 3. Aggregates statistics by test hour to show patterns
-- 4. Provides key metrics for scheduling optimization

-- Assumptions and Limitations:
-- - Assumes 8 hours as minimum fasting requirement
-- - Only includes records with non-null fasting times
-- - Test times are converted from minutes to hours
-- - Based on historical data patterns which may vary by facility

-- Possible Extensions:
-- 1. Add day-of-week analysis for more detailed scheduling patterns
-- 2. Include seasonal variations in fasting compliance
-- 3. Correlate with test completion success rates
-- 4. Add demographic factors to identify group-specific patterns
-- 5. Calculate optimal appointment slots based on compliance rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:25:29.304321
    - Additional Notes: The query focuses on operational scheduling optimization by analyzing fasting patterns. It assumes a standard 8-hour fasting requirement and only processes records with valid fasting times. Results can be used for resource allocation and appointment scheduling but should be validated against local clinical protocols.
    
    */