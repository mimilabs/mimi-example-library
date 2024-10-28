
/*******************************************************************************
Title: NHANES Lab Fasting Analysis - Basic Patient Preparation Compliance
 
Business Purpose:
This query analyzes patient compliance with pre-lab fasting requirements by:
- Calculating overall fasting durations
- Identifying consumption of substances that could affect lab results
- Providing insights into patient preparation behaviors before lab tests

This information helps:
1. Assess validity of lab results
2. Identify areas for improved patient education
3. Understand typical patient preparation patterns
*******************************************************************************/

WITH fasting_stats AS (
  -- Convert hours and minutes to total minutes for better comparison
  SELECT 
    seqn,
    -- Convert fasting time to total minutes
    COALESCE(phafsthr, 0) * 60 + COALESCE(phafstmn, 0) as total_fasting_minutes,
    
    -- Key substances consumed (1 = Yes, 2 = No)
    phq020 as had_coffee_or_tea,
    phq030 as had_alcohol,
    phq040 as had_cough_drops,
    phq050 as had_antacids,
    phq060 as had_supplements,
    
    -- Session timing
    phdsesn
  FROM mimi_ws_1.cdc.nhanes_lab_fasting_questionnaire
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cdc.nhanes_lab_fasting_questionnaire)
)

SELECT
  -- Calculate fasting compliance metrics
  COUNT(DISTINCT seqn) as total_patients,
  
  -- Standard fasting metrics
  ROUND(AVG(total_fasting_minutes)/60, 1) as avg_fasting_hours,
  ROUND(MIN(total_fasting_minutes)/60, 1) as min_fasting_hours,
  ROUND(MAX(total_fasting_minutes)/60, 1) as max_fasting_hours,
  
  -- Substance consumption rates
  ROUND(100.0 * COUNT(CASE WHEN had_coffee_or_tea = 1 THEN 1 END)/COUNT(*), 1) as pct_consumed_coffee_tea,
  ROUND(100.0 * COUNT(CASE WHEN had_alcohol = 1 THEN 1 END)/COUNT(*), 1) as pct_consumed_alcohol,
  ROUND(100.0 * COUNT(CASE WHEN had_cough_drops = 1 THEN 1 END)/COUNT(*), 1) as pct_consumed_cough_drops,
  ROUND(100.0 * COUNT(CASE WHEN had_antacids = 1 THEN 1 END)/COUNT(*), 1) as pct_consumed_antacids,
  ROUND(100.0 * COUNT(CASE WHEN had_supplements = 1 THEN 1 END)/COUNT(*), 1) as pct_consumed_supplements,
  
  -- Session distribution
  ROUND(100.0 * COUNT(CASE WHEN phdsesn = 1 THEN 1 END)/COUNT(*), 1) as pct_morning_session,
  ROUND(100.0 * COUNT(CASE WHEN phdsesn = 2 THEN 1 END)/COUNT(*), 1) as pct_afternoon_session
FROM fasting_stats

/*******************************************************************************
How this query works:
1. Creates a CTE to standardize fasting times into minutes
2. Calculates key metrics around fasting duration and substance consumption
3. Provides session timing distribution

Assumptions & Limitations:
- Uses most recent data file based on mimi_src_file_date
- Assumes coding of 1 = Yes, 2 = No for substance consumption
- Does not account for potential data quality issues or missing values
- Does not segment by demographics or other patient characteristics

Possible Extensions:
1. Add demographic breakdowns (if linked to demographic data)
2. Analyze seasonal or temporal trends using mimi_src_file_date
3. Create compliance thresholds based on lab test requirements
4. Add statistical tests for significant differences between sessions
5. Create patient risk categories based on consumption patterns
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:10:02.737936
    - Additional Notes: Query focuses on aggregate analysis of patient fasting behaviors and substance consumption prior to lab tests. Results are presented as percentages and averages, making it suitable for high-level reporting and trend analysis. Note that the query assumes consistent coding (1=Yes, 2=No) across all substance consumption fields and relies on the most recent data file based on mimi_src_file_date.
    
    */