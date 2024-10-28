
/*************************************************************************
Title: NHANES Recent Tobacco Use Analysis - Core Usage Patterns
 
Business Purpose:
- Analyze patterns of recent tobacco use across different product types
- Identify frequency and intensity of tobacco consumption
- Provide baseline metrics for public health assessments

Created: 2024
*************************************************************************/

-- Main analysis of recent tobacco product usage patterns
WITH tobacco_users AS (
  SELECT 
    seqn,
    -- Identify if used any tobacco in past 5 days
    CASE WHEN smq68_ = 1 THEN 'Yes' 
         WHEN smq68_ = 2 THEN 'No'
         ELSE 'Unknown' END as used_tobacco_past_5days,
    
    -- Calculate cigarette consumption
    CASE WHEN smq710 BETWEEN 1 AND 5 THEN smq710 ELSE NULL END as days_smoked_cigarettes,
    COALESCE(smq720, 0) as avg_cigarettes_per_day,
    
    -- Identify other tobacco product usage
    CASE WHEN smq690b = 1 THEN 1 ELSE 0 END as used_pipe,
    CASE WHEN smq690c = 1 THEN 1 ELSE 0 END as used_cigars,
    CASE WHEN smq690h = 1 THEN 1 ELSE 0 END as used_ecigarettes,
    CASE WHEN smq851 = 1 THEN 1 ELSE 0 END as used_smokeless
  FROM mimi_ws_1.cdc.nhanes_qre_smoking_recent_tobacco_use
)

SELECT
  -- Calculate overall usage statistics
  COUNT(DISTINCT seqn) as total_respondents,
  SUM(CASE WHEN used_tobacco_past_5days = 'Yes' THEN 1 ELSE 0 END) as tobacco_users,
  ROUND(100.0 * SUM(CASE WHEN used_tobacco_past_5days = 'Yes' THEN 1 ELSE 0 END) / 
        COUNT(DISTINCT seqn), 1) as pct_tobacco_users,

  -- Analyze cigarette consumption patterns  
  AVG(CASE WHEN days_smoked_cigarettes > 0 THEN days_smoked_cigarettes END) as avg_days_smoked,
  AVG(CASE WHEN avg_cigarettes_per_day > 0 THEN avg_cigarettes_per_day END) as avg_cigarettes_per_day,

  -- Calculate product type breakdown
  SUM(used_pipe) as pipe_users,
  SUM(used_cigars) as cigar_users, 
  SUM(used_ecigarettes) as ecigarette_users,
  SUM(used_smokeless) as smokeless_users,

  -- Calculate multi-product usage
  AVG(used_pipe + used_cigars + used_ecigarettes + used_smokeless) as avg_products_per_user
FROM tobacco_users;

/*
How this query works:
1. Creates CTE to standardize key tobacco use indicators
2. Calculates overall usage statistics and patterns
3. Provides breakdown by product type
4. Identifies multi-product usage patterns

Assumptions & Limitations:
- Self-reported data may have reporting biases
- Missing values are excluded from averages
- Recent 5-day usage may not represent long-term patterns
- Survey weights not applied

Possible Extensions:
1. Add demographic breakdowns (age, gender, etc.)
2. Trend analysis across survey years
3. Cross-tabulation with health outcomes
4. Geographic analysis of usage patterns
5. More detailed analysis of dual/multi-product use
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:07:02.727920
    - Additional Notes: Query provides core tobacco usage metrics from NHANES survey data. Note that survey weights are not applied, which may impact population-level estimates. For accurate population-level statistics, the query should be modified to incorporate NHANES survey weights. The 5-day recall period may not fully represent long-term tobacco use patterns.
    
    */