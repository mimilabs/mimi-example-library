-- business_importance_analysis.sql

-- Business Purpose: This query evaluates the strategic importance of ZIP codes by analyzing their 
-- connectivity to Census tracts and business coverage. It helps identify key geographic areas that 
-- serve as business hubs and could be prioritized for commercial development, market expansion,
-- or service deployment.

-- Main Query
WITH latest_data AS (
    -- Get the most recent data snapshot
    SELECT *
    FROM mimi_ws_1.huduser.tract_to_zip
    WHERE mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.huduser.tract_to_zip
    )
),

zip_metrics AS (
    -- Calculate key business metrics by ZIP code
    SELECT 
        zip,
        usps_zip_pref_city,
        usps_zip_pref_state,
        COUNT(DISTINCT tract) as connected_tracts,
        AVG(bus_ratio) as avg_business_ratio,
        SUM(bus_ratio) as total_business_coverage,
        AVG(tot_ratio) as avg_total_ratio
    FROM latest_data
    GROUP BY zip, usps_zip_pref_city, usps_zip_pref_state
)

SELECT 
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    connected_tracts,
    ROUND(avg_business_ratio, 3) as avg_business_ratio,
    ROUND(total_business_coverage, 3) as total_business_coverage,
    ROUND(avg_total_ratio, 3) as avg_total_ratio
FROM zip_metrics
WHERE connected_tracts > 1  -- Focus on ZIPs that span multiple tracts
ORDER BY total_business_coverage DESC
LIMIT 100;

-- How it works:
-- 1. First CTE gets the most recent data to ensure analysis is current
-- 2. Second CTE calculates key business metrics for each ZIP code:
--    - Number of connected Census tracts
--    - Average business ratio across connected tracts
--    - Total business coverage (sum of business ratios)
--    - Average total ratio for context
-- 3. Final query filters and sorts results to highlight most significant business areas

-- Assumptions and Limitations:
-- - Uses most recent data snapshot only
-- - Assumes business_ratio is a good proxy for commercial importance
-- - Does not account for absolute numbers of businesses
-- - Limited to top 100 results for manageability

-- Possible Extensions:
-- 1. Add year-over-year comparison to identify trending business areas
-- 2. Include population density data to evaluate market potential
-- 3. Add geographic clustering analysis to identify business corridors
-- 4. Compare business vs residential ratios to identify commercial districts
-- 5. Join with additional demographic or economic data for deeper insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:28:49.208123
    - Additional Notes: Query identifies strategic ZIP codes based on business density and tract connectivity. Best used for commercial zone planning and market analysis. Note that results are limited to multi-tract ZIP codes and may need adjustment for smaller geographic areas or specialized business districts.
    
    */