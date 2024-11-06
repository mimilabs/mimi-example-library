-- Title: Brand Name Product Portfolio Analysis

-- Business Purpose:
-- This analysis examines brand name drug products and their variations to:
-- - Identify product line extensions through suffix patterns
-- - Map brand-generic relationships
-- - Track product lifecycle timing across brand portfolios
-- - Support market positioning and competitive intelligence

SELECT 
    -- Core brand identifiers
    brand_name,
    brand_name_base,
    brand_name_suffix,
    generic_name,
    
    -- Product details
    dosage_form,
    manufacturer_name,
    
    -- Market timing
    marketing_start_date,
    marketing_end_date,
    
    -- Count related products
    COUNT(*) as product_variations,
    
    -- Active status
    SUM(CASE 
        WHEN marketing_end_date IS NULL 
        AND (listing_expiration_date IS NULL OR listing_expiration_date > CURRENT_DATE)
        THEN 1 ELSE 0 
    END) as active_products

FROM mimi_ws_1.fda.ndc_directory
WHERE brand_name IS NOT NULL
  AND marketing_start_date IS NOT NULL
  
GROUP BY 
    brand_name,
    brand_name_base,
    brand_name_suffix,
    generic_name,
    dosage_form,
    manufacturer_name,
    marketing_start_date,
    marketing_end_date

HAVING active_products > 0

ORDER BY 
    product_variations DESC,
    marketing_start_date DESC
LIMIT 100;

-- How the Query Works:
-- 1. Filters for products with brand names and known market start dates
-- 2. Groups by key brand and product attributes
-- 3. Calculates total variations and currently active products
-- 4. Orders results to highlight brands with most variations
-- 5. Limits to top 100 results for manageable analysis

-- Assumptions and Limitations:
-- - Assumes NULL marketing_end_date indicates currently marketed product
-- - Limited to products with brand names (excludes generic-only products)
-- - May include some discontinued products if end dates not updated
-- - Groups exact matches only (slight variations in names may create separate groups)

-- Possible Extensions:
-- 1. Add time-based analysis of product launches within brand families
-- 2. Include pricing data to analyze premium positioning
-- 3. Compare brand vs generic timing patterns
-- 4. Analyze suffix patterns for common product line strategies
-- 5. Add therapeutic category analysis for portfolio assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:33:08.892374
    - Additional Notes: The query focuses on active branded drug products and their variations, providing insights into product line extensions and portfolio management. Note that results may be affected by data quality issues in marketing dates and brand name consistency. Consider increasing the LIMIT if comprehensive portfolio analysis is needed.
    
    */