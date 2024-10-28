
/*******************************************************************************
Title: Basic Analysis of Fasting Plasma Glucose Distribution and Diabetes Risk
 
Business Purpose:
- Analyze the distribution of fasting plasma glucose levels in the NHANES sample
- Identify prevalence of diabetes risk categories based on clinical guidelines
- Provide foundation for population health analysis and diabetes screening

Clinical Reference Values (mg/dL):
- Normal: < 100 
- Prediabetes: 100-125
- Diabetes: >= 126
*******************************************************************************/

WITH glucose_categories AS (
  SELECT 
    -- Categorize glucose levels based on clinical guidelines
    CASE 
      WHEN lbxglu < 100 THEN 'Normal'
      WHEN lbxglu BETWEEN 100 AND 125 THEN 'Prediabetes'  
      WHEN lbxglu >= 126 THEN 'Diabetes'
      ELSE 'Unknown'
    END AS glucose_category,
    
    -- Count records and basic stats
    COUNT(*) as sample_size,
    
    -- Calculate summary statistics
    ROUND(AVG(lbxglu), 1) as avg_glucose_mgdl,
    ROUND(MIN(lbxglu), 1) as min_glucose_mgdl,
    ROUND(MAX(lbxglu), 1) as max_glucose_mgdl,
    
    -- Get most recent data year
    MAX(YEAR(mimi_src_file_date)) as data_year
    
  FROM mimi_ws_1.cdc.nhanes_lab_plasma_fasting_glucose
  WHERE lbxglu IS NOT NULL
    AND phafsthr >= 8  -- Include only true fasting samples (≥8 hours)
  GROUP BY 
    CASE 
      WHEN lbxglu < 100 THEN 'Normal'
      WHEN lbxglu BETWEEN 100 AND 125 THEN 'Prediabetes'  
      WHEN lbxglu >= 126 THEN 'Diabetes'
      ELSE 'Unknown'
    END
)

SELECT
  glucose_category,
  sample_size,
  ROUND(100.0 * sample_size / SUM(sample_size) OVER(), 1) as percent_of_total,
  avg_glucose_mgdl,
  min_glucose_mgdl,
  max_glucose_mgdl,
  data_year
FROM glucose_categories
ORDER BY 
  CASE glucose_category
    WHEN 'Normal' THEN 1
    WHEN 'Prediabetes' THEN 2 
    WHEN 'Diabetes' THEN 3
    ELSE 4
  END;

/*******************************************************************************
How this query works:
1. Filters for valid fasting glucose readings (≥8 hours fasting)
2. Categorizes readings based on clinical guidelines
3. Calculates basic statistics and distribution for each category
4. Returns results ordered by risk level

Assumptions & Limitations:
- Uses standard clinical cutoffs for diabetes risk categories
- Requires proper fasting status (≥8 hours)
- Does not account for sampling weights
- Single test result only (clinical diagnosis requires confirmation)

Possible Extensions:
1. Add demographic analysis (age, gender, race/ethnicity)
2. Incorporate sampling weights for population-level estimates
3. Trend analysis across survey years
4. correlation analysis with insulin levels
5. Add confidence intervals for prevalence estimates
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:20:47.696919
    - Additional Notes: Query assumes 8-hour fasting threshold for valid samples. Results show raw sample counts rather than population-weighted estimates. Categories follow American Diabetes Association guidelines for fasting plasma glucose: Normal (<100 mg/dL), Prediabetes (100-125 mg/dL), and Diabetes (≥126 mg/dL).
    
    */