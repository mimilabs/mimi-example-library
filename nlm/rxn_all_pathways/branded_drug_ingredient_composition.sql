-- RxNorm Branded Drug Mapping Analysis
-- 
-- Business Purpose:
-- This query analyzes the mapping between branded drugs (BD) and their corresponding 
-- generic ingredients (IN), providing insights for formulary management and 
-- cost containment strategies. Understanding these relationships helps:
-- 1. Identify branded-to-generic substitution opportunities
-- 2. Support pharmacy benefit design decisions
-- 3. Enable cost-saving initiatives through generic alternatives

WITH branded_to_ingredient AS (
    -- Focus on direct paths from branded drugs to ingredients
    SELECT DISTINCT
        source_rxcui,
        source_name as brand_name,
        target_rxcui,
        target_name as ingredient_name,
        path
    FROM mimi_ws_1.nlm.rxn_all_pathways
    WHERE source_tty = 'BD'  -- Branded Drug
    AND target_tty = 'IN'    -- Ingredient
),

brand_ingredient_counts AS (
    -- Calculate number of ingredients per brand and brands per ingredient
    SELECT 
        brand_name,
        COUNT(DISTINCT ingredient_name) as ingredient_count,
        COLLECT_LIST(DISTINCT ingredient_name) as ingredients_list
    FROM branded_to_ingredient
    GROUP BY brand_name
    HAVING COUNT(DISTINCT ingredient_name) > 1  -- Multi-ingredient brands
)

SELECT
    brand_name,
    ingredient_count,
    ARRAY_JOIN(ingredients_list, ' + ') as ingredients_combined
FROM brand_ingredient_counts
ORDER BY ingredient_count DESC, brand_name
LIMIT 100;

-- How this query works:
-- 1. First CTE filters relationships between branded drugs and their ingredients
-- 2. Second CTE aggregates to show brands with multiple ingredients using COLLECT_LIST
-- 3. Final output presents multi-ingredient brands sorted by complexity
--
-- Assumptions and Limitations:
-- - Focuses only on BD (branded drug) to IN (ingredient) relationships
-- - Does not consider strength or dosage form
-- - Limited to direct relationships in the paths
--
-- Possible Extensions:
-- 1. Add cost analysis by joining with pricing data
-- 2. Include dosage form analysis (SBDF relationships)
-- 3. Compare brand vs generic market availability
-- 4. Analyze therapeutic equivalence through path relationships
-- 5. Track historical brand-generic relationship changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:54:15.904876
    - Additional Notes: Query focuses on multi-ingredient branded drugs to support formulary management. Note that COLLECT_LIST and ARRAY_JOIN are Spark SQL specific functions used for string aggregation. Results are limited to top 100 most complex drug compositions by ingredient count.
    
    */