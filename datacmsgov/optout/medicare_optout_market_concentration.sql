-- Title: Opt-Out Provider Geographic Market Coverage Analysis

-- Business Purpose:
-- This query helps identify geographic areas with high concentrations of opt-out providers
-- to support market strategy, network adequacy planning, and identify potential 
-- business opportunities for alternative payment models or private insurance networks.
-- The analysis is valuable for healthcare payers, provider organizations, and market strategists.

WITH provider_geo_summary AS (
  -- Aggregate providers by geographic region
  SELECT 
    state_code,
    city_name,
    LEFT(zip_code, 3) as zip3,
    COUNT(DISTINCT npi) as opt_out_provider_count,
    COUNT(DISTINCT specialty) as unique_specialties,
    -- Get most recent opt-out date to understand timing
    MAX(optout_effective_date) as latest_opt_out_date
  FROM mimi_ws_1.datacmsgov.optout
  WHERE optout_end_date >= CURRENT_DATE() -- Only active opt-outs
  GROUP BY state_code, city_name, LEFT(zip_code, 3)
),

market_rankings AS (
  -- Rank markets by provider concentration
  SELECT 
    state_code,
    city_name,
    zip3,
    opt_out_provider_count,
    unique_specialties,
    latest_opt_out_date,
    -- Calculate relative market size
    ROW_NUMBER() OVER (ORDER BY opt_out_provider_count DESC) as market_rank
  FROM provider_geo_summary
)

-- Final output with key market insights
SELECT
  state_code,
  city_name,
  zip3 as market_area,
  opt_out_provider_count,
  unique_specialties,
  latest_opt_out_date,
  market_rank
FROM market_rankings
WHERE market_rank <= 20 -- Focus on top markets
ORDER BY opt_out_provider_count DESC;

-- How it works:
-- 1. Aggregates opt-out providers by geographic region (state, city, ZIP3)
-- 2. Calculates key metrics like provider count and specialty diversity
-- 3. Ranks markets by concentration of opt-out providers
-- 4. Returns top 20 markets with highest opt-out provider presence

-- Assumptions & Limitations:
-- - Uses ZIP3 as proxy for market area (may need refinement for specific use cases)
-- - Only includes currently active opt-outs
-- - Does not account for total provider population in area
-- - Market size based purely on opt-out count, not weighted by specialty or other factors

-- Possible Extensions:
-- 1. Add year-over-year growth rates for each market
-- 2. Include specialty-specific analysis within top markets
-- 3. Incorporate demographic data to identify market characteristics
-- 4. Add distance calculations to identify market clusters
-- 5. Include total provider counts to calculate opt-out penetration rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:37:12.373959
    - Additional Notes: Query focuses on geographic market concentration analysis for opt-out providers. ZIP3-based market definition may need adjustment for rural vs urban areas. Consider adding population normalization for more accurate market comparison.
    
    */