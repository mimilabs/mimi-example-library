
/*******************************************************************************
Title: Healthcare Provider Geographic Distribution Analysis

Business Purpose:
This query analyzes the geographic distribution of healthcare providers across
states to identify potential coverage gaps and provider density patterns. This
information is valuable for:
- Healthcare resource planning
- Identifying underserved areas
- Supporting provider network development
- Informing healthcare policy decisions

Created: 2024-02-14
*******************************************************************************/

-- Main query analyzing provider distribution by state with key metrics
SELECT 
    state,
    -- Count unique providers in each state
    COUNT(DISTINCT npi) as provider_count,
    
    -- Calculate percentage of total providers
    ROUND(COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER(), 2) as pct_of_total,
    
    -- Count distinct cities to understand urban coverage
    COUNT(DISTINCT city) as unique_cities,
    
    -- Get most common cities for context using collect_set
    concat_ws(', ', collect_set(city)) as top_cities
FROM (
    SELECT 
        state,
        npi,
        city,
        ROW_NUMBER() OVER (PARTITION BY state ORDER BY COUNT(*) OVER (PARTITION BY state, city) DESC) as city_rank
    FROM mimi_ws_1.nppes.fhir_address
    WHERE 
        -- Focus on current business addresses
        use = 'work' 
        AND type = 'physical'
        AND country = 'US'
        AND (period_end IS NULL OR period_end > CURRENT_DATE)
        AND state IS NOT NULL
) ranked
WHERE city_rank <= 3
GROUP BY state
ORDER BY provider_count DESC;

/*******************************************************************************
How this query works:
1. Filters to active business addresses in the US
2. Ranks cities within each state by provider count
3. Groups providers by state
4. Calculates key metrics per state:
   - Total provider count
   - Percentage of national total
   - Number of unique cities served
   - Top 3 cities by provider count (using collect_set and concat_ws)

Assumptions and Limitations:
- Assumes current addresses where period_end is NULL or future
- Limited to business/physical addresses (excludes mailing addresses)
- US-only analysis
- Does not account for provider specialties or practice size
- City names may have variations or data quality issues

Possible Extensions:
1. Add provider specialty analysis by joining with provider details
2. Calculate provider density per capita using population data
3. Add year-over-year trend analysis
4. Include geographic coordinates for mapping
5. Add rural vs urban classification analysis
6. Break down by provider type or specialty
7. Add distance analysis to identify coverage gaps
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:30:22.900949
    - Additional Notes: Query performs state-level analysis of healthcare provider distribution including provider counts, percentages, and top cities per state. Limited to current US business addresses only. The collect_set function may have memory limitations for very large city sets. Results are ordered by provider count to highlight states with highest concentration of providers.
    
    */