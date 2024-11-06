
-- Active Ingredient Market Landscape Analysis
-- 
-- Business Purpose:
-- Analyze the distribution and diversity of active pharmaceutical ingredients
-- across different drug products to understand market composition, potential
-- therapeutic area concentrations, and ingredient prevalence.

WITH ingredient_summary AS (
    -- Extract and unnest active ingredients, counting occurrences
    SELECT 
        trim(ingredient) AS active_ingredient,
        COUNT(DISTINCT package_ndc) AS unique_drug_count,
        COUNT(DISTINCT set_id) AS unique_label_versions,
        MIN(effective_time) AS earliest_label_date,
        MAX(effective_time) AS latest_label_date
    FROM (
        SELECT 
            package_ndc, 
            set_id, 
            effective_time, 
            trim(value) AS ingredient
        FROM mimi_ws_1.fda.ndc_label
        LATERAL VIEW explode(split(active_ingredient, ',')) AS value
    )
    WHERE ingredient != ''
    GROUP BY active_ingredient
),

ingredient_classification AS (
    -- Classify ingredients by market presence and longevity
    SELECT 
        active_ingredient,
        unique_drug_count,
        unique_label_versions,
        earliest_label_date,
        latest_label_date,
        CASE 
            WHEN unique_drug_count > 100 THEN 'High Volume'
            WHEN unique_drug_count > 20 THEN 'Medium Volume'
            ELSE 'Low Volume'
        END AS market_presence,
        DATEDIFF(latest_label_date, earliest_label_date) AS label_update_span_days
    FROM ingredient_summary
)

-- Final query presenting strategic insights
SELECT 
    active_ingredient,
    unique_drug_count,
    market_presence,
    label_update_span_days,
    earliest_label_date,
    latest_label_date
FROM ingredient_classification
WHERE unique_drug_count > 10  -- Focus on more prevalent ingredients
ORDER BY unique_drug_count DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Unnest active ingredients from comma-separated field
-- 2. Count unique drug products and label versions per ingredient
-- 3. Classify ingredients by market volume
-- 4. Calculate label update time spans
-- 5. Present top ingredients by drug product count

-- Assumptions and Limitations:
-- - Assumes comma-separated active ingredient lists
-- - Uses package_ndc as proxy for unique drug products
-- - Does not validate ingredient clinical significance
-- - Limited to ingredients with > 10 unique drug products

-- Potential Extensions:
-- 1. Join with ndc_directory for additional drug details
-- 2. Analyze ingredient trends over time
-- 3. Correlate with dosage and administration information
-- 4. Integrate therapeutic class categorization


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:51:08.095712
    - Additional Notes: Query provides a high-level overview of pharmaceutical active ingredients by analyzing their market presence, label versioning, and temporal characteristics. Assumes clean, comma-separated ingredient data and focuses on ingredients with more than 10 unique drug products.
    
    */