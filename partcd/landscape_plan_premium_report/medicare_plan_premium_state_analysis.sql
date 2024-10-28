
/*******************************************************************************
Title: Medicare Advantage Plan Premium Analysis by State and Organization Type

Business Purpose:
This query analyzes Medicare Advantage plan premiums and ratings across states and 
organization types to help:
- Identify premium variations across regions
- Compare costs between organization types
- Assess plan quality through star ratings
- Support strategic planning and policy decisions

Created: 2024-02-20
*******************************************************************************/

WITH recent_plans AS (
  -- Get most recent data based on source file date
  SELECT * 
  FROM mimi_ws_1.partcd.landscape_plan_premium_report
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.partcd.landscape_plan_premium_report
  )
)

SELECT
  -- Geographic and organizational dimensions
  state,
  organization_type,
  
  -- Volume metrics
  COUNT(DISTINCT contract_id) as num_contracts,
  COUNT(DISTINCT plan_id) as num_plans,
  
  -- Premium analysis 
  ROUND(AVG(COALESCE(part_c_premium, 0)), 2) as avg_part_c_premium,
  ROUND(AVG(COALESCE(part_d_total_premium, 0)), 2) as avg_part_d_premium,
  
  -- Quality metrics
  ROUND(AVG(CAST(overall_star_rating as FLOAT)), 2) as avg_star_rating,
  
  -- Special plan indicators
  COUNT(CASE WHEN special_needs_plan = 'Yes' THEN 1 END) as num_special_needs_plans,
  COUNT(CASE WHEN extra_coverage_in_gap = 'Yes' THEN 1 END) as num_plans_with_gap_coverage

FROM recent_plans
GROUP BY 
  state,
  organization_type
HAVING 
  num_plans >= 5  -- Focus on states/org types with meaningful presence
ORDER BY 
  state,
  num_plans DESC

/*******************************************************************************
How it works:
1. CTE gets most recent data snapshot
2. Main query aggregates key metrics by state and organization type
3. Results filtered to show only groups with 5+ plans for significance
4. Output ordered by state and plan volume

Assumptions & Limitations:
- Uses most recent data snapshot only
- Treats NULL premiums as $0 for averaging
- Excludes small volume state/org type combinations
- Star ratings treated as numeric for averaging

Possible Extensions:
1. Add year-over-year premium trend analysis
2. Include county-level geographic detail
3. Add premium range metrics (min/max/stddev)
4. Compare against national averages
5. Add filters for specific plan types or benefits
6. Include market share analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:32:40.260991
    - Additional Notes: Query aggregates premium and quality metrics at state/organization level for Medicare Advantage plans. Filters for minimum 5 plans per group to ensure statistical relevance. Star rating averages should be interpreted with caution as they are ordinal values being treated as continuous for aggregation purposes.
    
    */