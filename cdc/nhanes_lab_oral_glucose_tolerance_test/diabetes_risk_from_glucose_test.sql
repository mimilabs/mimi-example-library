
/*******************************************************************************
Title: Basic Analysis of Glucose Tolerance Test Results
 
Business Purpose:
- Analyze oral glucose tolerance test (OGTT) results to assess diabetes risk
- Calculate distribution of 2-hour glucose levels to identify prediabetes/diabetes
- Evaluate completeness and quality of glucose tolerance testing 

Key metrics:
- 2-hour glucose levels (mg/dL)
- Test completion rates
- Fasting compliance
*******************************************************************************/

WITH glucose_categories AS (
  SELECT
    -- Categorize 2-hour glucose levels based on clinical thresholds
    CASE 
      WHEN lbxglt < 140 THEN 'Normal'
      WHEN lbxglt >= 140 AND lbxglt < 200 THEN 'Prediabetes' 
      WHEN lbxglt >= 200 THEN 'Diabetes'
      ELSE 'Unknown'
    END AS glucose_status,
    COUNT(*) as patient_count,
    
    -- Calculate average glucose and standard deviation
    AVG(lbxglt) as avg_glucose_mgdl,
    STDDEV(lbxglt) as stddev_glucose_mgdl,
    
    -- Test quality metrics
    AVG(gtdbl2mn) as avg_test_duration_min,
    SUM(CASE WHEN gtxdrank = 'All' THEN 1 ELSE 0 END) / COUNT(*) * 100 as complete_test_pct,
    AVG(phafsthr) as avg_fasting_hours
  
  FROM mimi_ws_1.cdc.nhanes_lab_oral_glucose_tolerance_test
  WHERE lbxglt IS NOT NULL -- Focus on valid measurements
  GROUP BY 1
)

SELECT
  glucose_status,
  patient_count,
  ROUND(patient_count * 100.0 / SUM(patient_count) OVER (), 1) as pct_of_total,
  ROUND(avg_glucose_mgdl, 1) as avg_glucose_mgdl,
  ROUND(stddev_glucose_mgdl, 1) as stddev_glucose_mgdl,
  ROUND(avg_test_duration_min, 1) as avg_test_duration_min,
  ROUND(complete_test_pct, 1) as complete_test_pct,
  ROUND(avg_fasting_hours, 1) as avg_fasting_hours
FROM glucose_categories
ORDER BY 
  CASE glucose_status 
    WHEN 'Normal' THEN 1
    WHEN 'Prediabetes' THEN 2 
    WHEN 'Diabetes' THEN 3
    ELSE 4
  END;

/*******************************************************************************
How this query works:
1. Creates categories based on standard glucose tolerance thresholds
2. Calculates key statistics per category including counts and averages
3. Computes quality metrics for test administration
4. Presents results ordered by clinical significance

Assumptions and Limitations:
- Uses standard clinical thresholds for diabetes classification
- Assumes null glucose values should be excluded
- Does not account for repeated tests per patient
- Does not consider demographic or other risk factors

Possible Extensions:
1. Add demographic breakdowns (requires joining with demographic data)
2. Trend analysis over time using mimi_src_file_date
3. Quality control analysis of test administration timing
4. Risk factor analysis incorporating other health metrics
5. Geographic distribution analysis if location data available
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:41:44.363762
    - Additional Notes: Query focuses on clinical glucose tolerance categories and test quality metrics. Note that the weight column (wtsog2yr) is not currently used in calculations, which may affect population-level estimates. Consider incorporating sample weights for more accurate prevalence estimates in the target population.
    
    */