-- Title: ZIP Code Geographic Analysis by State and Metro Status
-- Business Purpose: Analyze ZIP code distribution patterns across states and identify 
-- potential urban/rural splits based on business vs residential ratios. This helps:
-- - Understand market coverage and penetration opportunities by state
-- - Identify ZIP codes with high business concentration for targeted B2B strategies
-- - Support network adequacy analysis for healthcare service planning
-- - Guide resource allocation for different geographic market segments

WITH zip_metrics AS (
  SELECT 
    usps_zip_pref_state as state,
    COUNT(DISTINCT zip) as total_zips,
    -- Identify high business concentration ZIPs
    SUM(CASE WHEN bus_ratio > 0.5 THEN 1 ELSE 0 END) as business_heavy_zips,
    -- Identify primarily residential ZIPs
    SUM(CASE WHEN res_ratio > 0.7 THEN 1 ELSE 0 END) as residential_heavy_zips,
    -- Calculate average ratios
    ROUND(AVG(res_ratio), 3) as avg_residential_ratio,
    ROUND(AVG(bus_ratio), 3) as avg_business_ratio
  FROM mimi_ws_1.huduser.zip_to_county_mto
  GROUP BY state
)

SELECT 
  state,
  total_zips,
  business_heavy_zips,
  residential_heavy_zips,
  avg_residential_ratio,
  avg_business_ratio,
  -- Calculate key business metrics
  ROUND(business_heavy_zips * 100.0 / total_zips, 1) as pct_business_zips,
  ROUND(residential_heavy_zips * 100.0 / total_zips, 1) as pct_residential_zips
FROM zip_metrics
WHERE total_zips > 100  -- Focus on states with meaningful ZIP coverage
ORDER BY total_zips DESC;

-- How the Query Works:
-- 1. Creates a CTE to aggregate ZIP metrics by state
-- 2. Calculates counts of business vs residential heavy ZIPs
-- 3. Computes average ratios and percentages
-- 4. Filters for states with significant ZIP presence
-- 5. Orders results by total ZIP count

-- Assumptions and Limitations:
-- - Uses simple thresholds (0.5 for business, 0.7 for residential) to categorize ZIPs
-- - Excludes smaller states/territories with few ZIPs
-- - Does not account for total address volume, only ratios
-- - Current snapshot only, no historical trends

-- Possible Extensions:
-- 1. Add county-level grouping for more granular analysis
-- 2. Incorporate population density data for urban/rural classification
-- 3. Create market opportunity scores based on business/residential mix
-- 4. Add time series analysis if historical data available
-- 5. Include geographic clustering analysis for market targeting
-- 6. Add healthcare facility density correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:27:02.322599
    - Additional Notes: Query provides high-level geographic distribution metrics focused on business vs residential ZIP codes. Best used for initial market assessment and strategic planning. Consider adding population data for more meaningful density analysis. Performance may be impacted when analyzing historical trends across multiple time periods.
    
    */