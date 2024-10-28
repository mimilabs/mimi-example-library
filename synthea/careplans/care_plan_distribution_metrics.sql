
/*******************************************************************************
Care Plan Analysis - Distribution and Duration Overview
-------------------------------------------------------------------------------
Business Purpose: 
Analyze key patterns in care plan distribution and duration to help healthcare 
administrators understand:
1. Most common types of care plans prescribed
2. Average duration of different care plan types
3. Active vs completed care plans
This helps optimize resource allocation and improve care plan effectiveness.

Created: 2024-02-20
*******************************************************************************/

WITH care_plan_metrics AS (
  -- Calculate duration and status for each care plan
  SELECT 
    description as care_plan_type,
    -- Calculate duration in days
    AVG(DATEDIFF(COALESCE(stop, CURRENT_DATE()), start)) as avg_duration_days,
    -- Count total plans
    COUNT(*) as total_plans,
    -- Count active plans
    SUM(CASE WHEN stop IS NULL THEN 1 ELSE 0 END) as active_plans,
    -- Calculate completion rate
    ROUND(SUM(CASE WHEN stop IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as completion_rate
  FROM mimi_ws_1.synthea.careplans
  WHERE start IS NOT NULL 
  GROUP BY description
)

SELECT 
  care_plan_type,
  total_plans,
  active_plans,
  ROUND(avg_duration_days, 1) as avg_duration_days,
  completion_rate || '%' as completion_rate
FROM care_plan_metrics
WHERE total_plans >= 10  -- Filter for statistically relevant samples
ORDER BY total_plans DESC
LIMIT 10;

/*******************************************************************************
How This Query Works:
--------------------
1. Creates CTE to calculate key metrics for each care plan type
2. Aggregates data to show distribution and duration patterns
3. Filters for care plans with meaningful sample sizes
4. Orders by frequency to highlight most common care plans

Assumptions & Limitations:
-------------------------
- Assumes NULL stop date means care plan is still active
- Limited to care plans with at least 10 instances for statistical relevance
- Does not account for seasonal variations or patient demographics
- Duration calculation assumes linear progression

Possible Extensions:
-------------------
1. Add patient demographic analysis:
   - Age groups
   - Gender distribution
   - Geographic regions

2. Include temporal analysis:
   - Seasonal patterns
   - Year-over-year trends
   - Day-of-week patterns

3. Enhance with clinical outcomes:
   - Success rates by care plan type
   - Correlation with patient readmissions
   - Cost effectiveness analysis

4. Add provider analysis:
   - Care plan patterns by provider type
   - Facility-specific completion rates
   - Provider specialization impact
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:59:15.941701
    - Additional Notes: Query focuses on care plan types with 10+ instances to ensure statistical relevance. Active plans are determined by NULL stop dates, which may need adjustment based on specific business rules. Duration calculations use current date for ongoing plans, which may overstate durations for abandoned or incomplete records.
    
    */