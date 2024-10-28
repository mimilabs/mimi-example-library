
/*******************************************************************************
Title: Hospital System Size and Teaching Status Analysis
 
Business Purpose:
This query analyzes the distribution of hospitals across health systems,
focusing on key indicators like bed capacity and teaching status. This helps:
1. Understand market concentration in healthcare delivery
2. Identify major teaching centers and their system affiliations
3. Support strategic planning and resource allocation decisions

Created: 2024-02
*******************************************************************************/

WITH system_metrics AS (
  -- Calculate key metrics for each health system
  SELECT 
    health_sys_id,
    health_sys_name,
    health_sys_state,
    COUNT(DISTINCT compendium_hospital_id) as total_hospitals,
    SUM(hos_beds) as total_beds,
    SUM(CASE WHEN hos_majteach = 1 THEN 1 ELSE 0 END) as teaching_hospitals,
    SUM(hos_dsch) as total_discharges
  FROM mimi_ws_1.ahrq.compendium_hospital_linkage
  WHERE health_sys_id IS NOT NULL
  GROUP BY health_sys_id, health_sys_name, health_sys_state
)

SELECT 
  health_sys_name,
  health_sys_state,
  total_hospitals,
  total_beds,
  teaching_hospitals,
  total_discharges,
  -- Calculate percentages for better context
  ROUND(teaching_hospitals * 100.0 / total_hospitals, 1) as pct_teaching,
  ROUND(total_beds * 1.0 / total_hospitals, 0) as avg_beds_per_hospital
FROM system_metrics
WHERE total_hospitals >= 3  -- Focus on multi-hospital systems
ORDER BY total_beds DESC
LIMIT 20;

/*******************************************************************************
How This Query Works:
1. Creates a CTE to aggregate hospital data at the health system level
2. Calculates key metrics including total facilities, beds, and teaching status
3. Filters for larger systems and ranks by total bed capacity
4. Adds derived metrics for better context and comparison

Assumptions & Limitations:
- Assumes health_sys_id is the primary identifier for health systems
- Missing or NULL values in key fields may affect calculations
- Teaching status is binary and may not capture all teaching arrangements
- Focuses only on systems with 3+ hospitals for meaningful comparison

Possible Extensions:
1. Add geographic analysis by incorporating city/state distributions
2. Include financial metrics like total revenue and uncompensated care
3. Add year-over-year comparison to track system growth
4. Incorporate quality metrics or patient outcomes
5. Add ownership type analysis to compare public vs private systems
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:30:43.499451
    - Additional Notes: This query prioritizes larger health systems (3+ hospitals) and may exclude smaller but significant healthcare providers. Teaching hospital calculations are based on the hos_majteach flag only and don't account for other teaching relationships. Revenue metrics are available but not included in this base analysis.
    
    */