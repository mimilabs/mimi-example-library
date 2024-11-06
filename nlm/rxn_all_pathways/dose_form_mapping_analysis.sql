-- dose_form_relationship_analysis.sql
-- 
-- Business Purpose:
-- This query analyzes the relationships between different dose forms in RxNorm,
-- which is critical for:
-- 1. Pharmacy inventory management
-- 2. Order entry system optimization
-- 3. Cross-facility medication reconciliation
-- 4. Drug product substitution protocols

WITH dose_form_pairs AS (
    -- Select relationships between different dose forms
    SELECT DISTINCT
        source_tty,
        source_name,
        target_tty,
        target_name,
        COUNT(*) as relationship_count
    FROM mimi_ws_1.nlm.rxn_all_pathways
    WHERE 
        -- Focus on dose form relationships
        source_tty IN ('DF', 'DFG') 
        AND target_tty IN ('DF', 'DFG')
        AND source_tty != target_tty
    GROUP BY 
        source_tty,
        source_name,
        target_tty,
        target_name
),

ranked_relationships AS (
    -- Rank relationships by frequency
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY relationship_count DESC) as rank
    FROM dose_form_pairs
)

-- Final output with most significant relationships
SELECT 
    source_tty as source_dose_form_type,
    source_name as source_dose_form,
    target_tty as target_dose_form_type,
    target_name as target_dose_form,
    relationship_count,
    ROUND(relationship_count * 100.0 / SUM(relationship_count) OVER (), 2) as percentage_of_total
FROM ranked_relationships
WHERE rank <= 20
ORDER BY relationship_count DESC;

-- How this query works:
-- 1. First CTE identifies distinct pairs of dose forms and counts their relationships
-- 2. Second CTE ranks these relationships by frequency
-- 3. Final query selects top 20 relationships with percentage calculations

-- Assumptions and Limitations:
-- 1. Focuses only on DF (Dose Form) and DFG (Dose Form Group) term types
-- 2. Does not consider intermediate relationships in paths
-- 3. Treats bidirectional relationships as distinct
-- 4. Limited to top 20 most frequent relationships

-- Possible Extensions:
-- 1. Add path length analysis to understand relationship complexity
-- 2. Include temporal analysis if version data is available
-- 3. Expand to include related drug products (SCD, SBD)
-- 4. Add filters for specific therapeutic areas
-- 5. Create views for common dose form substitution patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:43:09.372983
    - Additional Notes: The query focuses on dose form relationships in RxNorm and their frequencies, which is valuable for pharmacy operations and medication reconciliation systems. The 20-row limit in the final output should be adjusted based on specific use cases. Consider adding filters for specific therapeutic areas if analyzing a particular medical domain.
    
    */