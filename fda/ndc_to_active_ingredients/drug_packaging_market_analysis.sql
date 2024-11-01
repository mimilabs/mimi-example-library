-- Title: Drug Package Analysis: Market Availability and Formulation Patterns
-- Business Purpose:
-- - Analyze how pharmaceutical products are packaged and commercialized
-- - Identify distinct product formulations across different package sizes
-- - Support market analysis and supply chain optimization
-- - Aid in understanding product line diversity for manufacturers

WITH product_packaging AS (
    -- Group products by their base NDC to analyze package variations
    SELECT 
        product_ndc,
        COUNT(DISTINCT package_ndc) as package_variations,
        COUNT(DISTINCT active_ingredient_name) as ingredient_count,
        COLLECT_SET(active_ingredient_name) as ingredients_list
    FROM mimi_ws_1.fda.ndc_to_active_ingredients
    GROUP BY product_ndc
),

formulation_stats AS (
    -- Calculate statistics about product formulations
    SELECT 
        ingredient_count,
        COUNT(DISTINCT product_ndc) as product_count,
        AVG(package_variations) as avg_package_variations
    FROM product_packaging
    GROUP BY ingredient_count
)

SELECT 
    f.ingredient_count,
    f.product_count,
    ROUND(f.avg_package_variations, 2) as avg_package_variations,
    -- Calculate market share percentages
    ROUND(100.0 * f.product_count / SUM(f.product_count) OVER(), 2) as market_share_pct
FROM formulation_stats f
WHERE f.ingredient_count <= 5  -- Focus on common formulation types
ORDER BY f.product_count DESC;

-- How this query works:
-- 1. First CTE aggregates product packaging information by product_ndc
-- 2. Second CTE calculates statistics about formulation complexity
-- 3. Final query presents market share analysis with key metrics

-- Assumptions and Limitations:
-- - Assumes current NDC codes are valid and active
-- - Limited to products with 5 or fewer ingredients for clarity
-- - Package variations might include different sizes of same formulation
-- - Does not account for temporal changes in product availability

-- Possible Extensions:
-- 1. Add manufacturer analysis by joining with ndc_directory
-- 2. Include strength analysis for specific active ingredients
-- 3. Add time-based trending using mimi_dlt_load_date
-- 4. Expand to analyze therapeutic categories
-- 5. Compare package variations across different drug classes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:28:57.992791
    - Additional Notes: Query focuses on product diversity and market distribution patterns across different formulation complexities. The COLLECT_SET function returns arrays of ingredients, which might need post-processing for detailed ingredient analysis. Performance may be impacted with very large datasets due to the window function calculation for market share percentages.
    
    */