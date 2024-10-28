
/* 
Core Based Statistical Areas Analysis - Geographic Hierarchy Overview
====================================================================

Business Purpose:
This query analyzes the hierarchical relationship between Core Based Statistical Areas (CBSAs),
Metropolitan Divisions, and Combined Statistical Areas (CSAs) to understand regional economic
and demographic patterns. This information is valuable for:
- Regional economic development planning
- Market analysis and business expansion decisions 
- Understanding population distribution and urbanization patterns
*/

-- Main Query
SELECT 
    -- Count distinct CBSAs and their classifications
    COUNT(DISTINCT cbsa_code) as total_cbsas,
    COUNT(DISTINCT CASE WHEN metropolitan_micropolitan_statistical_area = 'Metropolitan Statistical Area' 
          THEN cbsa_code END) as metro_areas,
    COUNT(DISTINCT CASE WHEN metropolitan_micropolitan_statistical_area = 'Micropolitan Statistical Area' 
          THEN cbsa_code END) as micro_areas,
    
    -- Count areas with higher-level groupings
    COUNT(DISTINCT CASE WHEN metropolitan_division_code IS NOT NULL 
          THEN cbsa_code END) as cbsas_with_metro_divisions,
    COUNT(DISTINCT CASE WHEN csa_code IS NOT NULL 
          THEN cbsa_code END) as cbsas_in_csas,
    
    -- Get latest data date for reference
    MAX(mimi_src_file_date) as data_as_of_date

FROM mimi_ws_1.census.cbsa_to_metro_div_csa;

/*
How This Query Works:
--------------------
1. Counts total unique CBSAs using cbsa_code
2. Breaks down CBSAs into Metropolitan vs Micropolitan areas
3. Identifies CBSAs that are part of larger Metropolitan Divisions or CSAs
4. Includes data date for context

Assumptions & Limitations:
-------------------------
- Assumes data completeness and accuracy in classification fields
- One CBSA can only belong to one CSA
- Metropolitan Divisions only exist within larger Metropolitan Statistical Areas

Possible Extensions:
-------------------
1. Add geographic analysis by state:
   - GROUP BY state_name to see distribution across states

2. Analyze CSA compositions:
   - Group by csa_code, csa_title to show number of component CBSAs

3. Include population data (if joined with demographic tables):
   - Compare populations across different statistical area types

4. Add time-based analysis:
   - Compare changes in classifications over time using mimi_src_file_date

5. Analyze county patterns:
   - Examine central vs outlying county distributions
   - Count counties per CBSA/CSA
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:59:02.006443
    - Additional Notes: Query provides a high-level statistical overview of Core Based Statistical Areas and their hierarchical relationships. Results show counts/ratios that indicate the degree of metropolitan development and regional integration across different geographic classifications. Best used for initial assessment of regional economic structures before more detailed analysis.
    
    */