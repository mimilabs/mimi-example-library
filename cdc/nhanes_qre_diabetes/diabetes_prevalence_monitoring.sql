
-- Diabetes Diagnosis and Management Analysis
/*
Business Purpose:
This query analyzes key metrics around diabetes diagnosis, testing, and management from the
NHANES survey data to understand:
1. Prevalence of diabetes and prediabetes in the population
2. Age distribution of diabetes diagnosis
3. Blood sugar testing and monitoring practices
4. Overall diabetes risk assessment

This provides insights for public health planning and diabetes prevention programs.
*/

SELECT 
  -- Calculate overall diabetes statistics
  COUNT(*) as total_respondents,
  
  -- Diabetes diagnosis metrics
  ROUND(AVG(CASE WHEN diq010 = 1 THEN 100.0 ELSE 0 END),1) as pct_diagnosed_diabetes,
  ROUND(AVG(CASE WHEN diq160 = 1 THEN 100.0 ELSE 0 END),1) as pct_diagnosed_prediabetes,
  
  -- Average age of diagnosis
  ROUND(AVG(CASE WHEN did040 > 0 AND did040 < 90 THEN did040 END),1) as avg_age_at_diagnosis,
  
  -- Testing and monitoring
  ROUND(AVG(CASE WHEN diq180 = 1 THEN 100.0 ELSE 0 END),1) as pct_blood_sugar_test_3yr,
  ROUND(AVG(CASE WHEN diq275 = 1 THEN 100.0 ELSE 0 END),1) as pct_a1c_test_past_year,
  
  -- Treatment stats
  ROUND(AVG(CASE WHEN diq050 = 1 THEN 100.0 ELSE 0 END),1) as pct_taking_insulin,
  ROUND(AVG(CASE WHEN did070 = 1 THEN 100.0 ELSE 0 END),1) as pct_taking_diabetes_pills,
  
  -- Risk awareness
  ROUND(AVG(CASE WHEN diq172 = 1 THEN 100.0 ELSE 0 END),1) as pct_feel_at_risk

FROM mimi_ws_1.cdc.nhanes_qre_diabetes
WHERE seqn IS NOT NULL  -- Ensure valid respondent records only

/*
How the query works:
- Uses CASE statements to calculate percentages for yes/no responses
- Filters out invalid respondent IDs
- Rounds percentages to 1 decimal place for readability
- Aggregates across all valid responses

Assumptions & Limitations:
- Assumes response codes follow standard coding (1=Yes, 2=No)
- Missing or invalid responses are excluded from calculations
- Age values >90 are excluded as potential data quality issues
- Results represent survey sample, not full population

Possible Extensions:
1. Add demographic breakdowns (if demographics data available)
2. Trend analysis across survey years
3. Cross-tabulation with other health conditions
4. Geographic analysis of diabetes prevalence
5. Risk factor correlation analysis
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:24:11.433047
    - Additional Notes: Query averages may be impacted by survey non-response patterns. Consider adding weights from NHANES survey documentation for more accurate population-level estimates. Results should be interpreted as survey sample statistics rather than direct population estimates.
    
    */