
/*******************************************************************************
Title: Home Health Agency Distribution and Organization Analysis
 
Business Purpose:
This query analyzes the geographic distribution and organizational characteristics
of Medicare-enrolled home health agencies to understand:
1. Market presence across states
2. Mix of for-profit vs non-profit agencies
3. Organization types and structures

This information helps identify service coverage, ownership patterns, and potential 
gaps in home health care accessibility.
*******************************************************************************/

-- Get state-level counts and breakdowns of home health agencies
WITH state_summary AS (
  SELECT 
    state,
    COUNT(DISTINCT enrollment_id) as total_agencies,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN enrollment_id END) as for_profit_count,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' THEN enrollment_id END) as non_profit_count,
    -- Calculate percentage of for-profit agencies
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN enrollment_id END) / 
      COUNT(DISTINCT enrollment_id), 2) as for_profit_pct,
    -- Get most common organization structure
    MODE(organization_type_structure) as primary_org_type
  FROM mimi_ws_1.datacmsgov.pc_homehealth
  WHERE state IS NOT NULL
  GROUP BY state
)

SELECT 
  state,
  total_agencies,
  for_profit_count,
  non_profit_count,
  for_profit_pct,
  primary_org_type
FROM state_summary
ORDER BY total_agencies DESC;

/*******************************************************************************
How It Works:
1. Creates a summary by state using COUNT DISTINCT to get unique agency counts
2. Calculates separate counts for for-profit and non-profit agencies
3. Computes the percentage of for-profit agencies
4. Identifies the most common organization structure type
5. Orders results by total agencies to show states with highest coverage first

Assumptions & Limitations:
- Assumes enrollment_id uniquely identifies agencies
- Assumes current snapshot is representative of market
- Does not account for agency size/capacity
- Missing states are excluded from analysis

Possible Extensions:
1. Add time trend analysis using mimi_src_file_date
2. Include geographic clustering analysis using zip codes
3. Compare urban vs rural distribution using city data
4. Add ownership concentration analysis
5. Cross-reference with quality metrics if available
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:54:00.227010
    - Additional Notes: The query focuses on state-level market analysis of Medicare-enrolled home health agencies, highlighting profit status distribution. Results are ordered by agency count to identify states with highest coverage. Note that the analysis is limited to the current snapshot and does not reflect historical trends or agency capacity metrics.
    
    */