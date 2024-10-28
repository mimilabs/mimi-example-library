
/*******************************************************************************
Title: Healthcare Access and Utilization Analysis
 
Business Purpose:
This query analyzes key patterns in healthcare utilization and access to care
using CDC NHANES survey data. It provides insights into:
- Overall health status of respondents
- Access to regular healthcare facilities 
- Frequency of healthcare visits
- Hospital utilization
*******************************************************************************/

WITH healthcare_metrics AS (
  -- Calculate core metrics around healthcare access and utilization
  SELECT 
    mimi_src_file_date AS survey_date,
    
    -- Health status distribution
    COUNT(*) as total_respondents,
    ROUND(AVG(CASE WHEN huq010 = 1 THEN 1 WHEN huq010 = 5 THEN 5 END),2) as avg_health_score,
    
    -- Healthcare access
    ROUND(SUM(CASE WHEN huq030 = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) as pct_with_usual_care,
    
    -- Visit frequency in past 12 months 
    ROUND(AVG(CAST(huq05_ AS INT)),1) as avg_visits_past_year,
    
    -- Hospital utilization
    ROUND(SUM(CASE WHEN huq07_ = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) as pct_hospitalized,
    
    -- Mental health visits
    ROUND(SUM(CASE WHEN huq090 = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),1) as pct_mental_health_visits

  FROM mimi_ws_1.cdc.nhanes_qre_hospital_utilization_access_to_care
  WHERE mimi_src_file_date IS NOT NULL
  GROUP BY mimi_src_file_date
)

SELECT
  survey_date,
  total_respondents,
  avg_health_score as avg_health_score_1to5,
  pct_with_usual_care as pct_have_usual_care_location,
  avg_visits_past_year,
  pct_hospitalized as pct_hospitalized_past_year,
  pct_mental_health_visits as pct_saw_mental_health_provider
FROM healthcare_metrics
ORDER BY survey_date;

/*******************************************************************************
How this query works:
1. Creates a CTE to calculate key healthcare metrics by survey date
2. Aggregates responses into meaningful percentages and averages
3. Returns final results sorted chronologically

Assumptions & Limitations:
- Assumes huq010 (health score) uses 1-5 scale where 1 is best
- Null values are excluded from calculations
- Self-reported data subject to recall bias
- Survey responses may not be nationally representative

Possible Extensions:
1. Add demographic breakdowns (if demographic fields available)
2. Compare metrics across different types of usual care facilities
3. Analyze seasonal patterns in healthcare utilization
4. Add statistical significance testing between time periods
5. Create visualizations of trends over time
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:46:41.048894
    - Additional Notes: Query aggregates CDC NHANES survey data to track key healthcare access metrics over time. Note that health score calculations assume 1=excellent and 5=poor on the survey scale. Results are most meaningful when comparing relative changes between survey periods rather than absolute values due to potential sampling and self-reporting biases.
    
    */