
/*******************************************************************************
Title: SNF Geographic Distribution and Organization Type Analysis

Business Purpose:
This query analyzes the distribution of Skilled Nursing Facilities (SNFs) across 
states and organization types to understand:
1. Where Medicare-enrolled SNFs are concentrated geographically
2. What types of organizations (proprietary vs non-profit) operate in different areas
3. Basic facility counts and characteristics to inform healthcare planning

This provides insights for:
- Healthcare access analysis
- Resource allocation
- Policy making
- Market analysis
*******************************************************************************/

WITH state_summary AS (
  -- Aggregate facility counts and calculate percentages by state
  SELECT 
    state,
    COUNT(*) as total_facilities,
    COUNT(CASE WHEN proprietary_nonprofit = 'P' THEN 1 END) as proprietary_count,
    COUNT(CASE WHEN proprietary_nonprofit = 'N' THEN 1 END) as nonprofit_count,
    ROUND(COUNT(CASE WHEN proprietary_nonprofit = 'P' THEN 1 END) * 100.0 / COUNT(*), 1) as pct_proprietary,
    ROUND(COUNT(CASE WHEN proprietary_nonprofit = 'N' THEN 1 END) * 100.0 / COUNT(*), 1) as pct_nonprofit
  FROM mimi_ws_1.datacmsgov.pc_snf
  GROUP BY state
)

SELECT
  s.state,
  s.total_facilities,
  s.proprietary_count,
  s.nonprofit_count,
  s.pct_proprietary,
  s.pct_nonprofit,
  -- Calculate state's share of total facilities
  ROUND(s.total_facilities * 100.0 / SUM(s.total_facilities) OVER (), 1) as pct_of_total_facilities
FROM state_summary s
WHERE s.state IS NOT NULL
ORDER BY s.total_facilities DESC;

/*******************************************************************************
How this query works:
1. Creates a CTE to summarize facility counts and ownership types by state
2. Calculates percentages for proprietary vs non-profit facilities
3. Adds overall market share percentage for each state
4. Orders results by total facilities to show largest markets first

Assumptions & Limitations:
- Assumes current enrollment data is complete and accurate
- Does not account for facility size/capacity
- Some facilities may have missing ownership type data
- Territory/possession codes may be included in state counts

Possible Extensions:
1. Add facility size analysis using bed count data (if available)
2. Include temporal analysis to show market changes over time
3. Add geographic clustering analysis by zip code
4. Incorporate demographic data to analyze access relative to population
5. Add filters for specific organization types or chain affiliations
6. Include quality metrics or patient outcome data if available
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:51:12.040504
    - Additional Notes: Query focuses on top-level geographic and ownership patterns of SNFs. Results can be significantly affected by null values in state or proprietary_nonprofit fields. The percentages calculated assume complete data reporting. For accurate healthcare planning, results should be cross-referenced with population data and facility capacity metrics.
    
    */