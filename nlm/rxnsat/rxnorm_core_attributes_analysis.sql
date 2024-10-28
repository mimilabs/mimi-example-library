
/*******************************************************************************
Title: RxNorm Core Drug Attributes Analysis
 
Business Purpose:
This query analyzes key drug attributes from the RxNorm RXNSAT table to identify:
- Most common drug attribute types 
- Distribution of attribute sources
- Trends in prescribable content

This provides insights into drug classification patterns and data quality
for medication information systems.

Created: 2024
*******************************************************************************/

-- Main Query
WITH attribute_stats AS (
  -- Get counts of attribute types and sources
  SELECT 
    atn as attribute_name,
    sab as source,
    COUNT(*) as attribute_count,
    COUNT(DISTINCT rxcui) as unique_drugs,
    SUM(CASE WHEN cvf = '4096' THEN 1 ELSE 0 END) as prescribable_count
  FROM mimi_ws_1.nlm.rxnsat
  WHERE suppress != 'Y' -- Exclude suppressed attributes
  GROUP BY atn, sab
),

-- Calculate percentages and rankings
ranked_attributes AS (
  SELECT
    attribute_name,
    source,
    attribute_count,
    unique_drugs,
    prescribable_count,
    ROUND(100.0 * prescribable_count / attribute_count, 2) as pct_prescribable,
    ROW_NUMBER() OVER (ORDER BY attribute_count DESC) as popularity_rank
  FROM attribute_stats
)

-- Return top 20 most common attributes with key metrics
SELECT 
  popularity_rank,
  attribute_name,
  source,
  attribute_count,
  unique_drugs,
  prescribable_count,
  pct_prescribable
FROM ranked_attributes
WHERE popularity_rank <= 20
ORDER BY popularity_rank;

/*******************************************************************************
How this query works:
1. First CTE gets raw counts of attributes by type and source
2. Second CTE adds rankings and calculates percentages
3. Final output shows top 20 most common attributes with metrics

Assumptions & Limitations:
- Excludes suppressed attributes (suppress = 'Y')
- CVF='4096' indicates prescribable content
- Limited to top 20 attributes for readability
- Assumes current data in table is representative

Possible Extensions:
1. Add trend analysis over mimi_src_file_date
2. Filter for specific drug classes using rxcui joins
3. Compare attribute patterns across different sources (sab)
4. Add attribute value (atv) analysis for specific attribute types
5. Create views for common attribute subsets
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:08:29.911971
    - Additional Notes: Query focuses on attribute frequency analysis across drug sources. Note that the prescribable_count metric (cvf='4096') is specific to RxNorm's current prescribable content subset and may not reflect all clinically relevant medications. Performance may be impacted with large date ranges due to the aggregation of the full table.
    
    */