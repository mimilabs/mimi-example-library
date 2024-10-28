
/*******************************************************************************
Title: RxNorm Relationship Analysis for Drug Concept Mappings
 
Business Purpose:
This query analyzes relationships between drug concepts in RxNorm to help:
- Understand how different drug concepts are connected
- Map between different drug naming conventions
- Support medication reconciliation and clinical decision support
- Enable drug interaction checking

The core focus is on identifying the most common and important relationship 
types between drug concepts to enable accurate drug mapping.
*******************************************************************************/

-- Get the distribution of relationship types and their frequencies
-- to understand how drug concepts are connected
SELECT 
    rel,  -- Relationship type
    rela, -- Additional relationship details
    sab,  -- Source of the relationship
    COUNT(*) as relationship_count,
    COUNT(DISTINCT rxcui1) as unique_source_concepts,
    COUNT(DISTINCT rxcui2) as unique_target_concepts,
    -- Calculate what % of relationships this type represents
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total
FROM mimi_ws_1.nlm.rxnrel
WHERE cvf = '4096' -- Focus on current prescribable content only
GROUP BY rel, rela, sab
HAVING COUNT(*) > 100 -- Filter to show only common relationship types
ORDER BY relationship_count DESC;

/*******************************************************************************
How this query works:
1. Filters to current prescribable content using cvf = '4096'
2. Groups by relationship type (rel), subtype (rela) and source (sab)
3. Counts total relationships and unique concepts involved
4. Calculates percentage distribution
5. Filters to show only relationships occurring >100 times

Assumptions & Limitations:
- Focuses only on currently prescribable drugs (cvf = '4096')
- Aggregates across all time periods in the data
- Does not distinguish direction of relationships
- Minimum threshold of 100 occurrences may exclude rare but important relationships

Possible Extensions:
1. Add trending over time using mimi_src_file_date
2. Create network analysis of drug concept relationships
3. Focus on specific relationship types (e.g., 'has_ingredient')
4. Join to other RxNorm tables to include drug names and classes
5. Filter to specific drug classes or therapeutic categories
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:22:40.481843
    - Additional Notes: This query provides a high-level overview of RxNorm relationship patterns. For production use, consider adjusting the relationship count threshold (currently 100) based on specific needs. The results can be significantly large due to the comprehensive nature of RxNorm relationships. Consider adding additional filters for specific relationship types or drug classes if performance is a concern.
    
    */