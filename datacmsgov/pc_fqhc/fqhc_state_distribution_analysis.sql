
/*******************************************************************************
TITLE: FQHC Geographic Distribution and Organization Type Analysis

DESCRIPTION:
This query analyzes the geographic distribution and organizational characteristics
of Federally Qualified Health Centers (FQHCs) to understand:
- Regional distribution of healthcare access
- Prevalence of different organizational structures
- For-profit vs non-profit status across states

BUSINESS VALUE:
- Helps identify areas that may be underserved by FQHCs
- Provides insights into organizational models that could inform policy
- Enables analysis of healthcare accessibility patterns
*******************************************************************************/

WITH latest_data AS (
  -- Get most recent snapshot of data
  SELECT *
  FROM mimi_ws_1.datacmsgov.pc_fqhc 
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.datacmsgov.pc_fqhc)
)

SELECT 
  state,
  COUNT(DISTINCT enrollment_id) as num_fqhcs,
  
  -- Organization type breakdown
  COUNT(DISTINCT CASE WHEN organization_type_structure = 'CORPORATION' 
        THEN enrollment_id END) as num_corporations,
  COUNT(DISTINCT CASE WHEN organization_type_structure = 'LIMITED LIABILITY COMPANY' 
        THEN enrollment_id END) as num_llcs,
  
  -- Profit status breakdown  
  COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' 
        THEN enrollment_id END) as num_nonprofits,
  COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' 
        THEN enrollment_id END) as num_proprietary,
  
  -- Calculate percentages
  ROUND(COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' 
        THEN enrollment_id END) * 100.0 / 
        COUNT(DISTINCT enrollment_id), 1) as pct_nonprofit

FROM latest_data
GROUP BY state 
ORDER BY num_fqhcs DESC

/*******************************************************************************
HOW IT WORKS:
1. Uses CTE to get latest data snapshot based on mimi_src_file_date
2. Groups data by state and calculates key metrics:
   - Total number of unique FQHCs
   - Breakdown by organization type
   - For-profit vs non-profit counts and percentages
3. Orders results by total FQHC count to highlight states with most coverage

ASSUMPTIONS & LIMITATIONS:
- Uses enrollment_id as unique identifier for FQHCs
- Assumes latest snapshot is most relevant for analysis
- Does not account for FQHC size or capacity
- Geographic analysis at state level only

POSSIBLE EXTENSIONS:
1. Add geographic analysis at county/zip code level
2. Include temporal analysis to show FQHC growth patterns
3. Join with demographic data to analyze coverage vs population needs
4. Add filters for specific organization types or profit status
5. Calculate distance-based accessibility metrics
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:17:35.652923
    - Additional Notes: Query provides state-level aggregations of FQHC data. Note that it only uses the most recent snapshot via mimi_src_file_date and assumes enrollment_id uniquely identifies each FQHC. For time-series analysis or historical trends, the CTE would need to be modified to include multiple snapshots.
    
    */