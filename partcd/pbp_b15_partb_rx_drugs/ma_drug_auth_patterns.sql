-- medicare_advantage_plan_authorization_patterns.sql

/*
Business Purpose: 
This query analyzes Medicare Advantage plans' authorization requirements and step therapy 
patterns for Part B prescription drugs. Understanding these utilization management practices 
helps:
1. Health plans benchmark their practices against market standards
2. Providers anticipate prior authorization needs
3. Pharmaceutical companies assess market access barriers
4. Policymakers evaluate access to medications
*/

WITH authorization_summary AS (
  -- Get the latest data for each plan based on version number
  SELECT 
    pbp_a_plan_type,
    orgtype,
    mrx_b_auth_yn,
    mrx_b_step_tpy_yn,
    mrx_b_stp_tpy_chk,
    COUNT(*) as plan_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total
  FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs
  WHERE version = (SELECT MAX(version) FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs)
  GROUP BY 
    pbp_a_plan_type,
    orgtype,
    mrx_b_auth_yn,
    mrx_b_step_tpy_yn,
    mrx_b_stp_tpy_chk
)

SELECT 
  pbp_a_plan_type as plan_type,
  orgtype as organization_type,
  mrx_b_auth_yn as requires_authorization,
  mrx_b_step_tpy_yn as has_step_therapy,
  mrx_b_stp_tpy_chk as step_therapy_details,
  plan_count,
  pct_of_total as percent_of_total_plans
FROM authorization_summary
WHERE plan_count > 5  -- Filter out very small segments
ORDER BY 
  plan_count DESC,
  pbp_a_plan_type,
  orgtype;

/*
How it works:
- Creates a summary table of authorization patterns using the latest version of plan data
- Groups plans by type, organization, and utilization management approaches
- Calculates both raw counts and percentages
- Filters out statistically insignificant segments
- Orders results by prevalence

Assumptions and Limitations:
- Uses only the latest version number for current patterns
- Assumes authorization fields are consistently populated
- Does not account for seasonal or geographical variations
- Minimum threshold of 5 plans may need adjustment based on market size

Possible Extensions:
1. Add temporal analysis to show authorization requirement trends over time
2. Include geographic breakdowns by state or region
3. Cross-reference with plan enrollment numbers to weight by market impact
4. Compare authorization patterns between different drug categories (chemo vs other)
5. Analyze correlation between authorization requirements and cost sharing structures
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:34:25.408335
    - Additional Notes: Query analyzes utilization management patterns in Medicare Advantage plans but does not account for regional variations or plan size. The minimum threshold of 5 plans should be adjusted based on the specific analysis needs and market size under consideration. Version filtering assumes the highest version number represents the most current data.
    
    */