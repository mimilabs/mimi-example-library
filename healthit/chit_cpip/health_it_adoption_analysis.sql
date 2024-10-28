
/*******************************************************************************
Title: Analysis of Health IT System Adoption Patterns Across Healthcare Practices

Business Purpose:
This query analyzes the adoption of certified health information technology (CHIT) 
across different healthcare practices to understand:
- Which health IT systems are most widely used
- How adoption varies by practice size and location
- Key vendors in the market
This helps inform health IT strategy, vendor selection, and interoperability planning.

Created: 2024
*******************************************************************************/

-- Main analysis query
WITH practice_summary AS (
  -- Aggregate key metrics by practice
  SELECT 
    practice_state_or_us_territory as state,
    practice_size,
    developer,
    product,
    edition,
    COUNT(DISTINCT provider_key) as num_providers,
    COUNT(DISTINCT grp_key) as num_practices
  FROM mimi_ws_1.healthit.chit_cpip
  WHERE practice_state_or_us_territory IS NOT NULL
    AND practice_size IS NOT NULL
  GROUP BY 1,2,3,4,5
)

SELECT
  state,
  -- Categorize practice size
  CASE 
    WHEN practice_size <= 10 THEN 'Small (1-10)'
    WHEN practice_size <= 50 THEN 'Medium (11-50)' 
    ELSE 'Large (50+)'
  END as practice_size_category,
  developer,
  product,
  edition,
  num_providers,
  num_practices,
  -- Calculate relative market share within state
  ROUND(100.0 * num_practices / SUM(num_practices) OVER (PARTITION BY state), 2) as state_market_share_pct
FROM practice_summary
-- Focus on top systems by adoption
WHERE num_practices >= 5
ORDER BY state, num_practices DESC;

/*******************************************************************************
How this query works:
1. Creates a summary table aggregating providers and practices by state, size, 
   and health IT system
2. Categorizes practices into small/medium/large size bands
3. Calculates market share percentages within each state
4. Filters to systems with meaningful adoption (5+ practices)

Assumptions & Limitations:
- Assumes practice_size is accurate and current
- Limited to practices that reported complete data
- Market share calculations may not reflect total market due to data gaps
- Some practices may use multiple systems

Possible Extensions:
1. Add trend analysis over time using mimi_src_file_date
2. Include specialty-specific adoption patterns
3. Analyze regional clusters/patterns
4. Compare adoption across different editions
5. Study relationship between practice size and system choice
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:32:25.782911
    - Additional Notes: Query groups results by state and practice size, which may cause performance issues with very large datasets. Consider adding date filters or limiting output rows if needed for better performance. Market share calculations exclude practices with missing state or practice size data.
    
    */