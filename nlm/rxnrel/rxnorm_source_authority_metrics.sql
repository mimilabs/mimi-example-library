-- Title: RxNorm Drug Relationship Source Authority Analysis
--
-- Business Purpose:
-- This query analyzes the authoritative sources of drug relationships in RxNorm to:
-- - Identify which organizations/sources contribute the most relationship data
-- - Assess the comprehensiveness of different data sources for drug information
-- - Support data quality and source reliability assessments
-- - Guide decisions on which sources to prioritize for drug information systems

SELECT 
    -- Source organization metrics
    sab as source_authority,
    COUNT(*) as relationship_count,
    COUNT(DISTINCT rxcui1) as unique_primary_concepts,
    COUNT(DISTINCT rxcui2) as unique_related_concepts,
    
    -- Relationship type analysis
    COUNT(DISTINCT rel) as distinct_relationship_types,
    
    -- Calculate prescribable content percentage
    ROUND(SUM(CASE WHEN cvf = '4096' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as prescribable_content_pct,
    
    -- Sample of relationship types (using array_agg instead of string_agg)
    COLLECT_SET(rel) as relationship_types_sample
    
FROM mimi_ws_1.nlm.rxnrel

-- Focus on most recent data snapshot
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.nlm.rxnrel
)

GROUP BY sab
HAVING COUNT(*) > 1000  -- Filter for significant sources

ORDER BY relationship_count DESC
LIMIT 20;

-- How this query works:
-- 1. Groups relationships by their authoritative source (sab)
-- 2. Calculates key metrics for each source including:
--    - Total number of relationships
--    - Number of unique concepts involved
--    - Types of relationships provided
--    - Percentage of relationships that are prescribable
-- 3. Filters for the most recent data and significant sources
-- 4. Orders results by total relationship count

-- Assumptions and Limitations:
-- - Assumes sab (source authority) is consistently populated
-- - Limited to sources with >1000 relationships for focus on major contributors
-- - Current snapshot analysis only - doesn't show historical trends
-- - Doesn't distinguish between current and obsolete relationships

-- Possible Extensions:
-- 1. Add temporal analysis to show how source contributions change over time
-- 2. Include source-specific relationship type distribution analysis
-- 3. Cross-reference with other RxNorm tables to validate relationship quality
-- 4. Add filters for specific types of drug relationships of interest
-- 5. Incorporate error checking for relationship consistency within sources

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:40:22.890772
    - Additional Notes: Query focuses on source authorities (sab) in RxNorm relationships, providing metrics on relationship counts, concept coverage, and prescribable content ratios. Best used for evaluating data quality and source reliability. Note that the COLLECT_SET function may return a large array for sources with many relationship types, which could impact performance for very large datasets.
    
    */