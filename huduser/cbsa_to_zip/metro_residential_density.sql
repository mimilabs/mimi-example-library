-- metro_area_residential_analysis.sql
-- 
-- PURPOSE: Analyze residential concentration patterns across major metropolitan areas
-- to identify areas with high residential density and potential growth opportunities.
-- This analysis helps inform market entry strategies, resource allocation, and
-- demographic targeting for healthcare services and business development.
--
-- BUSINESS VALUE:
-- - Identifies high-residential metropolitan areas for market expansion
-- - Supports population health management initiatives
-- - Aids in network adequacy planning for healthcare organizations
-- - Informs site selection for new facilities or services

-- Get latest data for top metropolitan areas by residential concentration
WITH latest_data AS (
    SELECT MAX(mimi_src_file_date) as max_date
    FROM mimi_ws_1.huduser.cbsa_to_zip
),

metro_summary AS (
    SELECT 
        c.cbsa,
        MAX(c.usps_zip_pref_city) as major_city,
        MAX(c.usps_zip_pref_state) as state,
        COUNT(DISTINCT c.zip) as zip_count,
        SUM(c.res_ratio) as total_res_ratio,
        AVG(c.res_ratio) as avg_res_ratio,
        MAX(c.res_ratio) as max_res_ratio
    FROM mimi_ws_1.huduser.cbsa_to_zip c
    INNER JOIN latest_data l 
        ON c.mimi_src_file_date = l.max_date
    WHERE c.cbsa != '99999'  -- Exclude non-CBSA areas
    GROUP BY c.cbsa
)

SELECT 
    cbsa,
    major_city,
    state,
    zip_count,
    ROUND(total_res_ratio, 3) as total_res_ratio,
    ROUND(avg_res_ratio, 3) as avg_res_ratio,
    ROUND(max_res_ratio, 3) as max_res_ratio
FROM metro_summary
WHERE zip_count >= 10  -- Focus on significant metro areas
ORDER BY total_res_ratio DESC
LIMIT 20;

--
-- HOW IT WORKS:
-- 1. Gets the most recent data snapshot using mimi_src_file_date
-- 2. Aggregates ZIP codes within each CBSA to calculate residential metrics
-- 3. Filters for meaningful metropolitan areas (10+ ZIP codes)
-- 4. Returns top 20 areas ranked by total residential ratio
--
-- ASSUMPTIONS & LIMITATIONS:
-- - Uses latest available data only
-- - Focuses on metropolitan areas with multiple ZIP codes
-- - Excludes non-CBSA areas (code 99999)
-- - Residential ratio is used as primary metric for population density
--
-- POSSIBLE EXTENSIONS:
-- 1. Add year-over-year growth analysis by comparing multiple mimi_src_file_dates
-- 2. Include business ratio analysis for commercial development potential
-- 3. Add geographic clustering by state/region
-- 4. Incorporate population data for per-capita analysis
-- 5. Add filters for specific states or regions of interest

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:48:25.219981
    - Additional Notes: Query focuses on residential concentration metrics across metro areas using the latest available data. Results are limited to areas with 10+ ZIP codes to ensure statistical relevance. The total_res_ratio in results may exceed 1.0 due to ZIP codes being counted in multiple CBSAs. Consider adjusting the ZIP count threshold (currently 10) based on specific analysis needs.
    
    */