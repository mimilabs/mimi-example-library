-- DMECS Manufacturer Market Share and Product Portfolio Analysis
--
-- Business Purpose:
-- - Analyze manufacturer market presence and product diversity in DMEPOS market
-- - Identify manufacturers with broad vs specialized product portfolios
-- - Support strategic decision making for partnerships and market analysis
-- - Track manufacturer coverage across different HCPCS categories

WITH manufacturer_metrics AS (
  -- Get current product counts and HCPCS diversity per manufacturer
  SELECT 
    manufacturer,
    COUNT(DISTINCT model_number) as total_products,
    COUNT(DISTINCT hcpcs_code) as unique_hcpcs_codes,
    COUNT(DISTINCT LEFT(hcpcs_code, 1)) as hcpcs_categories,
    -- Calculate portfolio concentration
    COUNT(DISTINCT model_number) * 1.0 / COUNT(DISTINCT hcpcs_code) as products_per_hcpcs
  FROM mimi_ws_1.palmettogba.dmecs
  WHERE end_date IS NULL 
    AND manufacturer IS NOT NULL
  GROUP BY manufacturer
),
market_totals AS (
  -- Calculate market-wide totals for percentage calculations
  SELECT 
    SUM(total_products) as total_market_products,
    AVG(products_per_hcpcs) as avg_portfolio_concentration
  FROM manufacturer_metrics
)

SELECT 
  m.manufacturer,
  m.total_products,
  ROUND(m.total_products * 100.0 / mt.total_market_products, 2) as market_share_pct,
  m.unique_hcpcs_codes,
  m.hcpcs_categories,
  ROUND(m.products_per_hcpcs, 2) as portfolio_concentration,
  CASE 
    WHEN m.products_per_hcpcs > mt.avg_portfolio_concentration THEN 'Deep'
    ELSE 'Broad'
  END as portfolio_strategy
FROM manufacturer_metrics m
CROSS JOIN market_totals mt
WHERE m.total_products >= 10  -- Focus on manufacturers with meaningful presence
ORDER BY m.total_products DESC
LIMIT 20;

-- How it works:
-- 1. First CTE calculates key metrics per manufacturer including product counts and HCPCS diversity
-- 2. Second CTE determines market-wide totals for comparative analysis
-- 3. Main query combines these metrics to provide strategic insights about manufacturer positioning
--
-- Assumptions and Limitations:
-- - Assumes current market state (filters for null end_dates)
-- - Limited to manufacturers with 10+ products for meaningful analysis
-- - Portfolio concentration metric assumes equal weight across product lines
-- - Does not account for product revenue or market value
--
-- Possible Extensions:
-- 1. Add time-based analysis to track manufacturer growth patterns
-- 2. Include product level pricing data if available
-- 3. Add specific HCPCS category analysis for competitive assessment
-- 4. Incorporate geographic distribution of manufacturers
-- 5. Add year-over-year comparison of market share changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:43:44.661833
    - Additional Notes: Query focuses on active manufacturers with significant market presence (10+ products). Portfolio concentration metric helps identify manufacturers with deep specialization versus broad market coverage. Results limited to top 20 manufacturers by product count. Market share calculations based on product counts rather than revenue.
    
    */