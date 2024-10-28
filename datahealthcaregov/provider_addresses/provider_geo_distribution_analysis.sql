
/*******************************************************************************
Title: Healthcare Provider Geographic Distribution Analysis
 
Business Purpose:
This query analyzes the geographic distribution of healthcare providers to help:
- Identify areas that may be underserved by certain provider types
- Support network adequacy assessments
- Guide provider recruitment efforts
- Inform strategic planning for healthcare access

Usage: Run as-is or modify provider_type filters and geographic groupings
*******************************************************************************/

-- Main Analysis Query
SELECT 
    -- Location grouping
    state,
    city,
    provider_type,
    
    -- Provider metrics
    COUNT(DISTINCT npi) as provider_count,
    
    -- Calculate percentage of total providers in that state
    COUNT(DISTINCT npi) * 100.0 / 
        SUM(COUNT(DISTINCT npi)) OVER (PARTITION BY state) 
        as pct_of_state_total,
    
    -- Get most recent data point
    MAX(last_updated_on) as data_current_as_of

FROM mimi_ws_1.datahealthcaregov.provider_addresses

-- Filter to active providers with valid locations
WHERE state IS NOT NULL 
AND city IS NOT NULL
AND npi IS NOT NULL

-- Group by location and provider type
GROUP BY state, city, provider_type

-- Order by state and number of providers
ORDER BY state, provider_count DESC

/*******************************************************************************
How this query works:
1. Aggregates provider counts by state, city and provider type
2. Calculates what percentage each city represents of state total
3. Shows data currency via most recent update date
4. Filters out records missing key location data
5. Orders results to highlight areas with highest provider concentrations

Assumptions & Limitations:
- Assumes NPI numbers are unique per provider
- Does not account for providers practicing in multiple locations
- Currency of data depends on last_updated_on field maintenance
- Geographic analysis at city level may need zip code refinement
- No distinction between full-time vs part-time providers

Possible Extensions:
1. Add filters for specific provider types of interest
2. Calculate providers per capita using census data
3. Add distance analysis between cities
4. Compare provider counts across different time periods
5. Break out by specialty types within provider categories
6. Add facility type analysis where available
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:51:16.537403
    - Additional Notes: Query is optimized for state/city level analysis but may need modifications for larger datasets. Consider adding partitioning by last_updated_on if analyzing historical trends. The pct_of_state_total calculation assumes providers aren't double-counted across cities.
    
    */