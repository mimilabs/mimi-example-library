
/*******************************************************************************
Title: NHANES Kidney Conditions Prevalence Analysis
 
Business Purpose:
This query analyzes the prevalence of key kidney conditions and treatments among
NHANES survey participants. It provides insights into:
- Overall kidney condition rates
- Dialysis treatment rates
- Kidney stone occurrence
- Urgency of kidney health interventions
*******************************************************************************/

WITH kidney_stats AS (
  SELECT
    -- Calculate prevalence of different kidney conditions
    COUNT(*) as total_respondents,
    
    -- Weak/failing kidneys
    SUM(CASE WHEN kiq022 = 1 THEN 1 ELSE 0 END) as kidney_condition_count,
    ROUND(100.0 * SUM(CASE WHEN kiq022 = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as kidney_condition_pct,
    
    -- Dialysis treatment 
    SUM(CASE WHEN kiq025 = 1 THEN 1 ELSE 0 END) as dialysis_count,
    ROUND(100.0 * SUM(CASE WHEN kiq025 = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as dialysis_pct,
    
    -- History of kidney stones
    SUM(CASE WHEN kiq026 = 1 THEN 1 ELSE 0 END) as kidney_stones_count,
    ROUND(100.0 * SUM(CASE WHEN kiq026 = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as kidney_stones_pct,
    
    -- Recent kidney stone passage
    SUM(CASE WHEN kiq029 = 1 THEN 1 ELSE 0 END) as recent_stones_count,
    ROUND(100.0 * SUM(CASE WHEN kiq029 = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) as recent_stones_pct
    
  FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions
  WHERE kiq022 IS NOT NULL  -- Filter for valid responses
)

SELECT
  total_respondents as Total_Survey_Respondents,
  
  -- Kidney condition statistics
  kidney_condition_count as Count_Weak_Failing_Kidneys,
  kidney_condition_pct as Pct_with_Weak_Failing_Kidneys,
  
  -- Dialysis statistics
  dialysis_count as Count_Received_Dialysis,
  dialysis_pct as Pct_Received_Dialysis,
  
  -- Kidney stone statistics
  kidney_stones_count as Count_History_of_Kidney_Stones, 
  kidney_stones_pct as Pct_with_Kidney_Stone_History,
  recent_stones_count as Count_Recent_Kidney_Stones,
  recent_stones_pct as Pct_with_Recent_Kidney_Stones
  
FROM kidney_stats;

/*******************************************************************************
How this query works:
1. Creates a CTE to calculate counts and percentages for key kidney conditions
2. Uses CASE statements to count positive responses (1 = Yes)
3. Calculates percentages by dividing counts by total respondents
4. Presents results in a clear summary format

Assumptions and Limitations:
- Assumes response code 1 indicates "Yes" for condition questions
- Null responses are excluded from analysis
- Does not segment by demographics or time periods
- Does not account for survey weights or complex sampling design

Possible Extensions:
1. Add demographic breakdowns (age groups, gender, ethnicity)
2. Trend analysis across survey years using mimi_src_file_date
3. Cross-tabulation with other health conditions
4. Geographic analysis if location data available
5. Risk factor analysis incorporating other NHANES tables
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:01:17.668691
    - Additional Notes: This query provides summary statistics of kidney conditions from NHANES survey data, calculating prevalence rates for major kidney health indicators. Note that the analysis uses raw counts without applying NHANES survey weights, which may affect the representativeness of the results for the general population. Consider adding survey weight adjustments for more accurate population-level estimates.
    
    */