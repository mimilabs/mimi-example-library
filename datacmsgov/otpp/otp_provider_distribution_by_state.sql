
/* 
Geographic Distribution Analysis of Medicare Opioid Treatment Program Providers

Business Purpose:
- Analyze the distribution of opioid treatment providers across states
- Identify areas that may be underserved
- Support healthcare access planning and resource allocation
*/

-- Main query to show provider counts and density by state
SELECT 
    state,
    -- Get count of unique providers per state
    COUNT(DISTINCT npi) as provider_count,
    -- Calculate percentage of total providers
    ROUND(COUNT(DISTINCT npi) * 100.0 / 
          (SELECT COUNT(DISTINCT npi) FROM mimi_ws_1.datacmsgov.otpp), 2) as pct_of_total,
    -- Get count of unique cities served
    COUNT(DISTINCT city) as cities_served,
    -- Calculate providers per city ratio
    ROUND(COUNT(DISTINCT npi)::DECIMAL / 
          NULLIF(COUNT(DISTINCT city), 0), 2) as providers_per_city
FROM mimi_ws_1.datacmsgov.otpp
GROUP BY state
ORDER BY provider_count DESC;

/*
How this query works:
1. Groups providers by state
2. Calculates key metrics for each state:
   - Total number of unique providers
   - Percentage of nationwide providers
   - Number of cities with providers
   - Average providers per city

Assumptions & Limitations:
- Assumes current provider enrollment status is active
- Does not account for population differences between states
- Does not consider provider capacity or patient volumes
- City counts may be affected by variations in address formatting

Possible Extensions:
1. Add time-based analysis using medicare_id_effective_date to show growth trends
2. Join with population data to calculate providers per capita
3. Add geographic clustering analysis to identify coverage gaps
4. Include phone number availability analysis for accessibility
5. Create ZIP code level analysis for more granular insights
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:31:56.953086
    - Additional Notes: Query focuses on state-level distribution metrics but current snapshot only. Medicare effective dates in source table could enable temporal analysis. Consider adding WHERE clause to filter by _input_file_date if analyzing multiple snapshots.
    
    */