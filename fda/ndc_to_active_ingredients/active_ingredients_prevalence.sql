
/*************************************************************************
Title: Active Ingredients Analysis for Drug Products
 
Business Purpose:
- Analyze the composition of drug products by examining their active ingredients
- Identify common active ingredients and their strength variations
- Provide insights into drug formulation patterns and standardization
**************************************************************************/

-- Main query to analyze active ingredients across drug products
WITH ingredient_stats AS (
  -- Get ingredient frequency and strength patterns
  SELECT 
    active_ingredient_name,
    COUNT(DISTINCT cms_ndc) as num_products,
    COUNT(DISTINCT active_ingredient_strength) as num_strength_variations,
    MIN(active_ingredient_strength) as min_strength,
    MAX(active_ingredient_strength) as max_strength
  FROM mimi_ws_1.fda.ndc_to_active_ingredients
  GROUP BY active_ingredient_name
)

SELECT
  active_ingredient_name,
  num_products,
  num_strength_variations,
  min_strength,
  max_strength,
  -- Calculate percentage of total products containing this ingredient
  ROUND(100.0 * num_products / (SELECT COUNT(DISTINCT cms_ndc) FROM mimi_ws_1.fda.ndc_to_active_ingredients), 2) as pct_of_products
FROM ingredient_stats
WHERE num_products > 10  -- Focus on commonly used ingredients
ORDER BY num_products DESC
LIMIT 20;

/*
How this query works:
1. Creates a CTE to aggregate statistics for each active ingredient
2. Calculates key metrics like product count and strength variations
3. Computes percentage of total products containing each ingredient
4. Filters for commonly used ingredients and returns top 20

Assumptions & Limitations:
- Assumes ingredient names are standardized across products
- Strength values may have different units that aren't normalized
- Does not account for combination products where ingredients interact
- Time dimension not considered (data is treated as current snapshot)

Possible Extensions:
1. Add time trend analysis using mimi_dlt_load_date
2. Join with ndc_directory to analyze by manufacturer or drug class
3. Analyze common ingredient combinations in multi-ingredient products
4. Compare strength distributions across different product categories
5. Add validation for strength unit standardization
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:34:20.634782
    - Additional Notes: Query focuses on most frequently used active ingredients across drug products, with strength variations. Results are limited to ingredients appearing in more than 10 products and sorted by prevalence. Strength values should be reviewed carefully as units may not be standardized across all records.
    
    */