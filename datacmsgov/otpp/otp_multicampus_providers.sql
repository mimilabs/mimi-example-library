-- OTP Provider Service Area Coverage Analysis
--
-- Business Purpose:
-- - Identify providers serving multiple cities to understand service area reach
-- - Support network adequacy assessment for regional coverage
-- - Enable targeted outreach in areas with providers serving multiple locations
-- - Help understand provider capacity and service patterns

WITH provider_locations AS (
  -- Get distinct provider-city combinations and count cities per provider
  SELECT 
    npi,
    provider_name,
    COUNT(DISTINCT city) as cities_served,
    CONCAT_WS(', ', COLLECT_SET(city)) as service_areas,
    MIN(state) as primary_state
  FROM mimi_ws_1.datacmsgov.otpp
  WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.otpp)
  GROUP BY npi, provider_name
),

ranked_providers AS (
  -- Rank providers by number of cities served
  SELECT 
    *,
    RANK() OVER (ORDER BY cities_served DESC) as coverage_rank
  FROM provider_locations
)

SELECT
  npi,
  provider_name,
  cities_served,
  service_areas,
  primary_state,
  coverage_rank
FROM ranked_providers
WHERE cities_served > 1  -- Focus on multi-city providers
ORDER BY cities_served DESC, provider_name
LIMIT 100;

-- How this works:
-- 1. Creates temp table of distinct provider locations
-- 2. Counts cities served per provider
-- 3. Ranks providers by coverage breadth
-- 4. Returns those serving multiple cities
--
-- Assumptions:
-- - Current snapshot (latest _input_file_date) represents active service areas
-- - City names are standardized/clean in source data
-- - Multiple addresses in same city counted as single service area
--
-- Limitations:
-- - Doesn't account for actual service radius/distance between locations
-- - May miss providers with multiple locations in single city 
-- - No population or demand data to contextualize coverage
--
-- Possible Extensions:
-- - Add geographic distance calculations between service locations
-- - Include facility capacity/patient volume if available
-- - Compare coverage patterns across states/regions
-- - Analyze changes in service areas over time
-- - Add demographic data to assess population served

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:07:00.687626
    - Additional Notes: The query identifies providers operating across multiple cities, which helps in understanding regional service networks and provider reach. The use of COLLECT_SET may impact performance with very large datasets. Results are limited to top 100 providers but can be adjusted as needed.
    
    */