
/*******************************************************************************
Title: NHANES Body Measurements Analysis - Core Obesity Risk Indicators

Business Purpose:
This query analyzes key body measurement indicators from the NHANES dataset
to identify obesity prevalence and associated health risks in the US population.
Key metrics include BMI, waist circumference, and waist-to-height ratio which
are important predictors of metabolic health outcomes.

Created: 2024
*******************************************************************************/

WITH health_metrics AS (
  -- Calculate key health risk indicators
  SELECT
    seqn,
    bmxwt as weight_kg,
    bmxht as height_cm,
    bmxbmi as bmi,
    bmxwaist as waist_cm,
    -- Calculate waist-to-height ratio (key health risk indicator) 
    CASE 
      WHEN bmxht > 0 THEN ROUND(bmxwaist / bmxht, 3)
      ELSE NULL 
    END as waist_height_ratio,
    -- Categorize BMI into standard ranges
    CASE
      WHEN bmxbmi < 18.5 THEN 'Underweight'
      WHEN bmxbmi >= 18.5 AND bmxbmi < 25 THEN 'Normal'
      WHEN bmxbmi >= 25 AND bmxbmi < 30 THEN 'Overweight'
      WHEN bmxbmi >= 30 THEN 'Obese'
      ELSE 'Unknown'
    END as bmi_category
  FROM mimi_ws_1.cdc.nhanes_exam_body_measures
  WHERE bmxbmi IS NOT NULL
)

SELECT
  bmi_category,
  COUNT(*) as population_count,
  ROUND(AVG(bmi), 1) as avg_bmi,
  ROUND(AVG(waist_cm), 1) as avg_waist_cm,
  ROUND(AVG(waist_height_ratio), 3) as avg_waist_height_ratio,
  -- Calculate percentage within each BMI category
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) as population_percent
FROM health_metrics
GROUP BY bmi_category
ORDER BY 
  CASE bmi_category 
    WHEN 'Underweight' THEN 1
    WHEN 'Normal' THEN 2 
    WHEN 'Overweight' THEN 3
    WHEN 'Obese' THEN 4
    ELSE 5
  END;

/*******************************************************************************
How It Works:
1. CTE calculates key health metrics including BMI, waist circumference, and
   waist-to-height ratio for each individual
2. Main query aggregates data by BMI category to show population distribution
   and average measurements
3. Results ordered by BMI category severity

Assumptions & Limitations:
- Only includes records with valid BMI measurements
- Uses standard WHO BMI categories
- Doesn't account for age, gender, or ethnic differences in body composition
- Waist-to-height ratio > 0.5 generally indicates increased health risk

Possible Extensions:
1. Add demographic breakdowns (age groups, gender, ethnicity)
2. Include temporal trends if multiple survey years available
3. Add additional risk categories based on waist circumference thresholds
4. Calculate correlation between different body measurements
5. Add statistical significance tests between groups
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:25:24.843188
    - Additional Notes: The query focuses on primary obesity risk indicators and provides population-level statistics. Best used with complete NHANES datasets where BMI measurements are available. Consider adding demographic JOIN tables for more detailed analysis. The waist-to-height ratio calculation assumes measurements are in compatible units (centimeters).
    
    */