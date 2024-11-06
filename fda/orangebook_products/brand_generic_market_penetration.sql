-- fda_branded_generic_analysis.sql

-- Business Purpose:
-- - Analyze brand vs generic drug composition across therapeutic areas
-- - Track approval trends of brand/generic products over time
-- - Identify therapeutic segments with recent brand-to-generic transitions
-- - Support brand lifecycle and loss of exclusivity planning

-- Main Query
WITH approval_years AS (
  SELECT 
    YEAR(approval_date) as approval_year,
    appl_type,
    ingredient,
    df_route,
    CASE WHEN appl_type = 'NDA' THEN 'Brand' ELSE 'Generic' END as product_class,
    COUNT(*) as product_count
  FROM mimi_ws_1.fda.orangebook_products
  WHERE approval_date IS NOT NULL
  GROUP BY 1,2,3,4,5
),

recent_trends AS (
  SELECT
    ingredient,
    df_route,
    product_class,
    approval_year,
    product_count,
    SUM(product_count) OVER (PARTITION BY ingredient, df_route) as total_products,
    ROW_NUMBER() OVER (PARTITION BY ingredient, df_route ORDER BY approval_year DESC) as recency_rank
  FROM approval_years
  WHERE approval_year >= YEAR(CURRENT_DATE) - 5
)

SELECT
  ingredient,
  df_route,
  SUM(CASE WHEN product_class = 'Brand' THEN product_count ELSE 0 END) as brand_count,
  SUM(CASE WHEN product_class = 'Generic' THEN product_count ELSE 0 END) as generic_count,
  total_products,
  MAX(approval_year) as latest_approval_year,
  ROUND(SUM(CASE WHEN product_class = 'Generic' THEN product_count ELSE 0 END) * 100.0 / total_products, 1) as generic_penetration_pct
FROM recent_trends
WHERE recency_rank = 1
  AND total_products >= 5  -- Focus on established products
GROUP BY 1,2,total_products
HAVING MAX(approval_year) >= YEAR(CURRENT_DATE) - 3  -- Recent activity
ORDER BY total_products DESC, generic_penetration_pct DESC
LIMIT 50;

-- How it works:
-- 1. First CTE aggregates approval counts by year and product type
-- 2. Second CTE calculates recent trends and total product volumes
-- 3. Main query summarizes brand vs generic composition with penetration metrics
-- 4. Filters focus on active therapeutic areas with recent approvals

-- Assumptions & Limitations:
-- - Relies on approval_date being populated
-- - Assumes NDA = Brand and ANDA = Generic (simplified)
-- - Focus on last 5 years of approval activity
-- - Minimum threshold of 5 total products per ingredient/route
-- - Limited to top 50 results by volume

-- Possible Extensions:
-- 1. Add therapeutic class classification
-- 2. Include patent/exclusivity expiration analysis
-- 3. Expand to include pricing/reimbursement data
-- 4. Add market size/revenue potential metrics
-- 5. Include formulary coverage analysis
-- 6. Add manufacturer market share calculations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:29:02.709933
    - Additional Notes: Query focuses on recent brand-to-generic transitions in established drug markets, requiring minimum of 5 total products and activity within last 3 years. Results limited to top 50 products by volume. Approval date must be populated for products to be included in analysis.
    
    */