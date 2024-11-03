-- drug_strength_analysis.sql --
--
-- Business Purpose:
-- This query analyzes medication strength variations across different drug forms,
-- providing critical insights for:
-- 1. Drug formulary standardization
-- 2. Clinical decision support systems
-- 3. Drug cost optimization by identifying equivalent strength alternatives
--

WITH drug_strengths AS (
    -- Filter for strength-related relationships
    SELECT DISTINCT
        source_name,
        source_tty,
        target_name,
        target_tty
    FROM mimi_ws_1.nlm.rxn_all_pathways
    WHERE 
        -- Focus on Semantic Clinical Drug Forms (SCDF) to their Semantic Clinical Drugs (SCD)
        source_tty = 'SCDF' 
        AND target_tty = 'SCD'
),

strength_patterns AS (
    -- Analyze strength distribution patterns
    SELECT 
        source_name AS drug_form,
        COUNT(DISTINCT target_name) AS strength_variants,
        -- Using collect_set instead of STRING_AGG for Spark SQL compatibility
        collect_set(target_name) AS strength_list
    FROM drug_strengths
    GROUP BY source_name
)

SELECT 
    drug_form,
    strength_variants,
    -- Convert array to string for display
    concat_ws(' | ', strength_list) AS strength_examples,
    -- Flag high-variation products for review
    CASE 
        WHEN strength_variants > 5 THEN 'High Variation'
        WHEN strength_variants > 2 THEN 'Moderate Variation'
        ELSE 'Low Variation'
    END AS variation_category
FROM strength_patterns
WHERE strength_variants > 1  -- Only show drugs with multiple strengths
ORDER BY strength_variants DESC
LIMIT 100;

-- Query Operation:
-- 1. Identifies relationships between drug forms and their strength variations
-- 2. Aggregates and counts distinct strength variants for each drug form
-- 3. Categorizes drugs based on their strength variation complexity
--
-- Assumptions and Limitations:
-- - Focuses only on SCDF to SCD relationships
-- - Limited to current RxNorm relationships
-- - Does not account for deprecated or historical strength variants
--
-- Possible Extensions:
-- 1. Add temporal analysis to track new strength introductions
-- 2. Include cost analysis by joining with pricing data
-- 3. Expand to include brand-generic strength comparisons
-- 4. Add therapeutic class context to strength variations
-- 5. Include dosage form analysis alongside strength variations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:47:26.243486
    - Additional Notes: Query focuses on drug form to strength relationships in RxNorm, particularly useful for formulary management and clinical decision support. Results are limited to SCDF-to-SCD relationships and top 100 variations. The strength_examples field may contain long strings for medications with many variants.
    
    */