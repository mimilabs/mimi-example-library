-- Title: Critical Drug Ingredient Strength Standardization Analysis 
-- 
-- Business Purpose:
-- - Identify and analyze variations in active ingredient strength reporting formats
-- - Support drug safety initiatives by highlighting inconsistent strength documentation 
-- - Enable better data quality for pharmaceutical inventory management
-- - Facilitate accurate drug comparison and substitution decisions
--

WITH parsed_strength AS (
  -- Extract numeric values and units from strength strings
  SELECT 
    active_ingredient_name,
    active_ingredient_strength,
    -- Basic pattern matching for common strength formats
    REGEXP_EXTRACT(active_ingredient_strength, '([0-9.]+)') AS numeric_strength,
    REGEXP_EXTRACT(active_ingredient_strength, '[0-9.]+ ?([A-Za-z%]+)') AS unit
  FROM mimi_ws_1.fda.ndc_to_active_ingredients
  WHERE active_ingredient_strength IS NOT NULL
),

strength_patterns AS (
  -- Analyze strength reporting patterns for each ingredient
  SELECT 
    active_ingredient_name,
    COUNT(DISTINCT active_ingredient_strength) as strength_variations,
    COUNT(DISTINCT unit) as unit_variations,
    -- Using collect_set instead of string_agg for Databricks SQL compatibility
    COLLECT_SET(active_ingredient_strength) as strength_examples
  FROM parsed_strength
  GROUP BY active_ingredient_name
  HAVING COUNT(DISTINCT active_ingredient_strength) > 1
)

-- Final output focusing on ingredients with potential standardization needs
SELECT 
  active_ingredient_name,
  strength_variations,
  unit_variations,
  strength_examples[0] as example_1,
  strength_examples[1] as example_2,
  strength_examples[2] as example_3
FROM strength_patterns
ORDER BY strength_variations DESC, unit_variations DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE parses strength values into numeric and unit components
-- 2. Second CTE aggregates strength patterns by ingredient
-- 3. Final output identifies ingredients with multiple strength formats
--
-- Assumptions and Limitations:
-- - Assumes strength formats follow common patterns (number followed by unit)
-- - May not capture all complex strength formats
-- - Limited to basic pattern matching; doesn't handle all edge cases
-- - Shows only first three examples of strength variations
--
-- Possible Extensions:
-- 1. Add validation rules for specific therapeutic categories
-- 2. Include temporal analysis of strength reporting changes
-- 3. Cross-reference with standard units database
-- 4. Expand pattern matching for more complex strength formats
-- 5. Add severity scoring for standardization priorities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:49:54.402807
    - Additional Notes: Query focuses on identifying inconsistencies in drug strength reporting across the database. The COLLECT_SET function returns an array of unique values, and the output is limited to showing three example strength formats per ingredient. Results are ordered by ingredients with the most variations in strength reporting formats.
    
    */