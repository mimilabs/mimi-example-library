-- business_activity_analysis.sql
--
-- PURPOSE: Analyze the distribution of business activities across CBSAs and ZIP codes
-- to identify areas with high commercial concentration relative to residential density.
-- This analysis helps organizations understand market opportunities and optimize
-- location strategies for business expansion.

-- Select most recent data and analyze business vs residential ratios
WITH latest_data AS (
  SELECT 
    -- Get the most recent file date
    MAX(mimi_src_file_date) as max_date 
  FROM mimi_ws_1.huduser.cbsa_to_zip
),

business_metrics AS (
  SELECT
    cbsa,
    usps_zip_pref_state as state,
    COUNT(DISTINCT zip) as zip_count,
    AVG(bus_ratio) as avg_business_ratio,
    AVG(res_ratio) as avg_residential_ratio,
    SUM(CASE WHEN bus_ratio > res_ratio THEN 1 ELSE 0 END) as business_dominant_zips
  FROM mimi_ws_1.huduser.cbsa_to_zip cz
  INNER JOIN latest_data ld 
    ON cz.mimi_src_file_date = ld.max_date
  WHERE cbsa != '99999'  -- Exclude non-CBSA areas
  GROUP BY cbsa, usps_zip_pref_state
)

SELECT
  bm.cbsa,
  bm.state,
  bm.zip_count,
  ROUND(bm.avg_business_ratio, 3) as avg_business_ratio,
  ROUND(bm.avg_residential_ratio, 3) as avg_residential_ratio,
  bm.business_dominant_zips,
  ROUND(bm.business_dominant_zips * 100.0 / bm.zip_count, 1) as pct_business_dominant
FROM business_metrics bm
WHERE zip_count >= 5  -- Focus on CBSAs with meaningful ZIP coverage
ORDER BY avg_business_ratio DESC
LIMIT 20;

-- HOW IT WORKS:
-- 1. Identifies the most recent data snapshot using mimi_src_file_date
-- 2. Calculates key business metrics for each CBSA-state combination:
--    - Number of ZIP codes
--    - Average business and residential ratios
--    - Count of ZIPs where business ratio exceeds residential ratio
-- 3. Filters for CBSAs with at least 5 ZIP codes for statistical relevance
-- 4. Orders results by highest business concentration

-- ASSUMPTIONS & LIMITATIONS:
-- - Uses most recent data snapshot only
-- - Excludes non-CBSA areas (cbsa = '99999')
-- - Minimum threshold of 5 ZIPs per CBSA may exclude some smaller areas
-- - Business ratio is relative to CBSA total, not absolute business counts

-- POSSIBLE EXTENSIONS:
-- 1. Add year-over-year trend analysis to identify growing business areas
-- 2. Include additional filters for specific states or regions of interest
-- 3. Incorporate population data to calculate per-capita business density
-- 4. Add analysis of 'other' address types for more complete picture
-- 5. Create geographic clusters of high-business-activity areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:39:40.160991
    - Additional Notes: Query focuses on business-to-residential ratio comparisons across CBSAs and requires at least 5 ZIP codes per CBSA for meaningful analysis. Results are limited to top 20 business-dense areas using the most recent data snapshot. Performance may be impacted for very large datasets due to multiple aggregations.
    
    */