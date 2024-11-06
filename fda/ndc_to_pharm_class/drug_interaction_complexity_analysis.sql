-- File: drug_class_interaction_potential.sql
-- Business Purpose:
-- Analyze potential drug interactions by examining pharmacologic classes
-- with multiple mechanism types, helping:
-- 1. Identify drugs with complex pharmacological profiles
-- 2. Support clinical decision support systems
-- 3. Provide insights for drug safety and development research

WITH pharm_class_summary AS (
    -- Aggregate pharmacologic class information with multiple classification types
    SELECT 
        pharm_class,
        COUNT(DISTINCT pharm_class_type) AS unique_classification_types,
        COUNT(DISTINCT cms_ndc) AS drug_count,
        ARRAY_AGG(DISTINCT pharm_class_type) AS classification_types
    FROM mimi_ws_1.fda.ndc_to_pharm_class
    GROUP BY pharm_class
),

interaction_potential_ranking AS (
    -- Rank pharmacologic classes by interaction complexity
    SELECT 
        pharm_class,
        drug_count,
        unique_classification_types,
        classification_types,
        CASE 
            WHEN unique_classification_types > 2 THEN 'High Interaction Potential'
            WHEN unique_classification_types = 2 THEN 'Moderate Interaction Potential'
            ELSE 'Low Interaction Potential'
        END AS interaction_risk_category,
        ROUND(
            100.0 * unique_classification_types / 
            (SELECT MAX(unique_classification_types) FROM pharm_class_summary), 
            2
        ) AS complexity_percentile
    FROM pharm_class_summary
)

-- Main query to highlight pharmacologic classes with complex interaction profiles
SELECT 
    pharm_class,
    drug_count,
    interaction_risk_category,
    complexity_percentile,
    classification_types
FROM interaction_potential_ranking
WHERE drug_count > 10  -- Focus on classes with meaningful representation
ORDER BY 
    complexity_percentile DESC, 
    drug_count DESC
LIMIT 50;

-- How the Query Works:
-- 1. Aggregates pharmacologic classes by unique classification types
-- 2. Calculates drug count and classification diversity
-- 3. Assigns interaction risk categories
-- 4. Ranks classes by complexity and representation

-- Assumptions and Limitations:
-- - Assumes more classification types suggest higher interaction complexity
-- - Limited by data completeness in the NDC directory
-- - Drug count threshold of 10 helps filter statistically relevant classes

-- Potential Extensions:
-- 1. Join with drug pricing or prescription volume data
-- 2. Incorporate temporal analysis of classification changes
-- 3. Add specific mechanism of action details
-- 4. Create visualization of pharmacologic class networks

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:46:19.929085
    - Additional Notes: Requires at least 10 drugs in a pharmacologic class to be included. Provides insights into potential drug interactions by analyzing pharmacologic class diversity and complexity.
    
    */