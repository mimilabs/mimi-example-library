-- fda_exclusivity_value_analysis.sql
-- Business Purpose: Analyze the economic value and market protection periods of FDA-licensed biologics
-- by examining exclusivity periods and determining products with upcoming exclusivity expirations.
-- This helps identify market opportunities for biosimilar development and strategic licensing.

WITH active_products AS (
    -- Filter to currently marketed products with valid exclusivity dates
    SELECT 
        proprietary_name,
        proper_name,
        applicant,
        marketing_status,
        exclusivity_expiration_date,
        orphan_exclusivity_exp_date,
        ref_product_exclusivity_exp_date,
        approval_date
    FROM mimi_ws_1.fda.purplebook
    WHERE marketing_status = 'Active' 
    AND (
        exclusivity_expiration_date IS NOT NULL OR
        orphan_exclusivity_exp_date IS NOT NULL OR
        ref_product_exclusivity_exp_date IS NOT NULL
    )
),

exclusivity_categories AS (
    -- Categorize products by exclusivity type and time remaining
    SELECT
        proprietary_name,
        proper_name,
        applicant,
        CASE 
            WHEN exclusivity_expiration_date IS NOT NULL 
                THEN datediff(exclusivity_expiration_date, current_date())
            WHEN orphan_exclusivity_exp_date IS NOT NULL 
                THEN datediff(orphan_exclusivity_exp_date, current_date())
            WHEN ref_product_exclusivity_exp_date IS NOT NULL 
                THEN datediff(ref_product_exclusivity_exp_date, current_date())
        END as days_until_expiration,
        CASE
            WHEN exclusivity_expiration_date IS NOT NULL THEN 'Standard'
            WHEN orphan_exclusivity_exp_date IS NOT NULL THEN 'Orphan'
            WHEN ref_product_exclusivity_exp_date IS NOT NULL THEN 'Reference Product'
        END as exclusivity_type
    FROM active_products
)

SELECT
    exclusivity_type,
    CASE 
        WHEN days_until_expiration <= 365 THEN 'Within 1 Year'
        WHEN days_until_expiration <= 730 THEN 'Within 2 Years'
        WHEN days_until_expiration <= 1095 THEN 'Within 3 Years'
        ELSE 'More than 3 Years'
    END as expiration_window,
    COUNT(*) as product_count,
    concat_ws(', ', collect_set(proprietary_name)) as example_products
FROM exclusivity_categories
WHERE days_until_expiration > 0
GROUP BY exclusivity_type, expiration_window
ORDER BY exclusivity_type, expiration_window;

-- How it works:
-- 1. Filters for active products with valid exclusivity dates
-- 2. Calculates days until exclusivity expiration for each product
-- 3. Categorizes products by exclusivity type and time window
-- 4. Aggregates results to show product counts and examples in each category

-- Assumptions and Limitations:
-- - Only considers products with active marketing status
-- - Assumes current_date() for calculations
-- - Limited to products with at least one type of exclusivity date
-- - Does not account for potential patent protection beyond exclusivity

-- Possible Extensions:
-- 1. Add market size estimates by linking to sales data
-- 2. Include therapeutic area analysis
-- 3. Add competitive analysis by counting potential biosimilars in development
-- 4. Calculate estimated revenue at risk by expiration window
-- 5. Include historical patterns of post-exclusivity market dynamics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:26:17.449209
    - Additional Notes: Query focuses on market exclusivity timing analysis for biological products, showing distribution of products across different expiration windows. Results help identify upcoming market opportunities as exclusivity periods end. Note that some products may have multiple types of exclusivity, and the query prioritizes standard exclusivity over orphan and reference product exclusivity in such cases.
    
    */