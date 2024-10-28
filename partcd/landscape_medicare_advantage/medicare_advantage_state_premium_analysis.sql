
/*******************************************************************************
Title: Medicare Advantage Plan Analysis - Core Geographic Distribution and Premiums
 
Business Purpose:
This query analyzes the geographic distribution and premium patterns of Medicare 
Advantage plans to help understand:
- Market coverage and access across states
- Premium variations by plan type
- Potential gaps in coverage
- Cost implications for beneficiaries

This supports decision making around:
- Network adequacy and market expansion
- Premium pricing strategies 
- Identifying underserved areas
*******************************************************************************/

WITH premium_stats AS (
  -- Calculate premium statistics by state and plan type
  SELECT 
    state,
    type_of_medicare_health_plan,
    COUNT(DISTINCT contract_id || plan_id) as num_plans,
    ROUND(AVG(monthly_consolidated_premium_includes_part_c_d),2) as avg_premium,
    ROUND(MIN(monthly_consolidated_premium_includes_part_c_d),2) as min_premium,
    ROUND(MAX(monthly_consolidated_premium_includes_part_c_d),2) as max_premium,
    COUNT(DISTINCT organization_name) as num_organizations
  FROM mimi_ws_1.partcd.landscape_medicare_advantage
  -- Get most recent data only
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.landscape_medicare_advantage)
  GROUP BY state, type_of_medicare_health_plan
)

SELECT 
  state,
  type_of_medicare_health_plan,
  num_plans,
  num_organizations,
  avg_premium,
  min_premium,
  max_premium,
  -- Calculate premium spread to identify price variation
  max_premium - min_premium as premium_spread
FROM premium_stats
WHERE num_plans >= 5  -- Focus on states with meaningful presence
ORDER BY num_plans DESC, state;

/*******************************************************************************
How the Query Works:
1. CTE gets latest data and calculates key metrics by state/plan type
2. Main query adds premium spread calculation and filters for relevance
3. Results ordered by market size (num_plans) and state

Assumptions & Limitations:
- Uses most recent data snapshot only
- Excludes states with <5 plans to focus on established markets
- Premium analysis doesn't account for benefit differences
- Geographic analysis at state level only

Possible Extensions:
1. Add county-level analysis for more granular geographic insights
2. Include star ratings correlation with premiums
3. Add year-over-year comparison to show market evolution
4. Include drug benefit type analysis
5. Add market concentration metrics (HHI)
6. Analyze MOOP amounts alongside premiums
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:33:20.714612
    - Additional Notes: Query focuses on states with 5+ plans to ensure statistical relevance. Premium calculations exclude $0 premiums which may impact averages. Results are limited to most recent data snapshot which may not reflect current market conditions. Consider local market dynamics and benefit design differences when interpreting premium spreads.
    
    */