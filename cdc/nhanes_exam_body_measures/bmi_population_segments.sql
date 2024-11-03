-- Title: NHANES Body Mass Index Distribution Analysis - Population Health Stratification

-- Business Purpose: 
-- This query analyzes the distribution of BMI across the NHANES dataset to identify
-- key population health segments and support targeted intervention strategies.
-- The analysis helps healthcare organizations and public health officials understand
-- BMI patterns to inform resource allocation and program development.

WITH bmi_segments AS (
  -- Calculate BMI statistics and segment the population
  SELECT 
    CASE 
      WHEN bmxbmi < 18.5 THEN 'Underweight'
      WHEN bmxbmi >= 18.5 AND bmxbmi < 25 THEN 'Normal'
      WHEN bmxbmi >= 25 AND bmxbmi < 30 THEN 'Overweight'
      WHEN bmxbmi >= 30 AND bmxbmi < 35 THEN 'Obese Class I'
      WHEN bmxbmi >= 35 AND bmxbmi < 40 THEN 'Obese Class II'
      WHEN bmxbmi >= 40 THEN 'Obese Class III'
    END AS bmi_category,
    COUNT(*) as population_count,
    ROUND(AVG(bmxbmi), 2) as avg_bmi,
    ROUND(MIN(bmxbmi), 2) as min_bmi,
    ROUND(MAX(bmxbmi), 2) as max_bmi,
    ROUND(STDDEV(bmxbmi), 2) as std_dev_bmi
  FROM mimi_ws_1.cdc.nhanes_exam_body_measures
  WHERE bmxbmi IS NOT NULL 
    AND bmxbmi > 0 
    AND bmxbmi < 100  -- Exclude extreme outliers
  GROUP BY 
    CASE 
      WHEN bmxbmi < 18.5 THEN 'Underweight'
      WHEN bmxbmi >= 18.5 AND bmxbmi < 25 THEN 'Normal'
      WHEN bmxbmi >= 25 AND bmxbmi < 30 THEN 'Overweight'
      WHEN bmxbmi >= 30 AND bmxbmi < 35 THEN 'Obese Class I'
      WHEN bmxbmi >= 35 AND bmxbmi < 40 THEN 'Obese Class II'
      WHEN bmxbmi >= 40 THEN 'Obese Class III'
    END
)

-- Calculate population distribution and statistics
SELECT
  bmi_category,
  population_count,
  ROUND(100.0 * population_count / SUM(population_count) OVER (), 2) as percentage_of_total,
  avg_bmi,
  min_bmi,
  max_bmi,
  std_dev_bmi
FROM bmi_segments
ORDER BY 
  CASE bmi_category
    WHEN 'Underweight' THEN 1
    WHEN 'Normal' THEN 2
    WHEN 'Overweight' THEN 3
    WHEN 'Obese Class I' THEN 4
    WHEN 'Obese Class II' THEN 5
    WHEN 'Obese Class III' THEN 6
  END;

-- How this query works:
-- 1. Creates a CTE to segment the population based on standard BMI categories
-- 2. Calculates key statistics for each segment including count, average, min, max, and standard deviation
-- 3. Computes the percentage distribution across segments
-- 4. Orders results in a clinically meaningful sequence

-- Assumptions and Limitations:
-- - BMI values between 0 and 100 are considered valid
-- - Standard WHO BMI categories are used for segmentation
-- - The analysis does not account for age, gender, or ethnic variations in BMI interpretation
-- - Missing or null BMI values are excluded from the analysis

-- Possible Extensions:
-- 1. Add temporal analysis to track BMI distribution changes over time
-- 2. Include demographic stratification (age groups, gender, ethnicity)
-- 3. Incorporate waist circumference for more refined health risk assessment
-- 4. Add year-over-year comparison to identify trends
-- 5. Include confidence intervals for population estimates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:55:38.237751
    - Additional Notes: This query focuses on population-level BMI distribution analysis, providing a foundation for public health surveillance. Note that it excludes records with null or extreme BMI values (>100), which might affect population estimates in certain segments. For clinical applications, additional validation of BMI thresholds and inclusion of age-specific criteria may be needed.
    
    */