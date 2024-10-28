
/*******************************************************************************
Title: Health System Home Health Organization Network Analysis
 
Business Purpose:
- Analyze distribution and characteristics of home health organizations within health systems
- Provide insights into healthcare delivery network structure and coverage
- Support strategic planning for health system partnerships and service expansion

Created: 2024
*******************************************************************************/

-- Main query analyzing home health organization distribution across health systems
WITH health_sys_summary AS (
  SELECT 
    health_sys_name,
    health_sys_state,
    -- Count distinct types of home health organizations
    COUNT(DISTINCT compendium_hh_id) as total_hh_orgs,
    COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home health' THEN compendium_hh_id END) as home_health_count,
    COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'hospice' THEN compendium_hh_id END) as hospice_count,
    COUNT(DISTINCT home_health_care_org_state) as states_served
  FROM mimi_ws_1.ahrq.compendium_homehealth_linkage
  WHERE health_sys_name IS NOT NULL
  GROUP BY health_sys_name, health_sys_state
)

SELECT
  health_sys_name,
  health_sys_state,
  total_hh_orgs,
  home_health_count,
  hospice_count,
  states_served,
  -- Calculate service mix percentages
  ROUND(home_health_count * 100.0 / total_hh_orgs, 1) as pct_home_health,
  ROUND(hospice_count * 100.0 / total_hh_orgs, 1) as pct_hospice
FROM health_sys_summary
-- Focus on health systems with significant home health presence
WHERE total_hh_orgs >= 5
ORDER BY total_hh_orgs DESC
LIMIT 20;

/*******************************************************************************
How This Query Works:
1. Creates summary metrics for each health system using a CTE
2. Calculates counts of different organization types and geographic reach
3. Computes percentage breakdown of services
4. Filters to show larger networks and sorts by total organizations

Assumptions & Limitations:
- Focuses only on health systems with 5+ home health organizations
- Assumes current/active status for all organizations
- Does not account for organization size or patient volume
- Geographic analysis limited to state level

Possible Extensions:
1. Add temporal analysis using mimi_src_file_date
2. Include geographic density analysis using ZIP codes
3. Incorporate corporate parent relationships
4. Add quality metrics or patient outcome data if available
5. Analyze urban vs rural distribution of services
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:49:00.887253
    - Additional Notes: Query provides top 20 health systems by home health network size. Results are filtered to systems with 5+ organizations to focus on significant networks. Organizations without health system affiliations are excluded. Geographic analysis is state-level only and does not account for population density or market coverage.
    
    */