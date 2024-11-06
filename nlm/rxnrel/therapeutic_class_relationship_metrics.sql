-- Title: RxNorm Therapeutic Class Relationship Analysis for Clinical Decision Support

-- Business Purpose:
-- This query analyzes therapeutic class relationships between medications to support:
-- - Clinical decision support systems for medication alternatives
-- - Drug class-based protocols and order sets
-- - Therapeutic interchange program development
-- - Formulary management by drug class

SELECT 
    -- Get the relationship type
    rel,
    rela,
    -- Get the source authority
    sab,
    -- Count relationships that are currently prescribable
    COUNT(CASE WHEN cvf = '4096' THEN 1 END) as prescribable_count,
    -- Count total relationships
    COUNT(*) as total_count,
    -- Calculate percentage of relationships that are prescribable
    ROUND(COUNT(CASE WHEN cvf = '4096' THEN 1 END) * 100.0 / COUNT(*), 2) as prescribable_pct
FROM mimi_ws_1.nlm.rxnrel
-- Focus on therapeutic class relationships
WHERE rela IN ('has_therapeutic_class', 'therapeutic_class_of')
GROUP BY rel, rela, sab
-- Order by most common relationships first
ORDER BY total_count DESC;

-- How this query works:
-- 1. Filters for therapeutic class relationships using the rela column
-- 2. Groups results by relationship type (rel), specific relationship (rela), and source (sab)
-- 3. Calculates counts for prescribable and total relationships
-- 4. Computes percentage of relationships that are currently prescribable
-- 5. Orders results by total relationship count to highlight most common relationships

-- Assumptions and Limitations:
-- - Assumes therapeutic class relationships are primarily indicated by rela values
-- - Limited to relationships currently in RxNorm
-- - May not capture all therapeutic classification systems
-- - Prescribable status (cvf='4096') may change over time

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating mimi_src_file_date
-- 2. Join with RXNCONSO to get actual drug/class names
-- 3. Create hierarchical view of therapeutic classes
-- 4. Compare therapeutic classifications across different sources (sab)
-- 5. Analyze changes in therapeutic class assignments over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:39:11.300904
    - Additional Notes: Query focuses on analyzing relationship patterns between drugs and their therapeutic classes. The prescribable_count metric is particularly useful for clinical decision support systems that need to suggest currently available therapeutic alternatives. Consider memory usage when extending with RXNCONSO joins as the relationship table can be quite large.
    
    */