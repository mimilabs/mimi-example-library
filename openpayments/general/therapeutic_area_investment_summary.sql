-- payment_product_analysis.sql
-- 
-- Business Purpose:
-- Analyze payment patterns related to specific products to understand: 
-- - Which therapeutic areas receive the most manufacturer investment
-- - How companies allocate funding across their product portfolios
-- - The relationship between product types and payment purposes
-- This helps identify market focus areas and competitive investment patterns.

WITH product_payments AS (
  -- Get relevant product and payment details while handling multiple products per payment
  SELECT
    program_year,
    total_amount_of_payment_us_dollars,
    nature_of_payment_or_transfer_of_value,
    COALESCE(name_of_drug_or_biological_or_device_or_medical_supply_1,
             name_of_drug_or_biological_or_device_or_medical_supply_2,
             name_of_drug_or_biological_or_device_or_medical_supply_3,
             name_of_drug_or_biological_or_device_or_medical_supply_4,
             name_of_drug_or_biological_or_device_or_medical_supply_5) as product_name,
    COALESCE(product_category_or_therapeutic_area_1,
             product_category_or_therapeutic_area_2, 
             product_category_or_therapeutic_area_3,
             product_category_or_therapeutic_area_4,
             product_category_or_therapeutic_area_5) as therapeutic_area,
    applicable_manufacturer_or_applicable_gpo_making_payment_name as manufacturer_name
  FROM mimi_ws_1.openpayments.general
  WHERE related_product_indicator = 'Yes'
    AND program_year >= 2020
)

SELECT 
  therapeutic_area,
  COUNT(DISTINCT product_name) as unique_products,
  COUNT(*) as payment_count,
  ROUND(SUM(total_amount_of_payment_us_dollars),2) as total_payment_amount,
  ROUND(AVG(total_amount_of_payment_us_dollars),2) as avg_payment_amount,
  FIRST(nature_of_payment_or_transfer_of_value) as primary_payment_type,
  COUNT(DISTINCT manufacturer_name) as manufacturer_count
FROM product_payments
WHERE therapeutic_area IS NOT NULL
GROUP BY therapeutic_area
HAVING COUNT(*) > 100
ORDER BY total_payment_amount DESC
LIMIT 20;

-- How it works:
-- 1. Creates CTE to consolidate product-related payments and handle multiple products per payment
-- 2. Filters to only include product-related payments from recent years
-- 3. Aggregates key metrics by therapeutic area to show investment patterns
-- 4. Includes payment counts, amounts, types and manufacturer diversity
--
-- Assumptions & Limitations:
-- - Takes first non-null product/therapeutic area when multiple exist
-- - Recent years only (2020+) for current market relevance
-- - Excludes therapeutic areas with few payments (<100) to focus on major categories
-- - Limited to top 20 therapeutic areas by payment amount
-- - Shows only the first payment type rather than all types due to aggregation limitations
--
-- Possible Extensions:
-- - Add year-over-year trend analysis
-- - Break down by specific products within therapeutic areas
-- - Compare manufacturer market share within therapeutic areas
-- - Analyze seasonal payment patterns
-- - Include recipient specialty alignment analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:50:50.804003
    - Additional Notes: Aggregates healthcare industry investments by therapeutic area, showing total payments, manufacturer participation, and product diversity. Only includes data from 2020 onwards and areas with >100 payments. Primary payment type shown may not fully represent the distribution of payment types within each therapeutic area.
    
    */