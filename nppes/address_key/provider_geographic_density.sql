-- Healthcare Provider Address Geographic Coverage Analysis
-- Business Purpose: Analyze the geographic coverage and density of healthcare providers
-- by examining address patterns and identifying areas with high/low provider presence.
-- This helps understand market penetration, access to care, and potential expansion opportunities.

WITH regional_stats AS (
  -- Extract state from address_key and calculate provider presence metrics
  SELECT 
    SPLIT(address_key, '\\|')[3] AS state,
    COUNT(DISTINCT address_key) AS unique_locations,
    SUM(npi_b1_cnt + COALESCE(npi_b2_cnt,0)) AS total_business_providers,
    AVG(npi_b1_cnt + COALESCE(npi_b2_cnt,0)) AS avg_providers_per_location
  FROM mimi_ws_1.nppes.address_key
  WHERE 
    -- Filter out invalid state codes and ensure data quality
    LENGTH(SPLIT(address_key, '\\|')[3]) = 2
  GROUP BY SPLIT(address_key, '\\|')[3]
),

density_categories AS (
  -- Categorize states by provider density using ntile function
  SELECT 
    state,
    unique_locations,
    total_business_providers,
    avg_providers_per_location,
    NTILE(3) OVER (ORDER BY avg_providers_per_location) as density_tier
  FROM regional_stats
),

density_tiers AS (
  -- Convert numerical tiers to meaningful labels
  SELECT 
    state,
    unique_locations,
    total_business_providers,
    avg_providers_per_location,
    CASE 
      WHEN density_tier = 3 THEN 'High Density'
      WHEN density_tier = 1 THEN 'Low Density'
      ELSE 'Medium Density'
    END AS market_density
  FROM density_categories
)

-- Final output with market insights
SELECT 
  market_density,
  COUNT(DISTINCT state) AS state_count,
  SUM(unique_locations) AS total_locations,
  SUM(total_business_providers) AS total_providers,
  ROUND(AVG(avg_providers_per_location), 2) AS avg_provider_density
FROM density_tiers
GROUP BY market_density
ORDER BY avg_provider_density DESC;

-- How this query works:
-- 1. First CTE extracts state information from address_key and calculates basic metrics
-- 2. Second CTE uses NTILE to divide states into three equal groups based on provider density
-- 3. Third CTE converts numerical tiers into descriptive categories
-- 4. Final query aggregates results by market density to show distribution patterns

-- Assumptions and Limitations:
-- - Assumes state codes in address_key are standardized and valid
-- - Does not account for population density or geographic size of states
-- - Limited to current snapshot based on mimi_dlt_load_date
-- - Combines business address counts but may need refinement for specific use cases

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating mimi_dlt_load_date
-- 2. Include city-level analysis for more granular insights
-- 3. Cross-reference with population data to calculate per-capita metrics
-- 4. Add specialty-specific analysis by joining with provider specialty data
-- 5. Implement geographic clustering analysis for market optimization

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:28:25.337955
    - Additional Notes: The query uses NTILE(3) to create equal-sized groupings of states based on provider density, which may produce different thresholds than absolute density measurements. The state extraction assumes a consistent address_key format with state code as the fourth pipe-delimited element.
    
    */