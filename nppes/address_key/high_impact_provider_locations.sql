-- Address Key High-Impact Location Analysis
-- Business Purpose: Identify high-impact provider locations that serve as major healthcare delivery hubs
-- by analyzing addresses that are frequently used across multiple providers and address types.
-- This helps:
-- - Identify major medical complexes and healthcare clusters
-- - Support network adequacy and provider directory accuracy
-- - Guide provider outreach and engagement strategies

WITH combined_metrics AS (
  -- Combine all address usage counts and calculate total impact
  SELECT
    address_key,
    npi_b1_cnt,
    npi_b2_cnt,
    npi_m1_cnt,
    (npi_b1_cnt + COALESCE(npi_b2_cnt,0) + COALESCE(npi_m1_cnt,0)) as total_usage
  FROM mimi_ws_1.nppes.address_key
  WHERE mimi_dlt_load_date = (SELECT MAX(mimi_dlt_load_date) FROM mimi_ws_1.nppes.address_key)
),

high_impact_locations AS (
  -- Identify addresses with significant provider presence
  SELECT 
    address_key,
    npi_b1_cnt as business_primary_count,
    npi_b2_cnt as business_secondary_count,
    npi_m1_cnt as mailing_count,
    total_usage,
    -- Calculate what percentage each type represents
    ROUND(100.0 * npi_b1_cnt / total_usage, 1) as business_primary_pct,
    ROUND(100.0 * COALESCE(npi_b2_cnt,0) / total_usage, 1) as business_secondary_pct,
    ROUND(100.0 * COALESCE(npi_m1_cnt,0) / total_usage, 1) as mailing_pct
  FROM combined_metrics
  WHERE total_usage >= 10  -- Focus on locations with meaningful provider presence
)

-- Return the top locations with their usage patterns
SELECT *
FROM high_impact_locations
ORDER BY total_usage DESC
LIMIT 100;

-- How this query works:
-- 1. Combines all address usage counts into a single metric
-- 2. Calculates percentage breakdowns for each address type
-- 3. Filters for locations with significant provider presence
-- 4. Ranks locations by total impact

-- Assumptions and limitations:
-- - Assumes current data (uses latest load date)
-- - Minimum threshold of 10 total uses may need adjustment based on market
-- - Address parsing quality impacts results
-- - Does not account for address proximity/clustering

-- Possible extensions:
-- 1. Add state/zip parsing to group by geography
-- 2. Include specialty mix analysis for each location
-- 3. Compare current vs historical patterns to track location growth
-- 4. Add distance calculations to identify distinct healthcare clusters
-- 5. Cross-reference with facility types to validate major medical centers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:14:46.492251
    - Additional Notes: Query identifies major healthcare delivery hubs by analyzing address frequency across provider types. The threshold of 10 total uses may need adjustment based on market size and density. Results are most meaningful when combined with facility type data to distinguish between medical complexes and multi-tenant office buildings.
    
    */