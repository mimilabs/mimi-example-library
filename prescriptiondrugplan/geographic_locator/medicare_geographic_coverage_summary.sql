
/*******************************************************************************
Title: Medicare Geographic Coverage Analysis
 
Business Purpose:
This query analyzes the geographic distribution of Medicare Advantage (MA) and 
Prescription Drug Plans (PDP) across states and regions to understand coverage
patterns and identify potential gaps in service areas.

Key metrics:
- Count of counties per state
- Count of unique MA and PDP regions
- Distribution across regions
*******************************************************************************/

WITH state_summary AS (
  -- Aggregate metrics at state level
  SELECT 
    statename,
    COUNT(DISTINCT county_code) as county_count,
    COUNT(DISTINCT ma_region_code) as ma_region_count,
    COUNT(DISTINCT pdp_region_code) as pdp_region_count
  FROM mimi_ws_1.prescriptiondrugplan.geographic_locator
  GROUP BY statename
)

SELECT
  s.statename,
  s.county_count,
  s.ma_region_count,
  s.pdp_region_count,
  -- Calculate percentages relative to total counties
  ROUND(s.county_count * 100.0 / SUM(s.county_count) OVER (), 2) as pct_total_counties
FROM state_summary s
ORDER BY s.county_count DESC;

/*******************************************************************************
How this query works:
1. Creates a CTE to summarize key metrics by state
2. Calculates counts of counties and unique regions
3. Adds percentage calculations in final SELECT
4. Orders results by county count to highlight states with most coverage

Assumptions and Limitations:
- Assumes each county code is unique
- Does not account for population differences between counties
- Point-in-time snapshot based on latest data load

Possible Extensions:
1. Add time-based analysis using mimi_src_file_date
2. Join with plan_information table to analyze plan availability
3. Add population data to weight the analysis
4. Include region-level breakdowns
5. Add filters for specific states or regions of interest

Sample Usage:
- Monitor geographic coverage patterns
- Identify states with complex regional structures
- Support network adequacy analysis
- Guide market expansion planning
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:34:37.903176
    - Additional Notes: Query provides a state-level summary of Medicare coverage distribution. Note that percentages are calculated against total county count, which may not reflect population distribution. For more detailed analysis, consider joining with demographic data or the plan_information table using the region codes.
    
    */