/* NHANES Insulin Resistance Analysis and Metabolic Health Profiling 

Business Purpose:
- Analyze the relationship between fasting glucose and insulin levels to identify insulin resistance patterns
- Calculate key metabolic health indicators for population health analysis
- Support early identification of metabolic syndrome risk factors
- Provide insights for preventive care and intervention programs

Created: 2024-02-12
*/

WITH metabolic_indicators AS (
  SELECT 
    -- Calculate average values for each metric
    AVG(lbxglu) as avg_glucose_mgdl,
    AVG(lbxin1) as avg_insulin_uuml,
    -- Basic statistics for reference ranges
    PERCENTILE(lbxglu, 0.25) as glucose_25th_percentile,
    PERCENTILE(lbxglu, 0.75) as glucose_75th_percentile,
    PERCENTILE(lbxin1, 0.25) as insulin_25th_percentile,
    PERCENTILE(lbxin1, 0.75) as insulin_75th_percentile,
    -- Count of samples
    COUNT(*) as total_samples,
    -- Calculate approximate HOMA-IR distribution
    AVG((lbxglu * lbxin1) / 405) as avg_homa_ir
  FROM mimi_ws_1.cdc.nhanes_lab_plasma_fasting_glucose
  WHERE 
    -- Ensure we have valid glucose and insulin readings
    lbxglu IS NOT NULL 
    AND lbxin1 IS NOT NULL
    -- Filter for proper fasting status (at least 8 hours)
    AND phafsthr >= 8
),

risk_stratification AS (
  SELECT 
    CASE 
      WHEN (lbxglu * lbxin1) / 405 < 2 THEN 'Low IR Risk'
      WHEN (lbxglu * lbxin1) / 405 < 4 THEN 'Moderate IR Risk'
      ELSE 'High IR Risk'
    END as risk_category,
    COUNT(*) as population_count,
    AVG(lbxglu) as avg_glucose,
    AVG(lbxin1) as avg_insulin
  FROM mimi_ws_1.cdc.nhanes_lab_plasma_fasting_glucose
  WHERE 
    lbxglu IS NOT NULL 
    AND lbxin1 IS NOT NULL
    AND phafsthr >= 8
  GROUP BY 1
)

SELECT 
  m.*,
  r.risk_category,
  r.population_count,
  ROUND(r.population_count * 100.0 / m.total_samples, 1) as risk_category_percentage
FROM metabolic_indicators m
CROSS JOIN risk_stratification r
ORDER BY 
  CASE r.risk_category 
    WHEN 'Low IR Risk' THEN 1 
    WHEN 'Moderate IR Risk' THEN 2 
    ELSE 3 
  END;

/* How this query works:
1. First CTE calculates population-level metabolic indicators
2. Second CTE stratifies the population by insulin resistance risk
3. Final query combines both analyses for a comprehensive view

Assumptions and Limitations:
- Uses simplified HOMA-IR calculation (glucose * insulin / 405)
- Assumes 8+ hours fasting for valid measurements
- Does not account for medications or other confounding factors
- Risk categories are simplified for demonstration purposes

Possible Extensions:
1. Add demographic stratification (age groups, gender, etc.)
2. Include trend analysis across different NHANES cycles
3. Incorporate C-peptide analysis for beta cell function assessment
4. Add BMI correlation analysis if linked to demographic data
5. Create specific high-risk cohort identification logic

Note: HOMA-IR thresholds are simplified for illustration. Clinical 
applications should use validated thresholds for specific populations.
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:48:10.401016
    - Additional Notes: Query focuses on insulin resistance metrics and metabolic health profiling using HOMA-IR calculations. Requires minimum 8-hour fasting samples and valid glucose/insulin readings. Risk stratification thresholds are simplified and should be adjusted based on specific clinical guidelines for actual use. Query performance may be impacted with large datasets due to multiple percentile calculations.
    
    */