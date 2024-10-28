
/* 
Title: Core Smoking Behavior Analysis from NHANES Survey Data

Business Purpose:
- Analyze key smoking behavior metrics from CDC NHANES survey data
- Identify smoking frequency patterns and nicotine dependency indicators
- Support public health research on tobacco use trends

Created: 2024-02-16
*/

WITH smoker_stats AS (
  -- Calculate core smoking metrics for active smokers
  SELECT 
    CAST(mimi_src_file_date AS DATE) as survey_period,
    COUNT(DISTINCT seqn) as total_respondents,
    
    -- Smoking prevalence
    AVG(CASE WHEN smq620 = 1 THEN 1 ELSE 0 END) as pct_ever_tried_smoking,
    AVG(CASE WHEN smq640 > 0 THEN 1 ELSE 0 END) as pct_smoked_last_30days,
    
    -- Consumption patterns
    AVG(CASE WHEN smq650 > 0 THEN smq650 ELSE NULL END) as avg_cigarettes_per_day,
    
    -- Early initiation
    AVG(CASE WHEN smd630 > 0 THEN smd630 ELSE NULL END) as avg_age_first_cigarette,
    
    -- Addiction indicators 
    AVG(CASE WHEN smq077 = 1 THEN 1 
             WHEN smq077 = 2 THEN 0.75
             WHEN smq077 = 3 THEN 0.5 
             WHEN smq077 = 4 THEN 0.25
             ELSE NULL END) as nicotine_dependency_score,
             
    -- Quit attempts
    AVG(CASE WHEN smq670 = 1 THEN 1 ELSE 0 END) as pct_attempted_quitting
    
  FROM mimi_ws_1.cdc.nhanes_qre_smoking_adult_recent_tobacco_use_youth_cigarettetobacco_use
  WHERE mimi_src_file_date IS NOT NULL
  GROUP BY CAST(mimi_src_file_date AS DATE)
)

SELECT
  survey_period,
  total_respondents,
  ROUND(pct_ever_tried_smoking * 100, 1) as pct_ever_tried_smoking,
  ROUND(pct_smoked_last_30days * 100, 1) as pct_current_smokers,
  ROUND(avg_cigarettes_per_day, 1) as avg_daily_cigarettes,
  ROUND(avg_age_first_cigarette, 1) as avg_age_first_cigarette,
  ROUND(nicotine_dependency_score * 100, 1) as dependency_score,
  ROUND(pct_attempted_quitting * 100, 1) as pct_tried_quitting
FROM smoker_stats
ORDER BY survey_period DESC;

/*
How this works:
1. Creates a CTE to calculate key smoking behavior metrics
2. Converts raw survey responses into meaningful percentages and averages
3. Presents results chronologically to show trends

Assumptions & Limitations:
- Relies on self-reported data which may have reporting bias
- Nicotine dependency score is simplified interpretation of time-to-first-cigarette
- Missing or refused responses are excluded from calculations
- Survey periods may not be consistently spaced

Possible Extensions:
1. Add demographic breakdowns (age groups, gender, etc)
2. Include analysis of specific cigarette brands and types
3. Compare smoking patterns with nicotine replacement therapy usage
4. Add statistical significance tests for trend analysis
5. Create visualizations of smoking behavior patterns over time
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:42:11.206250
    - Additional Notes: Query aggregates smoking behavior metrics across survey periods. The nicotine dependency score calculation (0.25-1.0 scale) is a simplified interpretation and may need adjustment based on specific research requirements. Consider adding survey weights for more accurate population-level estimates.
    
    */