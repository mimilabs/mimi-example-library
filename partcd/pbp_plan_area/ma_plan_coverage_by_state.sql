
/*******************************************************************************
Title: Medicare Advantage Plan Service Area Analysis
 
Business Purpose:
This query analyzes the geographic distribution and coverage patterns of Medicare
Advantage plans to help understand:
- Where plans are operating
- Types of plans available in different regions
- Employer vs standard plan coverage differences
- Service area completeness across counties

This information helps stakeholders understand market penetration and identify
potential expansion opportunities.
*******************************************************************************/

-- Main Analysis Query
WITH plan_summary AS (
  -- Aggregate key metrics by plan and state
  SELECT 
    contract_id,
    plan_id,
    stcd AS state_code,
    pbp_a_plan_type AS plan_type,
    COUNT(DISTINCT county_code) AS counties_covered,
    SUM(CASE WHEN partial_flag = 'Y' THEN 1 ELSE 0 END) AS partial_counties,
    SUM(CASE WHEN eghp_flag = 'Y' THEN 1 ELSE 0 END) AS eghp_counties
  FROM mimi_ws_1.partcd.pbp_plan_area
  WHERE contract_year = 2023  -- Focus on current year
  GROUP BY 1,2,3,4
)

SELECT
  state_code,
  plan_type,
  COUNT(DISTINCT contract_id || plan_id) AS number_of_plans,
  AVG(counties_covered) AS avg_counties_per_plan,
  SUM(partial_counties) / SUM(counties_covered)::FLOAT AS partial_coverage_ratio,
  SUM(eghp_counties) / SUM(counties_covered)::FLOAT AS eghp_coverage_ratio
FROM plan_summary
GROUP BY 1,2
HAVING COUNT(DISTINCT contract_id || plan_id) > 5  -- Filter to states with meaningful presence
ORDER BY 1,2;

/*******************************************************************************
How it works:
1. Creates initial aggregation of county-level data by plan and state
2. Calculates key metrics about coverage patterns
3. Summarizes to state/plan-type level with ratio calculations
4. Filters to meaningful sample sizes and orders results

Assumptions & Limitations:
- Assumes current year data is complete and accurate
- Does not account for population density or market size
- Partial county coverage treated equally regardless of portion covered
- Limited to geographic analysis without cost/benefit considerations

Possible Extensions:
1. Add time series analysis to show coverage changes over years
2. Include plan benefit data to correlate coverage with services offered
3. Add geographic clustering analysis to identify expansion patterns
4. Compare coverage patterns between different organization types
5. Analyze relationship between partial coverage and market demographics
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:02:15.574200
    - Additional Notes: Query focuses on 2023 data only - update contract_year filter for different periods. Results are filtered to states with >5 plans to ensure statistical relevance. Coverage ratios may need adjustment based on business requirements for partial county definitions.
    
    */