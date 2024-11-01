-- city_home_value_volatility_analysis.sql

-- Business Purpose:
-- Identify cities with the most volatile housing markets to help:
-- 1. Real estate investors identify potential opportunities
-- 2. Mortgage lenders assess market risk
-- 3. Insurance companies evaluate market stability
-- This analysis calculates price volatility using coefficient of variation
-- over the past year to highlight markets with significant price fluctuations

WITH monthly_stats AS (
  -- Get the last 12 months of data and calculate city-level statistics
  SELECT 
    city,
    state,
    metro,
    COUNT(DISTINCT zip) as zip_count,
    AVG(value) as avg_value,
    STDDEV(value) as std_value
  FROM mimi_ws_1.zillow.homevalue_zip
  WHERE date >= DATE_SUB(CURRENT_DATE(), 365)
  GROUP BY city, state, metro
  HAVING zip_count >= 3  -- Only cities with at least 3 ZIP codes
),

volatility_metrics AS (
  -- Calculate coefficient of variation (CV) as measure of volatility
  SELECT 
    city,
    state,
    metro,
    zip_count,
    avg_value,
    std_value,
    (std_value / avg_value * 100) as coefficient_variation
  FROM monthly_stats
  WHERE avg_value > 0
)

SELECT 
  city,
  state,
  metro,
  zip_count,
  ROUND(avg_value, 2) as avg_home_value,
  ROUND(coefficient_variation, 2) as price_volatility_pct,
  CASE 
    WHEN coefficient_variation >= 30 THEN 'High'
    WHEN coefficient_variation >= 15 THEN 'Medium'
    ELSE 'Low'
  END as volatility_category
FROM volatility_metrics
WHERE coefficient_variation > 0
ORDER BY coefficient_variation DESC
LIMIT 20;

-- How it works:
-- 1. First CTE gets city-level statistics for the past year
-- 2. Second CTE calculates coefficient of variation as volatility measure
-- 3. Main query formats results and categorizes volatility levels
-- 4. Results show cities with highest price variation across their ZIP codes

-- Assumptions and Limitations:
-- - Requires at least 3 ZIP codes per city for meaningful analysis
-- - Uses last 12 months of data only
-- - Assumes normal distribution of prices
-- - Does not account for seasonal variations
-- - Does not consider city size or total transaction volume

-- Possible Extensions:
-- 1. Add year-over-year volatility comparison
-- 2. Include population data to normalize results
-- 3. Add price tier analysis (low/medium/high value homes)
-- 4. Compare volatility across different metro areas
-- 5. Add economic indicators correlation analysis
-- 6. Include foreclosure rates or days-on-market metrics
-- 7. Add quarter-over-quarter volatility trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:10:42.856062
    - Additional Notes: Query requires sufficient data density (3+ ZIP codes per city) and 12 months of historical data. Volatility thresholds (30% for High, 15% for Medium) are configurable based on business needs. Consider adjusting these thresholds for different market conditions or regions.
    
    */