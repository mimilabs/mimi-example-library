
/*********************************************************************
Title: NHANES Smoking Behavior Analysis - Core Metrics

Business Purpose:
This query analyzes key smoking behavior metrics from the NHANES survey data to:
1. Assess smoking prevalence and patterns
2. Understand smoking initiation age and quit attempts
3. Provide baseline metrics for public health monitoring

These insights support public health initiatives and policy decisions around 
smoking prevention and cessation programs.
*********************************************************************/

WITH smoking_metrics AS (
  -- Calculate core smoking behavior metrics
  SELECT 
    -- Smoking status categories
    COUNT(*) as total_respondents,
    COUNT(CASE WHEN smq020 = 1 THEN 1 END) as ever_smoked_100,
    COUNT(CASE WHEN smq040 = 1 THEN 1 END) as current_smokers,
    COUNT(CASE WHEN smq040 = 2 THEN 1 END) as former_smokers,
    
    -- Age started smoking regularly 
    AVG(CASE WHEN smd030 > 0 THEN smd030 END) as avg_age_started,
    MIN(CASE WHEN smd030 > 0 THEN smd030 END) as min_age_started,
    MAX(CASE WHEN smd030 > 0 THEN smd030 END) as max_age_started,
    
    -- Current smoking intensity (cigarettes per day)
    AVG(CASE WHEN smd650 > 0 THEN smd650 END) as avg_cigs_per_day,
    
    -- Quit attempts
    COUNT(CASE WHEN smq670 = 1 THEN 1 END) as tried_quitting_last_12mo
    
  FROM mimi_ws_1.cdc.nhanes_qre_smoking_cigarette_use
)

SELECT
  -- Calculate percentages and format metrics
  total_respondents,
  ever_smoked_100,
  ROUND(100.0 * ever_smoked_100 / total_respondents, 1) as pct_ever_smoked,
  current_smokers,
  ROUND(100.0 * current_smokers / total_respondents, 1) as pct_current_smokers,
  former_smokers,
  ROUND(100.0 * former_smokers / total_respondents, 1) as pct_former_smokers,
  ROUND(avg_age_started, 1) as avg_age_started_smoking,
  min_age_started as youngest_age_started,
  max_age_started as oldest_age_started,
  ROUND(avg_cigs_per_day, 1) as avg_cigarettes_per_day,
  tried_quitting_last_12mo,
  ROUND(100.0 * tried_quitting_last_12mo / current_smokers, 1) as pct_attempted_quitting

FROM smoking_metrics;

/*********************************************************************
How this query works:
1. Creates a CTE to calculate base metrics from raw survey data
2. Computes key percentages and formats final output
3. Handles NULL values and zero cases appropriately

Assumptions and Limitations:
- Assumes survey responses are representative of population
- Self-reported data may have recall bias
- Missing or invalid responses are excluded from calculations
- Does not account for survey weights or complex sampling design

Possible Extensions:
1. Add demographic breakdowns (age groups, gender, etc.)
2. Include temporal trends across survey years
3. Analyze menthol vs non-menthol preferences
4. Compare quit success rates with attempt methods
5. Examine correlation with other health behaviors
*********************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:44:02.038224
    - Additional Notes: The query calculates core smoking behavior metrics including prevalence rates, age patterns, and quit attempts. Note that the results do not incorporate NHANES survey weights which are necessary for nationally representative estimates. Add survey weight calculations for official statistics.
    
    */