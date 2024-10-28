
/*******************************************************************************
Title: NHANES Blood Pressure and Cholesterol Key Metrics Analysis

Business Purpose:
This query analyzes key metrics from the CDC NHANES survey data related to 
hypertension and cholesterol conditions, medication adherence, and age of diagnosis.
The insights help understand prevalence of these conditions and treatment patterns
in the US population.

Created: 2024-02-14
*******************************************************************************/

-- Main analysis of hypertension and cholesterol metrics
WITH base_metrics AS (
  SELECT
    -- Calculate key prevalence metrics  
    COUNT(*) as total_respondents,
    SUM(CASE WHEN bpq020 = 1 THEN 1 ELSE 0 END) as hypertension_count,
    SUM(CASE WHEN bpq080 = 1 THEN 1 ELSE 0 END) as high_cholesterol_count,
    
    -- Analyze medication patterns
    SUM(CASE WHEN bpq040a = 1 AND bpq050a = 1 THEN 1 ELSE 0 END) as taking_bp_meds,
    SUM(CASE WHEN bpq090d = 1 AND bpq100d = 1 THEN 1 ELSE 0 END) as taking_cholesterol_meds,
    
    -- Look at age of hypertension diagnosis
    AVG(CAST(bpd035 AS FLOAT)) as avg_age_at_diagnosis,
    MIN(CAST(bpd035 AS FLOAT)) as min_age_at_diagnosis,
    MAX(CAST(bpd035 AS FLOAT)) as max_age_at_diagnosis
  FROM mimi_ws_1.cdc.nhanes_qre_blood_pressure_cholesterol
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cdc.nhanes_qre_blood_pressure_cholesterol)
)

SELECT
  -- Calculate prevalence percentages
  total_respondents,
  hypertension_count,
  ROUND(100.0 * hypertension_count / total_respondents, 1) as hypertension_pct,
  high_cholesterol_count,
  ROUND(100.0 * high_cholesterol_count / total_respondents, 1) as high_cholesterol_pct,
  
  -- Calculate medication adherence 
  taking_bp_meds,
  ROUND(100.0 * taking_bp_meds / NULLIF(hypertension_count, 0), 1) as bp_med_adherence_pct,
  taking_cholesterol_meds,
  ROUND(100.0 * taking_cholesterol_meds / NULLIF(high_cholesterol_count, 0), 1) as chol_med_adherence_pct,
  
  -- Age statistics
  ROUND(avg_age_at_diagnosis, 1) as avg_age_diagnosed,
  min_age_at_diagnosis as youngest_diagnosed,
  max_age_at_diagnosis as oldest_diagnosed
FROM base_metrics;

/*******************************************************************************
How this query works:
1. Uses CTE to calculate base metrics from most recent survey data
2. Computes prevalence percentages for hypertension and high cholesterol
3. Analyzes medication adherence rates
4. Provides age-related statistics for hypertension diagnosis

Assumptions and Limitations:
- Uses only most recent survey data snapshot
- Assumes answers of 1 indicate "Yes" responses
- Does not account for NULL/missing values
- Age calculations assume valid numeric entries
- Does not segment by demographics

Possible Extensions:
1. Add demographic breakdowns (would need demographic data joined)
2. Trend analysis across multiple survey years
3. Geographic analysis if location data available
4. Correlation analysis with lifestyle factors
5. Risk factor analysis combining multiple conditions
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:35:16.616988
    - Additional Notes: Query focuses on latest survey data only and provides high-level population health metrics for hypertension and cholesterol conditions. Results include prevalence rates, medication adherence, and age-related statistics. Missing values and data quality issues should be investigated before using results for clinical decisions.
    
    */