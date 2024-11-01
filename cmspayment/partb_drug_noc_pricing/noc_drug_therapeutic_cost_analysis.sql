-- Title: NOC Drug Payment Pattern Analysis by Therapeutic Category
-- 
-- Business Purpose:
-- - Identify patterns in NOC drug payments across therapeutic categories
-- - Surface potential therapeutic areas with pricing anomalies
-- - Support formulary management and cost containment strategies
-- - Enable more informed negotiations with drug manufacturers

WITH therapeutic_categories AS (
  -- Extract therapeutic category from drug names using common keywords
  SELECT 
    CASE 
      WHEN LOWER(drug_generic_name_trade_name) LIKE '%antibody%' OR LOWER(drug_generic_name_trade_name) LIKE '%mab%' THEN 'Monoclonal Antibodies'
      WHEN LOWER(drug_generic_name_trade_name) LIKE '%vaccine%' THEN 'Vaccines'
      WHEN LOWER(drug_generic_name_trade_name) LIKE '%immune%' THEN 'Immunologics'
      WHEN LOWER(drug_generic_name_trade_name) LIKE '%chemo%' OR LOWER(drug_generic_name_trade_name) LIKE '%cancer%' THEN 'Chemotherapy'
      ELSE 'Other'
    END AS therapeutic_category,
    drug_generic_name_trade_name,
    dosage,
    payment_limit,
    mimi_src_file_date
  FROM mimi_ws_1.cmspayment.partb_drug_noc_pricing
  WHERE payment_limit > 0
    AND mimi_src_file_date >= DATE_SUB(CURRENT_DATE(), 365)
)

SELECT 
  therapeutic_category,
  COUNT(DISTINCT drug_generic_name_trade_name) as unique_drugs,
  ROUND(AVG(payment_limit), 2) as avg_payment,
  ROUND(MIN(payment_limit), 2) as min_payment,
  ROUND(MAX(payment_limit), 2) as max_payment,
  ROUND(STDDEV(payment_limit), 2) as payment_std_dev
FROM therapeutic_categories
GROUP BY therapeutic_category
ORDER BY avg_payment DESC;

-- How it works:
-- 1. CTE creates therapeutic categories based on drug name keywords
-- 2. Filters to positive payment amounts and last 12 months of data
-- 3. Aggregates key payment statistics by therapeutic category
-- 4. Orders results by average payment to highlight highest cost categories

-- Assumptions and Limitations:
-- - Therapeutic categorization is based on simple keyword matching
-- - Only considers last 12 months of data
-- - Excludes zero/negative payment amounts
-- - Categories may not align perfectly with official therapeutic classifications
-- - Some drugs may be miscategorized due to naming conventions

-- Possible Extensions:
-- 1. Add trending analysis to show category price movements over time
-- 2. Include dosage standardization for more accurate comparisons
-- 3. Add sub-categories for more granular therapeutic classification
-- 4. Compare against historical averages to identify unusual patterns
-- 5. Join with utilization data to weight by prescription volume

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:22:01.323762
    - Additional Notes: Query relies on keyword-based categorization which may need periodic updates as new drug naming patterns emerge. Consider reviewing and adjusting keywords based on actual drug classifications in your dataset. Performance may be impacted with very large datasets due to string matching operations.
    
    */