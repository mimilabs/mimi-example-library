
/*******************************************************************************
Title: NHANES Air Quality Behavioral Response Analysis
 
Business Purpose:
- Analyze how people modify their behavior in response to poor air quality alerts
- Identify most common protective actions taken during poor air quality events
- Help inform public health messaging and intervention strategies
*******************************************************************************/

WITH response_counts AS (
  -- Calculate total respondents and those who changed behavior
  SELECT 
    COUNT(DISTINCT seqn) as total_respondents,
    COUNT(DISTINCT CASE WHEN paq685 = 1 THEN seqn END) as changed_behavior
  FROM mimi_ws_1.cdc.nhanes_qre_air_quality
),

behavior_types AS (
  -- Aggregate different types of behavioral changes
  SELECT
    SUM(CASE WHEN paq690a = 1 THEN 1 ELSE 0 END) as stayed_indoors,
    SUM(CASE WHEN paq690b = 1 THEN 1 ELSE 0 END) as limited_time_outside,
    SUM(CASE WHEN paq690c = 1 THEN 1 ELSE 0 END) as limited_physical_activity,
    SUM(CASE WHEN paq690d = 1 THEN 1 ELSE 0 END) as wore_mask,
    SUM(CASE WHEN paq690e = 1 THEN 1 ELSE 0 END) as used_air_filter,
    COUNT(DISTINCT seqn) as respondents_who_changed
  FROM mimi_ws_1.cdc.nhanes_qre_air_quality
  WHERE paq685 = 1
)

SELECT
  rc.total_respondents,
  rc.changed_behavior,
  ROUND(rc.changed_behavior * 100.0 / rc.total_respondents, 1) as pct_changed_behavior,
  
  -- Calculate percentages for each behavior type
  ROUND(bt.stayed_indoors * 100.0 / bt.respondents_who_changed, 1) as pct_stayed_indoors,
  ROUND(bt.limited_time_outside * 100.0 / bt.respondents_who_changed, 1) as pct_limited_time,
  ROUND(bt.limited_physical_activity * 100.0 / bt.respondents_who_changed, 1) as pct_limited_activity,
  ROUND(bt.wore_mask * 100.0 / bt.respondents_who_changed, 1) as pct_wore_mask,
  ROUND(bt.used_air_filter * 100.0 / bt.respondents_who_changed, 1) as pct_used_filter

FROM response_counts rc
CROSS JOIN behavior_types bt;

/*******************************************************************************
How this query works:
1. First CTE counts total respondents and those who changed behavior
2. Second CTE aggregates specific types of behavioral changes
3. Main query joins these together to calculate percentages

Assumptions & Limitations:
- Assumes paq685=1 indicates "yes" to behavior change
- Only analyzes a subset of possible behavioral responses
- Does not account for multiple responses per person
- No temporal analysis across survey cycles

Possible Extensions:
1. Add demographic breakdowns (if available through joins)
2. Analyze trends over time using mimi_src_file_date
3. Include additional behavior types (paq690f through paq690o)
4. Add geographic analysis if location data available
5. Cross-tabulate with health conditions data
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:07:12.195578
    - Additional Notes: Query provides baseline analysis of behavioral responses to air quality alerts using CDC NHANES data. Results show both overall response rates and breakdowns of specific protective actions taken. Note that percentage calculations are based only on valid responses and may not represent total population statistics.
    
    */