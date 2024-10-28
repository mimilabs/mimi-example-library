
/*******************************************************************************
Title: Medicare Hospice Provider Analysis - Organization Type and Geographic Distribution

Business Purpose:
This query analyzes the distribution of Medicare-enrolled hospice providers across 
different organization types and states to understand:
- The mix of for-profit vs non-profit providers
- Geographic concentration of hospice services
- Organization structure patterns
This information helps identify potential gaps in hospice coverage and analyze 
market dynamics.

Created: 2024-02-14
*******************************************************************************/

WITH hospice_summary AS (
  -- First get counts by state and organization type
  SELECT 
    state,
    organization_type_structure,
    proprietary_nonprofit,
    COUNT(*) as provider_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY state) as pct_of_state
  FROM mimi_ws_1.datacmsgov.pc_hospice
  WHERE state IS NOT NULL
  GROUP BY state, organization_type_structure, proprietary_nonprofit
),

state_totals AS (
  -- Get overall totals by state for context
  SELECT
    state,
    COUNT(*) as total_providers,
    SUM(CASE WHEN proprietary_nonprofit = 'P' THEN 1 ELSE 0 END) as for_profit_count,
    SUM(CASE WHEN proprietary_nonprofit = 'N' THEN 1 ELSE 0 END) as non_profit_count
  FROM mimi_ws_1.datacmsgov.pc_hospice
  WHERE state IS NOT NULL
  GROUP BY state
)

-- Combine the summaries with state totals
SELECT 
  h.state,
  st.total_providers,
  h.organization_type_structure,
  h.proprietary_nonprofit,
  h.provider_count,
  ROUND(h.pct_of_state, 1) as pct_of_state_providers,
  ROUND(st.for_profit_count * 100.0 / st.total_providers, 1) as pct_for_profit,
  ROUND(st.non_profit_count * 100.0 / st.total_providers, 1) as pct_non_profit
FROM hospice_summary h
JOIN state_totals st ON h.state = st.state
ORDER BY 
  st.total_providers DESC,
  h.state,
  h.provider_count DESC;

/*******************************************************************************
How the Query Works:
1. Creates a summary of providers by state and organization type
2. Calculates state-level totals and for-profit/non-profit splits
3. Joins these together to provide a comprehensive view of provider distribution

Assumptions & Limitations:
- Assumes state field is populated for meaningful providers
- Does not account for size/capacity of providers
- Does not consider changes over time
- Geographic analysis is at state level only

Possible Extensions:
1. Add temporal analysis using incorporation_date
2. Include city-level geographic analysis
3. Join with owner data to analyze chain ownership patterns
4. Add demographic data to analyze coverage relative to population needs
5. Include analysis of multiple NPI relationships
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:57:47.919215
    - Additional Notes: The query provides high-level distribution metrics but may need adjustments for large datasets as it performs multiple aggregations. Consider adding WHERE clauses on mimi_src_file_date if analyzing specific time periods. The pct_of_state calculation assumes at least one provider per state to avoid division by zero.
    
    */