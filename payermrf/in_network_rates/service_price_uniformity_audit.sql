-- Title: Service Price Uniformity Analysis Across Provider Networks

-- Business Purpose: 
-- Analyzes price consistency within provider networks for common services to:
-- - Identify services with high price variation that may need standardization
-- - Find opportunities for price normalization in contracting
-- - Support fair pricing initiatives across provider networks

WITH price_stats AS (
  -- Calculate price statistics for each service within provider groups
  SELECT 
    provider_group_id,
    billing_code,
    billing_code_type,
    name,
    COUNT(*) as price_points,
    MIN(negotiated_rate) as min_rate,
    MAX(negotiated_rate) as max_rate,
    AVG(negotiated_rate) as avg_rate,
    (MAX(negotiated_rate) - MIN(negotiated_rate)) / NULLIF(AVG(negotiated_rate), 0) * 100 as price_variation_pct
  FROM mimi_ws_1.payermrf.in_network_rates
  WHERE 
    negotiated_rate > 0
    AND negotiation_arrangement = 'ffs' -- Focus on fee-for-service arrangements
    AND negotiated_type = 'negotiated' -- Focus on directly negotiated rates
  GROUP BY 
    provider_group_id,
    billing_code,
    billing_code_type,
    name
  HAVING COUNT(*) >= 5 -- Only include services with meaningful number of price points
)

SELECT
  billing_code,
  billing_code_type,
  name,
  COUNT(DISTINCT provider_group_id) as provider_networks,
  ROUND(AVG(price_variation_pct), 1) as avg_price_variation_pct,
  ROUND(AVG(avg_rate), 2) as typical_rate,
  ROUND(MIN(min_rate), 2) as lowest_rate,
  ROUND(MAX(max_rate), 2) as highest_rate
FROM price_stats
GROUP BY 
  billing_code,
  billing_code_type,
  name
HAVING COUNT(DISTINCT provider_group_id) >= 3 -- Focus on services common across networks
ORDER BY avg_price_variation_pct DESC
LIMIT 50;

-- How it works:
-- 1. Creates price statistics for each service within provider networks
-- 2. Calculates price variation as percentage of average price
-- 3. Aggregates across provider networks to find services with high variation
-- 4. Filters for services that appear across multiple networks
-- 5. Orders results by price variation to highlight standardization opportunities

-- Assumptions and Limitations:
-- - Focuses only on fee-for-service arrangements with directly negotiated rates
-- - Requires minimum of 5 price points per service per network
-- - Requires service to appear in at least 3 provider networks
-- - Price variation calculation assumes normal distribution
-- - Zero or negative rates are excluded

-- Possible Extensions:
-- 1. Add geographic analysis to account for regional cost differences
-- 2. Include time-based trending of price variations
-- 3. Compare variations across different billing classes
-- 4. Add service volume/frequency weighting
-- 5. Incorporate quality metrics to analyze price-quality relationships

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:12:46.059557
    - Additional Notes: Query focuses on fee-for-service rates only and requires minimum thresholds for both price points (5 per network) and network coverage (3 networks) to ensure statistical relevance. Price variation calculations exclude zero/negative rates and may need adjustment for services with non-normal price distributions.
    
    */