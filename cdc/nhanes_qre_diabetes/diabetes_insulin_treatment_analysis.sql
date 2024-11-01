-- Insulin_Treatment_Patterns.sql --

/********************************************************************************
Business Purpose: 
Analyze insulin treatment patterns among diabetes patients to identify:
1. Adoption rate of insulin therapy
2. Duration of insulin treatment
3. Relationship between age of diagnosis and insulin usage
4. Combination therapy patterns (insulin + oral medications)

This analysis helps healthcare providers and payers understand treatment pathways
and resource allocation needs for diabetes care.
********************************************************************************/

WITH insulin_stats AS (
  SELECT 
    -- Insulin usage flags
    COUNT(*) as total_patients,
    SUM(CASE WHEN diq050 = 1 THEN 1 ELSE 0 END) as insulin_users,
    
    -- Treatment combination analysis
    SUM(CASE WHEN diq050 = 1 AND did070 = 1 THEN 1 ELSE 0 END) as dual_therapy_users,
    
    -- Average age at diagnosis for insulin users
    AVG(CASE WHEN diq050 = 1 THEN CAST(did040 AS FLOAT) ELSE NULL END) as avg_age_insulin_users,
    
    -- Treatment duration patterns
    AVG(CASE WHEN diq050 = 1 THEN CAST(did060 AS FLOAT) ELSE NULL END) as avg_insulin_duration_years,
    
    -- Early vs late insulin adoption
    SUM(CASE WHEN diq050 = 1 AND did060 <= 1 THEN 1 ELSE 0 END) as early_insulin_users
  FROM mimi_ws_1.cdc.nhanes_qre_diabetes
  WHERE diq010 = 1  -- Confirmed diabetes diagnosis
)

SELECT
  total_patients,
  insulin_users,
  ROUND(100.0 * insulin_users / NULLIF(total_patients, 0), 1) as insulin_usage_pct,
  ROUND(100.0 * dual_therapy_users / NULLIF(insulin_users, 0), 1) as dual_therapy_pct,
  ROUND(avg_age_insulin_users, 1) as avg_diagnosis_age,
  ROUND(avg_insulin_duration_years, 1) as avg_treatment_years,
  ROUND(100.0 * early_insulin_users / NULLIF(insulin_users, 0), 1) as early_adoption_pct
FROM insulin_stats;

/*
How it works:
1. Filters for confirmed diabetes patients
2. Calculates key metrics around insulin usage
3. Derives percentages and averages for treatment patterns
4. Returns a single row with summary statistics

Assumptions and Limitations:
- Relies on self-reported data
- Does not account for temporary insulin use
- Treatment duration may be affected by recall bias
- Missing data is excluded from calculations

Possible Extensions:
1. Add temporal trends if multiple survey years are available
2. Segment by demographic factors
3. Include analysis of blood sugar control metrics
4. Compare outcomes between different treatment patterns
5. Add cost analysis if payment data is available
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:49:35.015852
    - Additional Notes: Query focuses exclusively on insulin therapy metrics while avoiding overlap with general diabetes prevalence analysis. The script requires the diq010 (diabetes diagnosis) and diq050 (insulin usage) columns to be populated for meaningful results. Consider row-level filtering for specific survey years if temporal analysis is needed.
    
    */