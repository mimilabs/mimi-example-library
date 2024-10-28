
/*******************************************************************************
Title: Analysis of Cardiovascular Health Symptoms and Patient Behaviors
-------------------------------------------------------------------------------
Business Purpose:
This query analyzes key cardiovascular health indicators from the NHANES survey
to understand:
1. Prevalence of chest pain/discomfort in the population
2. Patient behavior when experiencing symptoms
3. Distribution of related symptoms like shortness of breath

This information helps identify population health risks and patient education needs.
*******************************************************************************/

WITH symptom_responses AS (
  -- Aggregate key cardiovascular symptoms and responses
  SELECT
    COUNT(*) as total_respondents,
    
    -- Chest pain prevalence
    SUM(CASE WHEN cdq001 = 1 THEN 1 ELSE 0 END) as chest_pain_count,
    ROUND(100.0 * SUM(CASE WHEN cdq001 = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as chest_pain_pct,
    
    -- Response to chest pain while walking
    SUM(CASE WHEN cdq004 = 1 THEN 1 ELSE 0 END) as stops_for_pain,
    SUM(CASE WHEN cdq004 = 2 THEN 1 ELSE 0 END) as slows_down_for_pain,
    
    -- Shortness of breath indicators
    SUM(CASE WHEN cdq010 = 1 THEN 1 ELSE 0 END) as sob_when_hurrying,
    SUM(CASE WHEN cdq020 = 1 THEN 1 ELSE 0 END) as sob_normal_pace,
    
    -- Severe symptoms
    SUM(CASE WHEN cdq008 = 1 THEN 1 ELSE 0 END) as severe_chest_pain_count,
    SUM(CASE WHEN cdq080 = 1 THEN 1 ELSE 0 END) as ankle_swelling_count
    
  FROM mimi_ws_1.cdc.nhanes_qre_cardiovascular_health
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cdc.nhanes_qre_cardiovascular_health)
)

SELECT
  total_respondents,
  
  -- Chest pain statistics
  chest_pain_count,
  chest_pain_pct as chest_pain_percentage,
  
  -- Patient behaviors
  ROUND(100.0 * stops_for_pain / NULLIF(chest_pain_count, 0), 1) as pct_who_stop_for_pain,
  ROUND(100.0 * slows_down_for_pain / NULLIF(chest_pain_count, 0), 1) as pct_who_slow_for_pain,
  
  -- Shortness of breath prevalence
  ROUND(100.0 * sob_when_hurrying / total_respondents, 1) as pct_sob_when_hurrying,
  ROUND(100.0 * sob_normal_pace / total_respondents, 1) as pct_sob_normal_pace,
  
  -- Severe symptoms
  ROUND(100.0 * severe_chest_pain_count / total_respondents, 1) as pct_severe_chest_pain,
  ROUND(100.0 * ankle_swelling_count / total_respondents, 1) as pct_ankle_swelling

FROM symptom_responses;

/*******************************************************************************
How this query works:
- Uses a CTE to first aggregate key cardiovascular symptoms and responses
- Calculates percentages for main symptoms and patient behaviors
- Filters for most recent data using mimi_src_file_date

Assumptions and Limitations:
- Assumes survey responses are representative of population
- Null responses are excluded from percentage calculations
- Only looks at most recent survey data
- Does not account for demographic factors

Possible Extensions:
1. Add demographic breakdowns (if available through joins)
2. Trend analysis across multiple survey periods
3. Cross-tabulation of symptoms (e.g., chest pain vs shortness of breath)
4. Geographic analysis if location data available
5. Risk scoring based on combination of symptoms
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:45:43.398926
    - Additional Notes: The query focuses on aggregating patient-reported cardiovascular symptoms from NHANES survey data, providing population-level insights into chest pain, shortness of breath, and related symptoms. Note that response codes (1=yes, 2=no) are hardcoded and should be verified against the actual CDC coding schema before use in production.
    
    */