-- Title: RxNorm Drug Attribute Insights for Pharmaceutical Market Intelligence

/* Business Purpose:
   Identify unique drug characteristics and attribute patterns that can inform:
   - Pharmaceutical market segmentation
   - Drug classification strategy
   - Potential new product development opportunities
   - Competitive intelligence analysis
*/

WITH attribute_analysis AS (
    SELECT 
        atn AS attribute_name,           -- Specific attribute type
        sab AS source_vocabulary,        -- Source of attribute
        COUNT(DISTINCT rxcui) AS concept_count,  -- Unique drug concepts with this attribute
        COUNT(*) AS total_attribute_instances,  -- Total occurrences of attribute
        ROUND(
            100.0 * COUNT(DISTINCT rxcui) / (SELECT COUNT(DISTINCT rxcui) FROM mimi_ws_1.nlm.rxnsat),
            2
        ) AS concept_coverage_percentage
    FROM 
        mimi_ws_1.nlm.rxnsat
    WHERE 
        suppress = 'N' AND  -- Only include non-suppressed attributes
        cvf = '4096'        -- Focus on current prescribable content
    GROUP BY 
        atn, sab
)

SELECT 
    attribute_name,
    source_vocabulary,
    concept_count,
    total_attribute_instances,
    concept_coverage_percentage,
    RANK() OVER (ORDER BY concept_count DESC) AS attribute_importance_rank
FROM 
    attribute_analysis
WHERE 
    concept_count > 10  -- Filter out rare attributes
ORDER BY 
    concept_count DESC, 
    concept_coverage_percentage DESC
LIMIT 50;

/* Query Mechanics:
   - Aggregates RxNorm attributes across different drug concepts
   - Calculates attribute frequency and coverage
   - Ranks attributes by their prevalence and uniqueness
   - Provides insights into drug attribute landscape

   Key Assumptions:
   - Focuses on non-suppressed, prescribable drug concepts
   - Assumes attributes with >10 concepts are meaningful
   - Uses current prescribable content subset

   Potential Extensions:
   1. Analyze attributes by specific therapeutic category
   2. Compare attribute distributions across different sources
   3. Investigate rare or unique drug attributes
   4. Link with other RxNorm tables for deeper contextual analysis
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:50:54.585307
    - Additional Notes: Query provides pharmaceutical market intelligence by analyzing RxNorm drug attributes, focusing on non-suppressed, prescribable drug concepts. Requires careful interpretation of results and potential cross-referencing with other RxNorm datasets for comprehensive analysis.
    
    */