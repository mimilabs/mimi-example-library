
/*******************************************************************************
Title: NHANES Asthma Analysis - Core Patient Statistics
 
Business Purpose:
- Analyze the prevalence and characteristics of asthma among survey participants
- Understand diagnosis timing, current status, and recent episodes
- Identify high-risk populations and health care utilization patterns
*******************************************************************************/

WITH asthma_patients AS (
  -- Get base asthma diagnosis information
  SELECT
    seqn, 
    mcq010 AS has_asthma_diagnosis,
    mcq02_ AS age_at_diagnosis,
    mcq03_ AS still_has_asthma,
    mcq040 AS had_episode_12mo,
    mcq050 AS had_er_visit_12mo,
    mcq300b AS family_history_asthma,
    agq030 AS had_hay_fever_12mo
  FROM mimi_ws_1.cdc.nhanes_qre_medical_conditions
  WHERE mcq010 IS NOT NULL
)

-- Calculate key asthma metrics
SELECT
  -- Overall prevalence
  COUNT(*) as total_patients,
  ROUND(100.0 * COUNT(CASE WHEN has_asthma_diagnosis = 1 THEN 1 END) / COUNT(*), 1) as pct_with_asthma,
  
  -- Current status among diagnosed
  ROUND(100.0 * COUNT(CASE WHEN still_has_asthma = 1 THEN 1 END) / 
        NULLIF(COUNT(CASE WHEN has_asthma_diagnosis = 1 THEN 1 END), 0), 1) as pct_still_have_asthma,
  
  -- Recent episodes and healthcare utilization  
  ROUND(100.0 * COUNT(CASE WHEN had_episode_12mo = 1 THEN 1 END) /
        NULLIF(COUNT(CASE WHEN still_has_asthma = 1 THEN 1 END), 0), 1) as pct_with_recent_episode,
  
  ROUND(100.0 * COUNT(CASE WHEN had_er_visit_12mo = 1 THEN 1 END) /
        NULLIF(COUNT(CASE WHEN still_has_asthma = 1 THEN 1 END), 0), 1) as pct_with_er_visit,
        
  -- Associated conditions
  ROUND(100.0 * COUNT(CASE WHEN family_history_asthma = 1 THEN 1 END) /
        NULLIF(COUNT(CASE WHEN has_asthma_diagnosis = 1 THEN 1 END), 0), 1) as pct_with_family_history,
        
  ROUND(100.0 * COUNT(CASE WHEN had_hay_fever_12mo = 1 THEN 1 END) /
        NULLIF(COUNT(CASE WHEN has_asthma_diagnosis = 1 THEN 1 END), 0), 1) as pct_with_hay_fever,
        
  -- Average age at diagnosis
  ROUND(AVG(CASE WHEN has_asthma_diagnosis = 1 THEN age_at_diagnosis END), 1) as avg_age_at_diagnosis
  
FROM asthma_patients;

/*******************************************************************************
How this query works:
1. Creates CTE with relevant asthma fields from source table
2. Calculates percentages for key asthma metrics
3. Handles nulls using NULLIF to avoid division by zero
4. Rounds results to 1 decimal place for readability

Assumptions and Limitations:
- Assumes binary responses (1=Yes) for condition flags
- Missing/invalid responses are excluded from percentage calculations  
- Cross-sectional snapshot - doesn't show trends over time
- Self-reported data subject to recall bias

Possible Extensions:
1. Add demographic breakdowns (age, gender, race/ethnicity)
2. Analyze seasonal patterns in asthma episodes
3. Compare asthma rates across different survey years
4. Investigate correlations with other medical conditions
5. Map geographic variations in prevalence
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:12:29.967725
    - Additional Notes: Query calculates core asthma statistics from NHANES survey data including overall prevalence, current status, healthcare utilization, and comorbidities. Results show population-level percentages with null handling. Requires access to NHANES medical conditions table and assumes standard CDC coding for binary responses (1=Yes).
    
    */