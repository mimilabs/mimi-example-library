
/*************************************************************************
Secondary Practice Location Analysis - Growth Patterns
*************************************************************************

Business Purpose:
Analyze the expansion patterns of healthcare providers by tracking their
secondary practice locations over time. This helps understand:
- Geographic distribution of healthcare services
- Provider growth trajectories
- Areas with increasing medical presence

Created: 2024-02
*************************************************************************/

-- Main Analysis: Provider Growth by State and Time Period
WITH locations_by_period AS (
  -- Get distinct locations and their first appearance
  SELECT 
    npi,
    provider_secondary_practice_location_address__state_name as state,
    MIN(mimi_src_file_date) as first_seen_date,
    COUNT(DISTINCT provider_secondary_practice_location_address_address_line_1) as location_count
  FROM mimi_ws_1.nppes.pl
  WHERE provider_secondary_practice_location_address__state_name IS NOT NULL
  GROUP BY 1,2
)

SELECT 
  state,
  -- Count providers with secondary locations
  COUNT(DISTINCT npi) as providers_with_secondary_locations,
  -- Calculate average locations per provider
  ROUND(AVG(location_count),2) as avg_locations_per_provider,
  -- Get earliest expansion date
  MIN(first_seen_date) as earliest_expansion_date,
  -- Get latest expansion date
  MAX(first_seen_date) as latest_expansion_date
FROM locations_by_period
GROUP BY state
ORDER BY providers_with_secondary_locations DESC
LIMIT 20;

/*************************************************************************
How This Query Works:
1. CTE creates a provider-state level summary, identifying when each provider
   first established secondary locations in each state
2. Main query aggregates to state level to show expansion patterns
3. Results show states with most provider expansion and timing patterns

Assumptions & Limitations:
- Assumes address data is accurate and complete
- Does not account for closed/discontinued locations
- Limited to US states (excludes territories/foreign locations)
- Historical data availability may vary by region

Possible Extensions:
1. Add filters for specific time periods or provider types
2. Include city-level analysis for more granular insights
3. Add year-over-year growth rate calculations
4. Compare primary vs secondary location patterns
5. Map visualization of expansion patterns
6. Analyze specialty-specific expansion trends
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:18:50.604316
    - Additional Notes: Query focuses on state-level expansion patterns and may require significant memory for large datasets. Consider adding date range filters or provider type filters when analyzing specific segments. Results are most meaningful when analyzed over multi-year periods to identify true expansion trends.
    
    */