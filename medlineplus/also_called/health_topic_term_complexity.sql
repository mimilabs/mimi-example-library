-- Title: Health Topic Terminology Frequency Analysis

-- Business Purpose:
-- This query analyzes the frequency distribution of alternative terms for health topics to:
-- - Identify the most comprehensive health topics with multiple alternate names
-- - Support content strategy by understanding which conditions need better terminology mapping
-- - Enable better patient education materials by identifying topics with complex naming patterns
-- - Support SEO and content tagging strategies for health information systems

WITH topic_term_counts AS (
    -- Get count of alternative terms per topic
    SELECT 
        topic_id,
        COUNT(DISTINCT alias) as term_count,
        -- Create array of terms for reference
        COLLECT_LIST(DISTINCT alias) as term_list
    FROM mimi_ws_1.medlineplus.also_called
    GROUP BY topic_id
),

term_distribution AS (
    -- Calculate distribution statistics
    SELECT 
        PERCENTILE(term_count, 0.5) as median_terms,
        AVG(term_count) as avg_terms,
        MAX(term_count) as max_terms,
        MIN(term_count) as min_terms
    FROM topic_term_counts
)

-- Main result set combining counts and examples
SELECT 
    t.topic_id,
    t.term_count,
    t.term_list,
    -- Compare to overall statistics
    CASE 
        WHEN t.term_count > d.avg_terms THEN 'Above Average'
        ELSE 'Below Average'
    END as terminology_complexity
FROM topic_term_counts t
CROSS JOIN term_distribution d
WHERE t.term_count > 1  -- Focus on topics with multiple terms
ORDER BY t.term_count DESC
LIMIT 100;

-- How it works:
-- 1. First CTE counts distinct alternative terms per topic
-- 2. Second CTE calculates distribution statistics across all topics
-- 3. Main query combines the counts with statistical context
-- 4. Results show topics with multiple terms, ordered by complexity

-- Assumptions and Limitations:
-- - Assumes all terms in also_called are valid alternatives
-- - Does not account for term similarity or redundancy
-- - Limited to top 100 results for manageability
-- - Does not consider temporal aspects of terminology changes

-- Possible Extensions:
-- 1. Add term similarity analysis using string matching
-- 2. Include topic categories or domains for better context
-- 3. Compare terminology patterns across different medical specialties
-- 4. Add temporal analysis to see terminology evolution
-- 5. Link to usage statistics to see which terms are most frequently searched

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:59:01.495845
    - Additional Notes: Query focuses on identifying health topics with complex terminology patterns and may require additional memory resources when analyzing large datasets due to the COLLECT_LIST function. Consider adding WHERE clauses to filter by specific date ranges or topic categories if performance optimization is needed.
    
    */