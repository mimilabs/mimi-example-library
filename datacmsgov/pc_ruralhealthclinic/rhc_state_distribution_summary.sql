
/*************************************************************************
Title: Rural Health Clinic Geographic Distribution and Organization Analysis
 
Business Purpose:
This query analyzes the geographic distribution and organizational characteristics 
of Rural Health Clinics (RHCs) enrolled in Medicare to help:
- Identify areas that may be underserved
- Understand the types of organizations providing rural healthcare
- Support healthcare access planning and policy decisions
**************************************************************************/

WITH state_summary AS (
  -- Get counts and percentages by state
  SELECT 
    state,
    COUNT(*) as rhc_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_of_total,
    COUNT(CASE WHEN proprietary_nonprofit = 'P' THEN 1 END) as proprietary_count,
    COUNT(CASE WHEN proprietary_nonprofit = 'N' THEN 1 END) as nonprofit_count,
    COUNT(DISTINCT organization_type_structure) as unique_org_types,
    -- Get most common org type
    FIRST(organization_type_structure) as most_common_org_type
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic
  GROUP BY state
)

SELECT
  state,
  rhc_count,
  pct_of_total as pct_of_total_rhcs,
  proprietary_count,
  nonprofit_count,
  ROUND(proprietary_count * 100.0 / rhc_count, 1) as pct_proprietary,
  unique_org_types,
  most_common_org_type
FROM state_summary
WHERE state IS NOT NULL
ORDER BY rhc_count DESC;

/*
How this works:
1. Creates a CTE to aggregate key metrics by state
2. Calculates counts of RHCs, proprietary vs nonprofit status
3. Computes percentages and basic org type metrics
4. Orders results by total RHC count to show states with most coverage first

Assumptions & Limitations:
- Assumes current enrollment data is representative of actual RHC distribution
- Does not account for population size or rural geography of states
- Only shows count of unique org types and most common type
- Null state values are excluded

Possible Extensions:
1. Add population data to calculate RHCs per capita
2. Include geographic coordinates for mapping
3. Analyze trends over time using incorporation_date
4. Compare urban vs rural zip code distributions
5. Add detailed breakdowns of organization types using subqueries
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:35:28.159144
    - Additional Notes: The query provides a state-level overview of Rural Health Clinics focusing on key metrics like total count, ownership type (proprietary vs nonprofit), and organizational structure. The FIRST() function used for most_common_org_type will return an arbitrary value if multiple organization types have the same frequency. For time-based analysis, consider using incorporation_date from the source table.
    
    */