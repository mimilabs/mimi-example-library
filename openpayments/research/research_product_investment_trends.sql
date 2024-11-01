-- research_product_focus_trends.sql
/*
BUSINESS PURPOSE:
This analysis examines which medical products (drugs, devices, biologics) are receiving 
the most research investment attention from manufacturers. Understanding product-level 
research funding helps identify:
- Emerging therapeutic priorities
- Which products are in active development/study
- How manufacturers are allocating research dollars across their product portfolios

The insights can inform:
- Market intelligence on competitor research priorities
- Partnership and investment opportunities
- Product development strategy
*/

WITH product_research AS (
  -- Aggregate research payments at the product level
  SELECT 
    program_year,
    name_of_drug_or_biological_or_device_or_medical_supply_1 as product_name,
    indicate_drug_or_biological_or_device_or_medical_supply_1 as product_type,
    product_category_or_therapeutic_area_1 as therapeutic_area,
    COUNT(DISTINCT record_id) as num_research_payments,
    COUNT(DISTINCT applicable_manufacturer_or_applicable_gpo_making_payment_name) as num_manufacturers,
    SUM(total_amount_of_payment_us_dollars) as total_research_amount
  FROM mimi_ws_1.openpayments.research
  WHERE name_of_drug_or_biological_or_device_or_medical_supply_1 IS NOT NULL
  AND program_year >= 2019  -- Focus on recent years
  GROUP BY 1,2,3,4
)

SELECT
  program_year,
  product_name,
  product_type,
  therapeutic_area,
  num_research_payments,
  num_manufacturers,
  total_research_amount,
  -- Calculate percentage of total research spend
  ROUND(100.0 * total_research_amount / 
    SUM(total_research_amount) OVER (PARTITION BY program_year), 2) as pct_of_year_research
FROM product_research
WHERE total_research_amount > 100000  -- Focus on significant research programs
ORDER BY program_year DESC, total_research_amount DESC
LIMIT 100;

/*
HOW IT WORKS:
1. The CTE aggregates research payment data at the product level, counting payments,
   manufacturers and total amounts
2. Main query adds percentage calculations and filters to significant programs
3. Results show top products by research investment with context on manufacturer
   involvement and relative spending priority

ASSUMPTIONS & LIMITATIONS:
- Only looks at first product listed for each payment (payments can list up to 5)
- Research payments must be >$100k to be included
- Assumes product names are standardized/consistent
- Limited to 2019 onward for recent trends

POSSIBLE EXTENSIONS:
- Add year-over-year growth analysis for each product
- Include all 5 potential products per payment
- Break out by research phase (preclinical vs clinical)
- Add geographic analysis of research sites
- Compare manufacturer portfolio focus vs competitors
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:57:14.479238
    - Additional Notes: Query requires total amount fields to be clean numeric values without NULL or invalid entries. Results are sensitive to product name standardization - variations in product naming conventions may split what should be aggregated results. Consider adding product name standardization logic for more accurate aggregation.
    
    */