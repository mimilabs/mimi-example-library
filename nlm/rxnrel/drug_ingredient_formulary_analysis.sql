-- Title: RxNorm Clinical Drug-to-Ingredient Analysis for Formulary Management
-- 
-- Business Purpose:
-- This query helps healthcare organizations optimize their drug formulary by:
-- - Identifying all clinical drugs and their active ingredients
-- - Supporting formulary decision-making by showing ingredient relationships
-- - Enabling therapeutic substitution analysis
-- - Supporting cost optimization through ingredient-based alternatives
--
-- Note: Focuses on prescribable content (CVF=4096) to ensure clinical relevance

WITH ingredient_relationships AS (
    -- Get relationships between clinical drugs and their ingredients
    SELECT DISTINCT
        r.rxcui1 as drug_cui,
        r.rxcui2 as ingredient_cui,
        r.rela as relationship_type,
        r.sab as source
    FROM mimi_ws_1.nlm.rxnrel r
    WHERE r.cvf = '4096'  -- Only prescribable content
    AND r.rela IN ('has_ingredient', 'consists_of')  -- Focus on ingredient relationships
    AND r.sab = 'RXNORM'  -- Ensure RxNorm as source
),

ingredient_counts AS (
    -- Calculate number of ingredients per drug
    SELECT 
        drug_cui,
        COUNT(DISTINCT ingredient_cui) as ingredient_count
    FROM ingredient_relationships
    GROUP BY drug_cui
)

SELECT 
    ir.drug_cui,
    ir.ingredient_cui,
    ir.relationship_type,
    ic.ingredient_count,
    -- Flag multi-ingredient drugs for analysis
    CASE 
        WHEN ic.ingredient_count > 1 THEN 'Multi-ingredient'
        ELSE 'Single-ingredient'
    END as drug_complexity
FROM ingredient_relationships ir
JOIN ingredient_counts ic ON ir.drug_cui = ic.drug_cui
WHERE ic.ingredient_count <= 5  -- Filter out complex compounds for clarity
ORDER BY ic.ingredient_count DESC, ir.drug_cui;

-- How it works:
-- 1. First CTE identifies direct relationships between drugs and their ingredients
-- 2. Second CTE calculates the number of ingredients per drug
-- 3. Main query combines the data and adds classification
--
-- Assumptions and Limitations:
-- - Only includes current prescribable content (CVF=4096)
-- - Limited to direct ingredient relationships
-- - Excludes very complex compounds (>5 ingredients)
-- - Assumes RxNorm as authoritative source
--
-- Possible Extensions:
-- 1. Add drug names by joining with RXNCONSO
-- 2. Include strength information for detailed analysis
-- 3. Add therapeutic classification grouping
-- 4. Incorporate cost data for financial analysis
-- 5. Add time-based trending of formulation changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:48:51.399564
    - Additional Notes: Query focuses on 1:1 and 1:many relationships between drugs and their ingredients, specifically for formulary management. Limited to prescribable content with up to 5 ingredients per drug. Best used in conjunction with drug pricing data for complete formulary analysis. May need memory optimization for very large datasets.
    
    */