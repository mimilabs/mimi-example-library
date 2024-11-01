-- geographic_market_concentration.sql

-- Business Purpose: Analyze market concentration by identifying ZIP codes that span multiple Census tracts
-- and quantifying business vs residential address distributions. This helps:
-- - Market planning teams understand fragmented service areas
-- - Sales teams identify ZIP codes with high business concentrations
-- - Operations teams optimize resource allocation across complex geographic areas

-- Identify ZIP codes with significant business presence and geographic complexity
WITH zip_metrics AS (
  SELECT 
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    COUNT(DISTINCT tract) as tract_count,
    SUM(bus_ratio) as total_bus_ratio,
    SUM(res_ratio) as total_res_ratio,
    MAX(bus_ratio) as max_bus_concentration
  FROM mimi_ws_1.huduser.zip_to_tract
  WHERE mimi_src_file_date = '2023-03-01' -- Using most recent data
  GROUP BY 1,2,3
)

SELECT
  zip,
  usps_zip_pref_city,
  usps_zip_pref_state,
  tract_count,
  ROUND(total_bus_ratio, 3) as total_bus_ratio,
  ROUND(total_res_ratio, 3) as total_res_ratio,
  ROUND(max_bus_concentration, 3) as max_bus_concentration,
  -- Classify ZIP complexity
  CASE 
    WHEN tract_count >= 5 AND total_bus_ratio > 0.3 THEN 'High Complexity & Business'
    WHEN tract_count >= 5 THEN 'High Geographic Complexity'
    WHEN total_bus_ratio > 0.3 THEN 'High Business Concentration'
    ELSE 'Standard' 
  END as market_segment
FROM zip_metrics
WHERE tract_count > 1 -- Focus on multi-tract ZIPs
ORDER BY tract_count DESC, total_bus_ratio DESC
LIMIT 100;

-- How it works:
-- 1. Aggregates metrics by ZIP code from the crosswalk table
-- 2. Calculates key indicators of geographic complexity and business concentration
-- 3. Applies business rules to segment markets
-- 4. Returns top areas warranting strategic attention

-- Assumptions & Limitations:
-- - Uses most recent crosswalk data only
-- - Business ratio as proxy for commercial activity
-- - Threshold values (5 tracts, 0.3 ratio) may need adjustment
-- - Limited to top 100 results

-- Possible Extensions:
-- 1. Add year-over-year comparison of business concentration changes
-- 2. Include demographic data from Census tract level
-- 3. Calculate distance/dispersion metrics between tracts
-- 4. Add filters for specific states or metro areas
-- 5. Incorporate additional business metrics like company count or revenue

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:44:32.345784
    - Additional Notes: Query identifies complex service areas by analyzing ZIP codes that span multiple Census tracts with significant business presence. The market segmentation thresholds (5 tracts, 0.3 business ratio) are configurable parameters that should be adjusted based on specific business needs and geographic region characteristics. Current limit of 100 records may need adjustment for comprehensive analysis.
    
    */