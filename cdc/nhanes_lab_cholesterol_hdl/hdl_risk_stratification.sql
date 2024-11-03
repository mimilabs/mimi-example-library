-- hdl_cholesterol_risk_segmentation.sql
--
-- Business Purpose:
-- - Segment patient population into HDL cholesterol risk categories based on clinical guidelines
-- - Enable targeted intervention strategies for different risk groups
-- - Support population health management and resource allocation decisions
-- - Guide preventive care initiatives based on risk stratification

-- Main Query
WITH risk_segments AS (
  SELECT 
    -- Risk categorization based on HDL levels (mg/dL)
    CASE
      WHEN lbdhdd < 40 THEN 'High Risk'
      WHEN lbdhdd BETWEEN 40 AND 59 THEN 'Moderate Risk'
      WHEN lbdhdd >= 60 THEN 'Optimal'
      ELSE 'Unknown'
    END as risk_category,
    
    -- Count patients in each category
    COUNT(*) as patient_count,
    
    -- Calculate percentage of total
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage,
    
    -- Get average HDL level per category
    ROUND(AVG(lbdhdd), 1) as avg_hdl_level,
    
    -- Most recent data period
    MAX(mimi_src_file_date) as latest_data_period
  FROM mimi_ws_1.cdc.nhanes_lab_cholesterol_hdl
  WHERE lbdhdd IS NOT NULL
  GROUP BY 
    CASE
      WHEN lbdhdd < 40 THEN 'High Risk'
      WHEN lbdhdd BETWEEN 40 AND 59 THEN 'Moderate Risk'
      WHEN lbdhdd >= 60 THEN 'Optimal'
      ELSE 'Unknown'
    END
)
SELECT 
  risk_category,
  patient_count,
  ROUND(percentage, 1) as percentage,
  avg_hdl_level,
  latest_data_period
FROM risk_segments
ORDER BY 
  CASE risk_category
    WHEN 'High Risk' THEN 1
    WHEN 'Moderate Risk' THEN 2
    WHEN 'Optimal' THEN 3
    ELSE 4
  END;

-- How it works:
-- 1. Creates risk segments based on clinical HDL guidelines
-- 2. Calculates key metrics for each segment including patient counts and averages
-- 3. Computes percentage distribution across risk categories
-- 4. Orders results by risk severity for easy interpretation

-- Assumptions and Limitations:
-- - Risk categories based on standard clinical guidelines but may need adjustment
-- - Assumes data quality and completeness in source measurements
-- - Does not account for other cardiovascular risk factors
-- - Point-in-time analysis that may need periodic updates

-- Possible Extensions:
-- 1. Add demographic breakdowns within risk categories
-- 2. Include temporal trending of risk distributions
-- 3. Incorporate additional lab values for comprehensive risk assessment
-- 4. Add statistical significance testing between groups
-- 5. Create visualization-ready output for dashboard integration

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:03:10.590459
    - Additional Notes: Query defines HDL risk categories using standard clinical thresholds (<40 mg/dL: High Risk, 40-59 mg/dL: Moderate Risk, ≥60 mg/dL: Optimal). Results include population distribution and average HDL levels per risk category. Best used for initial population health screening and resource allocation planning.
    
    */